`include "../common.vh"
`include "../decoded.vh"

module cpu7_ifu_imd(
   input  [31:0]                        inst,
   input  [`LSOC1K_DECODE_RES_BIT-1:0]  op,
   output [31:0]                        imm_shifted,
   output [`GRLEN-1:0]                  alu_c,
   output [`GRLEN-1:0]                  br_offs
   );

   //immediate operater prepare
   wire [ 4:0] port0_i5  = `GET_I5(inst);
   wire [ 5:0] port0_i6  = `GET_I6(inst);
   wire [11:0] port0_i12 = `GET_I12(inst);
   wire [13:0] port0_i14 = `GET_I14(inst);
   wire [15:0] port0_i16 = `GET_I16(inst);
   wire [19:0] port0_i20 = `GET_I20(inst);
   
   wire [31:0] port0_i5_u  = {27'b0,port0_i5};
   wire [31:0] port0_i6_u  = {26'b0,port0_i6};
   wire [31:0] port0_i12_u = {20'b0,port0_i12};
   wire [31:0] port0_i12_s = {{20{port0_i12[11]}},port0_i12};
   wire [31:0] port0_i14_s = {{18{port0_i14[13]}},port0_i14};
   wire [31:0] port0_i16_s = {{16{port0_i16[15]}},port0_i16};
   wire [31:0] port0_i20_s = {{12{port0_i20[19]}},port0_i20};

   wire [31:0] port0_i5_i = op[`LSOC1K_DOUBLE_WORD] ? port0_i6_u : port0_i5_u;
   wire [31:0] port0_i12_i = op[`LSOC1K_UNSIGN] ? port0_i12_u : port0_i12_s;

   wire [31:0] port0_imm = op[`LSOC1K_I5 ] ? port0_i5_i  :
	       op[`LSOC1K_I12] ? port0_i12_i :
	       op[`LSOC1K_I14] ? port0_i14_s :
	       op[`LSOC1K_I16] ? port0_i16_s :
	       op[`LSOC1K_I20] ? port0_i20_s :
	       32'b0;

   assign imm_shifted = op[`LSOC1K_IMM_SHIFT] == `LSOC1K_IMM_SHIFT_2  ? {port0_imm[29:0], 2'b0} :
				  op[`LSOC1K_IMM_SHIFT] == `LSOC1K_IMM_SHIFT_12 ? {port0_imm[19:0],12'b0} :
				  op[`LSOC1K_IMM_SHIFT] == `LSOC1K_IMM_SHIFT_16 ? {port0_imm[15:0],16'b0} :
				  op[`LSOC1K_IMM_SHIFT] == `LSOC1K_IMM_SHIFT_18 ? {port0_imm[13:0],18'b0} :
				  port0_imm; 


   assign alu_c = (op[`LSOC1K_ALU_CODE] == `LSOC1K_ALU_COUNT_L || op[`LSOC1K_ALU_CODE] == `LSOC1K_ALU_COUNT_T) ? {31'd0,!op[`LSOC1K_UNSIGN]} :
			(op[`LSOC1K_SA] || op[`LSOC1K_ALU_CODE] == `LSOC1K_ALU_ALIGN) ? {29'd0,`GET_SA(inst)} :
			(op[`LSOC1K_ALU_CODE] == `LSOC1K_ALU_EXT || op[`LSOC1K_ALU_CODE] == `LSOC1K_ALU_INS) ? {20'd0,`GET_MSLSBD(inst)} :
			(op[`LSOC1K_ALU_CODE] == `LSOC1K_ALU_ROT) ? port0_imm :
			port0_imm;


   wire [15:0] port0_offset16 = `GET_OFFSET16(inst);
   wire [20:0] port0_offset21 = `GET_OFFSET21(inst);
   wire [25:0] port0_offset26 = `GET_OFFSET26(inst);
   
   wire [31:0] port0_offset = op[`LSOC1K_RD_READ    ] ? {{14{port0_offset16[15]}},port0_offset16,2'b0} :
	                      op[`LSOC1K_HIGH_TARGET] ? {{ 4{port0_offset26[25]}},port0_offset26,2'b0} :
	                                                          {{ 9{port0_offset21[20]}},port0_offset21,2'b0} ;

   assign br_offs = port0_offset;
   
endmodule // cpu7_ifu_imd
