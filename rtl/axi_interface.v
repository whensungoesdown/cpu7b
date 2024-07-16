`include "defines.vh"

`define IFU_ID              4'b0000
`define LSU_ID              4'b0001

module axi_interface(
   
   input                        aclk   ,
   input                        aresetn,
   //  axi_control
   //ar
   output [`Larid   -1 :0]      arid   ,
   output [`Laraddr -1 :0]      araddr ,
   output [`Larlen  -1 :0]      arlen  ,
   output [`Larsize -1 :0]      arsize ,
   output [`Larburst-1 :0]      arburst,
   output [`Larlock -1 :0]      arlock ,
   output [`Larcache-1 :0]      arcache,
   output [`Larprot -1 :0]      arprot ,
   output                       arvalid,
   input                        arready,
   //r
   input  [`Lrid    -1 :0]      rid    ,
   input  [`Lrdata  -1 :0]      rdata  ,
   input  [`Lrresp  -1 :0]      rresp  ,
   input                        rlast  ,
   input                        rvalid ,
   output                       rready ,

   //aw
   output [`Lawid   -1 :0]      awid   ,
   output [`Lawaddr -1 :0]      awaddr ,
   output [`Lawlen  -1 :0]      awlen  ,
   output [`Lawsize -1 :0]      awsize ,
   output [`Lawburst-1 :0]      awburst,
   output [`Lawlock -1 :0]      awlock ,
   output [`Lawcache-1 :0]      awcache,
   output [`Lawprot -1 :0]      awprot ,
   output                       awvalid,
   input                        awready,
   //w
   output [`Lwid    -1 :0]      wid    ,
   output [`Lwdata  -1 :0]      wdata  ,
   output [`Lwstrb  -1 :0]      wstrb  ,
   output                       wlast  ,
   output                       wvalid ,
   input                        wready ,
   //b
   input  [`Lbid    -1 :0]      bid    ,
   input  [`Lbresp  -1 :0]      bresp  ,
   input                        bvalid ,
   output                       bready ,


   input                        inst_req,    
   output                       inst_busy,    
   input  [`GRLEN-1:0]          inst_addr,
   input                        inst_cancel,
   output                       inst_addr_ok,
   //output [127:0]               inst_rdata,
   output [`GRLEN-1:0]          inst_rdata_f,    // read 32 bits
   output                       inst_valid_f,    // uty: test output only do inst_rdata_f inst_valid_f, do the reset later
   output [  1:0]               inst_count,
   output                       inst_uncache,
   output                       inst_exception,
   output [  5:0]               inst_exccode, 

   input                        data_req,       
   input  [`GRLEN-1:0]          data_pc,        
   input                        data_wr,        
   input  [3 :0]                data_wstrb,     
   input  [`GRLEN-1:0]          data_addr,      
   input                        data_cancel_ex2,
   input                        data_cancel,    
   input  [`GRLEN-1:0]          data_wdata,     
   input                        data_recv,      
   input                        data_prefetch,  
   input                        data_ll,        
   input                        data_sc,        

   output [`GRLEN-1:0]          data_rdata_m,  // uty: test   do the rest later    
   output                       data_addr_ok,   
   output                       data_data_ok_m,   
   output [ 5:0]                data_exccode,   
   output                       data_exception, 
   output [`GRLEN-1:0]          data_badvaddr,  
   output                       data_req_empty, 
   output                       data_scsucceed 

   );

   
   //
   // req_rd_busy        : ___---_
   //
   // data_req           : __-____
   // rvalid & rready    : _____-_
   wire req_rd_busy;
   wire req_rd_busy_nxt;

   // ((rvalid & rready) & ~data_req) means (rvalid & rready) should be the one
   // that after data_req goes low
   // also, while req_rd_busy is 1, data_req shold not be 1 again
   assign req_rd_busy_nxt = (req_rd_busy | (data_req & ~data_wr)) & (~((rvalid & rready) & ~data_req));

   dffrl_s #(1) req_rd_busy_reg (
      .din   (req_rd_busy_nxt),
      .clk   (aclk),
      .rst_l (aresetn),
      .q     (req_rd_busy), 
      .se(), .si(), .so());    


   //
   // req_wr_busy        : ___---_
   //
   // data_req & data_wr : __-____
   // bvalid & bready    : _____-_
   wire req_wr_busy;
   wire req_wr_busy_nxt;

   assign req_wr_busy_nxt = (req_wr_busy | (data_req & data_wr)) & (~((bvalid & bready) & ~data_req));

   dffrl_s #(1) req_wr_busy_reg (
      .din   (req_wr_busy_nxt),
      .clk   (aclk),
      .rst_l (aresetn),
      .q     (req_wr_busy), 
      .se(), .si(), .so());

   // 
   // priority lsu_read lsu_write ifu_fetch
   // 

   // they are actually ifu_fetch_e lsu_read_e lsu_write_e
   wire                ifu_fetch;
   wire                lsu_read;
   wire                lsu_write;

   wire                ifu_fetch_f;
   wire                lsu_read_m;
   wire                lsu_write_m;


   // todo: do fetch later, should be the same mechanism as data req takes

   assign ifu_fetch = inst_req & ~lsu_write & ~lsu_read;
   assign lsu_read  = data_req & ~lsu_write;
   assign lsu_write = data_req & data_wr;

   assign lsu_read_m  = req_rd_busy;
   assign lsu_write_m = req_wr_busy;

   dffrl_s #(1) ifu_fetch_bf2f_reg (
      .din   (ifu_fetch),
      .clk   (aclk),
      .rst_l (aresetn),
      .q     (ifu_fetch_f), 
      .se(), .si(), .so());

