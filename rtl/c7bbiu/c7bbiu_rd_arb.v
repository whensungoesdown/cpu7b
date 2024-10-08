module c7bbiu_rd_arb(
   input              clk,
   input              resetn,

   input              axi_ar_ready,

   input              ifu_biu_rd_req,
   output             biu_ifu_rd_ack,
   input  [31:0]      ifu_biu_rd_addr,
   
   input              lsu_biu_rd_req,
   output             biu_lsu_rd_ack,
   input  [31:0]      lsu_biu_rd_addr,

   input              axi_rdata_ifu_val,
   input              axi_rdata_lsu_val,
 
   output             arb_rd_val, 
   output [3:0]       arb_rd_id,
   output [31:0]      arb_rd_addr, 
   output [7:0]       arb_rd_len,
   output [2:0]       arb_rd_size,  
   output [1:0]       arb_rd_burst,
   output             arb_rd_lock,
   output [3:0]       arb_rd_cache,
   output [2:0]       arb_rd_prot
   );

`include "axi_types.v"

   wire ifu_select;
   wire lsu_select;


   assign lsu_select = lsu_biu_rd_req;

   assign ifu_select = ~lsu_biu_rd_req &
	                ifu_biu_rd_req;


   assign biu_ifu_rd_ack = axi_ar_ready & ifu_select;
   assign biu_lsu_rd_ack = axi_ar_ready & lsu_select;

   assign arb_rd_val = biu_ifu_rd_ack | biu_lsu_rd_ack;


   assign {arb_rd_id,
           arb_rd_addr,
           arb_rd_len,
           arb_rd_size,
           arb_rd_burst,
           arb_rd_lock,
           arb_rd_cache,
           arb_rd_prot
	   } = 
           {57{ifu_select}} & {AXI_RID_IFU, ifu_biu_rd_addr, 8'h0, AXI_SIZE_WORD, 2'b00, 1'b0, 4'b0000, 3'b000} |
           {57{lsu_select}} & {AXI_RID_LSU, lsu_biu_rd_addr, 8'h0, AXI_SIZE_WORD, 2'b00, 1'b0, 4'b0000, 3'b000}
	   ;
endmodule

