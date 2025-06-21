module c7bbiu_axi_interface(
      input            clk,
      input            resetn,

      // Arbitrated read signals
      input            arb_rd_val, 
      input  [3:0]     arb_rd_id,
      input  [31:0]    arb_rd_addr, 
      input  [1:0]     arb_rd_burst,
      input  [7:0]     arb_rd_len,
      input  [2:0]     arb_rd_size,
      input            arb_rd_lock,
      input  [3:0]     arb_rd_cache,
      input  [2:0]     arb_rd_prot,

      output           axi_ar_ready,

      // AXI Read Address Channel
      input            ext_biu_ar_ready,
      output           biu_ext_ar_valid,
      output [3:0]     biu_ext_ar_id,
      output [31:0]    biu_ext_ar_addr,
      output [7:0]     biu_ext_ar_len,
      output [2:0]     biu_ext_ar_size,
      output [1:0]     biu_ext_ar_burst,
      output           biu_ext_ar_lock,
      output [3:0]     biu_ext_ar_cache,
      output [2:0]     biu_ext_ar_prot,

      // AXI Read Data Channel
      output           biu_ext_r_ready,
      input            ext_biu_r_valid,
      input  [3:0]     ext_biu_r_id,
      input  [63:0]    ext_biu_r_data,
      input            ext_biu_r_last,
      input  [1:0]     ext_biu_r_resp,

      // Arbitrated write signals
      input            arb_wr_aw_val,
      input  [3:0]     arb_wr_aw_id,
      input  [31:0]    arb_wr_aw_addr,
      input  [7:0]     arb_wr_aw_len,
      input  [2:0]     arb_wr_aw_size,
      input  [1:0]     arb_wr_aw_burst,
      input            arb_wr_aw_lock,
      input  [3:0]     arb_wr_aw_cache,
      input  [2:0]     arb_wr_aw_prot,

      output           axi_aw_ready,

      input            arb_wr_w_val,
      input  [3:0]     arb_wr_w_id,
      input  [63:0]    arb_wr_w_data,
      input  [7:0]     arb_wr_w_strb,
      input            arb_wr_w_last,

      output           axi_w_ready,


      // AXI Write address channel
      input            ext_biu_aw_ready,
      output           biu_ext_aw_valid,
      output [3:0]     biu_ext_aw_id,
      output [31:0]    biu_ext_aw_addr,
      output [7:0]     biu_ext_aw_len,
      output [2:0]     biu_ext_aw_size,
      output [1:0]     biu_ext_aw_burst,
      output           biu_ext_aw_lock,
      output [3:0]     biu_ext_aw_cache,
      output [2:0]     biu_ext_aw_prot,

      // AXI Write data channel
      input            ext_biu_w_ready,
      output           biu_ext_w_valid,
      output [3:0]     biu_ext_w_id,
      output [63:0]    biu_ext_w_data,
      output [7:0]     biu_ext_w_strb,
      output           biu_ext_w_last,

      // AXI Write response channel
      output           biu_ext_b_ready,
      input            ext_biu_b_valid,
      input  [3:0]     ext_biu_b_id,
      input  [1:0]     ext_biu_b_resp,


      // Read data from the AXI interface
      output [63:0]    axi_rdata,
      output           axi_rdata_ifu_val,
      output           axi_rdata_lsu_val, 
      output           axi_rdata_icu_val, 
      output           axi_rdata_last,

      // Write data to the AXI interface
      output           axi_write_lsu_val
   );

