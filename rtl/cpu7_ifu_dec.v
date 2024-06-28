`include "common.vh"
`include "decoded.vh"

module cpu7_ifu_dec(
   input  wire                         clk,
   input  wire                         resetn,

   // port0
//   input  wire                         fdp_dec_valid_f,
//   input  wire [`GRLEN-1:0]            fdp_dec_pc,
//   input  wire [31:0]                  fdp_dec_inst_f,
//   input  wire [`GRLEN-3:0]            fdp_dec_br_target,
//   input  wire                         fdp_dec_br_taken,
//   input  wire                         fdp_dec_exception,
//   input  wire [5 :0]                  fdp_dec_exccode,
//   input  wire [`LSOC1K_PRU_HINT-1:0]  fdp_dec_hint,
//
//   output wire                         dec_fdp_valid_d,
//
//   input  wire                              int_except,
   // port0
//   output wire                              ifu_exu_valid_d,
   input  wire [31:0]                       ifu_exu_inst_d,
//   output wire [`GRLEN-1:0]                 ifu_exu_pc_d,
   output wire [`LSOC1K_DECODE_RES_BIT-1:0] ifu_exu_op_d,
//   output wire                              ifu_exu_exception_d,
//   output wire [5 :0]                       ifu_exu_exccode_d,
//   output wire [`GRLEN-3:0]                 ifu_exu_br_target_d,
//   output wire                              ifu_exu_br_taken_d,
   output wire                              ifu_exu_rf_wen_d,
   output wire [4:0]                        ifu_exu_rf_target_d
 //  output wire [`LSOC1K_PRU_HINT-1:0]       ifu_exu_hint_d,

//   input  wire                              exu_ifu_stall_req,
//   input  wire                              kill_f
   );

wire int_except = 1'b0;
wire fdp_dec_exception = 1'b0;
wire [5 :0] fdp_dec_exccode = 6'b0;

// define
wire rst = !resetn;
wire [`LSOC1K_DECODE_RES_BIT-1:0] port0_op;

////func
decoder port0_decoder(.inst(ifu_exu_inst_d), .res(port0_op)); //decode the inst

//reg file related
wire rf_wen0 = port0_op[`LSOC1K_GR_WEN];

wire [4:0] waddr0 = (port0_op[`LSOC1K_BRU_RELATED] && (port0_op[`LSOC1K_BRU_CODE] == `LSOC1K_BRU_BL)) ? 5'd1 : `GET_RD(ifu_exu_inst_d);

//// crash check
// exception
//wire port0_fpd = !csr_output[`LSOC1K_CSR_OUTPUT_EUEN_FPE] && port0_op[`LSOC1K_FLOAT];
//
//`ifdef LA64
//wire port0_ipe = ((csr_output[`LSOC1K_CSR_OUTPUT_CRMD_PLV] == 2'd1) && csr_output[`LSOC1K_CSR_OUTPUT_MISC_DRDTL1] && port0_op[`LSOC1K_RDTIME]) ||
//                 ((csr_output[`LSOC1K_CSR_OUTPUT_CRMD_PLV] == 2'd2) && csr_output[`LSOC1K_CSR_OUTPUT_MISC_DRDTL2] && port0_op[`LSOC1K_RDTIME]) ||
//                 ((csr_output[`LSOC1K_CSR_OUTPUT_CRMD_PLV] == 2'd3) && csr_output[`LSOC1K_CSR_OUTPUT_MISC_DRDTL3] && port0_op[`LSOC1K_RDTIME]) ;
//`elsif LA32
//wire port0_ipe = 1'B0;//(csr_output[`LSOC1K_CSR_OUTPUT_CRMD_PLV] != 2'd0) && (port0_op[`LSOC1K_CSR_READ] || port0_op[`LSOC1K_CACHE_RELATED] || port0_op[`LSOC1K_TLB_RELATED] || port0_op[`LSOC1K_WAIT] || port0_op[`LSOC1K_ERET]);
//
//`endif


// uty: review
// here, port0_exception and port0_excccode both use fdp_dec_exception
// it may actually need to use ifu_exu_exception_d instead
// wait until debugging exception code
   
//wire port0_exception = fdp_dec_exception   || port0_op[`LSOC1K_SYSCALL] || port0_op[`LSOC1K_BREAK ] || port0_op[`LSOC1K_INE] ||
//                       port0_fpd || port0_ipe || int_except;
wire port0_exception = fdp_dec_exception   || port0_op[`LSOC1K_SYSCALL] || port0_op[`LSOC1K_BREAK ] || port0_op[`LSOC1K_INE] || int_except;
   
//
//wire [5:0] port0_exccode = int_except                ? `EXC_INT          :
//                           fdp_dec_exception       ? fdp_dec_exccode : 
//                           port0_op[`LSOC1K_SYSCALL] ? `EXC_SYS          :
//                           port0_op[`LSOC1K_BREAK  ] ? `EXC_BRK          :
//                           port0_op[`LSOC1K_INE    ] ? `EXC_INE          :
//                           port0_fpd                 ? `EXC_FPD          :
//                                                       6'd0              ;
wire [5:0] port0_exccode = int_except                ? `EXC_INT          :
                           fdp_dec_exception         ? fdp_dec_exccode   : 
                           port0_op[`LSOC1K_SYSCALL] ? `EXC_SYS          :
                           port0_op[`LSOC1K_BREAK  ] ? `EXC_BRK          :
                           port0_op[`LSOC1K_INE    ] ? `EXC_INE          :
                                                       6'd0              ;
   
//assign de_allow_in = is_allow_in || bru_cancel || exception || eret;
//assign de_accept   = {0, 0, de_allow_in};






   assign ifu_exu_op_d = port0_op;
   assign ifu_exu_rf_wen_d = rf_wen0;
   assign ifu_exu_rf_target_d = {5{rf_wen0}}&waddr0;
   

endmodule // cpu7_ifu_dec
