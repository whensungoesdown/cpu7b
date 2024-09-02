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





//   // 
//   // priority lsu_read lsu_write ifu_fetch
//   // 
//
//   // they are actually ifu_fetch_e lsu_read_e lsu_write_e
//   wire                ifu_fetch;
//   wire                lsu_read;
//   wire                lsu_write;
//
//   wire                ifu_fetch_f;
//   wire                lsu_read_m;
//   wire                lsu_write_m;
//
//
//   // todo: do fetch later, should be the same mechanism as data req takes
//
//   assign ifu_fetch = inst_req & ~lsu_write & ~lsu_read;
//   assign lsu_read  = data_req & ~lsu_write;
//   assign lsu_write = data_req & data_wr;
//
//   assign lsu_read_m  = req_rd_busy;
//   assign lsu_write_m = req_wr_busy;
//
//   dffrl_s #(1) ifu_fetch_bf2f_reg (
//      .din   (ifu_fetch),
//      .clk   (aclk),
//      .rst_l (aresetn),
//      .q     (ifu_fetch_f), 
//      .se(), .si(), .so());
//
////   dffrl_s #(1) lsu_read_e2m_reg (
////      .din   (lsu_read),
////      .clk   (aclk),
////      .rst_l (aresetn),
////      .q     (lsu_read_m), 
////      .se(), .si(), .so());
////
////   dffrl_s #(1) lsu_write_e2m_reg (
////      .din   (lsu_write),
////      .clk   (aclk),
////      .rst_l (aresetn),
////      .q     (lsu_write_m), 
////      .se(), .si(), .so());
//
//
//   //
//   // code review, should combine all these to ar bus, ar payload
//   //
   



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
   

//   wire new_ar;
//   //assign new_ar = ifu_fetch | lsu_read;
//   assign new_ar = arb_rd_val;

//   wire ar_bus_en;
//   assign ar_bus_en = new_ar;
//
//   wire [`Larid+`Laraddr+`Larlen+`Larsize+`Larburst+`Larlock+`Larcache+`Larprot-1:0] ar_bus_in;
//   wire [`Larid+`Laraddr+`Larlen+`Larsize+`Larburst+`Larlock+`Larcache+`Larprot-1:0] ar_bus_q;
//   wire [`Larid+`Laraddr+`Larlen+`Larsize+`Larburst+`Larlock+`Larcache+`Larprot-1:0] ar_bus;
//
//   wire [`Larid-1:0]    ar_id_in;
//   wire [`Laraddr-1:0]  ar_addr_in;
//   wire [`Larlen-1:0]   ar_len_in;
//   wire [`Larsize-1:0]  ar_size_in;
//   wire [`Larburst-1:0] ar_burst_in;
//   wire [`Larlock-1:0]  ar_lock_in;
//   wire [`Larcache-1:0] ar_cache_in;
//   wire [`Larprot-1:0]  ar_prot_in;
//
//
//   //assign ar_id_in     = ifu_fetch ? `IFU_ID : `LSU_ID; // lsu_read & lsu_write use the same LSU_ID
//   //assign ar_addr_in   = {inst_addr & {32{ifu_fetch}}} | {data_addr & {32{lsu_read}}};
//
//   assign ar_id_in     = arb_rd_id;
//   assign ar_addr_in   = arb_rd_addr;
//
//   //assign ar_len_in    = `Larlen'h0;
//   //assign ar_size_in   = `Larsize'h2; // 32 bits
//   assign ar_len_in    = biu_ext_ar_len;
//   assign ar_size_in   = biu_ext_ar_size;
//
//   assign ar_burst_in  = `Larburst'h0;
//   assign ar_lock_in   = `Larlock'h0;
//   assign ar_cache_in  = `Larcache'h0;
//   assign ar_prot_in   = `Larprot'h0;
//
//   assign ar_bus_in = { ar_id_in,
//                        ar_addr_in,
//			ar_len_in,
//			ar_size_in,
//			ar_burst_in,
//			ar_lock_in,
//			ar_cache_in,
//			ar_prot_in
//			};
//
//   assign ar_bus = ar_bus_in | ({`Larid+`Laraddr+`Larlen+`Larsize+`Larburst+`Larlock+`Larcache+`Larprot{~new_ar}} & ar_bus_q);
//
//
//   dffrle_s #(`Larid+`Laraddr+`Larlen+`Larsize+`Larburst+`Larlock+`Larcache+`Larprot) ar_bus_reg (
//      .din   (ar_bus_in),
//      .clk   (clk),
//      .rst_l (resetn),
//      .en    (ar_bus_en),
//      .q     (ar_bus_q), 
//      .se(), .si(), .so());
//
//
//
////   //
////   // read_busy
////   //
////   
////
////   //
////   //
////   // new_ar             : __-____
////   // read_fin           : _____-_
////   //
////   // read_busy_in       : __---__
////   // read_busy_q        : ___---_
////
////
////   wire read_busy_in;
////   wire read_busy_q;
////
////   wire read_fin;
////   assign read_fin = rvalid & rready;
////
////   assign read_busy_in = (read_busy_q | new_ar) & (~read_fin);
////
////   dffrl_s #(1) read_busy_reg (
////      .din   (read_busy_in),
////      .clk   (aclk),
////      .rst_l (aresetn),
////      .q     (read_busy_q), 
////      .se(), .si(), .so());    
////
////   //
////   // cannot use read_busy_in here, read_busy_in and inst_fetch in ifu_fdp
////   // form a loop.
////   // registed signal breaks loop
////   //
////   assign inst_busy = read_busy_q;
//
//
//   assign {biu_ext_ar_id,
//	   biu_ext_ar_addr,
//	   biu_ext_ar_len,
//	   biu_ext_ar_size,
//	   biu_ext_ar_burst,
//	   biu_ext_ar_lock,
//	   biu_ext_ar_cache,
//	   biu_ext_ar_prot
//	   } = ar_bus & {`Larid+`Laraddr+`Larlen+`Larsize+`Larburst+`Larlock+`Larcache+`Larprot{biu_ext_ar_valid}}; 
//


   assign biu_ext_ar_id = arb_rd_id_q;
   assign biu_ext_ar_addr = arb_rd_addr_q;
   assign biu_ext_ar_len = arb_rd_len_q;
   assign biu_ext_ar_size = arb_rd_size_q;
   assign biu_ext_ar_burst = arb_rd_burst_q;
   assign biu_ext_ar_lock = arb_rd_lock_q;
   assign biu_ext_ar_cache = arb_rd_cache_q;
   assign biu_ext_ar_prot = arb_rd_prot_q;





   assign biu_ext_r_ready = 1'b1;


   //wire inst_valid;

   ////assign inst_valid = (rready & rvalid) & ifu_fetch_f 
   ////                      & ~(|rresp); // rresp should be 0 to indicate no error, only OKAY
   //assign inst_valid = (rready & rvalid) & ifu_fetch_f 
   //                      & ~(|rresp) // rresp should be 0 to indicate no error, only OKAY
   //     		 & (rid == `IFU_ID);
   //assign inst_rdata_f = (rdata          ) & {`GRLEN{ifu_fetch_f}};




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

   // arb_rd_val is regsitered in rd_arbiter 
