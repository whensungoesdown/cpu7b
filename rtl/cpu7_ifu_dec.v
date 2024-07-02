`include "common.vh"
`include "decoded.vh"

module cpu7_ifu_dec(
   input                                clk,
   input                                resetn,
   input  [31:0]                        fdp_dec_inst_d,

   input [`GRLEN-1:0]                   fdp_dec_pc_d,
   input                                fdp_dec_inst_vld_kill_d,

   output [`GRLEN-1:0]                  ifu_exu_alu_a_e,
   output [`GRLEN-1:0]                  ifu_exu_alu_b_e,
   output [`LSOC1K_ALU_CODE_BIT-1:0]    ifu_exu_alu_op_e,
   output [`GRLEN-1:0]                  ifu_exu_alu_c_e,
   output                               ifu_exu_alu_double_word_e,
   output                               ifu_exu_alu_b_imm_e,

   output [4:0]                         ifu_exu_rs1_d,
   output [4:0]                         ifu_exu_rs2_d,
   output [4:0]                         ifu_exu_rs1_e,
   output [4:0]                         ifu_exu_rs2_e,

   input  [`GRLEN-1:0]                  exu_ifu_rs1_data_d,
   input  [`GRLEN-1:0]                  exu_ifu_rs2_data_d,

   // lsu
   output                               ifu_exu_lsu_valid_e,
   output [`LSOC1K_LSU_CODE_BIT-1:0]    ifu_exu_lsu_op_e,
   output                               ifu_exu_double_read_e,
   output [`GRLEN-1:0]                  ifu_exu_imm_shifted_e,
   output [4:0]                         ifu_exu_lsu_rd_e,
   output                               ifu_exu_lsu_wen_e,

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
   
   output                               ifu_exu_illinst_e
   );


   wire int_except = 1'b0;
   wire fdp_dec_exception = 1'b0;
   wire [5 :0] fdp_dec_exccode = 6'b0;

   wire [`LSOC1K_DECODE_RES_BIT-1:0] op_d;

   wire alu_dispatch_d;
   wire lsu_dispatch_d; 
   wire bru_dispatch_d;
   wire mul_dispatch_d; 
   wire div_dispatch_d; 
   wire none_dispatch_d;
   wire ertn_dispatch_d;


   ////func
   decoder u_decoder(.inst(fdp_dec_inst_d), .res(op_d)); //decode the inst

   //reg file related
   wire rf_wen0 = op_d[`LSOC1K_GR_WEN];

   wire [4:0] waddr0 = (op_d[`LSOC1K_BRU_RELATED] && (op_d[`LSOC1K_BRU_CODE] == `LSOC1K_BRU_BL)) ? 5'd1 : `GET_RD(fdp_dec_inst_d);


////// crash check
//// exception
////wire port0_fpd = !csr_output[`LSOC1K_CSR_OUTPUT_EUEN_FPE] && op_d[`LSOC1K_FLOAT];
////
////`ifdef LA64
////wire port0_ipe = ((csr_output[`LSOC1K_CSR_OUTPUT_CRMD_PLV] == 2'd1) && csr_output[`LSOC1K_CSR_OUTPUT_MISC_DRDTL1] && op_d[`LSOC1K_RDTIME]) ||
////                 ((csr_output[`LSOC1K_CSR_OUTPUT_CRMD_PLV] == 2'd2) && csr_output[`LSOC1K_CSR_OUTPUT_MISC_DRDTL2] && op_d[`LSOC1K_RDTIME]) ||
////                 ((csr_output[`LSOC1K_CSR_OUTPUT_CRMD_PLV] == 2'd3) && csr_output[`LSOC1K_CSR_OUTPUT_MISC_DRDTL3] && op_d[`LSOC1K_RDTIME]) ;
////`elsif LA32
////wire port0_ipe = 1'B0;//(csr_output[`LSOC1K_CSR_OUTPUT_CRMD_PLV] != 2'd0) && (op_d[`LSOC1K_CSR_READ] || op_d[`LSOC1K_CACHE_RELATED] || op_d[`LSOC1K_TLB_RELATED] || op_d[`LSOC1K_WAIT] || op_d[`LSOC1K_ERET]);
////
////`endif
//
//
//// uty: review
//// here, port0_exception and port0_excccode both use fdp_dec_exception
//// it may actually need to use ifu_exu_exception_d instead
//// wait until debugging exception code
//   
////wire port0_exception = fdp_dec_exception   || op_d[`LSOC1K_SYSCALL] || op_d[`LSOC1K_BREAK ] || op_d[`LSOC1K_INE] ||
////                       port0_fpd || port0_ipe || int_except;
//wire port0_exception = fdp_dec_exception   || op_d[`LSOC1K_SYSCALL] || op_d[`LSOC1K_BREAK ] || op_d[`LSOC1K_INE] || int_except;
//   
////
////wire [5:0] port0_exccode = int_except                ? `EXC_INT          :
////                           fdp_dec_exception       ? fdp_dec_exccode : 
////                           op_d[`LSOC1K_SYSCALL] ? `EXC_SYS          :
////                           op_d[`LSOC1K_BREAK  ] ? `EXC_BRK          :
////                           op_d[`LSOC1K_INE    ] ? `EXC_INE          :
////                           port0_fpd                 ? `EXC_FPD          :
////                                                       6'd0              ;
//wire [5:0] port0_exccode = int_except                ? `EXC_INT          :
//                           fdp_dec_exception         ? fdp_dec_exccode   : 
//                           op_d[`LSOC1K_SYSCALL] ? `EXC_SYS          :
//                           op_d[`LSOC1K_BREAK  ] ? `EXC_BRK          :
//                           op_d[`LSOC1K_INE    ] ? `EXC_INE          :
//                                                       6'd0              ;


// ifu_exu_exception_e
// ifu_exu_exccode_e

   wire [4:0] rf_target_d; 
   wire rf_wen_d;


   assign rf_wen_d = rf_wen0;
   assign rf_target_d = {5{rf_wen0}}&waddr0;


   wire [`GRLEN-1:0] alu_c_d;
   wire [`GRLEN-1:0] imm_shifted_d;
   wire [`GRLEN-1:0] br_offs_d;


   // cpu7_ifu_imd, decode offset imm
   cpu7_ifu_imd u_imd(
      .inst              (fdp_dec_inst_d        ),
      .op                (op_d                  ),
      .imm_shifted       (imm_shifted_d         ),
      .alu_c             (alu_c_d               ),
      .br_offs           (br_offs_d             )
      );
   

   assign alu_dispatch_d  = !op_d[`LSOC1K_LSU_RELATED] && !op_d[`LSOC1K_BRU_RELATED] && !op_d[`LSOC1K_MUL_RELATED] && !op_d[`LSOC1K_DIV_RELATED] && !op_d[`LSOC1K_CSR_RELATED] && fdp_dec_inst_vld_kill_d; // && !port0_exception; // alu0 is binded to port0
   assign lsu_dispatch_d  = op_d[`LSOC1K_LSU_RELATED] && fdp_dec_inst_vld_kill_d; // && !port0_exception;
   assign bru_dispatch_d  = op_d[`LSOC1K_BRU_RELATED] && fdp_dec_inst_vld_kill_d; // && !port0_exception;
   assign mul_dispatch_d  = op_d[`LSOC1K_MUL_RELATED] && fdp_dec_inst_vld_kill_d; // && !port0_exception;
   assign div_dispatch_d  = op_d[`LSOC1K_DIV_RELATED] && fdp_dec_inst_vld_kill_d; // && !port0_exception;
   assign none_dispatch_d = (op_d[`LSOC1K_CSR_RELATED] || op_d[`LSOC1K_TLB_RELATED] || op_d[`LSOC1K_CACHE_RELATED]) && fdp_dec_inst_vld_kill_d; // || port0_exception ;
   assign ertn_dispatch_d = op_d[`LSOC1K_ERET] && fdp_dec_inst_vld_kill_d;


   ////register interface
   // common registers

   wire [4:0] rs1_d;
   wire [4:0] rs2_d;

   assign rs1_d = op_d[`LSOC1K_RD2RJ  ] ? `GET_RD(fdp_dec_inst_d) : `GET_RJ(fdp_dec_inst_d);
   assign rs2_d = op_d[`LSOC1K_RD_READ] ? `GET_RD(fdp_dec_inst_d) : `GET_RK(fdp_dec_inst_d);

   assign ifu_exu_rs1_d = rs1_d;
   assign ifu_exu_rs2_d = rs2_d;


   // code review illinst exception should go through excode
   wire illinst_d;
   wire illinst_e;

   // illegal instruction exception
   assign illinst_d = op_d[`LSOC1K_INE] && fdp_dec_inst_vld_kill_d;
   
   dff_s #(1) illinst_d2e_reg (
      .din (illinst_d),
      .clk (clk),
      .q   (illinst_e),
      .se(), .si(), .so());

//   assign ecl_csr_illinst_e = illinst_e;
   assign ifu_exu_illinst_e = illinst_e;




   /////////////////////////
   // ALU parameters
   /////////////////////////
   
   
   wire [`LSOC1K_ALU_CODE_BIT-1:0] alu_op_d = op_d[`LSOC1K_ALU_CODE];



   // those imm and rs1 rs2 should be handle in cpu7_exu_byp 
   
   ////ALU input
   //A:
   wire alu_a_zero = op_d[`LSOC1K_LUI];// op_rdpgpr_1 || op_wrpgpr_1; //zero
   wire alu_a_pc = op_d[`LSOC1K_PC_RELATED];

   //B:
   //wire alu_b_imm = op_d[`LSOC1K_I5] || op_d[`LSOC1K_I12] || op_d[`LSOC1K_I16] || op_d[`LSOC1K_I20];
   wire alu_b_imm_d = (op_d[`LSOC1K_I5] || op_d[`LSOC1K_I12] || op_d[`LSOC1K_I16] || op_d[`LSOC1K_I20]) & alu_dispatch_d;

   //wire ecl_alu_b_get_a = op_d[`LSOC1K_ALU_CODE] == `LSOC1K_ALU_EXT;



   wire [`GRLEN-1:0] alu_a_d = alu_a_pc? fdp_dec_pc_d : exu_ifu_rs1_data_d;
   wire [`GRLEN-1:0] alu_b_d = alu_b_imm_d? imm_shifted_d : exu_ifu_rs2_data_d;


   wire alu_double_word_d = op_d[`LSOC1K_DOUBLE_WORD];
   
   wire [`GRLEN-1:0] alu_a_e;

   dff_s #(`GRLEN) alu_a_d2e_reg (
      .din (alu_a_d),
      .clk (clk),
      .q   (alu_a_e),
      .se(), .si(), .so());

   assign ifu_exu_alu_a_e = alu_a_e;
   

   wire [`GRLEN-1:0] alu_b_e;

   dff_s #(`GRLEN) alu_b_d2e_reg (
      .din (alu_b_d),
      .clk (clk),
      .q   (alu_b_e),
      .se(), .si(), .so());
   
   assign ifu_exu_alu_b_e = alu_b_e;
   

   wire [`LSOC1K_ALU_CODE_BIT-1:0] alu_op_e;

   dff_s #(`LSOC1K_ALU_CODE_BIT) alu_op_d2e_reg (
      .din (alu_op_d),
      .clk (clk),
      .q   (alu_op_e),
      .se(), .si(), .so());

   assign ifu_exu_alu_op_e = alu_op_e;


   wire [`GRLEN-1:0] alu_c_e;

   dff_s #(`GRLEN) alu_c_d2e_reg (
      .din (alu_c_d),
      .clk (clk),
      .q   (alu_c_e),
      .se(), .si(), .so());
   
   assign ifu_exu_alu_c_e = alu_c_e;

   
   wire alu_double_word_e;

   dff_s #(1) alu_double_word_d2e_reg (
      .din (alu_double_word_d),
      .clk (clk),
      .q   (alu_double_word_e),
      .se(), .si(), .so());

   assign ifu_exu_alu_double_word_e = alu_double_word_e;


   wire alu_b_imm_e;

   dff_s #(1) alu_b_imm_d2e_reg (
      .din (alu_b_imm_d),
      .clk (clk),
      .q   (alu_b_imm_e),
      .se(), .si(), .so());

   assign ifu_exu_alu_b_imm_e = alu_b_imm_e;


   //
   // Bypass logic
   //

   wire [4:0] rs1_e;

   dff_s #(5) rs1_d2e_reg (
      //.din (ecl_irf_rs1_d),
      .din (rs1_d),
      .clk (clk),
      .q   (rs1_e),
      .se(), .si(), .so());

   assign ifu_exu_rs1_e = rs1_e; 
   

   wire [4:0] rs2_e;

   dff_s #(5) rs2_d2e_reg (
      //.din (ecl_irf_rs2_d),
      .din (rs2_d),
      .clk (clk),
      .q   (rs2_e),
      .se(), .si(), .so());

   assign ifu_exu_rs2_e = rs2_e;

   

   //
   // LSU
   //


   wire lsu_valid_d;
   wire lsu_valid_e;
   
   assign lsu_valid_d = lsu_dispatch_d; // & ifu_exu_valid_d; 
   
   dff_s #(1) lsu_valid_d2e_reg (
      .din (lsu_valid_d),
      .clk (clk),
      .q   (lsu_valid_e),
      .se(), .si(), .so());
   
   assign ifu_exu_lsu_valid_e = lsu_valid_e;



   wire [`LSOC1K_LSU_CODE_BIT-1:0] lsu_op_d;
   wire [`LSOC1K_LSU_CODE_BIT-1:0] lsu_op_e;

   assign lsu_op_d = op_d[`LSOC1K_OP_CODE];
   
   dff_s #(`LSOC1K_LSU_CODE_BIT) lsu_op_d2e_reg (
      .din (lsu_op_d),
      .clk (clk),
      .q   (lsu_op_e),
      .se(), .si(), .so());

   assign ifu_exu_lsu_op_e = lsu_op_e;


   wire double_read_d;
   wire double_read_e;

   assign double_read_d = op_d[`LSOC1K_DOUBLE_READ] & lsu_dispatch_d;

   dff_s #(1) double_read_d2e_reg (
      .din (double_read_d),
      .clk (clk),
      .q   (double_read_e),
      .se(), .si(), .so());

   assign ifu_exu_double_read_e = double_read_e;


   wire [`GRLEN-1:0] imm_shifted_e;

   dff_s #(`GRLEN) imm_shifted_d2e_reg (
      .din (imm_shifted_d),
      .clk (clk),
      .q   (imm_shifted_e),
      .se(), .si(), .so());

   assign ifu_exu_imm_shifted_e = imm_shifted_e;



   wire [4:0] lsu_rd_d;
   wire [4:0] lsu_rd_e;
 
   assign lsu_rd_d = rf_target_d;
 
   dff_s #(5) lsu_rd_d2e_reg (
      .din (lsu_rd_d),
      .clk (clk),
      .q   (lsu_rd_e),
      .se(), .si(), .so());

   assign ifu_exu_lsu_rd_e = lsu_rd_e;



   wire lsu_wen_d;
   wire lsu_wen_e;
   
   //assign lsu_wen_d = rf_wen_d;
   assign lsu_wen_d = rf_wen_d & lsu_dispatch_d;
   
   dff_s #(1) lsu_wen_d2e_reg (
      .din (lsu_wen_d),
      .clk (clk),
      .q   (lsu_wen_e),
      .se(), .si(), .so());

   assign ifu_exu_lsu_wen_e = lsu_wen_e;


   //
   // BRU
   //
   
   wire bru_valid_d;
   wire bru_valid_e;

   assign bru_valid_d = bru_dispatch_d; // & ifu_exu_valid_d;

   dff_s #(1) bru_valid_d2e_reg (
      .din (bru_valid_d),
      .clk (clk),
      .q   (bru_valid_e),
      .se(), .si(), .so());

   assign ifu_exu_bru_valid_e = bru_valid_e;


   wire [`LSOC1K_BRU_CODE_BIT-1:0] bru_op_d;
   wire [`LSOC1K_BRU_CODE_BIT-1:0] bru_op_e;

   assign bru_op_d = op_d[`LSOC1K_BRU_CODE];
   
   dff_s #(`LSOC1K_BRU_CODE_BIT) bru_op_d2e_reg (
      .din (bru_op_d),
      .clk (clk),
      .q   (bru_op_e),
      .se(), .si(), .so());

   assign ifu_exu_bru_op_e = bru_op_e;


   wire [`GRLEN-1:0] bru_offset_d;
   wire [`GRLEN-1:0] bru_offset_e;

   assign bru_offset_d = br_offs_d;

   dff_s #(`GRLEN) bru_offset_d2e_reg (
      .din (bru_offset_d),
      .clk (clk),
      .q   (bru_offset_e),
      .se(), .si(), .so());

   assign ifu_exu_bru_offset_e = bru_offset_e;



   //
   // MUL
   //

   wire mul_wen_d;
   wire mul_wen_e;

   assign mul_wen_d = rf_wen_d & mul_dispatch_d;

   dff_s #(1) mul_wen_d2e_reg (
      .din (mul_wen_d),
      .clk (clk),
      .q   (mul_wen_e),
      .se(), .si(), .so());

   assign ifu_exu_mul_wen_e = mul_wen_e;




   wire mul_valid_d;
   wire mul_valid_e;

   assign mul_valid_d = mul_dispatch_d;
 
   dff_s #(1) mul_valid_d2e_reg (
      .din (mul_valid_d),
      .clk (clk),
      .q   (mul_valid_e),
      .se(), .si(), .so());

   assign ifu_exu_mul_valid_e = mul_valid_e;



   wire [`LSOC1K_MDU_CODE_BIT-1:0] mul_op_d;
   assign mul_op_d = op_d[`LSOC1K_MDU_CODE];

   wire mul_signed_d;
   wire mul_signed_e;

   wire mul_double_d;
   wire mul_double_e;

   wire mul_hi_d;
   wire mul_hi_e;

   wire mul_short_d;
   wire mul_short_e;
   

   assign mul_signed_d = mul_op_d == `LSOC1K_MDU_MUL_W     ||
			 mul_op_d == `LSOC1K_MDU_MULH_W    ||
			 mul_op_d == `LSOC1K_MDU_MUL_D     ||
			 mul_op_d == `LSOC1K_MDU_MULH_D    ||
			 mul_op_d == `LSOC1K_MDU_MULW_D_W  ;
   assign mul_double_d = mul_op_d == `LSOC1K_MDU_MUL_D     ||
			 mul_op_d == `LSOC1K_MDU_MULH_D    ||
			 mul_op_d == `LSOC1K_MDU_MULH_DU   ;
   assign mul_hi_d     = mul_op_d == `LSOC1K_MDU_MULH_W    ||
			 mul_op_d == `LSOC1K_MDU_MULH_WU   ||
			 mul_op_d == `LSOC1K_MDU_MULH_D    ||
			 mul_op_d == `LSOC1K_MDU_MULH_DU   ;
   assign mul_short_d  = mul_op_d == `LSOC1K_MDU_MUL_W     ||
			 mul_op_d == `LSOC1K_MDU_MULH_W    ||
			 mul_op_d == `LSOC1K_MDU_MULH_WU   ;


   dff_s #(1) mul_signed_d2e_reg (
      .din (mul_signed_d),
      .clk (clk),
      .q   (mul_signed_e),
      .se(), .si(), .so());

   assign ifu_exu_mul_signed_e = mul_signed_e;


   dff_s #(1) mul_double_d2e_reg (
      .din (mul_double_d),
      .clk (clk),
      .q   (mul_double_e),
      .se(), .si(), .so());

   assign ifu_exu_mul_double_e = mul_double_e;


   dff_s #(1) mul_hi_d2e_reg (
      .din (mul_hi_d),
      .clk (clk),
      .q   (mul_hi_e),
      .se(), .si(), .so());

   assign ifu_exu_mul_hi_e = mul_hi_e;


   dff_s #(1) mul_short_d2e_reg (
      .din (mul_short_d),
      .clk (clk),
      .q   (mul_short_e),
      .se(), .si(), .so());

   assign ifu_exu_mul_short_e = mul_short_e;


   //
   // CSR
   //

   wire csr_valid_d;
   wire csr_valid_e;

   assign csr_valid_d = none_dispatch_d;

   dff_s #(1) csr_valid_d2e_reg (
      .din (csr_valid_d),
      .clk (clk),
      .q   (csr_valid_e),
      .se(), .si(), .so());

   assign ifu_exu_csr_valid_e = csr_valid_e;

 
   assign ifu_exu_csr_raddr_d = `GET_CSR(fdp_dec_inst_d);




   wire csr_rdwen_d;
   wire csr_rdwen_e;

   assign csr_rdwen_d = rf_wen_d & none_dispatch_d;

   dff_s #(1) csr_rdwen_d2e_reg (
      .din (csr_rdwen_d),
      .clk (clk),
      .q   (csr_rdwen_e),
      .se(), .si(), .so());

   assign ifu_exu_csr_rdwen_e = csr_rdwen_e;



   wire csr_xchg_d;
   wire csr_xchg_e;
 
 
   assign csr_xchg_d = op_d[`LSOC1K_CSR_XCHG];
   
   dff_s #(1) csr_xchg_d2e_reg (
      .din (csr_xchg_d),
      .clk (clk),
      .q   (csr_xchg_e),
      .se(), .si(), .so());

   assign ifu_exu_csr_xchg_e = csr_xchg_e;



   wire csr_wen_d;
   wire csr_wen_e;

   assign csr_wen_d = (op_d[`LSOC1K_CSR_XCHG] | op_d[`LSOC1K_CSR_WRITE]) & csr_valid_d;
 
   dff_s #(1) csr_wen_d2e_reg (
      .din (csr_wen_d),
      .clk (clk),
      .q   (csr_wen_e),
      .se(), .si(), .so());

   assign ifu_exu_csr_wen_e = csr_wen_e;


   wire [`LSOC1K_CSR_BIT-1:0] csr_waddr_d;
   wire [`LSOC1K_CSR_BIT-1:0] csr_waddr_e;
 
   assign csr_waddr_d = `GET_CSR(fdp_dec_inst_d);

   dff_s #(`LSOC1K_CSR_BIT) csr_waddr_d2e_reg (
      .din (csr_waddr_d),
      .clk (clk),
      .q   (csr_waddr_e),
      .se(), .si(), .so());

   assign ifu_exu_csr_waddr_e = csr_waddr_e;


   //
   // ALU
   //

   wire [4:0] rf_target_e;
 
   dff_s #(5) rd_d2e_reg (
      .din (rf_target_d),
      .clk (clk),
      .q   (rf_target_e),
      .se(), .si(), .so());

   assign ifu_exu_rf_target_e = rf_target_e;



   wire alu_wen_d;
   wire alu_wen_e;
 
   assign alu_wen_d = rf_wen_d & alu_dispatch_d;
 
   dff_s #(1) alu_wen_d2e_reg (
      .din (alu_wen_d),
      .clk (clk),
      .q   (alu_wen_e),
      .se(), .si(), .so());

   assign ifu_exu_alu_wen_e = alu_wen_e;


   //
   // ERTN (ERET)
   //
   
   wire ertn_valid_d;
   wire ertn_valid_e;

   assign ertn_valid_d = ertn_dispatch_d;
 
   dff_s #(1) ertn_valid_d2e_reg (
      .din (ertn_valid_d),
      .clk (clk),
      .q   (ertn_valid_e),
      .se(), .si(), .so());

   assign ifu_exu_ertn_valid_e = ertn_valid_e;

endmodule // cpu7_ifu_dec
