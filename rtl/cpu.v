`include "defines.vh"

module cpu(
   input                        clk    ,
   input                        resetn ,

   input                        ext_intr,

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
   wire                   inst_ack      ;
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


   wire biu_lsu_data_valid;
   wire biu_lsu_write_done;

   assign data_data_ok_m = biu_lsu_data_valid | biu_lsu_write_done;

   wire biu_lsu_rd_ack;
   wire biu_lsu_wr_aw_ack;
   wire biu_lsu_wr_w_ack;

   assign data_addr_ok = biu_lsu_rd_ack | biu_lsu_wr_aw_ack;


   cpu7_nocache cpu(
        .clk              (clk                 ),
        .resetn           (resetn              ),

	.ext_intr         (ext_intr            ),

        .inst_req         (inst_req             ),
        .inst_ack         (inst_ack             ),
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


   c7bbiu u_biu(
      .clk                (clk                  ),
      .resetn             (resetn               ),

      // IFU Interface
      .ifu_biu_rd_req     (inst_req             ),    
      .ifu_biu_rd_addr    (inst_addr            ),
      .ifu_biu_cancel     (inst_cancel          ),

      .biu_ifu_rd_ack     (inst_ack             ), 
      .biu_ifu_data_valid (inst_valid_f         ),
      .biu_ifu_data       (inst_rdata_f         ),

// uty: test

      // LSU Interface
      .lsu_biu_rd_req     (data_req & ~data_wr  ),
      .lsu_biu_rd_addr    (data_addr            ),
   
      .biu_lsu_rd_ack     (biu_lsu_rd_ack       ), //
      .biu_lsu_data_valid (biu_lsu_data_valid   ),
      .biu_lsu_data       (data_rdata_m         ),

      .lsu_biu_wr_aw_req  (data_req & data_wr   ),
      .lsu_biu_wr_addr    (data_addr            ),
      .lsu_biu_wr_w_req   (data_req & data_wr   ),
      .lsu_biu_wr_data    (data_wdata           ),
      .lsu_biu_wr_strb    (data_wstrb           ),
      .lsu_biu_wr_last    (1'b1                 ),

      .biu_lsu_wr_aw_ack  (biu_lsu_wr_aw_ack    ), //
      .biu_lsu_wr_w_ack   (biu_lsu_wr_w_ack     ), //
      .biu_lsu_write_done (biu_lsu_write_done   ),
//

      // AXI Read Address Channel
      .ext_biu_ar_ready   (arready              ),
      .biu_ext_ar_valid   (arvalid              ),
      .biu_ext_ar_id      (arid                 ),
      .biu_ext_ar_addr    (araddr               ),
      .biu_ext_ar_len     (arlen                ),
      .biu_ext_ar_size    (arsize               ),
      .biu_ext_ar_burst   (arburst              ),
      .biu_ext_ar_lock    (arlock               ),
      .biu_ext_ar_cache   (arcache              ),
      .biu_ext_ar_prot    (arprot               ),

      // AXI Read Data Channel
      .biu_ext_r_ready    (rready               ),
      .ext_biu_r_valid    (rvalid               ),
      .ext_biu_r_id       (rid                  ),
      .ext_biu_r_data     (rdata                ),
      .ext_biu_r_last     (rlast                ),
      .ext_biu_r_resp     (rresp                ),

      // AXI Write address channel
      .ext_biu_aw_ready   (awready              ),
      .biu_ext_aw_valid   (awvalid              ),
      .biu_ext_aw_id      (awid                 ),
      .biu_ext_aw_addr    (awaddr               ),
      .biu_ext_aw_len     (awlen                ),
      .biu_ext_aw_size    (awsize               ),
      .biu_ext_aw_burst   (awburst              ),
      .biu_ext_aw_lock    (awlock               ),
      .biu_ext_aw_cache   (awcache              ),
      .biu_ext_aw_prot    (awprot               ),

      // AXI Write data channel
      .ext_biu_w_ready    (wready               ),
      .biu_ext_w_valid    (wvalid               ),
      .biu_ext_w_id       (wid                  ),
      .biu_ext_w_data     (wdata                ),
      .biu_ext_w_strb     (wstrb                ),
      .biu_ext_w_last     (wlast                ),

      // AXI Write response channel
      .biu_ext_b_ready    (bready               ),
      .ext_biu_b_valid    (bvalid               ),
      .ext_biu_b_id       (bid                  ),
      .ext_biu_b_resp     (bresp                ) 
   );


endmodule // cpu
