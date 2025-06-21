module c7bicu
(
   input                 clk,
   input                 resetn,

   // ic1
   input                 ifu_icu_req_ic1,
   input  [31:3]         ifu_icu_addr_ic1,
   
   output                icu_ifu_ack_ic1,

   input                 ifu_icu_cancel,

   // ic2
   output                icu_ifu_data_valid_ic2,
   output [63:0]         icu_ifu_data_ic2,

   // outputs to tag RAMs
   output [1:0]          icu_ram_tag_en,
   output                icu_ram_tag_wr,
   output [9:0]          icu_ram_tag_addr,
   output [21:0]         icu_ram_tag_wdata0, // 22 bits: V, addr[31:11]
   output [21:0]         icu_ram_tag_wdata1, 

   // inputs from tag RAMs
   input  [21:0]         ram_icu_tag_rdata0,
   input  [21:0]         ram_icu_tag_rdata1,


   // outputs to data RAMs
   output [1:0]          icu_ram_data_en,
   output                icu_ram_data_wr,
   output [11:0]         icu_ram_data_addr0,
   output [11:0]         icu_ram_data_addr1,
   output [63:0]         icu_ram_data_wdata0,
   output [63:0]         icu_ram_data_wdata1,

   // inputs from data RAMs
   input  [63:0]         ram_icu_data_rdata0,
   input  [63:0]         ram_icu_data_rdata1,


   // interface with BIU
   output                icu_biu_req,
   output [31:3]         icu_biu_addr,
   output                icu_biu_single,

   input                 biu_icu_ack,
   input                 biu_icu_data_valid,
   input                 biu_icu_data_last,
   input  [63:0]         biu_icu_data,
   input                 biu_icu_fault

   );



   wire ic_lfb_hit_data_valid;
   wire [63:0] ic_lfb_hit_data;

   // internal data valid
   wire data_valid_ic2;

   ////////
   // cache lookup and hit
   //

   // icache lookup in progress, lookup contains linefill, both end with
   // icu_ifu_data_valid_ic2 signaled


   // bookkeeping when the hit or miss result should come out
   wire ic_lu_ic1;
   wire ic_lu_ic2;

   assign ic_lu_ic1 = ifu_icu_req_ic1 & icu_ifu_ack_ic1;

   dffrl_s #(1) ic_lu_reg (
      .din   (ic_lu_ic1),
      .clk   (clk),
      .rst_l (resetn),
      .q     (ic_lu_ic2),
      .se(), .si(), .so());



   // icache lookup in progress
   // start ifu_icu_req_ic1 & icu_ifu_ack_ic1  : _-_____    ic_lu_ic1
   // end           data_valid_ic2             : _____-_    internal data
   // valid
   //
   // lu_inprog_in                             : _----__
   // lu_inprog_q                              : __----_

   wire lu_inprog_in;
   wire lu_inprog_q;

   assign lu_inprog_in = (lu_inprog_q & ~data_valid_ic2) | ic_lu_ic1;

   dffrl_s #(1) lu_inprog_reg (
      .din   (lu_inprog_in),
      .clk   (clk),
      .rst_l (resetn),
      .q     (lu_inprog_q),
      .se(), .si(), .so());


   wire ic_hit_ic2;
   wire ic_miss_ic2;

   assign icu_ifu_ack_ic1 = ifu_icu_req_ic1 & ~lu_inprog_q; // uty: review  loop? lu_inprog_q is registered so it breaks the loop
                                          // but will it slow down the design ?                                                              

   wire [31:3] ic_lu_addr_ic2;

   dffrle_s #(29) ic_lu_addr_reg (
      .din   (ifu_icu_addr_ic1[31:3]),
      .en    (ic_lu_ic1),
      .rst_l (resetn),
      .clk   (clk),
      .q     (ic_lu_addr_ic2),
      .se(), .si(), .so());


   //
   // itag
   //

   //assign icu_ram_tag_addr[9:0] = ifu_icu_addr_ic1[14:5];
   //assign icu_ram_tag_en = 2'b11;
   //assign icu_ram_tag_en = {2{ic_lu_ic1}};


   wire ic_tag_way0_v_ic2;
   wire ic_tag_way1_v_ic2;

   assign ic_tag_way0_v_ic2 = ram_icu_tag_rdata0[21];
   assign ic_tag_way1_v_ic2 = ram_icu_tag_rdata1[21];


   wire ic_tag_way0_match_ic2;
   wire ic_tag_way1_match_ic2;

   //compare tag with addr

   wire [31:11] tmp_tag; // convinence for checking the tag value
   assign tmp_tag = ifu_icu_addr_ic1[31:11];

   assign ic_tag_way0_match_ic2 = (ram_icu_tag_rdata0[20:0] == ic_lu_addr_ic2[31:11]) & ic_tag_way0_v_ic2;
   assign ic_tag_way1_match_ic2 = (ram_icu_tag_rdata1[20:0] == ic_lu_addr_ic2[31:11]) & ic_tag_way1_v_ic2;

   assign ic_hit_ic2 = ic_lu_ic2 & (ic_tag_way0_match_ic2 | ic_tag_way1_match_ic2);
   assign ic_miss_ic2 = ic_lu_ic2 & (~ic_tag_way0_match_ic2 & ~ic_tag_way1_match_ic2);





   //
   // ifu cancel(ignore) next coming icu data
   //

   wire ifu_cancel_q;

   dffrle_s #(1) ifu_cancel_reg (
      .din   (ifu_icu_cancel & ~data_valid_ic2), // if the data need to cancel is right valid at this cycle, then do not set ifu_cancel_reg 
      .clk   (clk),
      .rst_l (resetn),
      //.en    (ifu_icu_cancel | icu_ifu_data_valid_ic2),
      .en    (ifu_icu_cancel | data_valid_ic2),
      .q     (ifu_cancel_q), 
      .se(), .si(), .so());


   //
   // idata
   //
   
   //assign icu_ram_data_addr0[11:0] = {ifu_icu_addr_ic1[14:5], ifu_icu_addr_ic1[4:3]};
   //assign icu_ram_data_addr1[11:0] = {ifu_icu_addr_ic1[14:5], ifu_icu_addr_ic1[4:3]};

   // read all ways data out at ic1
   // cache line allcation at ic2
   //assign icu_ram_data_en = {2{ic_lu_ic1}};

   //assign icu_ifu_data_valid_ic2 = ic_tag_way0_match_ic2 | ic_tag_way1_match_ic2;
