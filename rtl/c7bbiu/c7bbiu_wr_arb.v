module c7bbiu_wr_arb(
   input                clk,
   input                resetn,

   input                axi_aw_ready,
   input                axi_w_ready,

   // now, only one requester
   input                lsu_biu_wr_req,
   output               biu_lsu_wr_ack,
   
   input [31:0]         lsu_biu_wr_addr,
   input [31:0]         lsu_biu_wr_data,
   input [3:0]          lsu_biu_wr_strb,
   input                lsu_biu_wr_last,

   output               arb_wr_val, 
   output [3:0]         arb_wr_id,
   output [31:0]        arb_wr_addr, 
   output [7:0]         arb_wr_len,
   output [2:0]         arb_wr_size,
   output [1:0]         arb_wr_burst,
   output               arb_wr_lock,
   output [3:0]         arb_wr_cache,
   output [2:0]         arb_wr_prot,

   output [31:0]        arb_wr_data,
   output [3:0]         arb_wr_strb,
   output               arb_wr_last
   );

`include "axi_types.v"

   wire lsu_select;

   assign lsu_select = lsu_biu_wr_req;

   assign arb_wr_id = AXI_WID_LSU; 

   assign {arb_wr_addr,
	   arb_wr_len,
	   arb_wr_size,
           arb_wr_burst,
           arb_wr_lock,
           arb_wr_cache,
           arb_wr_prot,
           arb_wr_data,
           arb_wr_strb,
           arb_wr_last
	   } =
           {90{lsu_select}} & {lsu_biu_wr_addr, 8'h0, AXI_SIZE_WORD, 2'b00, 1'b0, 4'b0000, 3'b000, lsu_biu_wr_data, lsu_biu_wr_strb, lsu_biu_wr_last}
	   ;

   assign biu_lsu_wr_ack = axi_aw_ready & axi_w_ready & lsu_select;

   assign arb_wr_val = biu_lsu_wr_ack;
endmodule
