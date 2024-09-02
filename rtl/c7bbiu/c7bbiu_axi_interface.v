module c7bbiu_axi_interface(
      input            clk   ,
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

      // AXI Read Address Channel
      input            ext_biu_ar_ready	 ,
      output           biu_ext_ar_valid	 ,
      output [3:0]     biu_ext_ar_id     ,
      output [31:0]    biu_ext_ar_addr ,
      output [7:0]     biu_ext_ar_len	 ,
      output [2:0]     biu_ext_ar_size ,
      output [1:0]     biu_ext_ar_burst,
      output           biu_ext_ar_lock ,
      output [3:0]     biu_ext_ar_cache,
      output [2:0]     biu_ext_ar_prot ,

      // AXI Read Data Channel
      output           biu_ext_r_ready,
      input            ext_biu_r_valid,
      input  [3:0]     ext_biu_r_id   ,
      input  [31:0]    ext_biu_r_data ,
      input            ext_biu_r_last ,
      input  [1:0]     ext_biu_r_resp ,

      // Arbitrated write signals
      input            arb_wr_val ,
      input [3:0]      arb_wr_id  ,
      input [31:0]     arb_wr_addr,
      input [7:0]      arb_wr_len ,
      input [2:0]      arb_wr_size,

      input  [31:0]    arb_wr_data,
      input  [3:0]     arb_wr_strb,
      input            arb_wr_last,

      // AXI Write address channel
      input            ext_biu_aw_ready,
      output           biu_ext_aw_valid,
      output [3:0]     biu_ext_aw_id   ,
      output [31:0]    biu_ext_aw_addr ,
      output [7:0]     biu_ext_aw_len  ,
      output [2:0]     biu_ext_aw_size ,
      output [1:0]     biu_ext_aw_burst,
      output           biu_ext_aw_lock,
      output [3:0]     biu_ext_aw_cache,
      output [2:0]     biu_ext_aw_prot,

      // AXI Write data channel
      input            ext_biu_w_ready,
      output           biu_ext_w_valid,
      output [3:0]     biu_ext_w_id   ,
      output [31:0]    biu_ext_w_data ,
      output [3:0]     biu_ext_w_strb ,
      output           biu_ext_w_last ,

      // AXI Write response channel
      output           biu_ext_b_ready,
      input            ext_biu_b_valid,
      input  [3:0]     ext_biu_b_id   ,
      input  [1:0]     ext_biu_b_resp,


      // Read data from the AXI interface
      output [31:0]    axi_rdata,
      output           axi_rdata_ifu_val,
      output           axi_rdata_lsu_val, 

      // Write data to the AXI interface
      output           axi_write_lsu_val
   );