//   dffrl_s #(1) lsu_read_e2m_reg (
//      .din   (lsu_read),
//      .clk   (aclk),
//      .rst_l (aresetn),
//      .q     (lsu_read_m), 
//      .se(), .si(), .so());
//
//   dffrl_s #(1) lsu_write_e2m_reg (
//      .din   (lsu_write),
//      .clk   (aclk),
//      .rst_l (aresetn),
//      .q     (lsu_write_m), 
//      .se(), .si(), .so());


   //
   // code review, should combine all these to ar bus, ar payload
   //
   

   ///////////////////////
   // ar bus
   //
   ///////////////////////


   // scenario 0
   //
   // ifu_fetch | lsu_read : _-_____
   // arready              : _____-_
   //
   // arvalid_in           : _----__
   // arvalid_q            : __----_
   // arvalid              : _-----_ 

   // scenario 1
   // 
   // ifu_fetch | lsu_read : _-_____
   // arready              : _-_____
   //
   // arvalid_in           : _______
   // arvalid_q            : _______ 
   // arvalid              : _-_____ 

   // scenario 2
   // 
   // ifu_fetch | lsu_read : -______
   // arready              : -______
   //
   // arvalid_in           : _______
   // arvalid_q            : -______ 
   // arvalid              : -______ 

   wire arvalid_in;
   wire arvalid_q;

   assign arvalid_in = (arvalid_q | (ifu_fetch | lsu_read)) & (~arready); 
   assign arvalid = arvalid_q | (ifu_fetch | lsu_read);

   dffrl_s #(1) arvalid_reg (
      .din   (arvalid_in),
      .clk   (aclk),
      .rst_l (aresetn),
      .q     (arvalid_q), 
      .se(), .si(), .so());
   

   wire new_ar;
   assign new_ar = ifu_fetch | lsu_read;

   wire ar_bus_en;
   assign ar_bus_en = new_ar;

   wire [`Larid+`Laraddr+`Larlen+`Larsize+`Larburst+`Larlock+`Larcache+`Larprot-1:0] ar_bus_in;
   wire [`Larid+`Laraddr+`Larlen+`Larsize+`Larburst+`Larlock+`Larcache+`Larprot-1:0] ar_bus_q;
   wire [`Larid+`Laraddr+`Larlen+`Larsize+`Larburst+`Larlock+`Larcache+`Larprot-1:0] ar_bus;

   wire [`Larid-1:0]    arid_in;
   //wire [`Larid-1:0]    arid_q;

   wire [`Laraddr-1:0]  araddr_in;
   //wire [`Laraddr-1:0]  araddr_q;

   wire [`Larlen-1:0]   arlen_in;
   //wire [`Larlen-1:0]   arlen_q;

   wire [`Larsize-1:0]  arsize_in;
   //wire [`Larsize-1:0]  arsize_q;

   wire [`Larburst-1:0] arburst_in;
   //wire [`Larburst-1:0] arburst_q;

   wire [`Larlock-1:0]  arlock_in;
   //wire [`Larlock-1:0]  arlock_q;

   wire [`Larcache-1:0] arcache_in;
   //wire [`Larcache-1:0] arcache_q;

   wire [`Larprot-1:0]  arprot_in;
   //wire [`Larprot-1:0]  arprot_q;


   assign arid_in     = ifu_fetch ? `IFU_ID : `LSU_ID; // lsu_read & lsu_write use the same LSU_ID
   assign araddr_in   = {inst_addr & {32{ifu_fetch}}} | {data_addr & {32{lsu_read}}};

   assign arlen_in    = `Larlen'h0;
   assign arsize_in   = `Larsize'h2; // 32 bits
   assign arburst_in  = `Larburst'h0;
   assign arlock_in   = `Larlock'h0;
   assign arcache_in  = `Larcache'h0;
   assign arprot_in   = `Larprot'h0;

   assign ar_bus_in = { arid_in,
                        araddr_in,
			arlen_in,
			arsize_in,
			arburst_in,
			arlock_in,
			arcache_in,
			arprot_in
			};

   assign ar_bus = ar_bus_in | ({`Larid+`Laraddr+`Larlen+`Larsize+`Larburst+`Larlock+`Larcache+`Larprot{~new_ar}} & ar_bus_q);

