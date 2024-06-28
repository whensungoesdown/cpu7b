`include "common.vh"
`include "decoded.vh"

module cpu7_ifu(
   input                               clock,
   input                               resetn,
   input  [31:0]                       pc_init,

   // group inst
   output [31:0]                       inst_addr,
   input                               inst_addr_ok,
   output                              inst_cancel,
   input  [1:0]                        inst_count,
   input                               inst_ex,
   input  [5:0]                        inst_exccode,
   input  [`GRLEN-1:0]                 inst_rdata_f,
   output                              inst_req, // inst_req_bf
   input                               inst_uncache,
   input                               inst_valid_f,

   input                               exu_ifu_br_taken,
   input  [31:0]                       exu_ifu_br_target,

   // exception
   input  [`GRLEN-1:0]                 exu_ifu_eentry,
   input                               exu_ifu_except,
   // ertn
   input  [`GRLEN-1:0]                 exu_ifu_era,
   input                               exu_ifu_ertn_e,
   
   // port0
   output                              ifu_exu_valid_d,
   output [31:0]                       ifu_exu_inst_d,
   output [`GRLEN-1:0]                 ifu_exu_pc_d,
   output [`LSOC1K_DECODE_RES_BIT-1:0] ifu_exu_op_d,
   output                              ifu_exu_exception_d,
   output [5 :0]                       ifu_exu_exccode_d,
   output [`GRLEN-3:0]                 ifu_exu_br_target_d,
   output                              ifu_exu_br_taken_d,
   output                              ifu_exu_rf_wen_d,
   output [4:0]                        ifu_exu_rf_target_d,
   output [`LSOC1K_PRU_HINT-1:0]       ifu_exu_hint_d,

   output [31:0]                       ifu_exu_imm_shifted_d,
   output [`GRLEN-1:0]                 ifu_exu_c_d,
   output [`GRLEN-1:0]                 ifu_exu_br_offs,

   output [`GRLEN-1:0]                 ifu_exu_pc_w,
   output [`GRLEN-1:0]                 ifu_exu_pc_e,

   input                               exu_ifu_stall_req
   );


   cpu7_ifu_fdp fdp(
      .clk              (clock             ),
      .reset            (~resetn           ),

      .pc_init          (pc_init           ),

      .br_taken         (exu_ifu_br_taken  ),
      .br_target        (exu_ifu_br_target ),

      // exception
      .exu_ifu_eentry   (exu_ifu_eentry    ),
      .exu_ifu_except   (exu_ifu_except    ),
      // ertn
      .exu_ifu_era      (exu_ifu_era       ),
      .exu_ifu_ertn_e   (exu_ifu_ertn_e    ),

      .inst_req         (inst_req          ),
      .inst_addr        (inst_addr         ),
      .inst_cancel      (inst_cancel       ),
      .inst_addr_ok     (inst_addr_ok      ),
      .inst_valid_f     (inst_valid_f      ),
      .inst_count       (inst_count        ),
      .inst_rdata_f     (inst_rdata_f      ),
      .inst_uncache     (inst_uncache      ),
      .inst_ex          (inst_ex           ),
      .inst_exccode     (inst_exccode      ),

      .ifu_exu_valid_d  (ifu_exu_valid_d   ),
      .ifu_exu_pc_d     (ifu_exu_pc_d      ),
      .ifu_exu_inst_d   (ifu_exu_inst_d    ),

      .ifu_exu_pc_w     (ifu_exu_pc_w      ),
      .ifu_exu_pc_e     (ifu_exu_pc_e      ),

      .exu_ifu_stall_req(exu_ifu_stall_req )
      );


   cpu7_ifu_dec dec(
      .clk                   (clock             ),
      .resetn                (resetn            ),

      .ifu_exu_inst_d       (ifu_exu_inst_d      ),
      .ifu_exu_op_d         (ifu_exu_op_d        ),
      .ifu_exu_rf_wen_d     (ifu_exu_rf_wen_d    ),
      .ifu_exu_rf_target_d  (ifu_exu_rf_target_d )
      );

   // cpu7_ifu_imd, decode offset imm
   cpu7_ifu_imd imd(
      .ifu_exu_inst_d        (ifu_exu_inst_d        ),
      .ifu_exu_op_d          (ifu_exu_op_d          ),
      .ifu_exu_imm_shifted_d (ifu_exu_imm_shifted_d ),
      .ifu_exu_c_d           (ifu_exu_c_d           ),
      .ifu_exu_br_offs       (ifu_exu_br_offs       )
      );
   
endmodule // cpu7_ifu