//   assign icu_ifu_data_valid_ic2 = ic_hit_ic2 |
//                                   ic_lfb_hit_data_valid; // data fetched in the linefill buffer
   assign data_valid_ic2 = ic_hit_ic2 | ic_lfb_hit_data_valid; // data fetched in the linefill buffer
   assign icu_ifu_data_valid_ic2 = data_valid_ic2 & ~(ifu_icu_cancel | ifu_cancel_q);

   assign icu_ifu_data_ic2 = ram_icu_data_rdata0 & {64{ic_tag_way0_match_ic2}} |
	                     ram_icu_data_rdata1 & {64{ic_tag_way1_match_ic2}} |
                             ic_lfb_hit_data & {64{ic_lfb_hit_data_valid}} ;


   ////////
   // cache miss and linefile
   //

   // start biu_icu_ack       : _-_____
   // end biu_icu_data_last   : _____-_
   //
   // lf_inprog_in            : _----__
   // lf_inprog_q             : __----_

   // linefill in progress
   wire lf_inprog_in;
   wire lf_inprog_q;

   assign lf_inprog_in = (lf_inprog_q & ~biu_icu_data_last) | biu_icu_ack;

   dffrl_s #(1) lf_inprog_reg (
      .din   (lf_inprog_in),
      .clk   (clk),
      .rst_l (resetn),
      .q     (lf_inprog_q),
      .se(), .si(), .so());

   wire biu_rd_busy;
   assign biu_rd_busy = lf_inprog_q; // | others


   // bug scenario
   // ic_miss_ic2   : __-____
   // biu_icu_ack   : __-____
   // lf_req_q      : ___----
   // icu_biu_req   : ___----
   // in this case, icu_biu_req <-- lf_req_q will not be unsignaled, because ack will not come again.
   // then icu repeatly request a line fill.
   // So, use biu_rd_busy instead of biu_icu_ack
   // ic_miss_ic2   : __-____
   // biu_rd_busy   : ___----
   // lf_req_q      : ___-___
   // icu_biu_req   : ___-___

   wire lf_req_q;

   dffrle_s #(1) lf_req_reg (
      .din   (ic_miss_ic2),
      .clk   (clk),
      .rst_l (resetn),
      //.en    (ic_miss_ic2 | biu_icu_ack),
      .en    (ic_miss_ic2 | biu_rd_busy),
      .q     (lf_req_q),
      .se(), .si(), .so());

   assign icu_biu_req = (lf_req_q | ic_miss_ic2) & ~biu_rd_busy;

   assign icu_biu_addr = {ic_lu_addr_ic2[31:5], 2'b00}; // line fill at 32-byte boundary

   assign icu_biu_single = 1'b0;  // line fill, not single, actually this is known to biu

   //wire linefill_en;
   //assign linefill_en = lf_inprog_q;

   wire [3:0] lfb_cnt_in;
   wire [3:0] lfb_cnt_q;

   assign lfb_cnt_in = {{4{icu_biu_req}} & 4'b0001} |
                       {{4{~icu_biu_req}} & {lfb_cnt_q << 1'b1}};

   dffrle_s #(4) lfb_cnt_reg (
      .clk   (clk),
      .rst_l (resetn),
      .din   (lfb_cnt_in),
      .en    (icu_biu_req | biu_icu_data_valid),
      .q     (lfb_cnt_q),
      .se(), .si(), .so());


   // linefill buffer is 256-bit, same as a cache line
   wire [ 63:0]  lfb0_in;   
   wire [127:64] lfb1_in;
   wire [191:128] lfb2_in;
   wire [255:192] lfb3_in;

   wire [ 63:0]  lfb0_q;   
   wire [127:64] lfb1_q;
   wire [191:128] lfb2_q;
   wire [255:192] lfb3_q;

   assign lfb0_in = biu_icu_data;
   assign lfb1_in = biu_icu_data;
   assign lfb2_in = biu_icu_data;
   assign lfb3_in = biu_icu_data;

   dffe_s #(64) lfb0_reg (
      .clk   (clk),
      .din   (lfb0_in),
      .en    (biu_icu_data_valid & lfb_cnt_q[0]),
      .q     (lfb0_q),
      .se(), .si(), .so());

   dffe_s #(64) lfb1_reg (
      .clk   (clk),
      .din   (lfb1_in),
      .en    (biu_icu_data_valid & lfb_cnt_q[1]),
      .q     (lfb1_q),
      .se(), .si(), .so());

   dffe_s #(64) lfb2_reg (
      .clk   (clk),
      .din   (lfb2_in),
      .en    (biu_icu_data_valid & lfb_cnt_q[2]),
      .q     (lfb2_q),
      .se(), .si(), .so());

   dffe_s #(64) lfb3_reg (
      .clk   (clk),
      .din   (lfb3_in),
      .en    (biu_icu_data_valid & lfb_cnt_q[3]),
      .q     (lfb3_q),
      .se(), .si(), .so());


   assign ic_lfb_hit_data_valid = biu_icu_data_last;
   assign ic_lfb_hit_data = ic_lu_addr_ic2[4:3] == 2'b00 ? lfb0_q :
                            ic_lu_addr_ic2[4:3] == 2'b01 ? lfb1_q :
                            ic_lu_addr_ic2[4:3] == 2'b10 ? lfb2_q :
                                                           lfb3_in ; // the cycle that biu_icu_data_last arrives lfb3_in is not registered yet



   /////
   /// cache line allocation
   //

   wire ic_al_ic2;
   wire ic_al_way01_ic2_q;

   assign ic_al_ic2 = ic_miss_ic2;

   // default is way0, unless way0 is occupied and way1 is available
   // reset to 0 at the last cycle of allocation, that is when
   // biu_icu_data_last is signaled
   //assign ic_al_way01_ic2 = ic_tag_way0_v_ic2 & ~ic_tag_way1_v_ic2;
   dffrle_s #(1) ic_al_way01_ic2_reg (
      .clk   (clk),
      .rst_l (resetn),
      .din   ((ic_tag_way0_v_ic2 & ~ic_tag_way1_v_ic2) & ~biu_icu_data_last),
      .en    (ic_al_ic2 | biu_icu_data_last),
      .q     (ic_al_way01_ic2_q),
      .se(), .si(), .so());

