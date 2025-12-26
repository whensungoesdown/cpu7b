`include "../defines.vh"
`include "../c7blsu/rtl/c7blsu_defs.v"
`include "../c7bcsr/csr_defs.v"
`include "../alu_defs.v"
`include "../bru_defs.v"

module cpu7_exu_ecl(
   input                                clk,
   input                                resetn,

   input                                ifu_exu_valid_e,

   input  [`GRLEN-1:0]                  ifu_exu_alu_a_e,
   input  [`GRLEN-1:0]                  ifu_exu_alu_b_e,
   input  [`LALU_CODE_BIT-1:0]    ifu_exu_alu_op_e,
   input  [`GRLEN-1:0]                  ifu_exu_alu_c_e,
   input                                ifu_exu_alu_double_word_e,
   input                                ifu_exu_alu_b_imm_e,
   input  [4:0]                         ifu_exu_rs1_e,
   input  [4:0]                         ifu_exu_rs2_e,

   // lsu
   input                                ifu_exu_lsu_valid_e,
   input  [`LLSU_CODE_BIT-1:0]    ifu_exu_lsu_op_e,
   input                                ifu_exu_double_read_e,
   input  [`GRLEN-1:0]                  ifu_exu_imm_shifted_e,
   input  [4:0]                         ifu_exu_lsu_rd_e,
   input                                ifu_exu_lsu_wen_e,

   // bru
   input  [`GRLEN-1:0]	                ifu_exu_pc_e,

   input                                ifu_exu_bru_valid_e,
   input  [`LBRU_CODE_BIT-1:0]    ifu_exu_bru_op_e,
   input  [`GRLEN-1:0]                  ifu_exu_bru_offset_e,

   // mul
   input                                ifu_exu_mul_valid_e,
   input                                ifu_exu_mul_wen_e,
   input                                ifu_exu_mul_signed_e,
   input                                ifu_exu_mul_double_e,
   input                                ifu_exu_mul_hi_e,
   input                                ifu_exu_mul_short_e,

   // csr
   input                                ifu_exu_csr_valid_e,
   input  [`LCSR_BIT-1:0]         ifu_exu_csr_raddr_d,
   input                                ifu_exu_csr_rdwen_e,
   input                                ifu_exu_csr_xchg_e,
   input                                ifu_exu_csr_wen_e,
   input  [`LCSR_BIT-1:0]         ifu_exu_csr_waddr_e,

   // alu
   input  [4:0]                         ifu_exu_rf_target_e,
   input                                ifu_exu_alu_wen_e,

   // ertn
   input                                ifu_exu_ertn_valid_e,

   //input                                ifu_exu_illinst_e,
   input                                ifu_exu_exception_e,
   input  [5:0]                         ifu_exu_exccode_e,


   // alu
   output [`GRLEN-1:0]                  ecl_alu_a_e,
   output [`GRLEN-1:0]                  ecl_alu_b_e,
   output [`LALU_CODE_BIT-1:0]    ecl_alu_op_e,
   output [`GRLEN-1:0]                  ecl_alu_c_e,
   output                               ecl_alu_double_word_e,
   input  [`GRLEN-1:0]                  alu_ecl_res_e,  // alu result

   // lsu
   output                               ecl_lsu_valid_e,
   output [`LLSU_CODE_BIT-1:0]    ecl_lsu_op_e,
   output [`GRLEN-1:0]                  ecl_lsu_base_e,
   output [`GRLEN-1:0]                  ecl_lsu_offset_e,
   output [`GRLEN-1:0]                  ecl_lsu_wdata_e,
   input  [`GRLEN-1:0]                  lsu_ecl_rdata_m, // _m inputs are for writting to regfile
   input                                lsu_ecl_data_valid_ls3,
   input                                lsu_ecl_wr_fin_ls3,
   input                                lsu_ecl_ale_e, 
   input  [31:0]                        lsu_ecl_except_badv_ls1,

   // bru
   output                               ecl_bru_valid_e,
   output [`LBRU_CODE_BIT-1:0]    ecl_bru_op_e,
   output [`GRLEN-1:0]                  ecl_bru_a_e,
   output [`GRLEN-1:0]                  ecl_bru_b_e,
   output [`GRLEN-1:0]                  ecl_bru_pc_e,
   output [`GRLEN-1:0]                  ecl_bru_offset_e,

   input  [`GRLEN-1:0]                  bru_ecl_brpc_e,
   input                                bru_ecl_br_taken_e,
   input  [`GRLEN-1:0]                  bru_byp_link_pc_e,
   input                                bru_ecl_wen_e,

   // mul
   output                               ecl_mul_valid_e,
   output [`GRLEN-1:0]                  byp_mul_a_e,
   output [`GRLEN-1:0]                  byp_mul_b_e,
   output                               ecl_mul_signed_e,
   output                               ecl_mul_double_e,
   output                               ecl_mul_hi_e,
   output                               ecl_mul_short_e,
   input                                mul_ecl_ready_m, // mul returns result at _m, so this is signal is unused
   input  [`GRLEN-1:0]                  mul_byp_res_m,

   // csr
   input  [`GRLEN-1:0]                  csr_byp_rdata_d,
   output [`LCSR_BIT-1:0]         ecl_csr_raddr_d,
   output [`LCSR_BIT-1:0]         ecl_csr_waddr_m,
   output [`GRLEN-1:0]                  byp_csr_wdata_m,
   output                               ecl_csr_wen_m,
   output [`GRLEN-1:0]                  ecl_csr_mask_m,
   output [31:0]                        ecl_csr_badv_e,

   // exception
   output                               exu_ifu_except,
   output [5:0]                         ecl_csr_exccode_e,
   input                                csr_ecl_crmd_ie,
   input                                csr_ecl_timer_intr,

   // ertn
   output                               exu_ifu_ertn_e,
   output                               ecl_csr_ertn_e,
   
   // ifu stall req
   output                               exu_ifu_stall_req,
   
   output [`GRLEN-1:0]                  exu_ifu_brpc_e,
   output                               exu_ifu_br_taken_e,

   output [`GRLEN-1:0]                  ecl_irf_rd_data_w,
   output                               ecl_irf_wen_w,
   output [4:0]                         ecl_irf_rd_w,

   input                                ext_intr
   );


   wire [4:0] rd_m;
   wire [4:0] rd_w;

   wire wen_m;
   wire wen_w;


   wire [`GRLEN-1:0] rd_data_m;
   wire [`GRLEN-1:0] rd_data_w;

   wire kill_e;
  


   
   /////////////////////////
   // ALU parameters
   /////////////////////////
   

   assign ecl_alu_op_e = ifu_exu_alu_op_e;
   assign ecl_alu_c_e = ifu_exu_alu_c_e;
   assign ecl_alu_double_word_e = ifu_exu_alu_double_word_e;


   //////////////////
   //  bypass logic
   //////////////////


   wire [`GRLEN-1:0] byp_rs1_data_e;
   wire [`GRLEN-1:0] byp_rs2_data_e;

   wire  ecl_byp_rs1_mux_sel_rf;
   wire  ecl_byp_rs1_mux_sel_m;   
   wire  ecl_byp_rs1_mux_sel_w;
   
   wire  ecl_byp_rs2_mux_sel_rf;
   wire  ecl_byp_rs2_mux_sel_m;   
   wire  ecl_byp_rs2_mux_sel_w;

   wire use_other_e;
   
   
   cpu7_exu_eclbyplog_rs1 byplog_rs1(
      .rs_e           (ifu_exu_rs1_e[4:0]     ),
      .rd_m           (rd_m[4:0]              ),
      .rd_w           (rd_w[4:0]              ),
      .wen_m          (wen_m                  ),
      .wen_w          (wen_w                  ),

      .rs_mux_sel_rf  (ecl_byp_rs1_mux_sel_rf ),
      .rs_mux_sel_m   (ecl_byp_rs1_mux_sel_m  ),
      .rs_mux_sel_w   (ecl_byp_rs1_mux_sel_w  )
      );

   assign use_other_e = ifu_exu_alu_b_imm_e | ifu_exu_double_read_e;

   cpu7_exu_eclbyplog byplog_rs2(
      .rs_e           (ifu_exu_rs2_e[4:0]     ),
      .rd_m           (rd_m[4:0]              ),
      .rd_w           (rd_w[4:0]              ),
      .wen_m          (wen_m                  ),
      .wen_w          (wen_w                  ),
      .use_other      (use_other_e            ),

      .rs_mux_sel_rf  (ecl_byp_rs2_mux_sel_rf ),
      .rs_mux_sel_m   (ecl_byp_rs2_mux_sel_m  ),
      .rs_mux_sel_w   (ecl_byp_rs2_mux_sel_w  )
      );
   
   mux3ds #(`GRLEN) mux_rs1_data (.dout(byp_rs1_data_e),
      .in0(ifu_exu_alu_a_e),
      .in1(rd_data_m),
      .in2(ecl_irf_rd_data_w),
      .sel0(ecl_byp_rs1_mux_sel_rf),
      .sel1(ecl_byp_rs1_mux_sel_m),
      .sel2(ecl_byp_rs1_mux_sel_w)
      );

   assign ecl_alu_a_e = byp_rs1_data_e;

   mux3ds #(`GRLEN) mux_rs2_data (.dout(byp_rs2_data_e),
      .in0(ifu_exu_alu_b_e),
      .in1(rd_data_m),
      .in2(ecl_irf_rd_data_w),
      .sel0(ecl_byp_rs2_mux_sel_rf),
      .sel1(ecl_byp_rs2_mux_sel_m),
      .sel2(ecl_byp_rs2_mux_sel_w)
      );

   assign ecl_alu_b_e = byp_rs2_data_e;


   
   
   ////////////////
   // LSU
   ///////////////

   assign ecl_lsu_valid_e = ifu_exu_lsu_valid_e & (~kill_e); 
   assign ecl_lsu_op_e = ifu_exu_lsu_op_e;
   assign ecl_lsu_base_e = byp_rs1_data_e;
   

   wire [`GRLEN-1:0]          lsu_offset_e;
 
   assign lsu_offset_e = ifu_exu_double_read_e ? byp_rs2_data_e : ifu_exu_imm_shifted_e; 
   assign ecl_lsu_offset_e = lsu_offset_e;
   assign ecl_lsu_wdata_e = byp_rs2_data_e;

   wire [4:0] lsu_rd_e = ifu_exu_lsu_rd_e;
   wire lsu_wen_e = ifu_exu_lsu_wen_e;
   wire [4:0] lsu_rd_m;
   wire lsu_wen_m;
   

   //////////////////////
   // BRU
   //////////////////////

   assign ecl_bru_valid_e = ifu_exu_bru_valid_e & (~kill_e);
   assign ecl_bru_op_e = ifu_exu_bru_op_e;
   assign ecl_bru_a_e = byp_rs1_data_e;
   assign ecl_bru_b_e = byp_rs2_data_e;
   assign ecl_bru_pc_e = ifu_exu_pc_e; 
   assign ecl_bru_offset_e = ifu_exu_bru_offset_e;
  

   assign exu_ifu_brpc_e = bru_ecl_brpc_e;
   assign exu_ifu_br_taken_e = ecl_bru_valid_e & bru_ecl_br_taken_e;
   

   
   wire [`GRLEN-1:0] bru_link_pc_e;
   wire [`GRLEN-1:0] bru_link_pc_m;

   assign bru_link_pc_e = bru_byp_link_pc_e;
   
   dff_s #(`GRLEN) bru_link_pc_e2m_reg (
      .din (bru_link_pc_e),
      .clk (clk),
      .q   (bru_link_pc_m),
      .se(), .si(), .so());


   wire bru_wen_e;
   wire bru_wen_m;

   assign bru_wen_e = bru_ecl_wen_e;
   
   dff_s #(1) bru_wen_e2m_reg (
      .din (bru_wen_e),
      .clk (clk),
      .q   (bru_wen_m),
      .se(), .si(), .so());
   
   

   /////////////////////////
   // MUL
   ////////////////////////

   wire mul_wen_m;

   dffrl_s #(1) mul_wen_e2m_reg (
      .din (ifu_exu_mul_wen_e),
      .clk (clk),
      .rst_l (resetn),
      .q   (mul_wen_m),
      .se(), .si(), .so());
   

   assign byp_mul_a_e = byp_rs1_data_e;
   assign byp_mul_b_e = byp_rs2_data_e;
   
   wire mul_valid_m;

   assign ecl_mul_valid_e = ifu_exu_mul_valid_e & (~kill_e);
   
   dffrl_s #(1) mul_valid_e2m_reg (
      .din (ecl_mul_valid_e),
      .clk (clk),
      .rst_l (resetn),
      .q   (mul_valid_m),
      .se(), .si(), .so());
   

   assign ecl_mul_signed_e = ifu_exu_mul_signed_e;
   assign ecl_mul_double_e = ifu_exu_mul_double_e;
   assign ecl_mul_hi_e = ifu_exu_mul_hi_e;
   assign ecl_mul_short_e = ifu_exu_mul_short_e;


   
   ///////////////////////
   // CSR
   ///////////////////////

   //
   // csrrd
   //

   wire ecl_csr_valid_e;
   wire csr_valid_m;

   assign ecl_csr_valid_e = ifu_exu_csr_valid_e & (~kill_e);

   dff_s #(1) csr_valid_e2m_reg (
      .din (ecl_csr_valid_e),
      .clk (clk),
      .q   (csr_valid_m),
      .se(), .si(), .so());

   
   
   wire [`GRLEN-1:0]             csr_rdata_d;
   wire [`GRLEN-1:0]             csr_rdata_e;
   wire [`GRLEN-1:0]             csr_rdata_m;
   
   assign ecl_csr_raddr_d = ifu_exu_csr_raddr_d;
   assign csr_rdata_d = csr_byp_rdata_d;

   
   dff_s #(`GRLEN) csr_rdata_d2e_reg (
      .din (csr_rdata_d),
      .clk (clk),
      .q   (csr_rdata_e),
      .se(), .si(), .so());
   
   dff_s #(`GRLEN) csr_rdata_e2m_reg (
      .din (csr_rdata_e),
      .clk (clk),
      .q   (csr_rdata_m),
      .se(), .si(), .so());

   

   

   // CSR's rd follows ALU rd's datapath

   // CSR rd wen
   wire csr_rdwen_m;

   dff_s #(1) csr_rdwen_e2m_reg (
      .din (ifu_exu_csr_rdwen_e),
      .clk (clk),
      .q   (csr_rdwen_m),
      .se(), .si(), .so());
   

   //
   // csrwr csrxchg
   //
   
   wire [`GRLEN-1:0] csr_mask_e;
   wire [`GRLEN-1:0] csr_mask_m;
   

   // according to the handbook
   // csrwr is a special csrxchg, that has a full mask.

   assign csr_mask_e = ifu_exu_csr_xchg_e ? byp_rs1_data_e : `GRLEN'hFFFFFFFF;

   dff_s #(`GRLEN) csr_mask_e2m_reg (
      .din (csr_mask_e),
      .clk (clk),
      .q   (csr_mask_m),
      .se(), .si(), .so());

   assign ecl_csr_mask_m = csr_mask_m;


   wire [`GRLEN-1:0] csr_wdata_e;
   wire [`GRLEN-1:0] csr_wdata_m;
   
   assign csr_wdata_e = byp_rs2_data_e;

   dff_s #(`GRLEN) csr_wdata_e2m_reg (
      .din (csr_wdata_e),
      .clk (clk),
      .q   (csr_wdata_m),
      .se(), .si(), .so());

   assign byp_csr_wdata_m = csr_wdata_m;
   

   // csr wen
   wire csr_wen_m;
   wire csr_wen_w;

   dffrl_s #(1) csr_wen_e2m_reg (
      //.din (csr_wen_e),
      .din (ifu_exu_csr_wen_e),
      .clk (clk),
      .rst_l (resetn),
      .q   (csr_wen_m),
      .se(), .si(), .so());

   assign ecl_csr_wen_m = csr_wen_m;
   
   dffrl_s #(1) csr_wen_m2w_reg (
      .din (csr_wen_m),
      .clk (clk),
      .rst_l (resetn),
      .q   (csr_wen_w),
      .se(), .si(), .so());

   
   // waddr is the same as raddr
   wire [`LCSR_BIT-1:0]    csr_waddr_m;
   
   dff_s #(`LCSR_BIT) csr_waddr_e2m_reg (
      //.din (csr_waddr_e),
      .din (ifu_exu_csr_waddr_e),
      .clk (clk),
      .q   (csr_waddr_m),
      .se(), .si(), .so());

   assign ecl_csr_waddr_m = csr_waddr_m;
   

   //
   // csr stall req
   //
   
   wire csr_stall_req;
   wire csr_stall_req_next;
   //wire csr_stall_req_ful;

   //assign csr_stall_req_next = (ifu_exu_csr_wen_e) | (csr_stall_req & ~csr_wen_m);
   assign csr_stall_req_next = (ifu_exu_csr_wen_e) | (csr_stall_req & ~csr_wen_w);
   
   dffrl_s #(1) csr_stall_req_reg (
      .din (csr_stall_req_next),
      .clk (clk),
      .rst_l (resetn),
      .q   (csr_stall_req),
      .se(), .si(), .so());

   //assign csr_stall_req_ful = ifu_exu_csr_rdwen_e | csr_stall_req;

   
   ///////////////////////
   // ALU
   ///////////////////////

   ////
   //  rf_target rd_data rf_wen
   //  only for ALU instructions
   //
   wire [4:0] rf_target_m;
   
   dff_s #(5) rd_e2m_reg (
      .din (ifu_exu_rf_target_e),
      .clk (clk),
      .q   (rf_target_m),
      .se(), .si(), .so());

  
   //
   // rf_wen, only for ALU instructions
   //
   
   wire ecl_alu_wen_e;
   wire alu_wen_m;
   
   assign ecl_alu_wen_e = ifu_exu_alu_wen_e & (~kill_e);
   
   dff_s #(1) alu_wen_e2m_reg (
      .din (ecl_alu_wen_e),
      .clk (clk),
      .q   (alu_wen_m),
      .se(), .si(), .so());


   // alu_res_m, only for ALU instructions
   wire [`GRLEN-1:0] alu_res_m;

   dff_s #(`GRLEN) rd_data_e2m_reg (
      .din (alu_ecl_res_e),
      .clk (clk),
      .q   (alu_res_m),
      .se(), .si(), .so());


   

   ////////////////////////////////////
   // rd wen rd_data MUX
   ////////////////////////////////////
   
   //
   //  rd mux
   //
   // Instructions other than ALU have longer pipeline.
   // they should maintain their own rd and mux them here at _m
   // ALU instructions take exactly 5 cyclc.
   //
   // BRU and MUL share ALU's rd because they exactly follow the 5 stage pipeline.
   // LSU takes uncertain cycles. It keeps record of its own rd.
   //

   
   dp_mux2es #(5) rd_mux(
      .dout (rd_m),
      .in0  (rf_target_m),
      .in1  (lsu_rd_m),
      .sel  (lsu_ecl_data_valid_ls3));
   
   dff_s #(5) rd_m2w_reg (
      .din (rd_m),
      .clk (clk),
      .q   (rd_w),
      .se(), .si(), .so());

   assign ecl_irf_rd_w = rd_w;

  
   //
   // wen mux
   //
   
   // set the wen if any module claims it
   //assign wen_m = alu_wen_m | (lsu_wen_m & lsu_ecl_finish_m) | bru_wen_m | mul_wen_m | csr_rdwen_m;
   assign wen_m = alu_wen_m | (lsu_wen_m & lsu_ecl_data_valid_ls3) | bru_wen_m | mul_wen_m | csr_rdwen_m;
   
   dff_s #(1) wen_m2w_reg (
      .din (wen_m),
      .clk (clk),
      .q   (wen_w),
      .se(), .si(), .so());

   assign ecl_irf_wen_w = wen_w;
   

   //
   // rd_data mux
   //
   

   wire rddata_sel_alu_res_m_l;
   wire rddata_sel_lsu_res_m_l;
   wire rddata_sel_bru_res_m_l;
   wire rddata_sel_mul_res_m_l;
   wire rddata_sel_csr_res_m_l;

   // uty: todo
   // alu better has a valid signal
   //assign rddata_sel_alu_res_m_l = (lsu_ecl_finish_m | bru_wen_m | mul_valid_m | csr_valid_m); // default is alu resulst if no other module claims it
   assign rddata_sel_alu_res_m_l = (lsu_ecl_data_valid_ls3 | bru_wen_m | mul_valid_m | csr_valid_m); // default is alu resulst if no other module claims it
   //assign rddata_sel_lsu_res_m_l = ~lsu_ecl_finish_m;
   assign rddata_sel_lsu_res_m_l = ~lsu_ecl_data_valid_ls3;
   assign rddata_sel_bru_res_m_l = ~bru_wen_m;   // bru's rd go with ALU's
   assign rddata_sel_mul_res_m_l = ~mul_valid_m; // mul's rd go with ALU's
   assign rddata_sel_csr_res_m_l = ~csr_valid_m; // csr's rd go with ALU's

   // maybe too much fan out? make it 4ds+3ds when adding div 
   dp_mux5ds #(`GRLEN) rd_data_mux(.dout  (rd_data_m),
                          .in0   (alu_res_m),
                          .in1   (lsu_ecl_rdata_m),
                          .in2   (bru_link_pc_m),
                          .in3   (mul_byp_res_m),
                          .in4   (csr_rdata_m),
                          .sel0_l (rddata_sel_alu_res_m_l),
                          .sel1_l (rddata_sel_lsu_res_m_l),
                          .sel2_l (rddata_sel_bru_res_m_l),
                          .sel3_l (rddata_sel_mul_res_m_l),
                          .sel4_l (rddata_sel_csr_res_m_l));
   
   
   dff_s #(`GRLEN) rd_data_w_reg (
      .din (rd_data_m),
      .clk (clk),
      .q   (rd_data_w),
      .se(), .si(), .so());

   assign ecl_irf_rd_data_w = rd_data_w;


   /////////////////////
   // stall IFU logic
   ////////////////////

   //
   // BRU also stalls IFU for one cycle, but it does not signal exu_ifu_stall_req,
   // becasue it involves pc_ logic, and changes control flow.
   // 

   
   //
   // lsu stall request
   //

   // ecl_lsu_valid_e    : _-______
   // lsu_ecl_finish_m   : ______-_
   //
   // lsu_stall_req      : __-----_
   // lsu_stall_req_next : _-----__
   // lsu_stall_req_ful  : _------_
   //
   
   wire lsu_stall_req;
   wire lsu_stall_req_next;

   wire lsu_stall_req_ful;

   assign lsu_stall_req_ful = lsu_stall_req | ecl_lsu_valid_e;

   //
   // ecl_lsu_valid_e is the staring signal
   // lsu_fin_ls3 ends it
   //
   
   // lsu_fin_ls3 determins when to end the IFU stall (lsu_stall_req). If
   // an Alignment Exception (ALE) occurs at LS1, the corresponding BIU
   // request (which would execute at LS2) is aborted. As a result, no
   // completion signals (lsu_ecl_data_valid_ls3 or lsu_ecl_wr_fin_ls3) are
   // generated. In such case, lsu_ecl_ale_e should complete the aborted LSU
   // request.
   wire lsu_fin_ls3 = lsu_ecl_data_valid_ls3 | lsu_ecl_wr_fin_ls3 | lsu_ecl_ale_e ;
   assign lsu_stall_req_next =  (ecl_lsu_valid_e) | (lsu_stall_req & ~lsu_fin_ls3); 
   
   dffr_s #(1) lsu_stall_req_reg (
      .din (lsu_stall_req_next),
      .clk (clk),
      .q   (lsu_stall_req),
      .se(), .si(), .so(), .rst (~resetn));



   //
   // interrupt
   //

   //
   // intr_all              : ____--------
   // ifu_exu_valid_risinge : ______-_____
   //
   // intr_all_sync         : ______-_____
   //
   // Later, intr_all also becomes
   //                       : ______-_____
   // Because csr_ecl_crmd_ie will be cleared by exu_ifu_except


   wire intr_all;
   assign intr_all = (csr_ecl_timer_intr | ext_intr) & csr_ecl_crmd_ie; // ext_intr as HWI0
   
   wire intr_all_sync; // intr_all_sync to ifu_exu_valid_e rising edge
   
   wire ifu_exu_valid_rising_e;

   wire prev_ifu_exu_valid_e;

   dff_s #(1) ifu_exu_valid_e_posedge_detect_reg (
      .din (ifu_exu_valid_e),
      .clk (clk),
      .q   (prev_ifu_exu_valid_e),
      .se(), .si(), .so());

   assign ifu_exu_valid_rising_e = ~prev_ifu_exu_valid_e & ifu_exu_valid_e;

   assign intr_all_sync = intr_all & ifu_exu_valid_rising_e;


   
   //
   // excetpion
   //

   wire       exception_all_e;
   wire [5:0] exccode_all_e;

   // exu_ifu_except should only be signaled 1 cycle to notify ifu, because it makes ifu stall 
   assign exception_all_e = ifu_exu_exception_e | lsu_ecl_ale_e;

   // if exception and interrupt come at the same time, handle interrupt
   // first, the casue-exception instruction will be reexecuted
   //
   // interrupt ecode is 0
   assign exccode_all_e = intr_all_sync ? 6'b0 : ifu_exu_exccode_e;
   assign ecl_csr_exccode_e = exccode_all_e;

   // exu_ifu_except tells ifu to change pc_bf
   assign exu_ifu_except = exception_all_e | intr_all_sync;
   
                 
   // BUG FIX
   // exu_ifu_except consists of lsu_ecl_ale_e | ecl_csr_illinst_e | csr_ecl_timer_intr, lsu_ecl_ale_e is signal from _e
   // so kill_e = exu_ifu_except may cause a loop
   // modelsim: ** Error: (vsim-3601) Iteration limit reached at time xxx us.
   assign kill_e = intr_all_sync; // exu_ifu_except;


   //
   // exu_ifu_stall_req
   //
   // uty: review  csr_stall_req_next probably should do the csr_stall_req_ful too
   assign exu_ifu_stall_req = lsu_stall_req_ful | csr_stall_req_next;
   //assign exu_ifu_stall_req = lsu_stall_req_ful | csr_stall_req_ful;
   


   //
   // ernt (eret) 
   //

   assign exu_ifu_ertn_e = ifu_exu_ertn_valid_e; // code review: exu_ifu_ertn_e is unnecessary
   assign ecl_csr_ertn_e = ifu_exu_ertn_valid_e;
   

   //
   // Passthrough
   //
   assign ecl_csr_badv_e = lsu_ecl_except_badv_ls1;


   //
   // Registers
   //

   // The load/store instruction's rd and wen are managed within the ECL
   // instead of the LSU before. Here uses a DFFE to preserve lsu_rd_m and
   // lsu_wen_m from being flushed. This works for now, future revisions
   // should consider a more comprehensive solution for the overall
   // instruction issue mechanism and pipeline.
   dffe_s #(5) lsu_rd_m_reg (
      .din (lsu_rd_e),
      .clk (clk),
      .en  (ecl_lsu_valid_e),
      .q   (lsu_rd_m),
      .se(), .si(), .so());

   dffe_s #(1) lsu_wen_m_reg (
      .din (lsu_wen_e),
      .clk (clk),
      .en  (ecl_lsu_valid_e),
      .q   (lsu_wen_m),
      .se(), .si(), .so());

endmodule // cpu7_exu_ecl