`include "axi_types.v"


   ///////////////////////
   // ar channel
   //
   ///////////////////////
   
   // 
   // arb_rd_val is 1 cycle ahead of arb_rd_xx_q
   //
   //
   // scenario 0
   //
   // arb_rd_val           : _-_____
   // ext_biu_ar_ready     : _____-_
   //
   // ar_valid_in          : _----__
   // ar_valid_q           : __----_
   // biu_ext_ar_valid     : __----_ 

   // scenario 1
   // 
   // arb_rd_val           : _-_____
   // ext_biu_ar_ready     : ---____
   //
   // ar_valid_in          : _-_____
   // ar_valid_q           : __-____ 
   // biu_ext_ar_valid     : __-____ 


   wire ar_valid_in;
   wire ar_valid_q;

   assign ar_valid_in = (ar_valid_q & ~ext_biu_ar_ready) | arb_rd_val; 
   assign biu_ext_ar_valid = ar_valid_q;

   dffrl_s #(1) ar_valid_reg (
      .din   (ar_valid_in),
      .clk   (clk),
      .rst_l (resetn),
      .q     (ar_valid_q), 
      .se(), .si(), .so());
   



   //           1                  0                   0
   //           1                  0                   1
   //           0                  1                   0
   //           1                  1                   1
   assign axi_ar_ready = ~(biu_ext_ar_valid & ~ext_biu_ar_ready);

   wire ar_enable;
   assign ar_enable = axi_ar_ready & arb_rd_val;


   wire [3:0]  arb_rd_id_q;
   wire [31:0] arb_rd_addr_q; 
   wire [1:0]  arb_rd_burst_q;
   wire [7:0]  arb_rd_len_q;
   wire [2:0]  arb_rd_size_q;
   wire        arb_rd_lock_q;
   wire [3:0]  arb_rd_cache_q;
   wire [2:0]  arb_rd_prot_q;


   wire [56:0] arb_rd_in;
   wire [56:0] arb_rd_q;

   assign arb_rd_in = {arb_rd_id,
                       arb_rd_addr,
                       arb_rd_len,
                       arb_rd_size,
                       arb_rd_burst,
                       arb_rd_lock,
                       arb_rd_cache,
                       arb_rd_prot
                       };

   dffrle_s #(57) arb_rd_reg (
      .din   (arb_rd_in),
      .rst_l (resetn),
      .en    (ar_enable),  
//      buffered here for timing's sake, arbitrated     
//      request should be sent out immediately, 
//
//      so, only buffered for one cycle (WRONG!), these signals also need to
//      be registered, to wait for the ar_ready 
      .clk   (clk),
      .q     (arb_rd_q),
      .se(), .si(), .so());

   assign {arb_rd_id_q,
	   arb_rd_addr_q,
	   arb_rd_len_q,
	   arb_rd_size_q,
           arb_rd_burst_q,
           arb_rd_lock_q,
           arb_rd_cache_q,
           arb_rd_prot_q
	   } = arb_rd_q;


   assign biu_ext_ar_id = arb_rd_id_q;
   assign biu_ext_ar_addr = arb_rd_addr_q;
   assign biu_ext_ar_len = arb_rd_len_q;
   assign biu_ext_ar_size = arb_rd_size_q;
   assign biu_ext_ar_burst = arb_rd_burst_q;
   assign biu_ext_ar_lock = arb_rd_lock_q;
   assign biu_ext_ar_cache = arb_rd_cache_q;
   assign biu_ext_ar_prot = arb_rd_prot_q;



   // r channel

   wire r_fin;
   assign r_fin = ext_biu_r_valid & biu_ext_r_ready;

   assign biu_ext_r_ready = 1'b1;

   // now, r channel data not registered after received

//   wire [38:0] r_in;
//   wire [38:0] r_q;
//
//   assign r_in = {ext_biu_r_data,
//	          ext_biu_r_id,
//	          ext_biu_r_last,
//	          ext_biu_r_resp
//	          };
//
//   dffrle_s #(39) r_reg (
//      .din   (r_in),
//      .clk   (clk),
//      .rst_l (resetn),
//      .en    (ext_biu_r_valid),
//      .q     (r_q), 
//      .se(), .si(), .so());
//	   
//   wire [31:0] r_data_q;
//   wire [3:0]  r_id_q;
//   wire        r_last_q;
//   wire [1:0]  r_resp_q;
//
//   assign { r_data_q,
//            r_id_q,
//	    r_last_q,
//	    r_resp_q } = r_q;
//

   wire rdata_val;

   //assign rdata_val = r_fin & ext_biu_r_last
   //                   & ~(|ext_biu_r_resp) // rresp should be 0 to indicate no error
   //                   ;
   assign rdata_val = r_fin 
                      & ~(|ext_biu_r_resp) // rresp should be 0 to indicate no error
                      ;

   assign axi_rdata_ifu_val = rdata_val & axi_rdata_last & (ext_biu_r_id == AXI_RID_IFU);
   assign axi_rdata_lsu_val = rdata_val & axi_rdata_last & (ext_biu_r_id == AXI_RID_LSU);
   assign axi_rdata_icu_val = rdata_val & (ext_biu_r_id == AXI_RID_ICU);

   assign axi_rdata = ext_biu_r_data;

   assign axi_rdata_last = ext_biu_r_last;



   ///////////////////////
   // aw channel
   //
   ///////////////////////

   // 
   // arb_wr_aw_val is 1 cycle ahead of arb_wr_aw_xx_q
   //
   //
   // scenario 0
   //
   // arb_wr_aw_val        : _-_____
   // ext_biu_aw_ready     : _____-_
   //
   // aw_valid_in          : _----__
   // aw_valid_q           : __----_
   // biu_ext_aw_valid     : __----_ 

   // scenario 1
   // 
   // arb_wr_aw_val        : _-_____
   // ext_biu_aw_ready     : ---____
   //
   // aw_valid_in          : _-_____
   // aw_valid_q           : __-____ 
   // biu_ext_aw_valid     : __-____ 

   wire aw_valid_in;
   wire aw_valid_q;

   assign aw_valid_in = (aw_valid_q & ~ext_biu_aw_ready) | arb_wr_aw_val; 
   assign biu_ext_aw_valid = aw_valid_q;

   dffrl_s #(1) aw_valid_reg (
      .din   (aw_valid_in),
      .clk   (clk),
      .rst_l (resetn),
      .q     (aw_valid_q), 
      .se(), .si(), .so());


   assign axi_aw_ready = ~(biu_ext_aw_valid & ~ext_biu_aw_ready);

   wire aw_enable;
   assign aw_enable = axi_aw_ready & arb_wr_aw_val;


   wire [3:0]  arb_wr_aw_id_q;
   wire [31:0] arb_wr_aw_addr_q;
   wire [7:0]  arb_wr_aw_len_q;
   wire [2:0]  arb_wr_aw_size_q;
   wire [1:0]  arb_wr_aw_burst_q;
   wire        arb_wr_aw_lock_q;
   wire [3:0]  arb_wr_aw_cache_q;
   wire [2:0]  arb_wr_aw_prot_q;

   wire [56:0] arb_wr_aw_in;
   wire [56:0] arb_wr_aw_q;

   assign arb_wr_aw_in = {arb_wr_aw_id,
                          arb_wr_aw_addr,
                          arb_wr_aw_len,
                          arb_wr_aw_size,
                          arb_wr_aw_burst,
                          arb_wr_aw_lock,
                          arb_wr_aw_cache,
                          arb_wr_aw_prot
                          };

   dffrle_s #(57) arb_wr_aw_reg (
      .din   (arb_wr_aw_in),
      .rst_l (resetn),
      .en    (aw_enable),  
      .clk   (clk),
      .q     (arb_wr_aw_q),
      .se(), .si(), .so());

   assign {arb_wr_aw_id_q,
           arb_wr_aw_addr_q,
           arb_wr_aw_len_q,
           arb_wr_aw_size_q,
           arb_wr_aw_burst_q,
           arb_wr_aw_lock_q,
           arb_wr_aw_cache_q,
           arb_wr_aw_prot_q
	   } = arb_wr_aw_q;


   assign biu_ext_aw_id = arb_wr_aw_id_q;
   assign biu_ext_aw_addr = arb_wr_aw_addr_q;
   assign biu_ext_aw_len = arb_wr_aw_len_q;
   assign biu_ext_aw_size = arb_wr_aw_size_q;
   assign biu_ext_aw_burst = arb_wr_aw_burst_q;
   assign biu_ext_aw_lock  = arb_wr_aw_lock_q;
   assign biu_ext_aw_cache = arb_wr_aw_cache_q;
   assign biu_ext_aw_prot  = arb_wr_aw_prot_q;



   ///////////////////////
   // w channel
   //
   ///////////////////////

   wire w_valid_in;
   wire w_valid_q;

   assign w_valid_in = (w_valid_q & ~ext_biu_w_ready) | arb_wr_w_val; 
   assign biu_ext_w_valid = w_valid_q;

   dffrl_s #(1) w_valid_reg (
      .din   (w_valid_in),
      .clk   (clk),
      .rst_l (resetn),
      .q     (w_valid_q), 
      .se(), .si(), .so());


   assign axi_w_ready = ~(biu_ext_w_valid & ~ext_biu_w_ready);

   wire w_enable = axi_w_ready & arb_wr_w_val;

   wire [3:0]  arb_wr_w_id_q;
   wire [63:0] arb_wr_w_data_q;
   wire [7:0]  arb_wr_w_strb_q;
   wire        arb_wr_w_last_q;

   wire [76:0] arb_wr_w_in;
   wire [76:0] arb_wr_w_q;


   assign arb_wr_w_in = {arb_wr_w_id,
	                 arb_wr_w_data,
		         arb_wr_w_strb,
		         arb_wr_w_last
			 };

   dffrle_s #(77) arb_wr_w_reg (
      .din   (arb_wr_w_in),
      .rst_l (resetn),
      .en    (w_enable),  
      .clk   (clk),
      .q     (arb_wr_w_q),
      .se(), .si(), .so());

   assign {arb_wr_w_id_q,
	   arb_wr_w_data_q,
           arb_wr_w_strb_q,
           arb_wr_w_last_q
	   } = arb_wr_w_q;



   assign biu_ext_w_id = arb_wr_w_id_q;
   assign biu_ext_w_data = arb_wr_w_data_q;
   assign biu_ext_w_strb = arb_wr_w_strb_q;
   assign biu_ext_w_last = arb_wr_w_last_q;



   // b channel
   wire b_fin;
   assign b_fin = ext_biu_b_valid & biu_ext_b_ready;

   assign biu_ext_b_ready = 1'b1;
   assign axi_write_lsu_val = b_fin & (ext_biu_b_id == AXI_WID_LSU);


endmodule