//   wire ic_al_ic2_q;
//
//   dffrle_s #(1) ic_al_ic_reg (
//      .clk   (clk),
//      .rst_l (resetn),
//      .din   (ic_al_ic2 & ~biu_icu_data_last),
//      .en    (ic_al_ic2 | biu_icu_data_last),
//      .q     (ic_al_ic2_q),
//      .se(), .si(), .so());
   

   // update idata
   // icu_ram_data_en is used both in ic1 and ic2
   assign icu_ram_data_en = {2{ic_lu_ic1}} | {{2{~ic_lu_ic1}} & {ic_al_way01_ic2_q == 1'b0 ? 2'b01 : 2'b10}};
   assign icu_ram_data_wr = biu_icu_data_valid;


   wire [1:0] al_cnt_in;
   wire [1:0] al_cnt_q;

   assign al_cnt_in = {{2{icu_biu_req}} & 2'b00} |
                       {{2{~icu_biu_req}} & {al_cnt_q + 2'b01}};

   dffrle_s #(2) al_cnt_reg (
      .clk   (clk),
      .rst_l (resetn),
      .din   (al_cnt_in),
      .en    (icu_biu_req | biu_icu_data_valid),
      .q     (al_cnt_q),
      .se(), .si(), .so());

   //assign icu_ram_data_addr0 = ic_lu_addr_ic2[14:3];
   //assign icu_ram_data_addr1 = ic_lu_addr_ic2[14:3];
   assign icu_ram_data_addr0 = {{12{ic_lu_ic1}} & ifu_icu_addr_ic1[14:3]} | {{{12{~ic_lu_ic1}} & {ic_lu_addr_ic2[14:5], al_cnt_q[1:0]}}};
   assign icu_ram_data_addr1 = {{12{ic_lu_ic1}} & ifu_icu_addr_ic1[14:3]} | {{{12{~ic_lu_ic1}} & {ic_lu_addr_ic2[14:5], al_cnt_q[1:0]}}};
   assign icu_ram_data_wdata0 = biu_icu_data;
   assign icu_ram_data_wdata1 = biu_icu_data;
   
   // update itag
   // update tag at last cycle
   //assign icu_ram_tag_en = {2{ic_lu_ic1}} | biu_icu_data_last;
   assign icu_ram_tag_en = {2{ic_lu_ic1}} | {{2{~ic_lu_ic1}} & {ic_al_way01_ic2_q == 1'b0 ? 2'b01 : 2'b10}};
   assign icu_ram_tag_wr = biu_icu_data_last;

   //
   assign icu_ram_tag_addr = {{10{ic_lu_ic1}} & ifu_icu_addr_ic1[14:5]} | {{10{~ic_lu_ic1}} & ic_lu_addr_ic2[14:5]};
   assign icu_ram_tag_wdata0 = {1'b1, ic_lu_addr_ic2[31:11]};
   assign icu_ram_tag_wdata1 = {1'b1, ic_lu_addr_ic2[31:11]};

endmodule
   
