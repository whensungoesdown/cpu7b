`include "../defines.vh"
`include "../c7blsu/rtl/c7blsu_defs.v"
`include "../c7bcsr/csr_defs.v"
`include "../alu_defs.v"
`include "../bru_defs.v"

module cpu7_exu(

   input                          clk,
   input                          resetn,

   input                          ifu_exu_valid_e,

   input  [31:0]                  ifu_exu_pc_w,
   input  [31:0]                  ifu_exu_pc_e,

   // memory interface  E M
   output                         lsu_biu_rd_req,
   output [31:0]                  lsu_biu_rd_addr,

   input                          biu_lsu_rd_ack,
   input                          biu_lsu_data_valid,
   input  [63:0]                  biu_lsu_data,

   output                         lsu_biu_wr_req,
   output [31:0]                  lsu_biu_wr_addr,
   output [63:0]                  lsu_biu_wr_data,
   output [7:0]                   lsu_biu_wr_strb,

   input                          biu_lsu_wr_ack,
   input                          biu_lsu_write_done,


   output                         exu_ifu_stall_req,
   output [31:0]                  exu_ifu_brpc_e,
   output                         exu_ifu_br_taken_e,

   // exception
   output [31:0]                  exu_ifu_eentry,
   output                         exu_ifu_except,
   // ertn
   output [31:0]                  exu_ifu_era,
   output                         exu_ifu_ertn_e,
   

   input  [31:0]                  ifu_exu_alu_a_e,
   input  [31:0]                  ifu_exu_alu_b_e,
   input  [`LALU_CODE_BIT-1:0]    ifu_exu_alu_op_e,
   input  [31:0]                  ifu_exu_alu_c_e,
   input                          ifu_exu_alu_double_word_e,
   input                          ifu_exu_alu_b_imm_e,

   input  [4:0]                   ifu_exu_rs1_d,
   input  [4:0]                   ifu_exu_rs2_d,
   input  [4:0]                   ifu_exu_rs1_e,
   input  [4:0]                   ifu_exu_rs2_e,
   
   output [31:0]                  exu_ifu_rs1_data_d,
   output [31:0]                  exu_ifu_rs2_data_d,

   // lsu
   input                          ifu_exu_lsu_valid_e,
   input  [`LLSU_CODE_BIT-1:0]    ifu_exu_lsu_op_e,
   input                          ifu_exu_double_read_e,
   input  [31:0]                  ifu_exu_imm_shifted_e,
   input  [4:0]                   ifu_exu_lsu_rd_e,
   input                          ifu_exu_lsu_wen_e,

   // bru
   input                          ifu_exu_bru_valid_e,
   input  [`LBRU_CODE_BIT-1:0]    ifu_exu_bru_op_e,
   input  [31:0]                  ifu_exu_bru_offset_e,

   // mul
   input                          ifu_exu_mul_valid_e,
   input                          ifu_exu_mul_wen_e,
   input                          ifu_exu_mul_signed_e,
   input                          ifu_exu_mul_double_e,
   input                          ifu_exu_mul_hi_e,
   input                          ifu_exu_mul_short_e,

   // csr
   input                          ifu_exu_csr_valid_e,
   input  [`LCSR_BIT-1:0]         ifu_exu_csr_raddr_d,
   input                          ifu_exu_csr_rdwen_e,
   input                          ifu_exu_csr_xchg_e,
   input                          ifu_exu_csr_wen_e,
   input  [`LCSR_BIT-1:0]         ifu_exu_csr_waddr_e,

   // alu
   input  [4:0]                   ifu_exu_rf_target_e,
   input                          ifu_exu_alu_wen_e,

   // ertn
   input                          ifu_exu_ertn_valid_e,

   //input                          ifu_exu_illinst_e
   input                          ifu_exu_exception_e,
   input  [5:0]                   ifu_exu_exccode_e,


   input                          ext_intr
   );


   
   // alu
   wire [31:0]                    ecl_alu_a_e;
   wire [31:0]                    ecl_alu_b_e;
   wire [31:0]                    ecl_alu_c_e;
   wire [`LALU_CODE_BIT-1:0]      ecl_alu_op_e;
   wire                           ecl_alu_double_word_e;
   wire [31:0]                    alu_ecl_res_e;


   // lsu
   wire                           ecl_lsu_valid_e;
   wire [`LLSU_CODE_BIT-1:0]      ecl_lsu_op_e;
   wire [31:0]                    ecl_lsu_base_e;
   wire [31:0]                    ecl_lsu_offset_e;
   wire [31:0]                    ecl_lsu_wdata_e;

   
   wire [31:0]                    ecl_irf_rd_data_w;
   wire [4:0]                     ecl_irf_rd_w; // derived from ifu_exu_rf_target_d
   wire                           ecl_irf_wen_w;


   // bru
   wire                           ecl_bru_valid_e;
   wire [`LBRU_CODE_BIT-1:0]      ecl_bru_op_e;
   wire [31:0]                    ecl_bru_a_e;       
   wire [31:0]                    ecl_bru_b_e;
   wire [31:0]                    ecl_bru_pc_e;
   wire [31:0]                    ecl_bru_offset_e;

   wire [31:0]                    bru_ecl_brpc_e;    
   wire                           bru_ecl_br_taken_e;  
   wire [31:0]                    bru_byp_link_pc_e;
   wire                           bru_ecl_wen_e;


   // mul
   wire [31:0]                    byp_mul_a_e;
   wire [31:0]                    byp_mul_b_e;
   wire                           ecl_mul_signed_e;
   wire                           ecl_mul_double_e;
   wire                           ecl_mul_hi_e;
   wire                           ecl_mul_short_e;
   wire                           ecl_mul_valid_e;
   wire                           mul_ecl_64ready;
   wire                           mul_ecl_32ready;
   wire [31:0]                    mul_byp_res_m;


   // csr
   wire [31:0]                   csr_byp_rdata_d;
   wire [`LCSR_BIT-1:0]          ecl_csr_raddr_d;
   wire [`LCSR_BIT-1:0]          ecl_csr_waddr_m;
   wire [31:0]                   byp_csr_wdata_m;
   wire [31:0]                   ecl_csr_mask_m;
   wire                          ecl_csr_wen_m;
   wire                          ecl_csr_ertn_e;
   wire                          csr_ecl_crmd_ie;
   wire                          csr_ecl_timer_intr;
   wire [5:0]                    ecl_csr_exccode_e;


   wire [31:0] dumb_rdata1_0;
   wire [31:0] dumb_rdata1_1;
   wire [31:0] dumb_rdata2_0;
   wire [31:0] dumb_rdata2_1;
   
   cpu7_exu_rf registers(
        .clk        (clk),
	.rst        (~resetn),

        .waddr1     (ecl_irf_rd_w),// I, 5
        .raddr0_0   (ifu_exu_rs1_d),// I, 5
        .raddr0_1   (ifu_exu_rs2_d),// I, 5
        .wen1       (ecl_irf_wen_w),// I, 1
        .wdata1     (ecl_irf_rd_data_w),// I, 32
        .rdata0_0   (exu_ifu_rs1_data_d),// O, 32
        .rdata0_1   (exu_ifu_rs2_data_d),// O, 32

      
        .waddr2     (5'b0),// I, 5
        .raddr1_0   (5'b0),// I, 32
        .raddr1_1   (5'b0),// I, 32
        .wen2       (1'b0),// I, 1
        .wdata2     (32'b0),// I, 32
        .rdata1_0   (dumb_rdata1_0),// O, 32
        .rdata1_1   (dumb_rdata1_1),// O, 32

        .raddr2_0   (5'b0),// I, 5
        .raddr2_1   (5'b0),// I, 5
        .rdata2_0   (dumb_rdata2_0),// O, 32
        .rdata2_1   (dumb_rdata2_1) // O, 32
      
//        .waddr2     (waddr2),// I, 32
//        .raddr1_0   (raddr1_0),// I, 32
//        .raddr1_1   (raddr1_1),// I, 32
//        .wen2       (wen2),// I, 1
//        .wdata2     (wdata2),// I, 32
//        .rdata1_0   (rdata1_0),// O, 32
//        .rdata1_1   (rdata1_1),// O, 32
//
//        .raddr2_0   (raddr2_0),// I, 32
//        .raddr2_1   (raddr2_1),// I, 32
//        .rdata2_0   (rdata2_0),// O, 32
//        .rdata2_1   (rdata2_1) // O, 32
      );

   wire [31:0]        lsu_ecl_data_ls3;
   wire               lsu_ecl_data_valid_ls3;
   wire               lsu_ecl_wr_fin_ls3; 
   wire               lsu_ecl_except_ale_ls1;
   wire [31:0]        ecl_csr_badv_e;
   wire [31:0]        lsu_ecl_except_badv_ls1;

   
   
   // cpu7_exu_byp
   
   cpu7_exu_ecl ecl(
      .clk                             (clk),
      .resetn                          (resetn),

      .ifu_exu_valid_e                 (ifu_exu_valid_e),
     
      .ifu_exu_alu_a_e                 (ifu_exu_alu_a_e),
      .ifu_exu_alu_b_e                 (ifu_exu_alu_b_e),
      .ifu_exu_alu_op_e                (ifu_exu_alu_op_e),
      .ifu_exu_alu_c_e                 (ifu_exu_alu_c_e),
      .ifu_exu_alu_double_word_e       (ifu_exu_alu_double_word_e),
      .ifu_exu_alu_b_imm_e             (ifu_exu_alu_b_imm_e),

      .ifu_exu_rs1_e                   (ifu_exu_rs1_e),
      .ifu_exu_rs2_e                   (ifu_exu_rs2_e),

      // lsu
      .ifu_exu_lsu_valid_e             (ifu_exu_lsu_valid_e), 
      .ifu_exu_lsu_op_e                (ifu_exu_lsu_op_e),
      .ifu_exu_double_read_e           (ifu_exu_double_read_e),
      .ifu_exu_imm_shifted_e           (ifu_exu_imm_shifted_e),
      .ifu_exu_lsu_rd_e                (ifu_exu_lsu_rd_e),
      .ifu_exu_lsu_wen_e               (ifu_exu_lsu_wen_e),


      // bru
      .ifu_exu_pc_e                    (ifu_exu_pc_e),

      .ifu_exu_bru_valid_e             (ifu_exu_bru_valid_e),
      .ifu_exu_bru_op_e                (ifu_exu_bru_op_e),
      .ifu_exu_bru_offset_e            (ifu_exu_bru_offset_e),

      // mul
      .ifu_exu_mul_valid_e             (ifu_exu_mul_valid_e),
      .ifu_exu_mul_wen_e               (ifu_exu_mul_wen_e),
      .ifu_exu_mul_signed_e            (ifu_exu_mul_signed_e),
      .ifu_exu_mul_double_e            (ifu_exu_mul_double_e),
      .ifu_exu_mul_hi_e                (ifu_exu_mul_hi_e),
      .ifu_exu_mul_short_e             (ifu_exu_mul_short_e),

      // csr
      .ifu_exu_csr_valid_e             (ifu_exu_csr_valid_e),
      .ifu_exu_csr_raddr_d             (ifu_exu_csr_raddr_d),
      .ifu_exu_csr_rdwen_e             (ifu_exu_csr_rdwen_e),
      .ifu_exu_csr_xchg_e              (ifu_exu_csr_xchg_e),
      .ifu_exu_csr_wen_e               (ifu_exu_csr_wen_e),
      .ifu_exu_csr_waddr_e             (ifu_exu_csr_waddr_e),

      // alu
      .ifu_exu_rf_target_e             (ifu_exu_rf_target_e),
      .ifu_exu_alu_wen_e               (ifu_exu_alu_wen_e),
                                                            
      // ertn                           
      .ifu_exu_ertn_valid_e            (ifu_exu_ertn_valid_e),

      //.ifu_exu_illinst_e               (ifu_exu_illinst_e),
      .ifu_exu_exception_e             (ifu_exu_exception_e),
      .ifu_exu_exccode_e               (ifu_exu_exccode_e),


      // alu
      .ecl_alu_a_e                     (ecl_alu_a_e),
      .ecl_alu_b_e                     (ecl_alu_b_e),
      .ecl_alu_op_e                    (ecl_alu_op_e),
      .ecl_alu_c_e                     (ecl_alu_c_e),
      .ecl_alu_double_word_e           (ecl_alu_double_word_e),
      .alu_ecl_res_e                   (alu_ecl_res_e),

      // lsu
      .ecl_lsu_valid_e                 (ecl_lsu_valid_e),
      .ecl_lsu_op_e                    (ecl_lsu_op_e),
      .ecl_lsu_base_e                  (ecl_lsu_base_e),
      .ecl_lsu_offset_e                (ecl_lsu_offset_e),
      .ecl_lsu_wdata_e                 (ecl_lsu_wdata_e),
      .lsu_ecl_rdata_m                 (lsu_ecl_data_ls3),
      .lsu_ecl_data_valid_ls3          (lsu_ecl_data_valid_ls3),
      .lsu_ecl_wr_fin_ls3              (lsu_ecl_wr_fin_ls3),
      .lsu_ecl_ale_e                   (lsu_ecl_except_ale_ls1),
      .lsu_ecl_except_badv_ls1         (lsu_ecl_except_badv_ls1),

      // bru
      .ecl_bru_valid_e                 (ecl_bru_valid_e),
      .ecl_bru_op_e                    (ecl_bru_op_e),
      .ecl_bru_a_e                     (ecl_bru_a_e),
      .ecl_bru_b_e                     (ecl_bru_b_e),
      .ecl_bru_pc_e                    (ecl_bru_pc_e),
      .ecl_bru_offset_e                (ecl_bru_offset_e),
      .bru_ecl_brpc_e                  (bru_ecl_brpc_e),
      .bru_ecl_br_taken_e              (bru_ecl_br_taken_e),
      .bru_byp_link_pc_e               (bru_byp_link_pc_e),
      .bru_ecl_wen_e                   (bru_ecl_wen_e),

      // mul
      .ecl_mul_valid_e                 (ecl_mul_valid_e),
      .byp_mul_a_e                     (byp_mul_a_e),
      .byp_mul_b_e                     (byp_mul_b_e),
      .ecl_mul_signed_e                (ecl_mul_signed_e),
      .ecl_mul_double_e                (ecl_mul_double_e),
      .ecl_mul_hi_e                    (ecl_mul_hi_e),
      .ecl_mul_short_e                 (ecl_mul_short_e),
      .mul_ecl_ready_m                 (mul_ecl_32ready),
      .mul_byp_res_m                   (mul_byp_res_m),

      // csr
      .csr_byp_rdata_d                 (csr_byp_rdata_d),
      .ecl_csr_raddr_d                 (ecl_csr_raddr_d),
      .ecl_csr_waddr_m                 (ecl_csr_waddr_m),
      .byp_csr_wdata_m                 (byp_csr_wdata_m),
      .ecl_csr_mask_m                  (ecl_csr_mask_m),
      .ecl_csr_wen_m                   (ecl_csr_wen_m),

      .ecl_csr_badv_e                  (ecl_csr_badv_e),

      .exu_ifu_except                  (exu_ifu_except),
      .ecl_csr_exccode_e               (ecl_csr_exccode_e),
      .csr_ecl_crmd_ie                 (csr_ecl_crmd_ie),
      .csr_ecl_timer_intr              (csr_ecl_timer_intr),
      
      .exu_ifu_ertn_e                  (exu_ifu_ertn_e),
      .ecl_csr_ertn_e                  (ecl_csr_ertn_e),
      
      .exu_ifu_stall_req               (exu_ifu_stall_req),

      .exu_ifu_brpc_e                  (exu_ifu_brpc_e),
      .exu_ifu_br_taken_e              (exu_ifu_br_taken_e),   

      .ecl_irf_rd_data_w               (ecl_irf_rd_data_w),
      .ecl_irf_rd_w                    (ecl_irf_rd_w),
      .ecl_irf_wen_w                   (ecl_irf_wen_w),


      .ext_intr                        (ext_intr)
      );

   // alu's result should pass to cpu7_exu_byp
   // now send it to ecl, ecl store is to the consequent
   // pipeline registers, then write back to rf  
   
   // alu
   alu u_alu(   
      .a                               (ecl_alu_a_e),
      .b                               (ecl_alu_b_e),
      .double_word                     (ecl_alu_double_word_e),
      .alu_op                          (ecl_alu_op_e),
      .c                               (ecl_alu_c_e),
      .Result                          (alu_ecl_res_e)
      );


   c7blsu u_lsu (
      .clk                             (clk),
      .resetn                          (resetn),

      // ECL Interface
      .ecl_lsu_valid_e                 (ecl_lsu_valid_e),
      .ecl_lsu_op_e                    (ecl_lsu_op_e),
      .ecl_lsu_base_e                  (ecl_lsu_base_e),
      .ecl_lsu_offset_e                (ecl_lsu_offset_e),
      .ecl_lsu_wdata_e                 (ecl_lsu_wdata_e),

      .lsu_ecl_data_valid_ls3          (lsu_ecl_data_valid_ls3),
      .lsu_ecl_data_ls3                (lsu_ecl_data_ls3),

      .lsu_ecl_wr_fin_ls3              (lsu_ecl_wr_fin_ls3),

      .lsu_ecl_except_ale_ls1          (lsu_ecl_except_ale_ls1),
      .lsu_ecl_except_badv_ls1         (lsu_ecl_except_badv_ls1),
      .lsu_ecl_except_buserr_ls3       (), // not used
      .lsu_ecl_except_ecc_ls3          (), // not used

      // BIU Interface
      .lsu_biu_rd_req_ls2              (lsu_biu_rd_req),
      .lsu_biu_rd_addr_ls2             (lsu_biu_rd_addr),
      .biu_lsu_rd_ack_ls2              (biu_lsu_rd_ack),
      .biu_lsu_data_valid_ls3          (biu_lsu_data_valid),
      .biu_lsu_data_ls3                (biu_lsu_data),

      .lsu_biu_wr_req_ls2              (lsu_biu_wr_req),
      .lsu_biu_wr_addr_ls2             (lsu_biu_wr_addr),
      .lsu_biu_wr_data_ls2             (lsu_biu_wr_data),
      .lsu_biu_wr_strb_ls2             (lsu_biu_wr_strb),
      .biu_lsu_wr_ack_ls2              (biu_lsu_wr_ack),
      .biu_lsu_wr_fin_ls3              (biu_lsu_write_done)
   );

   //
   // BRU
   //
   
   branch bru (
      .branch_valid                    (ecl_bru_valid_e),
      .branch_op                       (ecl_bru_op_e),
      .branch_a                        (ecl_bru_a_e),
      .branch_b                        (ecl_bru_b_e),
      .branch_pc                       (ecl_bru_pc_e),
      .branch_offset                   (ecl_bru_offset_e),

      .bru_target                      (bru_ecl_brpc_e),
      .bru_taken                       (bru_ecl_br_taken_e),
      .bru_link_pc                     (bru_byp_link_pc_e),
      .bru_wen                         (bru_ecl_wen_e)
      ); 
   

   wire [63:0] mul_a_input = {32'b0, byp_mul_a_e};
   wire [63:0] mul_b_input = {32'b0, byp_mul_b_e};
   wire [63:0] mul_res_output;
   assign mul_byp_res_m = mul_res_output[31:0];
   
   mul64x64 mul(
      .clk                             (clk),
      .rstn                            (resetn),

      .mul_validin                     (ecl_mul_valid_e),
      .ex2_allowin                     (1'b1),
      .mul_validout                    (mul_ecl_64ready),
      .ex1_readygo                     (1'b1),
      .ex2_readygo                     (1'b1),

      .opa                             (mul_a_input),
      .opb                             (mul_b_input),
      .mul_signed                      (ecl_mul_signed_e),
      .mul64                           (ecl_mul_double_e),
      .mul_hi                          (ecl_mul_hi_e),
      .mul_short                       (ecl_mul_short_e),

      .mul_res_out                     (mul_res_output),
      .mul_ready                       (mul_ecl_32ready)
      );


   //
   // CSR
   //

   cpu7_csr csr(
      .clk                             (clk),
      .resetn                          (resetn),
      .csr_rdata                       (csr_byp_rdata_d),
      .csr_raddr                       (ecl_csr_raddr_d),
      .csr_waddr                       (ecl_csr_waddr_m),
      .csr_wdata                       (byp_csr_wdata_m),
      .csr_mask                        (ecl_csr_mask_m),
      .csr_wen                         (ecl_csr_wen_m),

      .csr_eentry                      (exu_ifu_eentry),
      .csr_era                         (exu_ifu_era),

      .ecl_csr_badv_e                  (ecl_csr_badv_e),
      .exu_ifu_except                  (exu_ifu_except),
      .ecl_csr_exccode_e               (ecl_csr_exccode_e),
      .ifu_exu_pc_e                    (ifu_exu_pc_e),
      .ecl_csr_ertn_e                  (ecl_csr_ertn_e),

      .csr_ecl_crmd_ie                 (csr_ecl_crmd_ie),
      .csr_ecl_timer_intr              (csr_ecl_timer_intr),

      .ext_intr                        (ext_intr)  // as HWI0
      );
   
   
   
endmodule // cpu7_exu