//   assign {arid_q,
//	   araddr_q,
//	   arlen_q,
//	   arsize_q,
//	   arburst_q,
//	   arlock_q,
//	   arcache_q,
//	   arprot_q
//	   } = ar_bus_q & {`Larid+`Laraddr+`Larlen+`Larsize+`Larburst+`Larlock+`Larcache+`Larprot{arvalid}}; 


   dffrle_s #(`Larid+`Laraddr+`Larlen+`Larsize+`Larburst+`Larlock+`Larcache+`Larprot) ar_bus_reg (
      .din   (ar_bus_in),
      .clk   (aclk),
      .rst_l (aresetn),
      .en    (ar_bus_en),
      .q     (ar_bus_q), 
      .se(), .si(), .so());


   //
   // read_busy
   //
   

   //
   //
   // new_ar             : __-____
   // read_fin           : _____-_
   //
   // read_busy_in       : __---__
   // read_busy_q        : ___---_


   wire read_busy_in;
   wire read_busy_q;

   wire read_fin;
   assign read_fin = rvalid & rready;

   assign read_busy_in = (read_busy_q | new_ar) & (~read_fin);

   dffrl_s #(1) read_busy_reg (
      .din   (read_busy_in),
      .clk   (aclk),
      .rst_l (aresetn),
      .q     (read_busy_q), 
      .se(), .si(), .so());    

   //
   // cannot use read_busy_in here, read_busy_in and inst_fetch in ifu_fdp
   // form a loop.
   // registed signal breaks loop
   //
   assign inst_busy = read_busy_q;



//   assign arid      = arid_q;
//   assign araddr    = araddr_q;
//   assign arlen     = arlen_q;
//   assign arsize    = arsize_q;
//   assign arburst   = arburst_q;
//   assign arlock    = arlock_q;
//   assign arcache   = arcache_q;
//   assign arprot    = arprot_q;

   assign {arid,
	   araddr,
	   arlen,
	   arsize,
	   arburst,
	   arlock,
	   arcache,
	   arprot
	   } = ar_bus & {`Larid+`Laraddr+`Larlen+`Larsize+`Larburst+`Larlock+`Larcache+`Larprot{arvalid}}; 



