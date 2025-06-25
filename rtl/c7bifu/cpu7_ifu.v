`include "../defines.vh"
`include "../decoded.vh"

module cpu7_ifu(
   input                               clock,
   input                               resetn,
   input  [31:0]                       pc_init,

   output                              ifu_icu_req_ic1,
   output [31:0]                       ifu_icu_addr_ic1,
   input                               icu_ifu_ack_ic1,
   output                              ifu_icu_cancel,
   input  [63:0]                       icu_ifu_data_ic2,
   input                               icu_ifu_data_valid_ic2,   

   input                               exu_ifu_br_taken,
   input  [31:0]                       exu_ifu_br_target,

   // exception
   input  [`GRLEN-1:0]                 exu_ifu_eentry,
   input                               exu_ifu_except,
   // ertn
   input  [`GRLEN-1:0]                 exu_ifu_era,
   input                               exu_ifu_ertn_e,
   
   output                              ifu_exu_valid_e,

   output [`GRLEN-1:0]                 ifu_exu_alu_a_e,
   output [`GRLEN-1:0]                 ifu_exu_alu_b_e,
   output [`LSOC1K_ALU_CODE_BIT-1:0]   ifu_exu_alu_op_e,
   output [`GRLEN-1:0]                 ifu_exu_alu_c_e,
   output                              ifu_exu_alu_double_word_e,
   output                              ifu_exu_alu_b_imm_e,

   output [4:0]                        ifu_exu_rs1_d,
   output [4:0]                        ifu_exu_rs2_d,
   output [4:0]                        ifu_exu_rs1_e,
   output [4:0]                        ifu_exu_rs2_e,

   input  [`GRLEN-1:0]                 exu_ifu_rs1_data_d,
   input  [`GRLEN-1:0]                 exu_ifu_rs2_data_d,

   // lsu
   output                              ifu_exu_lsu_valid_e,
   output [`LSOC1K_LSU_CODE_BIT-1:0]   ifu_exu_lsu_op_e,
   output                              ifu_exu_double_read_e,
   output [`GRLEN-1:0]                 ifu_exu_imm_shifted_e,
   output [4:0]                        ifu_exu_lsu_rd_e,
   output                              ifu_exu_lsu_wen_e,

   // bru
   output                               ifu_exu_bru_valid_e,
   output [`LSOC1K_BRU_CODE_BIT-1:0]    ifu_exu_bru_op_e,
   output [`GRLEN-1:0]                  ifu_exu_bru_offset_e,

   // mul
   output                               ifu_exu_mul_valid_e,
   output                               ifu_exu_mul_wen_e,
   output                               ifu_exu_mul_signed_e,
   output                               ifu_exu_mul_double_e,
   output                               ifu_exu_mul_hi_e,
   output                               ifu_exu_mul_short_e,

   // csr
   output                               ifu_exu_csr_valid_e,
   output [`LSOC1K_CSR_BIT-1:0]         ifu_exu_csr_raddr_d,
   output                               ifu_exu_csr_rdwen_e,
   output                               ifu_exu_csr_xchg_e,
   output                               ifu_exu_csr_wen_e,
   output [`LSOC1K_CSR_BIT-1:0]         ifu_exu_csr_waddr_e,

   // alu
   output [4:0]                         ifu_exu_rf_target_e,
   output                               ifu_exu_alu_wen_e,
   // ertn
   output                               ifu_exu_ertn_valid_e,

//   output                               ifu_exu_illinst_e,
   output                               ifu_exu_exception_e,
   output [5:0]                         ifu_exu_exccode_e,


   output [`GRLEN-1:0]                 ifu_exu_pc_w,
   output [`GRLEN-1:0]                 ifu_exu_pc_e,

   input                               exu_ifu_stall_req
   );


   wire [31:0] fdp_dec_inst_d;
   wire [31:0] fdp_dec_pc_d;
   wire fdp_dec_inst_kill_vld_d;


   cpu7_ifu_fdp fdp(
      .clk                      (clock                ),
      .reset                    (~resetn              ),

      .pc_init                  (pc_init              ),

      .br_taken                 (exu_ifu_br_taken     ),
      .br_target                (exu_ifu_br_target    ),

      // exception
      .exu_ifu_eentry           (exu_ifu_eentry       ),
      .exu_ifu_except           (exu_ifu_except       ),
      // ertn
      .exu_ifu_era              (exu_ifu_era          ),
      .exu_ifu_ertn_e           (exu_ifu_ertn_e       ),


      .ifu_icu_req_ic1          (ifu_icu_req_ic1      ),
      .ifu_icu_addr_ic1         (ifu_icu_addr_ic1     ),
      .icu_ifu_ack_ic1          (icu_ifu_ack_ic1      ),      
      .ifu_icu_cancel           (ifu_icu_cancel       ),

      .icu_ifu_data_ic2         (icu_ifu_data_ic2     ),
      .icu_ifu_data_valid_ic2   (icu_ifu_data_valid_ic2),


      .fdp_dec_pc_d             (fdp_dec_pc_d         ),
      .fdp_dec_inst_d           (fdp_dec_inst_d       ),

      .fdp_dec_inst_kill_vld_d  (fdp_dec_inst_kill_vld_d),

      .ifu_exu_valid_e          (ifu_exu_valid_e      ),

      .ifu_exu_pc_w             (ifu_exu_pc_w         ),
      .ifu_exu_pc_e             (ifu_exu_pc_e         ),

      .exu_ifu_stall_req        (exu_ifu_stall_req    )
      );


   cpu7_ifu_dec dec(
      .clk                      (clock                    ),
      .resetn                   (resetn                   ),

      .fdp_dec_inst_d           (fdp_dec_inst_d           ),

      .fdp_dec_pc_d             (fdp_dec_pc_d             ),
      .fdp_dec_inst_kill_vld_d  (fdp_dec_inst_kill_vld_d  ),

      .ifu_exu_alu_a_e          (ifu_exu_alu_a_e          ), 
      .ifu_exu_alu_b_e          (ifu_exu_alu_b_e          ), 
      .ifu_exu_alu_op_e         (ifu_exu_alu_op_e         ), 
      .ifu_exu_alu_c_e          (ifu_exu_alu_c_e          ), 
      .ifu_exu_alu_double_word_e(ifu_exu_alu_double_word_e),
      .ifu_exu_alu_b_imm_e      (ifu_exu_alu_b_imm_e      ),
      .ifu_exu_rs1_d            (ifu_exu_rs1_d            ),
      .ifu_exu_rs2_d            (ifu_exu_rs2_d            ),
      .ifu_exu_rs1_e            (ifu_exu_rs1_e            ),
      .ifu_exu_rs2_e            (ifu_exu_rs2_e            ),

      .exu_ifu_rs1_data_d       (exu_ifu_rs1_data_d       ),
      .exu_ifu_rs2_data_d       (exu_ifu_rs2_data_d       ),

      // lsu
      .ifu_exu_lsu_valid_e      (ifu_exu_lsu_valid_e      ), 
      .ifu_exu_lsu_op_e         (ifu_exu_lsu_op_e         ),
      .ifu_exu_double_read_e    (ifu_exu_double_read_e    ),
      .ifu_exu_imm_shifted_e    (ifu_exu_imm_shifted_e    ),
      .ifu_exu_lsu_rd_e         (ifu_exu_lsu_rd_e         ),
      .ifu_exu_lsu_wen_e        (ifu_exu_lsu_wen_e        ),

      // bru
      .ifu_exu_bru_valid_e      (ifu_exu_bru_valid_e      ),
      .ifu_exu_bru_op_e         (ifu_exu_bru_op_e         ),
      .ifu_exu_bru_offset_e     (ifu_exu_bru_offset_e     ),

      // mul
      .ifu_exu_mul_valid_e      (ifu_exu_mul_valid_e      ),
      .ifu_exu_mul_wen_e        (ifu_exu_mul_wen_e        ),
      .ifu_exu_mul_signed_e     (ifu_exu_mul_signed_e     ),
      .ifu_exu_mul_double_e     (ifu_exu_mul_double_e     ),
      .ifu_exu_mul_hi_e         (ifu_exu_mul_hi_e         ),
      .ifu_exu_mul_short_e      (ifu_exu_mul_short_e      ),

      // csr
      .ifu_exu_csr_valid_e      (ifu_exu_csr_valid_e      ),
      .ifu_exu_csr_raddr_d      (ifu_exu_csr_raddr_d      ),
      .ifu_exu_csr_rdwen_e      (ifu_exu_csr_rdwen_e      ),
      .ifu_exu_csr_xchg_e       (ifu_exu_csr_xchg_e       ),
      .ifu_exu_csr_wen_e        (ifu_exu_csr_wen_e        ),
      .ifu_exu_csr_waddr_e      (ifu_exu_csr_waddr_e      ),

      // alu
      .ifu_exu_rf_target_e      (ifu_exu_rf_target_e      ),
      .ifu_exu_alu_wen_e        (ifu_exu_alu_wen_e        ),
                                                     
      // ertn                    
      .ifu_exu_ertn_valid_e     (ifu_exu_ertn_valid_e     ),

      //.ifu_exu_illinst_e        (ifu_exu_illinst_e        )
      .ifu_exu_exception_e      (ifu_exu_exception_e      ),
      .ifu_exu_exccode_e        (ifu_exu_exccode_e        )
      );

   
endmodule // cpu7_ifu
