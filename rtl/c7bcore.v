//`include "defines.vh"

module c7bcore(
   input                 clk,
   input                 resetn,            // active low
   
   input                 ext_intr,
   
   output                ifu_icu_req_ic1,
   output [31:0]         ifu_icu_addr_ic1,
   input                 icu_ifu_ack_ic1,
   //output                ifu_icu_cancel,
   input  [63:0]         icu_ifu_data_ic2,
   input                 icu_ifu_data_valid_ic2,   

   output                lsu_biu_rd_req,
   output [31:0]         lsu_biu_rd_addr,

   input                 biu_lsu_rd_ack,
   input                 biu_lsu_data_valid,
   input  [63:0]         biu_lsu_data,

   output                lsu_biu_wr_req,
   output [31:0]         lsu_biu_wr_addr,
   output [63:0]         lsu_biu_wr_data,
   output [7:0]          lsu_biu_wr_strb,

   input                 biu_lsu_wr_ack,
   input                 biu_lsu_write_done
);


//   wire [31:0] ifu_exu_pc_w;
//   wire [31:0] ifu_exu_pc_e;
//
//   wire        exu_ifu_stall_req;
//
//   wire [31:0] exu_ifu_brpc_e;
//   wire        exu_ifu_br_taken_e;
//
//   // exception
//   wire [31:0] exu_ifu_eentry;
//   wire        exu_ifu_except;
//   // ertn
//   wire [31:0] exu_ifu_era;
//   wire        exu_ifu_ertn_e;
//   
//
//
//   wire        ifu_exu_valid_e;
//   
//   wire [31:0] ifu_exu_alu_a_e;
//   wire [31:0] ifu_exu_alu_b_e;
//   wire [5:0]  ifu_exu_alu_op_e;
//   wire [31:0] ifu_exu_alu_c_e;
//   wire        ifu_exu_alu_double_word_e;
//   wire        ifu_exu_alu_b_imm_e;
//
//   wire [4:0]  ifu_exu_rs1_d;
//   wire [4:0]  ifu_exu_rs2_d;
//   wire [4:0]  ifu_exu_rs1_e;
//   wire [4:0]  ifu_exu_rs2_e;
//
//   wire [31:0] exu_ifu_rs1_data_d;
//   wire [31:0] exu_ifu_rs2_data_d;
//
//   // lsu
//   wire        ifu_exu_lsu_valid_e;
//   wire [6:0]  ifu_exu_lsu_op_e;
//   wire        ifu_exu_double_read_e;
//   wire [31:0] ifu_exu_imm_shifted_e;
//   wire [4:0]  ifu_exu_lsu_rd_e;
//   wire        ifu_exu_lsu_wen_e;
//
//   // bru
//   wire        ifu_exu_bru_valid_e;
//   wire [3:0]  ifu_exu_bru_op_e;
//   wire [31:0] ifu_exu_bru_offset_e;
//
//   // mul
//   wire        ifu_exu_mul_valid_e;
//   wire        ifu_exu_mul_wen_e;
//   wire        ifu_exu_mul_signed_e;
//   wire        ifu_exu_mul_double_e;
//   wire        ifu_exu_mul_hi_e;
//   wire        ifu_exu_mul_short_e;
//
//   // csr
//   wire        ifu_exu_csr_valid_e;
//   wire [13:0] ifu_exu_csr_raddr_d;
//   wire        ifu_exu_csr_rdwen_e;
//   wire        ifu_exu_csr_xchg_e;
//   wire        ifu_exu_csr_wen_e;
//   wire [13:0] ifu_exu_csr_waddr_e;
//
//   // alu
//   wire [4:0]  ifu_exu_rf_target_e;
//   wire        ifu_exu_alu_wen_e;
//   // ertn
//   wire        ifu_exu_ertn_valid_e;
//
//   //wire        ifu_exu_illinst_e;
//   wire        ifu_exu_exception_e;
//   wire [5:0]  ifu_exu_exccode_e;
//
//
//   cpu7_ifu ifu(
//      .clock                             (clk),
//      .resetn                            (resetn),
//
//      .pc_init                           (32'h1c000000),
//
//      .ifu_icu_req_ic1                   (ifu_icu_req_ic1),
//      .ifu_icu_addr_ic1                  (ifu_icu_addr_ic1),
//      .icu_ifu_ack_ic1                   (icu_ifu_ack_ic1),      
//      .ifu_icu_cancel                    (ifu_icu_cancel),
//
//      .icu_ifu_data_ic2                  (icu_ifu_data_ic2),
//      .icu_ifu_data_valid_ic2            (icu_ifu_data_valid_ic2),
//
//      .exu_ifu_br_taken                  (exu_ifu_br_taken_e), // BUG, need to change name
//      .exu_ifu_br_target                 (exu_ifu_brpc_e),
//
//      // exception
//      .exu_ifu_eentry                    (exu_ifu_eentry),
//      .exu_ifu_except                    (exu_ifu_except),
//      // ertn
//      .exu_ifu_era                       (exu_ifu_era),
//      .exu_ifu_ertn_e                    (exu_ifu_ertn_e),
//
//      .ifu_exu_valid_e                   (ifu_exu_valid_e),
//
//      .ifu_exu_alu_a_e                   (ifu_exu_alu_a_e), 
//      .ifu_exu_alu_b_e                   (ifu_exu_alu_b_e), 
//      .ifu_exu_alu_op_e                  (ifu_exu_alu_op_e), 
//      .ifu_exu_alu_c_e                   (ifu_exu_alu_c_e), 
//      .ifu_exu_alu_double_word_e         (ifu_exu_alu_double_word_e),
//      .ifu_exu_alu_b_imm_e               (ifu_exu_alu_b_imm_e),
//      .ifu_exu_rs1_d                     (ifu_exu_rs1_d),
//      .ifu_exu_rs2_d                     (ifu_exu_rs2_d),
//      .ifu_exu_rs1_e                     (ifu_exu_rs1_e),
//      .ifu_exu_rs2_e                     (ifu_exu_rs2_e),
//
//      .exu_ifu_rs1_data_d                (exu_ifu_rs1_data_d),
//      .exu_ifu_rs2_data_d                (exu_ifu_rs2_data_d),
//
//      // lsu
//      .ifu_exu_lsu_valid_e               (ifu_exu_lsu_valid_e), 
//      .ifu_exu_lsu_op_e                  (ifu_exu_lsu_op_e),
//      .ifu_exu_double_read_e             (ifu_exu_double_read_e),
//      .ifu_exu_imm_shifted_e             (ifu_exu_imm_shifted_e),
//      .ifu_exu_lsu_rd_e                  (ifu_exu_lsu_rd_e),
//      .ifu_exu_lsu_wen_e                 (ifu_exu_lsu_wen_e),
//
//      // bru
//      .ifu_exu_bru_valid_e               (ifu_exu_bru_valid_e),
//      .ifu_exu_bru_op_e                  (ifu_exu_bru_op_e),
//      .ifu_exu_bru_offset_e              (ifu_exu_bru_offset_e),
//
//      // mul
//      .ifu_exu_mul_valid_e               (ifu_exu_mul_valid_e),
//      .ifu_exu_mul_wen_e                 (ifu_exu_mul_wen_e),
//      .ifu_exu_mul_signed_e              (ifu_exu_mul_signed_e),
//      .ifu_exu_mul_double_e              (ifu_exu_mul_double_e),
//      .ifu_exu_mul_hi_e                  (ifu_exu_mul_hi_e),
//      .ifu_exu_mul_short_e               (ifu_exu_mul_short_e),
//
//      // csr
//      .ifu_exu_csr_valid_e               (ifu_exu_csr_valid_e),
//      .ifu_exu_csr_raddr_d               (ifu_exu_csr_raddr_d),
//      .ifu_exu_csr_rdwen_e               (ifu_exu_csr_rdwen_e),
//      .ifu_exu_csr_xchg_e                (ifu_exu_csr_xchg_e),
//      .ifu_exu_csr_wen_e                 (ifu_exu_csr_wen_e),
//      .ifu_exu_csr_waddr_e               (ifu_exu_csr_waddr_e),
//
//      // alu
//      .ifu_exu_rf_target_e               (ifu_exu_rf_target_e),
//      .ifu_exu_alu_wen_e                 (ifu_exu_alu_wen_e),
//                                                              
//      // ertn                             
//      .ifu_exu_ertn_valid_e              (ifu_exu_ertn_valid_e),
//
//      //.ifu_exu_illinst_e                 (ifu_exu_illinst_e),
//      .ifu_exu_exception_e               (ifu_exu_exception_e),
//      .ifu_exu_exccode_e                 (ifu_exu_exccode_e),
//
//
//      .ifu_exu_pc_w                      (ifu_exu_pc_w),
//      .ifu_exu_pc_e                      (ifu_exu_pc_e),
//
//      .exu_ifu_stall_req                 (exu_ifu_stall_req)
//      );

   wire exu_ifu_except;
   wire [31:0] exu_ifu_isr_addr;
   wire exu_ifu_branch;
   wire [31:0] exu_ifu_brn_addr;
   wire exu_ifu_ertn;
   wire [31:0] exu_ifu_ert_addr;
   wire exu_ifu_stall;

   wire ifu_exu_vld_d;
   wire [31:0] ifu_exu_pc_d;
   wire [4:0] ifu_exu_rs1_d;
   wire [4:0] ifu_exu_rs2_d;
   wire [4:0] ifu_exu_rd_d;
   wire ifu_exu_wen_d;
   wire [31:0] ifu_exu_imm_shifted_d;

   // alu
   wire ifu_exu_alu_vld_d;
   wire [5:0] ifu_exu_alu_op_d; // ALU_CODE_BIT 6
   wire ifu_exu_alu_a_pc_d;
   wire [31:0] ifu_exu_alu_c_d;
   wire ifu_exu_alu_double_word_d;
   wire ifu_exu_alu_b_imm_d;

   // lsu
   wire ifu_exu_lsu_vld_d;
   wire [6:0] ifu_exu_lsu_op_d; // LSU_CODE_BIT 7
   wire ifu_exu_lsu_double_read_d;

   // bru
   wire ifu_exu_bru_vld_d;
   wire [3:0] ifu_exu_bru_op_d; // BRU_CODE_BIT 4
   wire [31:0] ifu_exu_bru_offset_d;

   // mul
   wire ifu_exu_mul_vld_d;
   wire ifu_exu_mul_signed_d;
   wire ifu_exu_mul_double_d;
   wire ifu_exu_mul_hi_d;
   wire ifu_exu_mul_short_d;

   // csr
   wire ifu_exu_csr_vld_d;
   wire [13:0] ifu_exu_csr_raddr_d; // CSR_BIT 14
   wire ifu_exu_csr_xchg_d;
   wire ifu_exu_csr_wen_d;
   wire [13:0] ifu_exu_csr_waddr_d; // CSR_BIT 14

   // ertn
   wire ifu_exu_ertn_vld_d;

   // exc
   wire ifu_exu_exc_vld_d;
   wire [5:0] ifu_exu_exc_code_d;


   c7bifu u_ifu(
      .clk                             (clk),
      .resetn                          (resetn),
      
      // icu interface
      .ifu_icu_addr_ic1                (ifu_icu_addr_ic1),
      .ifu_icu_req_ic1                 (ifu_icu_req_ic1),
      .icu_ifu_ack_ic1                 (icu_ifu_ack_ic1),
      .icu_ifu_data_valid_ic2          (icu_ifu_data_valid_ic2),
      .icu_ifu_data_ic2                (icu_ifu_data_ic2),

      //
      .exu_ifu_except                  (exu_ifu_except),
      .exu_ifu_isr_addr                (exu_ifu_isr_addr),
      .exu_ifu_branch                  (exu_ifu_branch),
      .exu_ifu_brn_addr                (exu_ifu_brn_addr),
      .exu_ifu_ertn                    (exu_ifu_ertn),
      .exu_ifu_ert_addr                (exu_ifu_ert_addr),
      .exu_ifu_stall                   (exu_ifu_stall),

      .ifu_exu_vld_d                   (ifu_exu_vld_d),
      .ifu_exu_pc_d                    (ifu_exu_pc_d),
      .ifu_exu_rs1_d                   (ifu_exu_rs1_d),
      .ifu_exu_rs2_d                   (ifu_exu_rs2_d),
      .ifu_exu_rd_d                    (ifu_exu_rd_d),
      .ifu_exu_wen_d                   (ifu_exu_wen_d),
      .ifu_exu_imm_shifted_d           (ifu_exu_imm_shifted_d),

      // alu
      .ifu_exu_alu_vld_d               (ifu_exu_alu_vld_d),
      .ifu_exu_alu_op_d                (ifu_exu_alu_op_d),
      .ifu_exu_alu_a_pc_d              (ifu_exu_alu_a_pc_d),
      .ifu_exu_alu_c_d                 (ifu_exu_alu_c_d),
      .ifu_exu_alu_double_word_d       (ifu_exu_alu_double_word_d),
      .ifu_exu_alu_b_imm_d             (ifu_exu_alu_b_imm_d),

      // lsu
      .ifu_exu_lsu_vld_d               (ifu_exu_lsu_vld_d),
      .ifu_exu_lsu_op_d                (ifu_exu_lsu_op_d),
      .ifu_exu_lsu_double_read_d       (ifu_exu_lsu_double_read_d),

      // bru
      .ifu_exu_bru_vld_d               (ifu_exu_bru_vld_d),
      .ifu_exu_bru_op_d                (ifu_exu_bru_op_d),
      .ifu_exu_bru_offset_d            (ifu_exu_bru_offset_d),

      // mul
      .ifu_exu_mul_vld_d               (ifu_exu_mul_vld_d),
      .ifu_exu_mul_signed_d            (ifu_exu_mul_signed_d),
      .ifu_exu_mul_double_d            (ifu_exu_mul_double_d),
      .ifu_exu_mul_hi_d                (ifu_exu_mul_hi_d),
      .ifu_exu_mul_short_d             (ifu_exu_mul_short_d),

      // csr
      .ifu_exu_csr_vld_d               (ifu_exu_csr_vld_d),
      .ifu_exu_csr_raddr_d             (ifu_exu_csr_raddr_d),
      .ifu_exu_csr_xchg_d              (ifu_exu_csr_xchg_d),
      .ifu_exu_csr_wen_d               (ifu_exu_csr_wen_d),
      .ifu_exu_csr_waddr_d             (ifu_exu_csr_waddr_d),

      // ertn
      .ifu_exu_ertn_vld_d              (ifu_exu_ertn_vld_d),

      // exc
      .ifu_exu_exc_vld_d               (ifu_exu_exc_vld_d),
      .ifu_exu_exc_code_d              (ifu_exu_exc_code_d)
   );

