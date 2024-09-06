module c7bbiu(
   input               clk,
   input               resetn,

   // IFU Interface
   input               ifu_biu_rd_req,
   input  [31:0]       ifu_biu_rd_addr,
   input               ifu_biu_cancel,   
   
   output              biu_ifu_rd_ack,
   output              biu_ifu_data_valid,
   output [31:0]       biu_ifu_data,
   //output              biu_ifu_fault,


   // LSU Interface
   input               lsu_biu_rd_req,
   input  [31:0]       lsu_biu_rd_addr,

   output              biu_lsu_rd_ack, 
   output              biu_lsu_data_valid,
   output [31:0]       biu_lsu_data,

   input               lsu_biu_wr_req,
   input  [31:0]       lsu_biu_wr_addr,
   input  [31:0]       lsu_biu_wr_data,
   input  [ 3:0]       lsu_biu_wr_strb,
   input               lsu_biu_wr_last,
  
   output              biu_lsu_wr_ack, 
   output              biu_lsu_write_valid,  

   //output              biu_lsu_fault,

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
   input  [31:0]    ext_biu_r_data,
   input            ext_biu_r_last,
   input  [1:0]     ext_biu_r_resp,

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
   output [31:0]    biu_ext_w_data,
   output [3:0]     biu_ext_w_strb,
   output           biu_ext_w_last,

   // AXI Write response channel
   output           biu_ext_b_ready,
   input            ext_biu_b_valid,
   input  [3:0]     ext_biu_b_id   ,
   input  [1:0]     ext_biu_b_resp 
);

   wire                axi_ar_ready;

   wire                arb_rd_val;
   wire [3:0]          arb_rd_id;
   wire [31:0]         arb_rd_addr;
   wire [7:0]          arb_rd_len;
   wire [2:0]          arb_rd_size;
   wire [1:0]          arb_rd_burst;
   wire                arb_rd_lock;
   wire [3:0]          arb_rd_cache;
   wire [2:0]          arb_rd_prot;
   //wire                arb_rd_master;
   //wire                arb_rd_inner;
   //wire                arb_rd_share;


   wire                axi_aw_ready;
   wire                axi_w_ready;

   wire                arb_wr_val; 
   wire [3:0]          arb_wr_id;  
   wire [31:0]         arb_wr_addr;
   wire [7:0]          arb_wr_len; 
   wire [2:0]          arb_wr_size;
   wire [1:0]          arb_wr_burst;
   wire                arb_wr_lock;
   wire [3:0]          arb_wr_cache;
   wire [2:0]          arb_wr_prot;

   wire [31:0]         arb_wr_data;
   wire [3:0]          arb_wr_strb;
   wire                arb_wr_last;

   // Read data from the AXI interface
   wire [31:0]         axi_rdata;
   wire                axi_rdata_ifu_val;
   wire                axi_rdata_lsu_val; 

   // Write data to the AXI interface
   wire                axi_write_lsu_val;


   assign axi_ar_ready = ext_biu_ar_ready;

   c7bbiu_rd_arb u_read_arbiter(
      .clk             (clk             ),
      .resetn          (resetn          ),

      .axi_ar_ready    (axi_ar_ready    ),

      .ifu_biu_rd_req  (ifu_biu_rd_req  ),
      .biu_ifu_rd_ack  (biu_ifu_rd_ack  ),
      .ifu_biu_rd_addr (ifu_biu_rd_addr ),

      .lsu_biu_rd_req  (lsu_biu_rd_req  ),
      .biu_lsu_rd_ack  (biu_lsu_rd_ack  ),
      .lsu_biu_rd_addr (lsu_biu_rd_addr ),

      .axi_rdata_ifu_val    (axi_rdata_ifu_val ),
      .axi_rdata_lsu_val    (axi_rdata_lsu_val ),

      .arb_rd_val      (arb_rd_val      ), 
      .arb_rd_id       (arb_rd_id       ),
      .arb_rd_addr     (arb_rd_addr     ), 
      .arb_rd_len      (arb_rd_len      ),
      .arb_rd_size     (arb_rd_size     ),
      .arb_rd_burst    (arb_rd_burst    ),
      .arb_rd_lock     (arb_rd_lock     ),
      .arb_rd_cache    (arb_rd_cache    ),
      .arb_rd_prot     (arb_rd_prot     )
   );


   assign axi_aw_ready = ext_biu_aw_ready;
   assign axi_w_ready = ext_biu_w_ready;



   c7bbiu_wr_arb u_write_arbiter(
      .clk             (clk             ),
      .resetn          (resetn          ),

      .axi_aw_ready    (axi_aw_ready    ),
      .axi_w_ready     (axi_w_ready     ),

      // now, only one requester
      .lsu_biu_wr_req  (lsu_biu_wr_req  ),
      .biu_lsu_wr_ack  (biu_lsu_wr_ack  ),
      .lsu_biu_wr_addr (lsu_biu_wr_addr ),
      .lsu_biu_wr_data (lsu_biu_wr_data ),
      .lsu_biu_wr_strb (lsu_biu_wr_strb ),
      .lsu_biu_wr_last (lsu_biu_wr_last ),

      .arb_wr_val      (arb_wr_val      ), 
      .arb_wr_id       (arb_wr_id       ),
      .arb_wr_addr     (arb_wr_addr     ), 
      .arb_wr_len      (arb_wr_len      ),
      .arb_wr_size     (arb_wr_size     ),
      .arb_wr_burst    (arb_wr_burst    ),
      .arb_wr_lock     (arb_wr_lock     ),
      .arb_wr_cache    (arb_wr_cache    ),
      .arb_wr_prot     (arb_wr_prot     ),

      .arb_wr_data     (arb_wr_data     ),
      .arb_wr_strb     (arb_wr_strb     ),
      .arb_wr_last     (arb_wr_last     )
   );


   

   c7bbiu_axi_interface u_axi_interface(
      .clk             (clk          ),
      .resetn          (resetn       ),

      // Arbitrated read signals
      .arb_rd_val           (arb_rd_val        ), 
      .arb_rd_id            (arb_rd_id         ),
      .arb_rd_addr          (arb_rd_addr       ), 
      .arb_rd_burst         (arb_rd_burst      ),
      .arb_rd_len           (arb_rd_len        ),
      .arb_rd_size          (arb_rd_size       ),
      .arb_rd_lock          (arb_rd_lock       ),
      .arb_rd_cache         (arb_rd_cache      ),
      .arb_rd_prot          (arb_rd_prot       ),

      // AXI Read Address Channel
      .ext_biu_ar_ready	    (ext_biu_ar_ready  ),
      .biu_ext_ar_valid	    (biu_ext_ar_valid  ),
      .biu_ext_ar_id        (biu_ext_ar_id     ),
      .biu_ext_ar_addr      (biu_ext_ar_addr   ),
      .biu_ext_ar_len       (biu_ext_ar_len    ),
      .biu_ext_ar_size      (biu_ext_ar_size   ),
      .biu_ext_ar_burst     (biu_ext_ar_burst  ),
      .biu_ext_ar_lock      (biu_ext_ar_lock   ),
      .biu_ext_ar_cache     (biu_ext_ar_cache  ),
      .biu_ext_ar_prot      (biu_ext_ar_prot   ),

      // AXI Read Data Channel
      .biu_ext_r_ready      (biu_ext_r_ready   ),
      .ext_biu_r_valid      (ext_biu_r_valid   ),
      .ext_biu_r_id         (ext_biu_r_id      ),
      .ext_biu_r_data       (ext_biu_r_data    ),
      .ext_biu_r_last       (ext_biu_r_last    ),
      .ext_biu_r_resp       (ext_biu_r_resp    ),

      // Arbitrated write signals
      .arb_wr_val           (arb_wr_val        ),
      .arb_wr_id            (arb_wr_id         ),
      .arb_wr_addr          (arb_wr_addr       ),
      .arb_wr_len           (arb_wr_len        ),
      .arb_wr_size          (arb_wr_size       ),
      .arb_wr_burst         (arb_wr_burst      ),
      .arb_wr_lock          (arb_wr_lock       ),
      .arb_wr_cache         (arb_wr_cache      ),
      .arb_wr_prot          (arb_wr_prot       ),

      .arb_wr_data          (arb_wr_data       ),
      .arb_wr_strb          (arb_wr_strb       ),
      .arb_wr_last          (arb_wr_last       ),

      // AXI Write address channel
      .ext_biu_aw_ready     (ext_biu_aw_ready  ),
      .biu_ext_aw_valid     (biu_ext_aw_valid  ),
      .biu_ext_aw_id        (biu_ext_aw_id     ),
      .biu_ext_aw_addr      (biu_ext_aw_addr   ),
      .biu_ext_aw_len       (biu_ext_aw_len    ),
      .biu_ext_aw_size      (biu_ext_aw_size   ),
      .biu_ext_aw_burst     (biu_ext_aw_burst  ),
      .biu_ext_aw_lock      (biu_ext_aw_lock   ),
      .biu_ext_aw_cache     (biu_ext_aw_cache  ),
      .biu_ext_aw_prot      (biu_ext_aw_prot   ),

      // AXI Write data channel
      .ext_biu_w_ready      (ext_biu_w_ready   ),
      .biu_ext_w_valid      (biu_ext_w_valid   ),
      .biu_ext_w_id         (biu_ext_w_id      ),
      .biu_ext_w_data       (biu_ext_w_data    ),
      .biu_ext_w_strb       (biu_ext_w_strb    ),
      .biu_ext_w_last       (biu_ext_w_last    ),

      // AXI Write response channel
      .biu_ext_b_ready      (biu_ext_b_ready   ),
      .ext_biu_b_valid      (ext_biu_b_valid   ),
      .ext_biu_b_id         (ext_biu_b_id      ),
      .ext_biu_b_resp       (ext_biu_b_resp    ),

      // Read data from the AXI interface
      .axi_rdata            (axi_rdata         ), 
      .axi_rdata_ifu_val    (axi_rdata_ifu_val ),
      .axi_rdata_lsu_val    (axi_rdata_lsu_val ),

      // Write data to the AXI interface
      .axi_write_lsu_val    (axi_write_lsu_val )
   );

   assign biu_ifu_data_valid = axi_rdata_ifu_val;
   assign biu_ifu_data = axi_rdata;

   assign biu_lsu_data_valid = axi_rdata_lsu_val;
   assign biu_lsu_data = axi_rdata;

   assign biu_lsu_write_valid = axi_write_lsu_val;

endmodule
