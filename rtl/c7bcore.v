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
   input              icu_ifu_fault_ic2,
   input  [1:0]       icu_ifu_fault_code_ic2,

   output [31:0]      ifu_biu_rd_addr,
   output             ifu_biu_rd_req,
   input              biu_ifu_rd_ack,
   input              biu_ifu_data_valid,
   input  [63:0]      biu_ifu_data,
   input              biu_ifu_fault,
   input  [1:0]       biu_ifu_fault_code,

   output             lsu_biu_rd_req,
   output [31:0]      lsu_biu_rd_addr,

   input              biu_lsu_rd_ack,
   input              biu_lsu_data_valid,
   input  [63:0]      biu_lsu_data,
   input              biu_lsu_fault,
   input  [1:0]       biu_lsu_fault_code,

   output             lsu_biu_wr_req,
   output [31:0]      lsu_biu_wr_addr,
   output [63:0]      lsu_biu_wr_data,
   output [7:0]       lsu_biu_wr_strb,

   input              biu_lsu_wr_ack,
   input              biu_lsu_write_done,
   input              biu_lsu_write_fault,
   input  [1:0]       biu_lsu_write_fault_code
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
   wire ifu_exu_lsu_ibar_d;
   wire ifu_exu_lsu_dbar_d;
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

   // div
   wire ifu_exu_div_vld_d;
   wire ifu_exu_div_signed_d;
   wire ifu_exu_div_mod_d;

   // csr
   wire ifu_exu_csr_vld_d;
   wire [13:0] ifu_exu_csr_raddr_d; // CSR_BIT 14
   wire ifu_exu_csr_xchg_d;
   wire ifu_exu_csr_wen_d;
   wire [13:0] ifu_exu_csr_waddr_d; // CSR_BIT 14
   wire ifu_exu_csr_rdtimel_d;
   wire ifu_exu_csr_rdtimeh_d;

   // ertn
   wire ifu_exu_ertn_vld_d;

   // tlb
   wire ifu_exu_tlb_vld_d;
   wire [3:0] ifu_exu_tlb_op_d; 

   // exc
   wire ifu_exu_exc_vld_d;
   wire [5:0] ifu_exu_exc_code_d;
   wire [8:0] ifu_exu_exc_subcode_d;
   wire [31:0] ifu_exu_exc_badv_d;

   
   wire csr_ifu_ic_en; 
   wire csr_ifu_ic_en_pls;

   wire csr_ifu_crmd_da;
   wire csr_ifu_crmd_pg;

   wire [2:0] csr_ifu_dmw0_pseg;
   wire [2:0] csr_ifu_dmw0_vseg;
   wire [2:0] csr_ifu_dmw1_pseg;
   wire [2:0] csr_ifu_dmw1_vseg;

   wire [18:0] csr_itlb_tlbehi_vppn;

   wire        csr_itlb_tlbidx_ne;
   wire [5:0]  csr_itlb_tlbidx_ps;
   wire        csr_itlb_tlbidx_i_d;
   wire [4:0]  csr_itlb_tlbidx_index;

   wire [19:0] csr_itlb_tlbelo0_ppn;
   wire        csr_itlb_tlbelo0_g;
   wire [1:0]  csr_itlb_tlbelo0_mat;
   wire [1:0]  csr_itlb_tlbelo0_plv;
   wire        csr_itlb_tlbelo0_d;
   wire        csr_itlb_tlbelo0_v;

   wire [19:0] csr_itlb_tlbelo1_ppn;
   wire        csr_itlb_tlbelo1_g;
   wire [1:0]  csr_itlb_tlbelo1_mat;
   wire [1:0]  csr_itlb_tlbelo1_plv;
   wire        csr_itlb_tlbelo1_d;
   wire        csr_itlb_tlbelo1_v;
   wire [9:0]  csr_itlb_asid_asid;

   wire        csr_itlb_tlbrefill_ctx; 

   wire [1:0]  csr_itlb_crmd_plv;

   wire [4:0]  exu_itlb_random_index;

   wire        exu_itlb_tlbfill_vld_e;
   wire        exu_itlb_tlbwr_vld_e;
   wire        exu_itlb_tlbsrch_vld_e;
   wire        exu_itlb_invtlb_vld_e;

   wire [4:0]  exu_itlb_invtlb_op_e;
   wire [9:0]  exu_itlb_invtlb_asid_e;
   wire [18:0] exu_itlb_invtlb_vppn_e;

   // itlb to csr
   wire [4:0]  itlb_csr_tlbidx_index;
   wire [18:0] itlb_csr_tlbehi_vppn;
   wire        itlb_csr_tlbelo_g;
   wire [5:0]  itlb_csr_tlbidx_ps;
   wire        itlb_csr_tlbidx_e;
   wire        itlb_csr_tlbelo0_v;
   wire        itlb_csr_tlbelo0_d;
   wire [1:0]  itlb_csr_tlbelo0_mat;
   wire [1:0]  itlb_csr_tlbelo0_plv;
   wire [19:0] itlb_csr_tlbelo0_ppn;
   wire        itlb_csr_tlbelo1_v;
   wire        itlb_csr_tlbelo1_d;
   wire [1:0]  itlb_csr_tlbelo1_mat;
   wire [1:0]  itlb_csr_tlbelo1_plv;
   wire [19:0] itlb_csr_tlbelo1_ppn;
   wire [9:0]  itlb_csr_asid_asid;


   c7bifu u_ifu(
      .clk                             (clk),
      .resetn                          (resetn),
      
      .csr_ifu_ic_en                   (csr_ifu_ic_en),
      .csr_ifu_ic_en_pls               (csr_ifu_ic_en_pls),

      // icu interface
      .ifu_icu_addr_ic1                (ifu_icu_addr_ic1),
      .ifu_icu_req_ic1                 (ifu_icu_req_ic1),
      .icu_ifu_ack_ic1                 (icu_ifu_ack_ic1),
      .icu_ifu_data_valid_ic2          (icu_ifu_data_valid_ic2),
      .icu_ifu_data_ic2                (icu_ifu_data_ic2),

      .icu_ifu_fault_ic2               (icu_ifu_fault_ic2),
      .icu_ifu_fault_code_ic2          (icu_ifu_fault_code_ic2),

      // biu interface
      .ifu_biu_rd_addr                 (ifu_biu_rd_addr),
      .ifu_biu_rd_req                  (ifu_biu_rd_req),
      .biu_ifu_rd_ack                  (biu_ifu_rd_ack),
      .biu_ifu_data_valid              (biu_ifu_data_valid),
      .biu_ifu_data                    (biu_ifu_data),
      .biu_ifu_fault                   (biu_ifu_fault),
      .biu_ifu_fault_code              (biu_ifu_fault_code),

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
      .ifu_exu_lsu_ibar_d              (ifu_exu_lsu_ibar_d),
      .ifu_exu_lsu_dbar_d              (ifu_exu_lsu_dbar_d),
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

      // div
      .ifu_exu_div_vld_d               (ifu_exu_div_vld_d),
      .ifu_exu_div_signed_d            (ifu_exu_div_signed_d),
      .ifu_exu_div_mod_d               (ifu_exu_div_mod_d),

      // csr
      .ifu_exu_csr_vld_d               (ifu_exu_csr_vld_d),
      .ifu_exu_csr_raddr_d             (ifu_exu_csr_raddr_d),
      .ifu_exu_csr_xchg_d              (ifu_exu_csr_xchg_d),
      .ifu_exu_csr_wen_d               (ifu_exu_csr_wen_d),
      .ifu_exu_csr_waddr_d             (ifu_exu_csr_waddr_d),
      .ifu_exu_csr_rdtimel_d           (ifu_exu_csr_rdtimel_d),
      .ifu_exu_csr_rdtimeh_d           (ifu_exu_csr_rdtimeh_d),

      // ertn
      .ifu_exu_ertn_vld_d              (ifu_exu_ertn_vld_d),

      // tlb
      .ifu_exu_tlb_vld_d               (ifu_exu_tlb_vld_d),
      .ifu_exu_tlb_op_d                (ifu_exu_tlb_op_d),

      // exc
      .ifu_exu_exc_vld_d               (ifu_exu_exc_vld_d),
      .ifu_exu_exc_code_d              (ifu_exu_exc_code_d),
      .ifu_exu_exc_subcode_d           (ifu_exu_exc_subcode_d),
      .ifu_exu_exc_badv_d              (ifu_exu_exc_badv_d),

      .csr_ifu_crmd_da                 (csr_ifu_crmd_da),
      .csr_ifu_crmd_pg                 (csr_ifu_crmd_pg),

      .csr_ifu_dmw0_pseg               (csr_ifu_dmw0_pseg),
      .csr_ifu_dmw0_vseg               (csr_ifu_dmw0_vseg),
      .csr_ifu_dmw1_pseg               (csr_ifu_dmw1_pseg),
      .csr_ifu_dmw1_vseg               (csr_ifu_dmw1_vseg),

      .csr_itlb_tlbehi_vppn            (csr_itlb_tlbehi_vppn),

      .csr_itlb_tlbidx_ne              (csr_itlb_tlbidx_ne),
      .csr_itlb_tlbidx_ps              (csr_itlb_tlbidx_ps),
      .csr_itlb_tlbidx_i_d             (csr_itlb_tlbidx_i_d),
      .csr_itlb_tlbidx_index           (csr_itlb_tlbidx_index),

      .csr_itlb_tlbelo0_ppn            (csr_itlb_tlbelo0_ppn),
      .csr_itlb_tlbelo0_g              (csr_itlb_tlbelo0_g),
      .csr_itlb_tlbelo0_mat            (csr_itlb_tlbelo0_mat),
      .csr_itlb_tlbelo0_plv            (csr_itlb_tlbelo0_plv),
      .csr_itlb_tlbelo0_d              (csr_itlb_tlbelo0_d),
      .csr_itlb_tlbelo0_v              (csr_itlb_tlbelo0_v),

      .csr_itlb_tlbelo1_ppn            (csr_itlb_tlbelo1_ppn),
      .csr_itlb_tlbelo1_g              (csr_itlb_tlbelo1_g),
      .csr_itlb_tlbelo1_mat            (csr_itlb_tlbelo1_mat),
      .csr_itlb_tlbelo1_plv            (csr_itlb_tlbelo1_plv),
      .csr_itlb_tlbelo1_d              (csr_itlb_tlbelo1_d),
      .csr_itlb_tlbelo1_v              (csr_itlb_tlbelo1_v),

      .csr_itlb_asid_asid              (csr_itlb_asid_asid),

      .csr_itlb_tlbrefill_ctx          (csr_itlb_tlbrefill_ctx),

      .csr_itlb_crmd_plv               (csr_itlb_crmd_plv),

      .exu_itlb_random_index           (exu_itlb_random_index),

      .exu_itlb_tlbfill_vld_e          (exu_itlb_tlbfill_vld_e), 
      .exu_itlb_tlbwr_vld_e            (exu_itlb_tlbwr_vld_e),
      .exu_itlb_tlbsrch_vld_e          (exu_itlb_tlbsrch_vld_e),
      .exu_itlb_invtlb_vld_e           (exu_itlb_invtlb_vld_e),

      .exu_itlb_invtlb_op_e            (exu_itlb_invtlb_op_e),
      .exu_itlb_invtlb_asid_e          (exu_itlb_invtlb_asid_e),
      .exu_itlb_invtlb_vppn_e          (exu_itlb_invtlb_vppn_e),

      .itlb_csr_tlbidx_index           (itlb_csr_tlbidx_index),
      .itlb_csr_tlbehi_vppn            (itlb_csr_tlbehi_vppn),
      .itlb_csr_tlbelo_g               (itlb_csr_tlbelo_g),
      .itlb_csr_tlbidx_ps              (itlb_csr_tlbidx_ps),
      .itlb_csr_tlbidx_e               (itlb_csr_tlbidx_e),
      .itlb_csr_tlbelo0_v              (itlb_csr_tlbelo0_v),
      .itlb_csr_tlbelo0_d              (itlb_csr_tlbelo0_d),
      .itlb_csr_tlbelo0_mat            (itlb_csr_tlbelo0_mat),
      .itlb_csr_tlbelo0_plv            (itlb_csr_tlbelo0_plv),
      .itlb_csr_tlbelo0_ppn            (itlb_csr_tlbelo0_ppn),
      .itlb_csr_tlbelo1_v              (itlb_csr_tlbelo1_v),
      .itlb_csr_tlbelo1_d              (itlb_csr_tlbelo1_d),
      .itlb_csr_tlbelo1_mat            (itlb_csr_tlbelo1_mat),
      .itlb_csr_tlbelo1_plv            (itlb_csr_tlbelo1_plv),
      .itlb_csr_tlbelo1_ppn            (itlb_csr_tlbelo1_ppn),
      .itlb_csr_asid_asid              (itlb_csr_asid_asid) 
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
      .ifu_exu_lsu_ibar_d              (ifu_exu_lsu_ibar_d),
      .ifu_exu_lsu_dbar_d              (ifu_exu_lsu_dbar_d),
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

      // div
      .ifu_exu_div_vld_d               (ifu_exu_div_vld_d),
      .ifu_exu_div_signed_d            (ifu_exu_div_signed_d),
      .ifu_exu_div_mod_d               (ifu_exu_div_mod_d),

      // csr
      .ifu_exu_csr_vld_d               (ifu_exu_csr_vld_d),
      .ifu_exu_csr_raddr_d             (ifu_exu_csr_raddr_d),
      .ifu_exu_csr_xchg_d              (ifu_exu_csr_xchg_d),
      .ifu_exu_csr_wen_d               (ifu_exu_csr_wen_d),
      .ifu_exu_csr_waddr_d             (ifu_exu_csr_waddr_d),
      .ifu_exu_csr_rdtimel_d           (ifu_exu_csr_rdtimel_d),
      .ifu_exu_csr_rdtimeh_d           (ifu_exu_csr_rdtimeh_d),

      // ertn
      .ifu_exu_ertn_vld_d              (ifu_exu_ertn_vld_d),

      // tlb
      .ifu_exu_tlb_vld_d               (ifu_exu_tlb_vld_d),
      .ifu_exu_tlb_op_d                (ifu_exu_tlb_op_d),

      // exc
      .ifu_exu_exc_vld_d               (ifu_exu_exc_vld_d),
      .ifu_exu_exc_code_d              (ifu_exu_exc_code_d),
      .ifu_exu_exc_subcode_d           (ifu_exu_exc_subcode_d),
      .ifu_exu_exc_badv_d              (ifu_exu_exc_badv_d),

      // biu interface
      .lsu_biu_rd_req                  (lsu_biu_rd_req),
      .lsu_biu_rd_addr                 (lsu_biu_rd_addr),
      .biu_lsu_rd_ack                  (biu_lsu_rd_ack),
      .biu_lsu_data_vld                (biu_lsu_data_valid),
      .biu_lsu_data                    (biu_lsu_data),
      .biu_lsu_fault                   (biu_lsu_fault),
      .biu_lsu_fault_code              (biu_lsu_fault_code),

      .lsu_biu_wr_req                  (lsu_biu_wr_req),
      .lsu_biu_wr_addr                 (lsu_biu_wr_addr),
      .lsu_biu_wr_data                 (lsu_biu_wr_data),
      .lsu_biu_wr_strb                 (lsu_biu_wr_strb),
      .biu_lsu_wr_ack                  (biu_lsu_wr_ack),
      .biu_lsu_wr_fin                  (biu_lsu_write_done),
      .biu_lsu_wr_fault                (biu_lsu_write_fault),
      .biu_lsu_wr_fault_code           (biu_lsu_write_fault_code),

      .csr_ifu_ic_en                   (csr_ifu_ic_en),
      .csr_ifu_ic_en_pls               (csr_ifu_ic_en_pls),

      .csr_ifu_crmd_da                 (csr_ifu_crmd_da),
      .csr_ifu_crmd_pg                 (csr_ifu_crmd_pg),

      .csr_ifu_dmw0_pseg               (csr_ifu_dmw0_pseg),
      .csr_ifu_dmw0_vseg               (csr_ifu_dmw0_vseg),
      .csr_ifu_dmw1_pseg               (csr_ifu_dmw1_pseg),
      .csr_ifu_dmw1_vseg               (csr_ifu_dmw1_vseg),

      .csr_itlb_tlbehi_vppn            (csr_itlb_tlbehi_vppn),

      .csr_itlb_tlbidx_ne              (csr_itlb_tlbidx_ne),
      .csr_itlb_tlbidx_ps              (csr_itlb_tlbidx_ps),
      .csr_itlb_tlbidx_i_d             (csr_itlb_tlbidx_i_d),
      .csr_itlb_tlbidx_index           (csr_itlb_tlbidx_index),

      .csr_itlb_tlbelo0_ppn            (csr_itlb_tlbelo0_ppn),
      .csr_itlb_tlbelo0_g              (csr_itlb_tlbelo0_g),
      .csr_itlb_tlbelo0_mat            (csr_itlb_tlbelo0_mat),
      .csr_itlb_tlbelo0_plv            (csr_itlb_tlbelo0_plv),
      .csr_itlb_tlbelo0_d              (csr_itlb_tlbelo0_d),
      .csr_itlb_tlbelo0_v              (csr_itlb_tlbelo0_v),

      .csr_itlb_tlbelo1_ppn            (csr_itlb_tlbelo1_ppn),
      .csr_itlb_tlbelo1_g              (csr_itlb_tlbelo1_g),
      .csr_itlb_tlbelo1_mat            (csr_itlb_tlbelo1_mat),
      .csr_itlb_tlbelo1_plv            (csr_itlb_tlbelo1_plv),
      .csr_itlb_tlbelo1_d              (csr_itlb_tlbelo1_d),
      .csr_itlb_tlbelo1_v              (csr_itlb_tlbelo1_v), 

      .csr_itlb_asid_asid              (csr_itlb_asid_asid),

      .csr_itlb_tlbrefill_ctx          (csr_itlb_tlbrefill_ctx),

      .csr_itlb_crmd_plv               (csr_itlb_crmd_plv),

      .exu_itlb_random_index           (exu_itlb_random_index),

      .exu_itlb_tlbfill_vld_e          (exu_itlb_tlbfill_vld_e), 
      .exu_itlb_tlbwr_vld_e            (exu_itlb_tlbwr_vld_e),
      .exu_itlb_tlbsrch_vld_e          (exu_itlb_tlbsrch_vld_e),
      .exu_itlb_invtlb_vld_e           (exu_itlb_invtlb_vld_e),

      .exu_itlb_invtlb_op_e            (exu_itlb_invtlb_op_e),
      .exu_itlb_invtlb_asid_e          (exu_itlb_invtlb_asid_e),
      .exu_itlb_invtlb_vppn_e          (exu_itlb_invtlb_vppn_e),

      .itlb_csr_tlbidx_index           (itlb_csr_tlbidx_index),
      .itlb_csr_tlbehi_vppn            (itlb_csr_tlbehi_vppn),
      .itlb_csr_tlbelo_g               (itlb_csr_tlbelo_g),
      .itlb_csr_tlbidx_ps              (itlb_csr_tlbidx_ps),
      .itlb_csr_tlbidx_e               (itlb_csr_tlbidx_e),
      .itlb_csr_tlbelo0_v              (itlb_csr_tlbelo0_v),
      .itlb_csr_tlbelo0_d              (itlb_csr_tlbelo0_d),
      .itlb_csr_tlbelo0_mat            (itlb_csr_tlbelo0_mat),
      .itlb_csr_tlbelo0_plv            (itlb_csr_tlbelo0_plv),
      .itlb_csr_tlbelo0_ppn            (itlb_csr_tlbelo0_ppn),
      .itlb_csr_tlbelo1_v              (itlb_csr_tlbelo1_v),
      .itlb_csr_tlbelo1_d              (itlb_csr_tlbelo1_d),
      .itlb_csr_tlbelo1_mat            (itlb_csr_tlbelo1_mat),
      .itlb_csr_tlbelo1_plv            (itlb_csr_tlbelo1_plv),
      .itlb_csr_tlbelo1_ppn            (itlb_csr_tlbelo1_ppn),
      .itlb_csr_asid_asid              (itlb_csr_asid_asid) 
   );

endmodule // cpu7
