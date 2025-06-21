
module cpu7_ifu_iq (
   input             clk,
   input             resetn,

   input  [31:0]     pc_f,

   input             exu_ifu_stall_req,
  
   input  [63:0]     icu_ifu_data_ic2,
   input             icu_ifu_data_valid_ic2,

//   output            ifu_icu_req_ic1,
//   output [31:0]     ifu_icu_addr_ic1,
//   input             icu_ifu_ack_ic1,

   output            iq_not_empty,
   output            fetch_ahead,
   output [31:0]     inst_f,
   output            inst_valid_f
   );

   wire instr_2nd;

   assign instr_2nd = pc_f[2];


   wire iq_not_empty_q;

   //
   // switch
   //
   // on  instr_2nd
   // off icu_ifu_data_valid_ic2
   //
   //  inst_2nd           icu_ifu_data_valid_ic2       empty  notempty
   //     0                          0                   0       1
   //     0                          1                   0       1
   //     1                          0                   1       0
   //     1                          1                   0       1
   dffrle_s #(1) iq_not_empty_reg (
      .din   (~(instr_2nd & ~icu_ifu_data_valid_ic2)),
      .en    (instr_2nd | icu_ifu_data_valid_ic2), 
      .clk   (clk),
      .rst_l (resetn),
      .q     (iq_not_empty_q),
      .se(), .si(), .so());


   wire stalled_q;

   //
   // switch
   //
   // on  exu_ifu_stall_req
   // off icu_ifu_data_valid_ic2
   //
   //  exu_ifu_stall_req          icu_ifu_data_valid_ic2    stalled
   //          0                             0                 0
   //          0                             1                 0
   //          1                             0                 1
   //          1                             1                 1
   dffrle_s #(1) stalled_reg (
      .din   (exu_ifu_stall_req),
      .en    (exu_ifu_stall_req | icu_ifu_data_valid_ic2), 
      .clk   (clk),
      .rst_l (resetn),
      .q     (stalled_q),
      .se(), .si(), .so());


   wire [63:0] inst_rdata_q;

   dffe_s #(64) inst_rdata_reg (
      .din   (icu_ifu_data_ic2),
      .en    (icu_ifu_data_valid_ic2), 
      .clk   (clk),
      .q     (inst_rdata_q),
      .se(), .si(), .so());


   assign inst_valid_f = (icu_ifu_data_valid_ic2 | iq_not_empty_q) & ~exu_ifu_stall_req;

   assign inst_f = instr_2nd ? inst_rdata_q[63:32] :
                   stalled_q ? inst_rdata_q[31:0] :
                               icu_ifu_data_ic2[31:0];

   //assign iq_empty = (instr_2nd & ~icu_ifu_data_valid_ic2) | iq_empty_q;
   assign iq_not_empty = icu_ifu_data_valid_ic2 | iq_not_empty_q;


   // Since the instruction Q only stores two instructions,
   // when iq_not_empty_q signaled, and no stall, fetch ahead
   assign fetch_ahead = iq_not_empty_q & ~exu_ifu_stall_req;

endmodule