//   assign rdata_val = r_fin & arb_rd_val & r_last
//                      & ~(|r_resp) // rresp should be 0 to indicate no error
//                      ;
   assign rdata_val = r_fin & ext_biu_r_last
                      & ~(|ext_biu_r_resp) // rresp should be 0 to indicate no error
                      ;

   assign axi_rdata_ifu_val = rdata_val & (ext_biu_r_id == AXI_RID_IFU);
   assign axi_rdata_lsu_val = rdata_val & (ext_biu_r_id == AXI_RID_LSU);

   assign axi_rdata = ext_biu_r_data;

   // put cancel outside of c7bbiu_axi_interface

//   wire inst_cancel_q;
//
//   dffrle_s #(1) inst_cancel_reg (
//      .din   (inst_cancel),
//      .clk   (aclk),
//      .rst_l (aresetn),
//      .en    (inst_cancel | inst_valid),
//      .q     (inst_cancel_q), 
//      .se(), .si(), .so());
//
//
//   assign inst_valid_f = inst_valid & (~inst_cancel_q);




   //assign data_data_ok = (rready & rvalid) & lsu_read; // uty: test + (lsu_read | lsu_write);
   
   // rready & rvalid belong to the previous request
   //assign data_data_ok = (rready & rvalid) & (lsu_read | lsu_write); // lsu_read_e lsu_write data_data_ok_e
   //assign data_rdata   = (rdata          ) & {`GRLEN{lsu_read}};
//   assign data_rdata_m   = (rdata          ) & {`GRLEN{lsu_read_m}};



//   wire [`Lawaddr-1:0] awaddr_in;
//   wire [`Lawaddr-1:0] awaddr_q;
//
//   wire                new_aw;
//
//   assign awaddr_in = data_addr;
//
//   dffrle_s #(`Lawaddr) awaddr_reg (
//      .din   (awaddr_in),
//      .clk   (aclk),
//      .rst_l (aresetn),
//      .en    (data_wr),
//      .q     (awaddr_q), 
//      .se(), .si(), .so());
//
//   assign new_aw = lsu_write;
   //assign awaddr = data_addr;     

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




   //wire [`Lwdata-1:0] wdata_nxt;
//   assign wdata_nxt = data_wdata;
//
//   dffrle_s #(`Lwdata) wdata_reg (
//      .din   (wdata_nxt),
//      .clk   (aclk),
//      .rst_l (aresetn),
//      .en    (data_wr),
//      .q     (wdata), 
//      .se(), .si(), .so());
   //assign wdata = data_wdata;

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

   // set unimplemented signals to 0 
   //assign awid    = `Lawid'b0;
//   assign awid    = `LSU_ID; // ifu fetch never writes
//   //assign awaddr  = `Lawaddr'b0;
//   assign awlen   = `Lawlen'b0;
//   assign awsize  = `Lawsize'h2; // 32 bits
//   assign awburst = `Lawburst'b0;
//   assign awlock  = `Lawlock'b0;
//   assign awcache = `Lawcache'b0;
//   assign awprot  = `Lawprot'b0;
   //assign awvalid = 1'b0;

   assign biu_ext_aw_id = AXI_WID_LSU;
   assign biu_ext_aw_len = arb_wr_len;
   assign biu_ext_aw_size = arb_wr_size;

   assign biu_ext_aw_burst = `Lawburst'b0;
   assign biu_ext_aw_lock  = `Lawlock'b0;
   assign biu_ext_aw_cache = `Lawcache'b0;
   assign biu_ext_aw_prot  = `Lawprot'b0;



   //assign wid     = `Lwid'b0;
//   assign wid     = `LSU_ID;

   assign biu_ext_w_id = AXI_WID_LSU;

   //assign wdata   = `Lwdata'b0;
   //assign wstrb   = `Lwstrb'b0;
   //
//   assign wstrb   = data_wstrb;

   assign biu_ext_w_strb = arb_wr_strb;

//   assign wlast   = 1'b1;
   assign biu_ext_w_last = arb_wr_last;

   //assign wvalid  = 1'b0;

   //assign bready  = 1'b0;

endmodule
