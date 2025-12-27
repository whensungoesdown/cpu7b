module c7bbiu_rd_arb(
   input              clk,
   input              resetn,

   input              axi_ar_ready,

   input              ifu_biu_rd_req,
   output             biu_ifu_rd_ack,
   input  [31:0]      ifu_biu_rd_addr,

   input              icu_biu_req,
   output             biu_icu_ack,
   input  [31:3]      icu_biu_addr,
   input              icu_biu_single,
   
   input              lsu_biu_rd_req,
   output             biu_lsu_rd_ack,
   input  [31:0]      lsu_biu_rd_addr,



   //input              axi_rdata_ifu_val,
   //input              axi_rdata_lsu_val,
 
   output             arb_rd_val, 
   output [3:0]       arb_rd_id,
   output [31:0]      arb_rd_addr, 
   output [7:0]       arb_rd_len,
   output [2:0]       arb_rd_size,  
   output [1:0]       arb_rd_burst,
   output             arb_rd_lock,
   output [3:0]       arb_rd_cache,
   output [2:0]       arb_rd_prot,

   input              ext_biu_r_last
   );

`include "axi_types.v"

   wire ifu_select;
   wire lsu_select;
   wire icu_select;

   assign lsu_select = lsu_biu_rd_req;

   assign ifu_select = ~lsu_biu_rd_req &
	                ifu_biu_rd_req;
   
   assign icu_select = ~lsu_biu_rd_req &
                       ~ifu_biu_rd_req &
                       icu_biu_req;


   wire busy_in;
   wire busy_q;
   // start arb_rd_val     : _-_____
   // end   ext_biu_r_last : _____-_
   //
   // busy_in              : _----__
   // busy_q               : __----_
   assign busy_in = (busy_q & ~ext_biu_r_last) | arb_rd_val;

   dffrl_ns #(1) busy_reg (
      .din   (busy_in),
      .clk   (clk),
      .rst_l (resetn),
      .q     (busy_q));
      //.se(), .si(), .so());


   // If either the IFU or LSU is selected, there is a 1-cycle delay from the
   // AXI interface in registering the signals. As a result, axi_ar_ready also
   // experiences a 1-cycle delay to indicate the channel's busy state. 

   // Thus, if the BIU selects in the previous cycle, it should be marked as
   // busy in the next cycle and will depend on `axi_ar_ready` for the
   // following cycles.

//   wire axi_ar_ready_val;
//   wire axi_ar_ready_delay_in;
//   wire axi_ar_ready_delay_q;
//
//   assign axi_ar_ready_delay_in = biu_ifu_rd_ack | biu_lsu_rd_ack;
//
//   dffrl_s #(1) axi_ar_ready_delay_reg (
//      .din   (axi_ar_ready_delay_in),
//      .rst_l (resetn),
//      .clk   (clk),
//      .q     (axi_ar_ready_delay_q),
//      .se(), .si(), .so());
//
//   assign axi_ar_ready_val = axi_ar_ready & ~axi_ar_ready_delay_q;
//
//
//   assign biu_ifu_rd_ack = axi_ar_ready_val & ifu_select;
//   assign biu_lsu_rd_ack = axi_ar_ready_val & lsu_select;

   assign biu_ifu_rd_ack = axi_ar_ready & ifu_select & ~busy_q;
   assign biu_lsu_rd_ack = axi_ar_ready & lsu_select & ~busy_q;
   assign biu_icu_ack    = axi_ar_ready & icu_select & ~busy_q;
   
   assign arb_rd_val = biu_ifu_rd_ack | biu_lsu_rd_ack | biu_icu_ack;


   assign {arb_rd_id,
           arb_rd_addr,
           arb_rd_len,
           arb_rd_size,
           arb_rd_burst,
           arb_rd_lock,
           arb_rd_cache,
           arb_rd_prot
	   } = 
           {57{ifu_select}} & {AXI_RID_IFU, ifu_biu_rd_addr, 8'h0, AXI_SIZE_DOUBLEWORD, 2'b00, 1'b0, 4'b0000, 3'b000} |
           {57{lsu_select}} & {AXI_RID_LSU, lsu_biu_rd_addr, 8'h0, AXI_SIZE_DOUBLEWORD, 2'b00, 1'b0, 4'b0000, 3'b000} |
           {57{icu_select}} & {AXI_RID_ICU, {icu_biu_addr, 3'b0}, icu_biu_single ? 8'h0 : 8'h3, AXI_SIZE_DOUBLEWORD, 
                                                                  icu_biu_single ? 2'b00 : AXI_BURST_INCR, 1'b0, 4'b0000, 3'b000}
	   ;
endmodule