//   wire                arvalid_nxt;
//   wire                arvalid_tmp;
//   
//   //assign arid    = `Larid'h0; 
//   //assign arid    = ifu_fetch ? `IFU_ID : `LSU_ID; // lsu_read & lsu_write use the same LSU_ID
//   assign arlen   = `Larlen'h0;
//   assign arsize  = `Larsize'h2; // 32 bits
//   assign arburst = `Larburst'h0;
//   assign arlock  = `Larlock'h0;
//   assign arcache = `Larcache'h0;
//   assign arprot  = `Larprot'h0;
//
//
//   //
//   // aradd arid are sent out at the first cycle and last until arready
//   //
//
//   wire [`Laraddr-1:0] araddr_nxt;
//   wire [`Laraddr-1:0] araddr_q;
//
//   wire                new_ar;
// 
////   mux2ds #(`GRLEN) mux_araddr (.dout(araddr_nxt),
////	   .in0  (inst_addr),
////	   .in1  (data_addr),
////	   .sel0 (ifu_fetch),
////	   .sel1 (lsu_read));
//   // when lsu_write, ifu_fetch and lsu_read are both 0, then araddr_nxt
//   // becomes x
//   assign araddr_nxt = {inst_addr & {32{ifu_fetch}}} | {data_addr & {32{lsu_read}}};
//
////   dffrle_s #(`Laraddr) araddr_reg (
////      .din   (araddr_nxt),
////      .clk   (aclk),
////      .rst_l (aresetn),
////      .en    (inst_req | data_req),
////      .q     (araddr), 
////      .se(), .si(), .so());
//
//   dffrle_s #(`Laraddr) araddr_reg (
//      .din   (araddr_nxt),
//      .clk   (aclk),
//      .rst_l (aresetn),
//      //.en    (inst_req | data_req),
//      .en    (ifu_fetch | lsu_read),
//      .q     (araddr_q), 
//      .se(), .si(), .so());
//
//   assign new_ar = ifu_fetch | lsu_read;
//   assign araddr = araddr_nxt | ({32{~new_ar}} & araddr_q);
//
//
//   //
//   // this module is a mess, need code review
//   //
//
//   wire [`Larid-1:0] arid_in;
//   wire [`Larid-1:0] arid_q;
//   assign arid_in = ifu_fetch ? `IFU_ID : `LSU_ID; // lsu_read & lsu_write use the same LSU_ID
//
//   dffrle_s #(`Larid) arid_reg (
//      .din   (arid_in),
//      .clk   (aclk),
//      .rst_l (aresetn),
//      //.en    (inst_req | data_req),
//      .en    (ifu_fetch | lsu_read),
//      .q     (arid_q), 
//      .se(), .si(), .so());
//
//   assign arid = arid_in | ({32{~new_ar}} & arid_q);
//
//   
//
//   // ifu_fetch | lsu_read : _-_____
//   // arready              : _____-_
//   //
//   // arvalid_nxt          : _----__
//   // arvalid_tmp          : __----_
//   // arvalid              : _-----_ 
//
//
//   assign arvalid_nxt = (arvalid_tmp | (ifu_fetch | lsu_read)) & (~arready); 
//
//   dffrl_s #(1) arvalid_reg (
//      .din   (arvalid_nxt),
//      .clk   (aclk),
//      .rst_l (aresetn),
//      .q     (arvalid_tmp), 
//      .se(), .si(), .so());
//   
//   assign arvalid = arvalid_tmp | (ifu_fetch | lsu_read);


   assign rready = 1'b1;


   wire inst_valid;

   //assign inst_valid = (rready & rvalid) & ifu_fetch_f 
   //                      & ~(|rresp); // rresp should be 0 to indicate no error, only OKAY
   assign inst_valid = (rready & rvalid) & ifu_fetch_f 
                         & ~(|rresp) // rresp should be 0 to indicate no error, only OKAY
			 & (rid == `IFU_ID);
   assign inst_rdata_f = (rdata          ) & {`GRLEN{ifu_fetch_f}};

   //assign data_data_ok = (rready & rvalid) & lsu_read; // uty: test + (lsu_read | lsu_write);
   
   // rready & rvalid belong to the previous request
   //assign data_data_ok = (rready & rvalid) & (lsu_read | lsu_write); // lsu_read_e lsu_write data_data_ok_e
   //assign data_rdata   = (rdata          ) & {`GRLEN{lsu_read}};
   assign data_rdata_m   = (rdata          ) & {`GRLEN{lsu_read_m}};


   wire inst_cancel_q;

   dffrle_s #(1) inst_cancel_reg (
      .din   (inst_cancel),
      .clk   (aclk),
      .rst_l (aresetn),
      .en    (inst_cancel | inst_valid),
      .q     (inst_cancel_q), 
      .se(), .si(), .so());


   assign inst_valid_f = inst_valid & (~inst_cancel_q);



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
   assign awaddr = data_addr;     

   // data_req & data_wr : _-_____
   // awready            : _____-_
   // awvalid_nxt        : _----__
   // awvalid_tmp        : __----_
   // awvalid            : _-----_ 
   

   wire                awvalid_nxt;
   wire                awvalid_tmp;

   assign awvalid_nxt = (awvalid_tmp | (data_req & data_wr)) & (~awready); 
   dffrl_s #(1) awvalid_reg (
      .din   (awvalid_nxt),
      .clk   (aclk),
      .rst_l (aresetn),
      .q     (awvalid_tmp), 
      .se(), .si(), .so());
   
   assign awvalid = awvalid_tmp | (data_req & data_wr);



   wire [`Lwdata-1:0] wdata_nxt;
   wire               wvalid_nxt;
   wire               wvalid_tmp;

