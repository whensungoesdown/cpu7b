`include "common.vh"
`include "decoded.vh"

module cpu7_core(
   input                 clk,
   input                 resetn,            //low active
   
   input                 ext_intr,
   
   output                inst_req       ,
   input                 inst_ack       ,
   output  [ 31:0]       inst_addr      ,
   output                inst_cancel    ,
   input                 inst_addr_ok   ,
   input   [`GRLEN-1:0]  inst_rdata_f   ,
   input                 inst_valid_f   ,
   input   [  1:0]       inst_count     ,
   input                 inst_uncache   ,
   input   [  5:0]       inst_exccode   ,
   input                 inst_exception ,


   output                lsu_biu_rd_req,
   output [`GRLEN-1:0]   lsu_biu_rd_addr,

   input                 biu_lsu_rd_ack,
   input                 biu_lsu_data_valid,
   input  [31:0]         biu_lsu_data,

   output                lsu_biu_wr_req,
   output [`GRLEN-1:0]   lsu_biu_wr_addr,
   output [31:0]         lsu_biu_wr_data,
   output [3:0]          lsu_biu_wr_strb,

   input                 biu_lsu_wr_ack,
   input                 biu_lsu_write_done
);


   wire [`GRLEN-1:0]                 ifu_exu_pc_w;
   wire [`GRLEN-1:0]                 ifu_exu_pc_e;

   wire                              exu_ifu_stall_req;

   wire [`GRLEN-1:0]                 exu_ifu_brpc_e;
   wire                              exu_ifu_br_taken_e;

   // exception
   wire [`GRLEN-1:0]                 exu_ifu_eentry;
   wire                              exu_ifu_except;
   // ertn
   wire [`GRLEN-1:0]                 exu_ifu_era;
   wire                              exu_ifu_ertn_e;
   


   wire                              ifu_exu_valid_e;
   
   wire [`GRLEN-1:0]                 ifu_exu_alu_a_e;
   wire [`GRLEN-1:0]                 ifu_exu_alu_b_e;
   wire [`LSOC1K_ALU_CODE_BIT-1:0]   ifu_exu_alu_op_e;
   wire [`GRLEN-1:0]                 ifu_exu_alu_c_e;
   wire                              ifu_exu_alu_double_word_e;
   wire                              ifu_exu_alu_b_imm_e;

   wire [4:0]                        ifu_exu_rs1_d;
   wire [4:0]                        ifu_exu_rs2_d;
   wire [4:0]                        ifu_exu_rs1_e;
   wire [4:0]                        ifu_exu_rs2_e;

   wire [`GRLEN-1:0]                 exu_ifu_rs1_data_d;
   wire [`GRLEN-1:0]                 exu_ifu_rs2_data_d;

   // lsu
   wire                              ifu_exu_lsu_valid_e;
   wire [`LSOC1K_LSU_CODE_BIT-1:0]   ifu_exu_lsu_op_e;
   wire                              ifu_exu_double_read_e;
   wire [`GRLEN-1:0]                 ifu_exu_imm_shifted_e;
   wire [4:0]                        ifu_exu_lsu_rd_e;
   wire                              ifu_exu_lsu_wen_e;

   // bru
   wire                              ifu_exu_bru_valid_e;
   wire [`LSOC1K_BRU_CODE_BIT-1:0]   ifu_exu_bru_op_e;
   wire [`GRLEN-1:0]                 ifu_exu_bru_offset_e;

   // mul
   wire                              ifu_exu_mul_valid_e;
   wire                              ifu_exu_mul_wen_e;
   wire                              ifu_exu_mul_signed_e;
   wire                              ifu_exu_mul_double_e;
   wire                              ifu_exu_mul_hi_e;
   wire                              ifu_exu_mul_short_e;

   // csr
   wire                              ifu_exu_csr_valid_e;
   wire [`LSOC1K_CSR_BIT-1:0]        ifu_exu_csr_raddr_d;
   wire                              ifu_exu_csr_rdwen_e;
   wire                              ifu_exu_csr_xchg_e;
   wire                              ifu_exu_csr_wen_e;
   wire [`LSOC1K_CSR_BIT-1:0]        ifu_exu_csr_waddr_e;

   // alu
   wire [4:0]                        ifu_exu_rf_target_e;
   wire                              ifu_exu_alu_wen_e;
   // ertn
   wire                              ifu_exu_ertn_valid_e;

   //wire                              ifu_exu_illinst_e;
   wire                              ifu_exu_exception_e;
   wire [5:0]                        ifu_exu_exccode_e;

   
   cpu7_ifu ifu(
      .clock                   (clk                ),
      .resetn                  (resetn             ),

      .pc_init                 (`GRLEN'h1c000000   ),

      .inst_addr               (inst_addr          ),
      .inst_addr_ok            (inst_addr_ok       ),
      .inst_cancel             (inst_cancel        ),
      .inst_count              (inst_count         ),
      .inst_ex                 (inst_exception     ),
      .inst_exccode            (inst_exccode       ),
      .inst_rdata_f            (inst_rdata_f       ),
      .inst_req                (inst_req           ),
      .inst_ack                (inst_ack           ),
      .inst_uncache            (inst_uncache       ),
      .inst_valid_f            (inst_valid_f       ),

      .exu_ifu_br_taken        (exu_ifu_br_taken_e ), // BUG, need to change name
      .exu_ifu_br_target       (exu_ifu_brpc_e     ),

      // exception
      .exu_ifu_eentry          (exu_ifu_eentry       ),
      .exu_ifu_except          (exu_ifu_except       ),
      // ertn
      .exu_ifu_era             (exu_ifu_era          ),
      .exu_ifu_ertn_e          (exu_ifu_ertn_e       ),

      .ifu_exu_valid_e         (ifu_exu_valid_e      ),

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

      //.ifu_exu_illinst_e        (ifu_exu_illinst_e        ),
      .ifu_exu_exception_e      (ifu_exu_exception_e      ),
      .ifu_exu_exccode_e        (ifu_exu_exccode_e        ),


      .ifu_exu_pc_w            (ifu_exu_pc_w         ),
      .ifu_exu_pc_e            (ifu_exu_pc_e         ),

      .exu_ifu_stall_req       (exu_ifu_stall_req    )

      );


   

   cpu7_exu exu(
      .clk                     (clk                  ),
      .resetn                  (resetn               ),
      
      .ifu_exu_valid_e         (ifu_exu_valid_e      ),

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

      //.ifu_exu_illinst_e        (ifu_exu_illinst_e        ),
      .ifu_exu_exception_e      (ifu_exu_exception_e      ),
      .ifu_exu_exccode_e        (ifu_exu_exccode_e        ),


      .ifu_exu_pc_w             (ifu_exu_pc_w             ),
      .ifu_exu_pc_e             (ifu_exu_pc_e             ),

      // memory interface
      .lsu_biu_rd_req           (lsu_biu_rd_req           ),
      .lsu_biu_rd_addr          (lsu_biu_rd_addr          ),

      .biu_lsu_rd_ack           (biu_lsu_rd_ack           ),
      .biu_lsu_data_valid       (biu_lsu_data_valid       ),
      .biu_lsu_data             (biu_lsu_data             ),

      .lsu_biu_wr_req           (lsu_biu_wr_req           ),
      .lsu_biu_wr_addr          (lsu_biu_wr_addr          ),
      .lsu_biu_wr_data          (lsu_biu_wr_data          ),
      .lsu_biu_wr_strb          (lsu_biu_wr_strb          ),

      .biu_lsu_wr_ack           (biu_lsu_wr_ack           ),
      .biu_lsu_write_done       (biu_lsu_write_done       ),


      
      .exu_ifu_stall_req        (exu_ifu_stall_req        ),

      .exu_ifu_brpc_e           (exu_ifu_brpc_e           ),
      .exu_ifu_br_taken_e       (exu_ifu_br_taken_e       ),

      //exception
      .exu_ifu_eentry           (exu_ifu_eentry           ),
      .exu_ifu_except           (exu_ifu_except           ),
      //ertn
      .exu_ifu_era              (exu_ifu_era              ),
      .exu_ifu_ertn_e           (exu_ifu_ertn_e           ),

      .ext_intr                 (ext_intr                 )
      );
   
endmodule // cpu7
