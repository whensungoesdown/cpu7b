`include "defines.vh"

module cpu(
   input                    clk    ,
   input                    resetn ,

   input                    ext_intr,

   //  axi_control
   //ar
   output [3:0]             arid   ,
   output [31:0]            araddr ,
   output [7:0]             arlen  ,
   output [2:0]             arsize ,
   output [1:0]             arburst,
   output                   arlock ,
   output [3:0]             arcache,
   output [2:0]             arprot ,
   output                   arvalid,
   input                    arready,
   //r
   input  [3:0]             rid    ,
   input  [63:0]            rdata  ,
   input  [1:0]             rresp  ,
   input                    rlast  ,
   input                    rvalid ,
   output                   rready ,

   //aw
   output [3:0]             awid   ,
   output [31:0]            awaddr ,
   output [7:0]             awlen  ,
   output [2:0]             awsize ,
   output [1:0]             awburst,
   output                   awlock ,
   output [3:0]             awcache,
   output [2:0]             awprot ,
   output                   awvalid,
   input                    awready,
   //w
   output [3:0]             wid    ,
   output [63:0]            wdata  ,
   output [7:0]             wstrb  ,
   output                   wlast  ,
   output                   wvalid ,
   input                    wready ,
   //b
   input  [3:0]             bid    ,
   input  [1:0]             bresp  ,
   input                    bvalid ,
   output                   bready
   );



   wire                   inst_req      ;
   wire                   inst_ack      ;
   wire [`GRLEN-1:0]      inst_addr     ;
   wire                   inst_cancel   ;
   wire                   inst_addr_ok  ;
   //wire [`GRLEN-1:0]      inst_rdata_f  ;
   wire [63:0]      inst_rdata_f  ;
   wire                   inst_recv     ;
   wire                   inst_valid_f  ;
   wire [  1:0]           inst_count    ;
   wire                   inst_uncache  ;
   wire                   inst_exception;
   wire [  5:0]           inst_exccode  ;
   

   wire                   lsu_biu_rd_req;
   wire [`GRLEN-1:0]      lsu_biu_rd_addr;

   wire                   biu_lsu_rd_ack;
   wire                   biu_lsu_data_valid;
   wire [63:0]            biu_lsu_data;

   wire                   lsu_biu_wr_req;
   wire [`GRLEN-1:0]      lsu_biu_wr_addr;
   wire [63:0]            lsu_biu_wr_data;
   wire [7:0]             lsu_biu_wr_strb;

   wire                   biu_lsu_write_done;


   wire biu_lsu_wr_aw_ack;
   wire biu_lsu_wr_w_ack;

   

   // itag
   wire [1:0]          icu_ram_tag_en;
   wire                icu_ram_tag_wr;
   wire [9:0]          icu_ram_tag_addr;
   wire [21:0]         icu_ram_tag_wdata0; // 22 bits: V, addr[31:11]
   wire [21:0]         icu_ram_tag_wdata1;

   wire [21:0]         ram_icu_tag_rdata0;
   wire [21:0]         ram_icu_tag_rdata1;

   // idata
   wire [1:0]          icu_ram_data_en;
   wire                icu_ram_data_wr;
   wire [11:0]         icu_ram_data_addr0;
   wire [11:0]         icu_ram_data_addr1;
   wire [63:0]         icu_ram_data_wdata0;
   wire [63:0]         icu_ram_data_wdata1;

   wire [63:0]         ram_icu_data_rdata0;
   wire [63:0]         ram_icu_data_rdata1;


   // interface with BIU
   wire                icu_biu_req;
   wire [31:3]         icu_biu_addr;
   wire                icu_biu_single;

   wire                biu_icu_ack;
   wire                biu_icu_data_valid;
   wire                biu_icu_data_last;
   wire [63:0]         biu_icu_data;
   wire                biu_icu_fault;


   // these are the new signals that cpu7_core need to provide to icu
   // get rid of inst_* signals
   wire              ifu_icu_req_ic1;
   wire [31:0]       ifu_icu_addr_ic1;
   wire              icu_ifu_ack_ic1;

   wire              ifu_icu_cancel; 

   // ic2
   wire              icu_ifu_data_valid_ic2;
   wire [63:0]       icu_ifu_data_ic2;


   //assign ifu_icu_req_ic1 = inst_req;
   //assign ifu_icu_addr_ic1 = inst_addr[31:3]; 
   //assign inst_ack = icu_ifu_ack_ic1;

   // watch out for icu_ifu_data_valid_ic2 and icu_ifu_data_ic2