//   assign wdata_nxt = data_wdata;
//
//   dffrle_s #(`Lwdata) wdata_reg (
//      .din   (wdata_nxt),
//      .clk   (aclk),
//      .rst_l (aresetn),
//      .en    (data_wr),
//      .q     (wdata), 
//      .se(), .si(), .so());
   assign wdata = data_wdata;

   // data_req & data_wr : _-_____
   // wready             : _____-_
   // wvalid_nxt         : _----__
   // wvalid_tmp         : __----_
   // wvalid             : _-----_ 
   

   assign wvalid_nxt = (wvalid_tmp | (data_req & data_wr)) & (~wready); 
   dffrl_s #(1) wvalid_reg (
      .din   (wvalid_nxt),
      .clk   (aclk),
      .rst_l (aresetn),
      .q     (wvalid_tmp), 
      .se(), .si(), .so());
   
   assign wvalid = wvalid_tmp | (data_req & data_wr);



   assign bready = 1'b1;


   //assign data_data_ok_m = (rready & rvalid) & (lsu_read_m | lsu_write_m); // lsu_read_e lsu_write data_data_ok_e
   //// should check bresp value, then signal data_data_ok
   //assign data_data_ok_m = ((rready & rvalid) & lsu_read_m) | ((bready & bvalid) & lsu_write_m); 
   assign data_data_ok_m = ((rready & rvalid) & lsu_read_m & (rid == `LSU_ID)) | ((bready & bvalid) & lsu_write_m & (bid == `LSU_ID)); 
   
   // set unimplemented signals to 0 
   //assign awid    = `Lawid'b0;
   assign awid    = `LSU_ID; // ifu fetch never writes
   //assign awaddr  = `Lawaddr'b0;
   assign awlen   = `Lawlen'b0;
   assign awsize  = `Lawsize'h2; // 32 bits
   assign awburst = `Lawburst'b0;
   assign awlock  = `Lawlock'b0;
   assign awcache = `Lawcache'b0;
   assign awprot  = `Lawprot'b0;
   //assign awvalid = 1'b0;

   //assign wid     = `Lwid'b0;
   assign wid     = `LSU_ID;
   //assign wdata   = `Lwdata'b0;
   //assign wstrb   = `Lwstrb'b0;
   assign wstrb   = data_wstrb;
   assign wlast   = 1'b1;
   //assign wvalid  = 1'b0;

   //assign bready  = 1'b0;
   
endmodule // axi_interface
