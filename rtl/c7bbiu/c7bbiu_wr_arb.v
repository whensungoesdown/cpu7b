module c7bbiu_wr_arb(
   input                clk,
   input                resetn,

   input                axi_aw_ready,
   input                axi_w_ready,

   // now, only one requester
   input                lsu_biu_wr_aw_req,
   output               biu_lsu_wr_aw_ack,
   input                lsu_biu_wr_w_req,
   output               biu_lsu_wr_w_ack,
   
   input [31:0]         lsu_biu_wr_addr,
   input [63:0]         lsu_biu_wr_data,
   input [7:0]          lsu_biu_wr_strb,
   input                lsu_biu_wr_last,

   output               arb_wr_aw_val, 
   output [3:0]         arb_wr_aw_id,
   output [31:0]        arb_wr_aw_addr, 
   output [7:0]         arb_wr_aw_len,
   output [2:0]         arb_wr_aw_size,
   output [1:0]         arb_wr_aw_burst,
   output               arb_wr_aw_lock,
   output [3:0]         arb_wr_aw_cache,
   output [2:0]         arb_wr_aw_prot,

   output               arb_wr_w_val, 
   output [3:0]         arb_wr_w_id,
   output [63:0]        arb_wr_w_data,
   output [7:0]         arb_wr_w_strb,
   output               arb_wr_w_last
   );

`include "axi_types.v"

   wire lsu_select;

   assign lsu_select = lsu_biu_wr_aw_req;

   assign arb_wr_aw_id = AXI_WID_LSU; 
   assign arb_wr_w_id = AXI_WID_LSU; 

   assign {arb_wr_aw_addr,
	   arb_wr_aw_len,
	   arb_wr_aw_size,
           arb_wr_aw_burst,
           arb_wr_aw_lock,
           arb_wr_aw_cache,
           arb_wr_aw_prot

	   } = {53{lsu_select}} & {lsu_biu_wr_addr, 8'h0, AXI_SIZE_WORD, 2'b00, 1'b0, 4'b0000, 3'b000};

   assign {arb_wr_w_data,
           arb_wr_w_strb,
           arb_wr_w_last
           } = {73{lsu_select}} & {lsu_biu_wr_data, lsu_biu_wr_strb, lsu_biu_wr_last};

   assign biu_lsu_wr_aw_ack = axi_aw_ready & lsu_select;
   assign biu_lsu_wr_w_ack = axi_w_ready & lsu_select;

   assign arb_wr_aw_val = biu_lsu_wr_aw_ack;
   assign arb_wr_w_val = biu_lsu_wr_w_ack;

endmodule