//   cpu7_exu exu(
//      .clk                               (clk),
//      .resetn                            (resetn),
//      
//      .ifu_exu_valid_e                   (ifu_exu_valid_e),
//
//      .ifu_exu_alu_a_e                   (ifu_exu_alu_a_e), 
//      .ifu_exu_alu_b_e                   (ifu_exu_alu_b_e), 
//      .ifu_exu_alu_op_e                  (ifu_exu_alu_op_e), 
//      .ifu_exu_alu_c_e                   (ifu_exu_alu_c_e), 
//      .ifu_exu_alu_double_word_e         (ifu_exu_alu_double_word_e),
//      .ifu_exu_alu_b_imm_e               (ifu_exu_alu_b_imm_e),
//      .ifu_exu_rs1_d                     (ifu_exu_rs1_d),
//      .ifu_exu_rs2_d                     (ifu_exu_rs2_d),
//      .ifu_exu_rs1_e                     (ifu_exu_rs1_e),
//      .ifu_exu_rs2_e                     (ifu_exu_rs2_e),
//
//      .exu_ifu_rs1_data_d                (exu_ifu_rs1_data_d),
//      .exu_ifu_rs2_data_d                (exu_ifu_rs2_data_d),
//
//      // lsu
//      .ifu_exu_lsu_valid_e               (ifu_exu_lsu_valid_e), 
//      .ifu_exu_lsu_op_e                  (ifu_exu_lsu_op_e),
//      .ifu_exu_double_read_e             (ifu_exu_double_read_e),
//      .ifu_exu_imm_shifted_e             (ifu_exu_imm_shifted_e),
//      .ifu_exu_lsu_rd_e                  (ifu_exu_lsu_rd_e),
//      .ifu_exu_lsu_wen_e                 (ifu_exu_lsu_wen_e),
//
//      // bru
//      .ifu_exu_bru_valid_e               (ifu_exu_bru_valid_e),
//      .ifu_exu_bru_op_e                  (ifu_exu_bru_op_e),
//      .ifu_exu_bru_offset_e              (ifu_exu_bru_offset_e),
//
//      // mul
//      .ifu_exu_mul_valid_e               (ifu_exu_mul_valid_e),
//      .ifu_exu_mul_wen_e                 (ifu_exu_mul_wen_e),
//      .ifu_exu_mul_signed_e              (ifu_exu_mul_signed_e),
//      .ifu_exu_mul_double_e              (ifu_exu_mul_double_e),
//      .ifu_exu_mul_hi_e                  (ifu_exu_mul_hi_e),
//      .ifu_exu_mul_short_e               (ifu_exu_mul_short_e),
//
//      // csr
//      .ifu_exu_csr_valid_e               (ifu_exu_csr_valid_e),
//      .ifu_exu_csr_raddr_d               (ifu_exu_csr_raddr_d),
//      .ifu_exu_csr_rdwen_e               (ifu_exu_csr_rdwen_e),
//      .ifu_exu_csr_xchg_e                (ifu_exu_csr_xchg_e),
//      .ifu_exu_csr_wen_e                 (ifu_exu_csr_wen_e),
//      .ifu_exu_csr_waddr_e               (ifu_exu_csr_waddr_e),
//
//      // alu
//      .ifu_exu_rf_target_e               (ifu_exu_rf_target_e),
//      .ifu_exu_alu_wen_e                 (ifu_exu_alu_wen_e),
//                                                              
//      // ertn                             
//      .ifu_exu_ertn_valid_e              (ifu_exu_ertn_valid_e),
//
//      //.ifu_exu_illinst_e                 (ifu_exu_illinst_e),
//      .ifu_exu_exception_e               (ifu_exu_exception_e),
//      .ifu_exu_exccode_e                 (ifu_exu_exccode_e),
//
//
//      .ifu_exu_pc_w                      (ifu_exu_pc_w),
//      .ifu_exu_pc_e                      (ifu_exu_pc_e),
//
//      // memory interface
//      .lsu_biu_rd_req                    (lsu_biu_rd_req),
//      .lsu_biu_rd_addr                   (lsu_biu_rd_addr),
//
//      .biu_lsu_rd_ack                    (biu_lsu_rd_ack),
//      .biu_lsu_data_valid                (biu_lsu_data_valid),
//      .biu_lsu_data                      (biu_lsu_data),
//
//      .lsu_biu_wr_req                    (lsu_biu_wr_req),
//      .lsu_biu_wr_addr                   (lsu_biu_wr_addr),
//      .lsu_biu_wr_data                   (lsu_biu_wr_data),
//      .lsu_biu_wr_strb                   (lsu_biu_wr_strb),
//
//      .biu_lsu_wr_ack                    (biu_lsu_wr_ack),
//      .biu_lsu_write_done                (biu_lsu_write_done),
//
//
//      
//      .exu_ifu_stall_req                 (exu_ifu_stall_req),
//
//      .exu_ifu_brpc_e                    (exu_ifu_brpc_e),
//      .exu_ifu_br_taken_e                (exu_ifu_br_taken_e),
//
//      //exception
//      .exu_ifu_eentry                    (exu_ifu_eentry),
//      .exu_ifu_except                    (exu_ifu_except),
//      //ertn
//      .exu_ifu_era                       (exu_ifu_era),
//      .exu_ifu_ertn_e                    (exu_ifu_ertn_e),
//
//      .ext_intr                          (ext_intr) // ext_intr will be synced at exu_ecl, intr_all_sync
//      );
   
   // to do: ext_intr
   c7bexu u_exu(
      .clk                             (clk),
      .resetn                          (resetn),

      //
      .exu_ifu_except                  (exu_ifu_except),
      .exu_ifu_isr_addr                (exu_ifu_isr_addr),
      .exu_ifu_branch                  (exu_ifu_branch),
      .exu_ifu_brn_addr                (exu_ifu_brn_addr),
      .exu_ifu_ertn                    (exu_ifu_ertn),
      .exu_ifu_ert_addr                (exu_ifu_ert_addr),
      .exu_ifu_stall                   (exu_ifu_stall),

      .ifu_exu_vld_d                   (ifu_exu_vld_d),
      .ifu_exu_pc_d                    (ifu_exu_pc_d),
      .ifu_exu_rs1_d                   (ifu_exu_rs1_d),
      .ifu_exu_rs2_d                   (ifu_exu_rs2_d),
      .ifu_exu_rd_d                    (ifu_exu_rd_d),
      .ifu_exu_wen_d                   (ifu_exu_wen_d),
      .ifu_exu_imm_shifted_d           (ifu_exu_imm_shifted_d),

      // alu
      .ifu_exu_alu_vld_d               (ifu_exu_alu_vld_d),
      .ifu_exu_alu_op_d                (ifu_exu_alu_op_d),
      .ifu_exu_alu_a_pc_d              (ifu_exu_alu_a_pc_d),
      .ifu_exu_alu_c_d                 (ifu_exu_alu_c_d),
      .ifu_exu_alu_double_word_d       (ifu_exu_alu_double_word_d),
      .ifu_exu_alu_b_imm_d             (ifu_exu_alu_b_imm_d),

      // lsu
      .ifu_exu_lsu_vld_d               (ifu_exu_lsu_vld_d),
      .ifu_exu_lsu_op_d                (ifu_exu_lsu_op_d),
      .ifu_exu_lsu_double_read_d       (ifu_exu_lsu_double_read_d),

      // bru
      .ifu_exu_bru_vld_d               (ifu_exu_bru_vld_d),
      .ifu_exu_bru_op_d                (ifu_exu_bru_op_d),
      .ifu_exu_bru_offset_d            (ifu_exu_bru_offset_d),

      // mul
      .ifu_exu_mul_vld_d               (ifu_exu_mul_vld_d),
      .ifu_exu_mul_signed_d            (ifu_exu_mul_signed_d),
      .ifu_exu_mul_double_d            (ifu_exu_mul_double_d),
      .ifu_exu_mul_hi_d                (ifu_exu_mul_hi_d),
      .ifu_exu_mul_short_d             (ifu_exu_mul_short_d),

      // csr
      .ifu_exu_csr_vld_d               (ifu_exu_csr_vld_d),
      .ifu_exu_csr_raddr_d             (ifu_exu_csr_raddr_d),
      .ifu_exu_csr_xchg_d              (ifu_exu_csr_xchg_d),
      .ifu_exu_csr_wen_d               (ifu_exu_csr_wen_d),
      .ifu_exu_csr_waddr_d             (ifu_exu_csr_waddr_d),

      // ertn
      .ifu_exu_ertn_vld_d              (ifu_exu_ertn_vld_d),

      // exc
      .ifu_exu_exc_vld_d               (ifu_exu_exc_vld_d),
      .ifu_exu_exc_code_d              (ifu_exu_exc_code_d),

      // biu interface
      .lsu_biu_rd_req                  (lsu_biu_rd_req),
      .lsu_biu_rd_addr                 (lsu_biu_rd_addr),
      .biu_lsu_rd_ack                  (biu_lsu_rd_ack),
      .biu_lsu_data_vld                (biu_lsu_data_valid),
      .biu_lsu_data                    (biu_lsu_data),

      .lsu_biu_wr_req                  (lsu_biu_wr_req),
      .lsu_biu_wr_addr                 (lsu_biu_wr_addr),
      .lsu_biu_wr_data                 (lsu_biu_wr_data),
      .lsu_biu_wr_strb                 (lsu_biu_wr_strb),
      .biu_lsu_wr_ack                  (biu_lsu_wr_ack),
      .biu_lsu_wr_fin                  (biu_lsu_write_done)
   );

endmodule // cpu7