`include "axi_types.v"

   wire        arb_rd_val_q;
   wire [3:0]  arb_rd_id_q;
   wire [31:0] arb_rd_addr_q; 
   wire [1:0]  arb_rd_burst_q;
   wire [7:0]  arb_rd_len_q;
   wire [2:0]  arb_rd_size_q;
   wire        arb_rd_lock_q;
   wire [3:0]  arb_rd_cache_q;
   wire [2:0]  arb_rd_prot_q;


   wire [57:0] arb_rd_in;
   wire [57:0] arb_rd_q;

   assign arb_rd_in = {arb_rd_val,
                       arb_rd_id,
                       arb_rd_addr,
                       arb_rd_len,
                       arb_rd_size,
                       arb_rd_burst,
                       arb_rd_lock,
                       arb_rd_cache,
                       arb_rd_prot
                       };




   dffrle_s #(58) arb_rd_reg (
      .din   (arb_rd_in),
      .rst_l (resetn),
      .en    (arb_rd_val),
      .clk   (clk),
      .q     (arb_rd_q),
      .se(), .si(), .so());

   assign {arb_rd_val_q,
	   arb_rd_id_q,
	   arb_rd_addr_q,
	   arb_rd_len_q,
	   arb_rd_size_q,
           arb_rd_burst_q,
           arb_rd_lock_q,
           arb_rd_cache_q,
           arb_rd_prot_q
	   } = arb_rd_q;



   wire r_fin;
   assign r_fin = ext_biu_r_valid & biu_ext_r_ready;

   //
   // rd_busy            : ___---_
   //
   // arb_rd_val_q       : __-____
   // rvalid & rready    : _____-_
   wire rd_busy_in;
   wire rd_busy_q;

   // uty: review      ~arb_wr_val is still needed?
   //
   // (r_fin & ~arb_wr_val) indicates that "r_fin" should be the state that follows when data_req goes low.
   // also, when rd_busy_q is 1, arb_wr_val should not be set to 1 again
   assign rd_busy_in = (rd_busy_q | arb_rd_val_q) & ~(r_fin & ~arb_wr_val);

   dffrl_s #(1) rd_busy_reg (
      .din   (rd_busy_in),
      .clk   (clk),
      .rst_l (resetn),
      .q     (rd_busy_q), 
      .se(), .si(), .so());    



   wire b_fin;
   assign b_fin = ext_biu_b_valid & biu_ext_b_ready;

   //
   // wr_busy_q          : ___---_
   //
   // arb_wr_val         : __-____
   // bvalid & bready    : _____-_
   //
   wire wr_busy_in;
   wire wr_busy_q;

   assign wr_busy_in = (wr_busy_q | arb_wr_val) & ~(b_fin & ~arb_wr_val);


   dffrl_s #(1) wr_busy_reg (
      .din   (wr_busy_in),
      .clk   (clk),
      .rst_l (resetn),
      .q     (wr_busy_q), 
      .se(), .si(), .so());





   ///////////////////////
   // ar bus
   //
   ///////////////////////


   // scenario 0
   //
   // arb_rd_val_q         : _-_____
   // ext_biu_ar_ready     : _____-_
   //
   // ar_valid_in          : _----__
   // ar_valid_q           : __----_
   // biu_ext_ar_valid     : _-----_ 

   // scenario 1
   // 
   // arb_rd_val_q         : _-_____
   // ext_biu_ar_ready     : _-_____
   //
   // ar_valid_in          : _______
   // ar_valid_q           : _______ 
   // biu_ext_ar_valid     : _-_____ 

   // scenario 2
   // 
   // arb_rd_val_q         : -______
   // ext_biu_ar_ready     : -______
   //
   // ar_valid_in          : _______
   // ar_valid_q           : -______ 
   // biu_ext_ar_valid     : -______ 

   wire ar_valid_in;
   wire ar_valid_q;

   
   assign ar_valid_in = (ar_valid_q | arb_rd_val_q) & (~ext_biu_ar_ready); 
   assign biu_ext_ar_valid = ar_valid_q | arb_rd_val_q;

   dffrl_s #(1) ar_valid_reg (
      .din   (ar_valid_in),
      .clk   (clk),
      .rst_l (resetn),
      .q     (ar_valid_q), 
      .se(), .si(), .so());
   


   assign biu_ext_ar_id = arb_rd_id_q;
   assign biu_ext_ar_addr = arb_rd_addr_q;
   assign biu_ext_ar_len = arb_rd_len_q;
   assign biu_ext_ar_size = arb_rd_size_q;
   assign biu_ext_ar_burst = arb_rd_burst_q;
   assign biu_ext_ar_lock = arb_rd_lock_q;
   assign biu_ext_ar_cache = arb_rd_cache_q;
   assign biu_ext_ar_prot = arb_rd_prot_q;



   assign biu_ext_r_ready = 1'b1;



   wire [38:0] r_in;
   wire [38:0] r_q;

   assign r_in = {ext_biu_r_data,
	          ext_biu_r_id,
	          ext_biu_r_last,
	          ext_biu_r_resp
	          };

   dffrle_s #(39) r_reg (
      .din   (r_in),
      .clk   (clk),
      .rst_l (resetn),
      .en    (ext_biu_r_valid),
      .q     (r_q), 
      .se(), .si(), .so());
	   
   wire [31:0] r_data_q;
   wire [3:0]  r_id_q;
   wire        r_last_q;
   wire [1:0]  r_resp_q;

   assign { r_data_q,
            r_id_q,
	    r_last_q,
	    r_resp_q } = r_q;


   wire rdata_val;

   assign rdata_val = r_fin & ext_biu_r_last
                      & ~(|ext_biu_r_resp) // rresp should be 0 to indicate no error
                      ;

   assign axi_rdata_ifu_val = rdata_val & (ext_biu_r_id == AXI_RID_IFU);
   assign axi_rdata_lsu_val = rdata_val & (ext_biu_r_id == AXI_RID_LSU);

   assign axi_rdata = ext_biu_r_data;


   assign biu_ext_aw_addr = arb_wr_addr;


   // arb_wr_val         : _-_____
   // ext_biu_aw_ready   : _____-_
   // aw_valid_in        : _----__
   // aw_valid_q         : __----_
   // biu_ext_aw_valid   : _-----_ 
   

   wire aw_valid_in;
   wire aw_valid_q;

   assign aw_valid_in = (aw_valid_q | arb_wr_val) & (~ext_biu_aw_ready); 
   dffrl_s #(1) aw_valid_reg (
      .din   (aw_valid_in),
      .clk   (clk),
      .rst_l (resetn),
      .q     (aw_valid_q), 
      .se(), .si(), .so());
   
   assign biu_ext_aw_valid = aw_valid_q | arb_wr_val;

   assign biu_ext_w_data = arb_wr_data;



   wire w_valid_in;
   wire w_valid_q;


   // arb_wr_val         : _-_____
   // ext_biu_w_ready    : _____-_
   // w_valid_in         : _----__
   // w_valid_q          : __----_
   // biu_ext_w_valid    : _-----_ 
   

   assign w_valid_in = (w_valid_q | arb_wr_val) & (~ext_biu_w_ready); 
   dffrl_s #(1) w_valid_reg (
      .din   (w_valid_in),
      .clk   (clk),
      .rst_l (resetn),
      .q     (w_valid_q), 
      .se(), .si(), .so());
   
   assign biu_ext_w_valid = w_valid_q | arb_wr_val;



   //assign bready = 1'b1;
   assign biu_ext_b_ready = 1'b1;


   //assign data_data_ok_m = (rready & rvalid) & (lsu_read_m | lsu_write_m); // lsu_read_e lsu_write data_data_ok_e
   //// should check bresp value, then signal data_data_ok
   //assign data_data_ok_m = ((rready & rvalid) & lsu_read_m) | ((bready & bvalid) & lsu_write_m); 
//   assign data_data_ok_m = ((rready & rvalid) & lsu_read_m & (rid == `LSU_ID)) | ((bready & bvalid) & lsu_write_m & (bid == `LSU_ID)); 

   assign axi_write_lsu_val = b_fin & (ext_biu_b_id == AXI_WID_LSU);


   assign biu_ext_aw_id = AXI_WID_LSU;
   assign biu_ext_aw_len = arb_wr_len;
   assign biu_ext_aw_size = arb_wr_size;

   assign biu_ext_aw_burst = `Lawburst'b0;
   assign biu_ext_aw_lock  = `Lawlock'b0;
   assign biu_ext_aw_cache = `Lawcache'b0;
   assign biu_ext_aw_prot  = `Lawprot'b0;



   assign biu_ext_w_id = AXI_WID_LSU;
   assign biu_ext_w_strb = arb_wr_strb;
   assign biu_ext_w_last = arb_wr_last;


endmodule