//   assign inst_valid_f = icu_ifu_data_valid_ic2;
//   assign inst_rdata_f = icu_ifu_data_ic2;


   cpu7_core cpu(
      .clk              (clk                 ),
      .resetn           (resetn              ),

      .ext_intr         (ext_intr            ),

//      .inst_req         (inst_req             ),
//      .inst_ack         (inst_ack             ),
//      .inst_addr        (inst_addr            ),
//      .inst_cancel      (inst_cancel          ),
      .ifu_icu_req_ic1  (ifu_icu_req_ic1      ),
      .ifu_icu_addr_ic1 (ifu_icu_addr_ic1     ),
      .icu_ifu_ack_ic1  (icu_ifu_ack_ic1      ),      

      .ifu_icu_cancel   (ifu_icu_cancel       ),

      .icu_ifu_data_ic2 (icu_ifu_data_ic2     ),
      .icu_ifu_data_valid_ic2     (icu_ifu_data_valid_ic2         ),

//      .inst_addr_ok     (inst_addr_ok         ),
//      .inst_rdata_f     (inst_rdata_f         ),
//      .inst_valid_f     (inst_valid_f         ),
//      .inst_rdata_f     (icu_ifu_data_ic2     ),
//      .inst_valid_f     (icu_ifu_data_valid_ic2         ),
//      .inst_count       (inst_count           ),
//      .inst_uncache     (inst_uncache         ),
//      .inst_exccode     (inst_exccode         ),
//      .inst_exception   (inst_exception       ),


      .lsu_biu_rd_req           (lsu_biu_rd_req        ),
      .lsu_biu_rd_addr          (lsu_biu_rd_addr       ),

      .biu_lsu_rd_ack           (biu_lsu_rd_ack        ),
      .biu_lsu_data_valid       (biu_lsu_data_valid    ),
      .biu_lsu_data             (biu_lsu_data[31:0]    ), // uty: BUG!

      .lsu_biu_wr_req           (lsu_biu_wr_req        ),
      .lsu_biu_wr_addr          (lsu_biu_wr_addr       ),
      .lsu_biu_wr_data          (lsu_biu_wr_data[31:0] ), // uty: BUG!
      .lsu_biu_wr_strb          (lsu_biu_wr_strb[3:0]  ), // uty: BUG!

      .biu_lsu_wr_ack           (biu_lsu_wr_aw_ack & biu_lsu_wr_aw_ack),
      .biu_lsu_write_done       (biu_lsu_write_done    )
   );


   c7bicu u_icu(
      .clk                         (clk                    ),
      .resetn                      (resetn                 ),

      .ifu_icu_req_ic1             (ifu_icu_req_ic1        ),
      .ifu_icu_addr_ic1            (ifu_icu_addr_ic1[31:3] ),
                                                          
      .icu_ifu_ack_ic1             (icu_ifu_ack_ic1        ),

      .ifu_icu_cancel              (ifu_icu_cancel         ),
                                                          
      .icu_ifu_data_valid_ic2      (icu_ifu_data_valid_ic2 ),
      .icu_ifu_data_ic2            (icu_ifu_data_ic2       ),


      .icu_ram_tag_en              (icu_ram_tag_en         ),
      .icu_ram_tag_wr              (icu_ram_tag_wr         ),
      .icu_ram_tag_addr            (icu_ram_tag_addr       ),
      .icu_ram_tag_wdata0          (icu_ram_tag_wdata0     ),
      .icu_ram_tag_wdata1          (icu_ram_tag_wdata1     ),
      .ram_icu_tag_rdata0          (ram_icu_tag_rdata0     ),
      .ram_icu_tag_rdata1          (ram_icu_tag_rdata1     ),

      .icu_ram_data_en             (icu_ram_data_en        ),
      .icu_ram_data_wr             (icu_ram_data_wr        ),
      .icu_ram_data_addr0          (icu_ram_data_addr0     ),
      .icu_ram_data_addr1          (icu_ram_data_addr1     ),
      .icu_ram_data_wdata0         (icu_ram_data_wdata0    ),
      .icu_ram_data_wdata1         (icu_ram_data_wdata1    ),
      .ram_icu_data_rdata0         (ram_icu_data_rdata0    ),
      .ram_icu_data_rdata1         (ram_icu_data_rdata1    ),


      .icu_biu_req                 (icu_biu_req            ),
      .icu_biu_addr                (icu_biu_addr           ),
      .icu_biu_single              (icu_biu_single         ),
                                                      
      .biu_icu_ack                 (biu_icu_ack            ),
      .biu_icu_data_valid          (biu_icu_data_valid     ),
      .biu_icu_data_last           (biu_icu_data_last      ),
      .biu_icu_data                (biu_icu_data           ),
      .biu_icu_fault               (biu_icu_fault          )

   );
   

   c7b_cache_rams u_cache_rams(
      .clk                         (clk                    ),

      .icu_ram_tag_en              (icu_ram_tag_en         ),
      .icu_ram_tag_wr              (icu_ram_tag_wr         ),
      .icu_ram_tag_addr            (icu_ram_tag_addr       ),
      .icu_ram_tag_wdata0          (icu_ram_tag_wdata0     ),
      .icu_ram_tag_wdata1          (icu_ram_tag_wdata1     ),
      .ram_icu_tag_rdata0          (ram_icu_tag_rdata0     ),
      .ram_icu_tag_rdata1          (ram_icu_tag_rdata1     ),

      .icu_ram_data_en             (icu_ram_data_en        ),
      .icu_ram_data_wr             (icu_ram_data_wr        ),
      .icu_ram_data_addr0          (icu_ram_data_addr0     ),
      .icu_ram_data_addr1          (icu_ram_data_addr1     ),
      .icu_ram_data_wdata0         (icu_ram_data_wdata0    ),
      .icu_ram_data_wdata1         (icu_ram_data_wdata1    ),
      .ram_icu_data_rdata0         (ram_icu_data_rdata0    ),
      .ram_icu_data_rdata1         (ram_icu_data_rdata1    )
   );



   // unused
   wire biu_ifu_rd_ack;
   wire biu_ifu_data_valid;
   wire [63:0] biu_ifu_data;

   c7bbiu u_biu(
      .clk                (clk                  ),
      .resetn             (resetn               ),

      // IFU Interface
//      .ifu_biu_rd_req     (inst_req             ),   // only for ifu uncache 
      .ifu_biu_rd_req     (1'b0                 ),    
      .ifu_biu_rd_addr    ('h0                  ),
      .ifu_biu_cancel     (1'b0                 ),

      .biu_ifu_rd_ack     (biu_ifu_rd_ack       ), 
      .biu_ifu_data_valid (biu_ifu_data_valid   ),
      .biu_ifu_data       (biu_ifu_data         ),


      // LSU Interface
      .lsu_biu_rd_req     (lsu_biu_rd_req       ),
      .lsu_biu_rd_addr    (lsu_biu_rd_addr      ),
                                             
      .biu_lsu_rd_ack     (biu_lsu_rd_ack       ), //
      .biu_lsu_data_valid (biu_lsu_data_valid   ),
      .biu_lsu_data       (biu_lsu_data         ),
                                             
      .lsu_biu_wr_aw_req  (lsu_biu_wr_req       ), // aw w are requested at the same time
      .lsu_biu_wr_addr    (lsu_biu_wr_addr      ),
      .lsu_biu_wr_w_req   (lsu_biu_wr_req       ),
      .lsu_biu_wr_data    (lsu_biu_wr_data      ),
      .lsu_biu_wr_strb    (lsu_biu_wr_strb      ),
      .lsu_biu_wr_last    (1'b1                 ),

      .biu_lsu_wr_aw_ack  (biu_lsu_wr_aw_ack    ), //
      .biu_lsu_wr_w_ack   (biu_lsu_wr_w_ack     ), //
      .biu_lsu_write_done (biu_lsu_write_done   ),

      // ICU Interface
      .icu_biu_req        (icu_biu_req          ),
      .icu_biu_addr       (icu_biu_addr         ),
      .icu_biu_single     (icu_biu_single       ),
                                             
      .biu_icu_ack        (biu_icu_ack          ),
      .biu_icu_data_valid (biu_icu_data_valid   ),
      .biu_icu_data_last  (biu_icu_data_last    ),
      .biu_icu_data       (biu_icu_data         ),
      .biu_icu_fault      (biu_icu_fault        ),
      

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



//   c7bbiu u_biu(
//      .clk                (clk                  ),
//      .resetn             (resetn               ),
//
//      // IFU Interface
//      .ifu_biu_rd_req     (inst_req             ),    
//      .ifu_biu_rd_addr    (inst_addr            ),
//      .ifu_biu_cancel     (inst_cancel          ),
//
//      .biu_ifu_rd_ack     (inst_ack             ), 
//      .biu_ifu_data_valid (inst_valid_f         ),
//      .biu_ifu_data       (inst_rdata_f         ),
//
//
//      // LSU Interface
//      .lsu_biu_rd_req     (lsu_biu_rd_req       ),
//      .lsu_biu_rd_addr    (lsu_biu_rd_addr      ),
//                                             
//      .biu_lsu_rd_ack     (biu_lsu_rd_ack       ), //
//      .biu_lsu_data_valid (biu_lsu_data_valid   ),
//      .biu_lsu_data       (biu_lsu_data         ),
//                                             
//      .lsu_biu_wr_aw_req  (lsu_biu_wr_req       ), // aw w are requested at the same time
//      .lsu_biu_wr_addr    (lsu_biu_wr_addr      ),
//      .lsu_biu_wr_w_req   (lsu_biu_wr_req       ),
//      .lsu_biu_wr_data    (lsu_biu_wr_data      ),
//      .lsu_biu_wr_strb    (lsu_biu_wr_strb      ),
//      .lsu_biu_wr_last    (1'b1                 ),
//
//      .biu_lsu_wr_aw_ack  (biu_lsu_wr_aw_ack    ), //
//      .biu_lsu_wr_w_ack   (biu_lsu_wr_w_ack     ), //
//      .biu_lsu_write_done (biu_lsu_write_done   ),
//
//
//      // AXI Read Address Channel
//      .ext_biu_ar_ready   (arready              ),
//      .biu_ext_ar_valid   (arvalid              ),
//      .biu_ext_ar_id      (arid                 ),
//      .biu_ext_ar_addr    (araddr               ),
//      .biu_ext_ar_len     (arlen                ),
//      .biu_ext_ar_size    (arsize               ),
//      .biu_ext_ar_burst   (arburst              ),
//      .biu_ext_ar_lock    (arlock               ),
//      .biu_ext_ar_cache   (arcache              ),
//      .biu_ext_ar_prot    (arprot               ),
//
//      // AXI Read Data Channel
//      .biu_ext_r_ready    (rready               ),
//      .ext_biu_r_valid    (rvalid               ),
//      .ext_biu_r_id       (rid                  ),
//      .ext_biu_r_data     (rdata                ),
//      .ext_biu_r_last     (rlast                ),
//      .ext_biu_r_resp     (rresp                ),
//
//      // AXI Write address channel
//      .ext_biu_aw_ready   (awready              ),
//      .biu_ext_aw_valid   (awvalid              ),
//      .biu_ext_aw_id      (awid                 ),
//      .biu_ext_aw_addr    (awaddr               ),
//      .biu_ext_aw_len     (awlen                ),
//      .biu_ext_aw_size    (awsize               ),
//      .biu_ext_aw_burst   (awburst              ),
//      .biu_ext_aw_lock    (awlock               ),
//      .biu_ext_aw_cache   (awcache              ),
//      .biu_ext_aw_prot    (awprot               ),
//
//      // AXI Write data channel
//      .ext_biu_w_ready    (wready               ),
//      .biu_ext_w_valid    (wvalid               ),
//      .biu_ext_w_id       (wid                  ),
//      .biu_ext_w_data     (wdata                ),
//      .biu_ext_w_strb     (wstrb                ),
//      .biu_ext_w_last     (wlast                ),
//
//      // AXI Write response channel
//      .biu_ext_b_ready    (bready               ),
//      .ext_biu_b_valid    (bvalid               ),
//      .ext_biu_b_id       (bid                  ),
//      .ext_biu_b_resp     (bresp                ) 
//   );


endmodule // cpu
