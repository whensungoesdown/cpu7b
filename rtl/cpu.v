`include "defines.vh"

module cpu(
   input                        clk    ,
   input                        resetn ,
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
   output                       bready
   );



   wire                   inst_req      ;
   wire [`GRLEN-1:0]      inst_addr     ;
   wire                   inst_cancel   ;
   wire                   inst_addr_ok  ;
   wire [`GRLEN-1:0]      inst_rdata_f  ;
   wire                   inst_recv     ;
   wire                   inst_valid_f  ;
   wire [  1:0]           inst_count    ;
   wire                   inst_uncache  ;
   wire                   inst_exception;
   wire [  5:0]           inst_exccode  ;
   
   wire                   data_req;
   wire [`GRLEN-1:0]      data_pc;
   wire                   data_wr;
   wire [3 :0]            data_wstrb;
   wire [`GRLEN-1:0]      data_addr;
   wire                   data_cancel_ex2;
   wire                   data_cancel;
   wire [`GRLEN-1:0]      data_wdata;
   wire                   data_recv;
   wire                   data_prefetch;
   wire                   data_ll;
   wire                   data_sc;

   wire [`GRLEN-1:0]      data_rdata_m;
   wire                   data_addr_ok;
   wire                   data_data_ok_m;
   wire [ 5:0]            data_exccode;




   cpu7_nocache cpu(
        .clk              (clk                 ),
        .resetn           (resetn              ),

        .inst_req         (inst_req             ),
        .inst_addr        (inst_addr            ),
        .inst_cancel      (inst_cancel          ),
        .inst_addr_ok     (inst_addr_ok         ),
        .inst_rdata_f     (inst_rdata_f         ),
        .inst_valid_f     (inst_valid_f         ),
        .inst_count       (inst_count           ),
        .inst_uncache     (inst_uncache         ),
        .inst_exccode     (inst_exccode         ),
        .inst_exception   (inst_exception       ),


        .data_req         (data_req             ), 
        .data_pc          (data_pc              ),
        .data_wr          (data_wr              ),
        .data_wstrb       (data_wstrb           ),
        .data_addr        (data_addr            ),
        .data_cancel_ex2  (data_cancel_ex2      ),
        .data_cancel      (data_cancel          ),
        .data_wdata       (data_wdata           ),
        .data_recv        (data_recv            ),
        .data_prefetch    (data_prefetch        ),
        .data_ll          (data_ll              ),
        .data_sc          (data_sc              ),
                                          
        .data_rdata_m     (data_rdata_m         ),
        .data_addr_ok     (data_addr_ok         ),
        .data_data_ok_m   (data_data_ok_m       ),
        .data_exccode     (data_exccode         ),

	.data_scsucceed   (1'b0                 ) // figure it out, later
    );


   
   axi_interface u_axi_interface(
      .aclk             (clk            ),
      .aresetn          (resetn         ), 


      .arid	        (arid           ),
      .araddr	        (araddr         ),
      .arlen	        (arlen          ),
      .arsize	        (arsize         ),
      .arburst	        (arburst        ),
      .arlock	        (arlock         ),
      .arcache	        (arcache        ),
      .arprot	        (arprot         ),
      .arvalid	        (arvalid        ),
      .arready	        (arready        ),

      .rid	        (rid            ),
      .rdata	        (rdata          ),
      .rresp	        (rresp          ),
      .rlast	        (rlast          ),
      .rvalid	        (rvalid         ),
      .rready	        (rready         ),


      .awid	        (awid           ),
      .awaddr	        (awaddr         ),
      .awlen	        (awlen          ),
      .awsize	        (awsize         ),
      .awburst	        (awburst        ),
      .awlock	        (awlock         ),
      .awcache	        (awcache        ),
      .awprot	        (awprot         ),
      .awvalid	        (awvalid        ),
      .awready	        (awready        ),

      .wid	        (wid            ),
      .wdata	        (wdata          ),
      .wstrb	        (wstrb          ),
      .wlast	        (wlast          ),
      .wvalid	        (wvalid         ),
      .wready	        (wready         ),

      .bid	        (bid            ),
      .bresp	        (bresp          ),
      .bvalid	        (bvalid         ),
      .bready	        (bready         ),

      .inst_req         (inst_req       ),
      .inst_addr        (inst_addr      ),
      .inst_cancel      (inst_cancel    ),
      .inst_valid_f     (inst_valid_f   ),
      .inst_rdata_f     (inst_rdata_f   ),

      .data_req	        (data_req       ),
      .data_wr          (data_wr        ),
      .data_wdata       (data_wdata     ),
      .data_wstrb       (data_wstrb     ),
      .data_addr        (data_addr      ),
      .data_data_ok_m   (data_data_ok_m ),
      .data_rdata_m     (data_rdata_m   )
      );
   
endmodule // cpu
