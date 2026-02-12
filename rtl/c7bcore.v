//`include "defines.vh"

module c7bcore(
   input              clk,
   input              resetn,            // active low
   
   input              ext_intr,
   
   output             ifu_icu_req_ic1,
   output [31:0]      ifu_icu_addr_ic1,
   input              icu_ifu_ack_ic1,
   //output             ifu_icu_cancel,
   input  [63:0]      icu_ifu_data_ic2,
   input              icu_ifu_data_valid_ic2,   

   output [31:0]      ifu_biu_rd_addr,
   output             ifu_biu_rd_req,
   input              biu_ifu_rd_ack,
   input              biu_ifu_data_valid,
   input  [63:0]      biu_ifu_data,

   output             lsu_biu_rd_req,
   output [31:0]      lsu_biu_rd_addr,

   input              biu_lsu_rd_ack,
   input              biu_lsu_data_valid,
   input  [63:0]      biu_lsu_data,

   output             lsu_biu_wr_req,
   output [31:0]      lsu_biu_wr_addr,
   output [63:0]      lsu_biu_wr_data,
   output [7:0]       lsu_biu_wr_strb,

   input              biu_lsu_wr_ack,
   input              biu_lsu_write_done
);

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
      
      .ic_en                           (1'b0),

      // icu interface
      .ifu_icu_addr_ic1                (ifu_icu_addr_ic1),
      .ifu_icu_req_ic1                 (ifu_icu_req_ic1),
      .icu_ifu_ack_ic1                 (icu_ifu_ack_ic1),
      .icu_ifu_data_valid_ic2          (icu_ifu_data_valid_ic2),
      .icu_ifu_data_ic2                (icu_ifu_data_ic2),

      // biu interface
      .ifu_biu_rd_addr                 (ifu_biu_rd_addr),
      .ifu_biu_rd_req                  (ifu_biu_rd_req),
      .biu_ifu_rd_ack                  (biu_ifu_rd_ack),
      .biu_ifu_data_valid              (biu_ifu_data_valid),
      .biu_ifu_data                    (biu_ifu_data),

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

   
   c7bexu u_exu(
      .clk                             (clk),
      .resetn                          (resetn),

      .ext_intr                        (ext_intr),
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
