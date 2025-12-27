`include "../defines.vh"
 
module cpu7_ifu_fdp(
   input                  clk,
   input                  reset,
   input  [31 :0]         pc_init,

   output                 ifu_icu_req_ic1,
   output [31:0]          ifu_icu_addr_ic1,
   input                  icu_ifu_ack_ic1,
   output                 ifu_icu_cancel,
   input  [63:0]          icu_ifu_data_ic2,
   input                  icu_ifu_data_valid_ic2,   

   input                  br_taken,
   input  [31 :0]         br_target,

   // exception
   input  [31:0]    exu_ifu_eentry,
   input                  exu_ifu_except,
   // ertn
   input  [31:0]    exu_ifu_era,
   input                  exu_ifu_ertn_e,

   output [31:0]    fdp_dec_pc_d,
   output [31:0]    fdp_dec_inst_d,

   output                 fdp_dec_inst_kill_vld_d,

   output                 ifu_exu_valid_e, //
   
   output [31:0]    ifu_exu_pc_w,
   output [31:0]    ifu_exu_pc_e,

   input                  exu_ifu_stall_req
   );


   wire [31:0] inst_f;
   wire inst_valid_f;
   wire iq_not_empty;
   wire fetch_ahead;

   //wire ifu_icu_cancel;

   wire ifu_fdp_valid_f;
   //assign ifu_fdp_valid_f = inst_valid_f;

   wire ifu_exu_valid_d;

   wire [31:0] pcbf_btwn_mux;
   
   wire ifu_pcbf_sel_init_bf_l;
   wire ifu_pcbf_sel_old_bf_l;
   wire ifu_pcbf_sel_pcinc_bf_l;
   wire ifu_pcbf_sel_brpc_bf_l;
   wire ifu_pcbf_sel_usemux1_l;
   wire ifu_pcbf_sel_excpc_bf_l;
   wire ifu_pcbf_sel_ertnpc_bf_l;


   // if exu ask ifu to stall, the pc_bf takes bc_f and the instruction passed
   // down the pipe should be invalid

   wire kill_f;
   wire kill_d;
   wire inst_kill_vld_f;
   wire inst_kill_vld_d;

   assign kill_f = br_taken | exu_ifu_except | exu_ifu_ertn_e; 
   assign inst_kill_vld_f = ifu_fdp_valid_f & (~kill_f); // pc_f shoudl not be passed to pc_d if a branch is taken at _e.
   // should not if exception happen

   //assign kill_d = br_taken | exu_ifu_except; // if branch is taken, kill the instruction at the pipeline _d stage.
   //
   //// if stall happens, should kill_d, at least for now, two sequent ld instructions is the case.
   //before, it is just because two instructions are not in sequent cycle,
   //this issue is uncovered

   // uty: review  exu_ifu_stall_req kill_d, it should just delay the
   // instruction at _d
   assign kill_d = br_taken | exu_ifu_except | exu_ifu_stall_req; // if branch is taken, kill the instruction at the pipeline _d stage.
   //assign kill_d = br_taken | exu_ifu_except; // if branch is taken, kill the instruction at the pipeline _d stage.
   assign inst_kill_vld_d = ifu_exu_valid_d & (~kill_d);
   assign fdp_dec_inst_kill_vld_d = inst_kill_vld_d;

   dffrle_ns #(1) inst_vld_kill_f2d_reg (
      .din   (inst_kill_vld_f),
      .rst_l (~reset),
      .clk   (clk),
      .en    (~exu_ifu_stall_req),
      .q     (ifu_exu_valid_d));
      //.se(), .si(), .so());

   dffrle_ns #(1) inst_vld_kill_d2e_reg (
      .din   (inst_kill_vld_d),
      .rst_l (~reset),
      .clk   (clk),
      .en    (~exu_ifu_stall_req),
      .q     (ifu_exu_valid_e));
      //.se(), .si(), .so());


   //===================================================
   // PC Datapath
   //===================================================

   wire [31:0] pc_bf;
   wire [31:0] pc_f;
   wire [31:0] pcinc_f;
   wire [31:0] pc_d;
   wire [31:0] pc_e;
   wire [31:0] pc_m;
   wire [31:0] pc_w;
   
   
   // pc_f must retain its initial value (0x1c000000) and not reset to 0,
   // as it serves as the oldpc value until icu_ifu_data_valid_ic2 arrives.
   dff_ns #(32) pc_bf2f_reg (
      .din (pc_bf),
      .clk (clk),
      //.rst_l (~reset),
      .q   (pc_f));
      //.se(), .si(), .so());

   
   assign pcinc_f[1:0] = pc_f[1:0];

   cpu7_ifu_incr30 pc_inc (
      .a     (pc_f[31:2]),
      .a_inc (pcinc_f[31:2]),
      .ofl   ()); // overflow output

   // pc_d_reg和cpu7_ifu_dec里的port0_pc_reg重复了
   //  这和设计模块时的想法有关
   // chiplab里的模块是像paterson书里的例子一样，一排流水线寄存器直接传给下一个周期
   // 但在opensparc T1里，比如pc相关的流水线寄存器都是大部分放在sparc_ifu_fdp里
   // 这里我也想学opensparc，pc相关的寄存器放在这里，后面在writeback阶段需要pc给debug port
   // 所以要把pc各阶段的寄存器都保留下去
   // 这样需要注意一个问题就是认为ifu传给dec开始就一个cycle一个cycle的执行下去了
   // 我在exu里吧valid传给了wen，这只是暂时的办法，因为现在只实现了算术运算指令，只要不wb rd
   // 指令就无效。
   // 但后面其它如lsu，一定需要valid跟着流水线走下去，或者像opensparc里那样，有kill信号
   // 现在就先这样。。。


   wire pc_f2d_en;
   assign pc_f2d_en = inst_kill_vld_f & ~exu_ifu_stall_req; 
   
   dffe_ns #(32) pc_f2d_reg (
      .din (pc_f),
      .clk (clk),
      .q   (pc_d),
      .en  (pc_f2d_en));
      //.se(), .si(), .so());

   assign fdp_dec_pc_d = pc_d;
   

   wire pc_d2e_en;
   assign pc_d2e_en = ifu_exu_valid_d & ~exu_ifu_stall_req;

   dffe_ns #(32) pc_d2e_reg (
      .din (pc_d),
      .clk (clk),
      .q   (pc_e),
      .en  (pc_d2e_en));
      //.se(), .si(), .so());



   dff_ns #(32) pc_e2m_reg (
      .din (pc_e),
      .clk (clk),
      .q   (pc_m));
      //.se(), .si(), .so());

   assign ifu_exu_pc_e = pc_e;
   
   dff_ns #(32) pc_m2w_reg (
      .din (pc_m),
      .clk (clk),
      .q   (pc_w));
      //.se(), .si(), .so());

   assign ifu_exu_pc_w = pc_w;

   
   

   assign ifu_pcbf_sel_init_bf_l = ~reset;
   // uty: test
   //assign ifu_pcbf_sel_old_bf_l = ((ifu_fdp_valid_f || reset || br_taken || exu_ifu_ertn_e) & (~exu_ifu_stall_req)) | exu_ifu_except; // exception need ifu to fetch instruction from eentry
   assign ifu_pcbf_sel_old_bf_l = ((iq_not_empty || reset || br_taken || exu_ifu_ertn_e) & (~exu_ifu_stall_req)) | exu_ifu_except; // exception need ifu to fetch instruction from eentry
   // uty: test 
   //assign ifu_pcbf_sel_pcinc_bf_l = ~(ifu_fdp_valid_f && ~br_taken && ~exu_ifu_except && ~exu_ifu_ertn_e) | exu_ifu_stall_req;  
   assign ifu_pcbf_sel_pcinc_bf_l = ~(iq_not_empty && ~br_taken && ~exu_ifu_except && ~exu_ifu_ertn_e) | exu_ifu_stall_req;  
   assign ifu_pcbf_sel_brpc_bf_l = ~br_taken; 


   assign ifu_pcbf_sel_usemux1_l = ifu_pcbf_sel_init_bf_l  &
                                   ifu_pcbf_sel_old_bf_l   &
                                   ifu_pcbf_sel_pcinc_bf_l &
                                   ifu_pcbf_sel_brpc_bf_l;
   
   assign ifu_pcbf_sel_excpc_bf_l = ~exu_ifu_except;
   assign ifu_pcbf_sel_ertnpc_bf_l = ~exu_ifu_ertn_e;
   

//   dp_mux5ds #(32) pcbf_mux(
//      .dout (pc_bf),
//      .in0  (pc_init),
//      .in1  (pc_f),
//      .in2  (pcinc_f),
//      .in3  (br_target),
//      .in4  (exu_ifu_eentry),
//      .sel0_l (ifu_pcbf_sel_init_bf_l),
//      .sel1_l (ifu_pcbf_sel_old_bf_l), 
//      .sel2_l (ifu_pcbf_sel_pcinc_bf_l),
//      .sel3_l (ifu_pcbf_sel_brpc_bf_l),
//      .sel4_l (ifu_pcbf_sel_excpc_bf_l));
      
   dp_mux4ds #(32) pcbf_mux_1(
      .dout    (pcbf_btwn_mux),
      .in0     (pc_init),
      .in1     (pc_f),
      .in2     (pcinc_f),
      .in3     (br_target),
      .sel0_l  (ifu_pcbf_sel_init_bf_l),
      .sel1_l  (ifu_pcbf_sel_old_bf_l),
      .sel2_l  (ifu_pcbf_sel_pcinc_bf_l),
      .sel3_l  (ifu_pcbf_sel_brpc_bf_l));

   dp_mux3ds #(32) pcbf_mux_2(
      .dout    (pc_bf),
      .in0     (pcbf_btwn_mux),
      .in1     (exu_ifu_eentry),
      .in2     (exu_ifu_era),
      .sel0_l  (ifu_pcbf_sel_usemux1_l),
      .sel1_l  (ifu_pcbf_sel_excpc_bf_l),
      .sel2_l  (ifu_pcbf_sel_ertnpc_bf_l));



   

   //===================================================
   // Fetched Instruction Datapath
   //===================================================
   
   dffe_ns #(32) inst_f2d_reg (
      .din (inst_f),
      .en  (inst_kill_vld_f & ~exu_ifu_stall_req), // same as pc_f2d_reg.en
      .clk (clk),
      .q   (fdp_dec_inst_d));
      //.se(), .si(), .so());

   


   //===================================================
   // Memory Interface
   //===================================================

   // inst_ack             : _-_____
   // if_fin               : _____-_
   //
   // if_in_prog_in        : _----__
   // if_in_prog_q         : __----_

   // instruction fetch in progress
   wire if_in_prog_in; 
   wire if_in_prog_q; 

   wire icu_busy;
   assign icu_busy = if_in_prog_q; // | others


   // if inst_cancel, inst_valid_f will not coming, so let if_in_prog_in finish
   wire if_fin;
   // uty: test
   //assign if_fin = inst_valid_f | inst_cancel;
   //assign if_fin = inst_valid_f;
   //assign if_fin = icu_ifu_data_valid_ic2;
   assign if_fin = icu_ifu_data_valid_ic2 | ifu_icu_cancel;

   //assign if_in_prog_in = (if_in_prog_q & ~if_fin) | inst_ack;                
   assign if_in_prog_in = (if_in_prog_q & ~if_fin) | icu_ifu_ack_ic1;                

   dffrl_ns #(1) lf_in_prog_reg (
      .din   (if_in_prog_in),
      .clk   (clk),
      .rst_l (~reset),
      .q     (if_in_prog_q));
      //.se(), .si(), .so());


   // uty: test
//   assign inst_req = ~reset & 
//                     ~exu_ifu_stall_req &
//                     ~icu_busy &
//		     iq_not_empty
//		     ;

//  iq_not_empty     fetch_ahead      req
//       0                0            1
//       0                1         should not exist
//       1                1            1
//       1                0            0


   // The logic works but could be improved.
   assign ifu_icu_req_ic1 = (~reset & 
                            ~exu_ifu_stall_req &
			    ~icu_busy &
			    ( fetch_ahead & ~ifu_icu_addr_ic1[2]) // fetch only at 64-bit aligment
                            )   

                            // Fetch if iq is empty while icu not busy
                          | (~icu_busy & ~iq_not_empty)

                            // Immediate refetch on cancel request
                          | ifu_icu_cancel
			  ;


   assign ifu_icu_addr_ic1 = pc_bf;

   assign ifu_fdp_valid_f = inst_valid_f;


   // when branch taken, inst_cancel need to be signal
   // so that the new target instruction can be fetched instead of the one previously requested
   //
   // uty: test
   //assign inst_cancel = br_taken | exu_ifu_except | exu_ifu_ertn_e;
   assign ifu_icu_cancel = (br_taken | exu_ifu_except | exu_ifu_ertn_e) & icu_busy; // icu_busy

   wire flush_iq;
   assign flush_iq = (br_taken | exu_ifu_except | exu_ifu_ertn_e) & ~icu_busy;


   cpu7_ifu_iq u_iq (
      .clk                    (clk                     ),
      .resetn                 (~reset                  ),
      
      .pc_f                   (pc_f                   ),
      .exu_ifu_stall_req      (exu_ifu_stall_req      ),
      .flush_iq               (flush_iq               ),

      .icu_ifu_data_ic2       (icu_ifu_data_ic2       ),
      .icu_ifu_data_valid_ic2 (icu_ifu_data_valid_ic2 ),

      .iq_not_empty           (iq_not_empty           ),
      .fetch_ahead            (fetch_ahead            ),
      .inst_f                 (inst_f                 ),
      .inst_valid_f           (inst_valid_f           )
      );

endmodule // cpu7_ifu_fdp


