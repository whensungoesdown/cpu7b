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


   wire axi_ar_busy;

   wire axi_ar_busy_ifu;
   wire axi_ar_busy_ifu_in;
   wire axi_ar_busy_ifu_q;

   wire axi_ar_busy_lsu;
   wire axi_ar_busy_lsu_in;
   wire axi_ar_busy_lsu_q;

   //
   // lsu has the highest priority, otherwise lsu read have no change to finish
   //
   // can not be selected if ar is busy (no interleaving)
   //
   assign lsu_select = lsu_biu_rd_req & ~axi_ar_busy;

   assign ifu_select = ~lsu_biu_rd_req &
	                ifu_biu_rd_req & ~axi_ar_busy;



   // scenario 0
   //
   // ifu_select           : _-_____
   // axi_rdata_ifu_val    : _____-_
   //
   // axi_ar_busy_ifu_in   : _----__
   // axi_ar_busy_ifu_q    : __----_

   // scenario 1
   // 
   // ifu_select           : _-_____
   // axi_rdata_ifu_val    : _-_____
   //
   // axi_ar_busy_ifu_in   : _-_____
   // axi_ar_busy_ifu_q    : __-____ 

   assign axi_ar_busy_ifu_in = (axi_ar_busy_ifu_q & ~axi_rdata_ifu_val) | ifu_select;

   dffrl_s #(1) axi_ar_busy_ifu_reg (
      .din   (axi_ar_busy_ifu_in),
      .clk   (clk),
      .rst_l (resetn),
      .q     (axi_ar_busy_ifu_q),
      .se(), .si(), .so());

   // it is not busy on the cycle of ifu_select, so do not use axi_ar_busy_ifu_q
   // if set busy on ifu_select, then arb_rd_val can not be set 
   assign axi_ar_busy_ifu = axi_ar_busy_ifu_q;

   
   // axi_ar_busy_lsu, the same

   assign axi_ar_busy_lsu_in = (axi_ar_busy_lsu_q & ~axi_rdata_lsu_val) | lsu_select;

   dffrl_s #(1) axi_ar_busy_lsu_reg (
      .din   (axi_ar_busy_lsu_in),
      .clk   (clk),
      .rst_l (resetn),
      .q     (axi_ar_busy_lsu_q),
      .se(), .si(), .so());

   assign axi_ar_busy_lsu = axi_ar_busy_lsu_q;


   // currently, axi_sram_bridge does not support interleaving
   // therefore, ifu or lsu, there can be only one that grant ar channel 
   assign axi_ar_busy = axi_ar_busy_ifu | axi_ar_busy_lsu;

   assign biu_ifu_rd_ack = axi_ar_ready /*& ~axi_ar_busy_ifu*/ & ~axi_ar_busy & ifu_select;
   assign biu_lsu_rd_ack = axi_ar_ready /*& ~axi_ar_busy_lsu*/ & ~axi_ar_busy & lsu_select;

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

