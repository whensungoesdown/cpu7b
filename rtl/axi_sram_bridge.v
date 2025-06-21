module axi_sram_bridge(
    input            aclk,
    input            aresetn,

    output [31:0]    ram_raddr,
    input  [63:0]    ram_rdata,
    output           ram_ren,
    output [31:0]    ram_waddr,
    output [63:0]    ram_wdata,
    output [7:0]     ram_wen,

    input  [31:0]    m_araddr,
    input  [1:0]     m_arburst,
    input  [3:0]     m_arcache,
    input  [3:0]     m_arid,
    input  [7:0]     m_arlen,
    input            m_arlock,
    input  [2:0]     m_arprot,
    output           m_arready,
    input  [2:0]     m_arsize,
    input            m_arvalid,

    output [63:0]    m_rdata,
    output [3:0]     m_rid,
    output           m_rlast,
    input            m_rready,
    output [1:0]     m_rresp,
    output           m_rvalid,
   
    input  [31:0]    m_awaddr,
    input  [1:0]     m_awburst,
    input  [3:0]     m_awcache,
    input  [3:0]     m_awid,
    input  [7:0]     m_awlen,
    input            m_awlock,
    input  [2:0]     m_awprot,
    output           m_awready,
    input  [2:0]     m_awsize,
    input            m_awvalid,

    input  [63:0]    m_wdata,
    input  [3:0]     m_wid,
    input            m_wlast,
    output           m_wready,
    input  [7:0]     m_wstrb,
    input            m_wvalid,
 
    output [3:0]     m_bid,
    input            m_bready,
    output [1:0]     m_bresp,
    output           m_bvalid 
);

   wire ar_enter;
   wire r_retire;

   wire aw_enter;
   wire w_enter;
   wire b_retire;
   
   wire busy;

   wire rdata_valid_tmp;
   wire rdata_valid;
   wire rdata_valid_next;

   assign ar_enter = m_arvalid & m_arready;
   assign r_retire = m_rvalid & m_rready & m_rlast;
   //
   // busy means that rready haven't come yet, so the sram
   // cannot accept new read, hence ar_ready should stay 0.
   //
   //  ar_enter      r_retire       busy
   //     0              0           0
   //     1              0           1
   //     0              1           0
   //     1              1           0   (should not happen)


   wire busy_din;
   wire busy_en;

   assign busy_din = (ar_enter & (~r_retire)) | ((aw_enter | w_enter) & (~b_retire));
   assign busy_en = ar_enter | r_retire | aw_enter | w_enter | b_retire;
   
   dffrle_s #(1) busy_reg (
      .din   (busy_din),
      .clk   (aclk),
      .rst_l (aresetn),
      .en    (busy_en),
      .q     (busy), 
      .se(), .si(), .so());

   assign m_arready = ~busy;

   //
   // If the ar_enter (address send in) in previous cycle,
   // then data ready in this cycle  
   //
   // Need to change logic if the sram's delay is not 1 cycle
   //

   //assign rdata_valid_next = (rdata_valid_tmp | ar_enter) & (~m_rready);
   assign rdata_valid_next = (rdata_valid_tmp | ar_enter) & (~m_rlast);
   
   dffrl_s #(1) rdata_valid_reg (
      .din   (rdata_valid_next),
      .clk   (aclk),
      .rst_l (aresetn),
      .q     (rdata_valid_tmp),
      .se(), .si(), .so());

   
   wire ar_enter_delay1;

   dffrl_s #(1) ar_enter_delay1_reg (
      .din   (ar_enter),
      .clk   (aclk),
      .rst_l (aresetn),
      .q     (ar_enter_delay1), 
      .se(), .si(), .so());
   
   // rdata_valid show up at lease one cycle
   assign rdata_valid = rdata_valid_tmp | ar_enter_delay1;


   
   wire [3:0] m_arid_q;
   wire [1:0] m_arburst_q;

   dffrle_s #(4) arid_reg (
      .din   (m_arid),
      .clk   (aclk),
      .rst_l (aresetn),
      .en    (ar_enter),
      .q     (m_arid_q), 
      .se(), .si(), .so());

   dffrle_s #(2) arburst_reg (
      .din   (m_arburst),
      .clk   (aclk),
      .rst_l (aresetn),
      .en    (ar_enter),
      .q     (m_arburst_q), 
      .se(), .si(), .so());

   wire [31:0] araddr_in;
   wire [31:0] araddr_q;
   assign araddr_in = m_arvalid ? m_araddr : araddr_q + 'h8;

   dffrl_s #(32) araddr_reg (
      .din   (araddr_in),
      .clk   (aclk),
      .rst_l (aresetn),
      //.en    (ar_enter),
      .q     (araddr_q), 
      .se(), .si(), .so());

   wire [7:0] rd_burst_cnt_in;
   wire [7:0] rd_burst_cnt_q;
   assign rd_burst_cnt_in = m_arvalid ? m_arlen : rd_burst_cnt_q - 1'b1;

   dffrl_s #(8) rd_burst_cnt_reg (
      .din   (rd_burst_cnt_in),
      .clk   (aclk),
      .rst_l (aresetn),
      //.en    (ar_enter),
      .q     (rd_burst_cnt_q), 
      .se(), .si(), .so());

   assign m_rid = m_arid_q;
   assign m_rlast = busy & (m_arburst_q == 2'b00 ? 1'b1 : rd_burst_cnt_q == 1'b0);
   assign m_rresp = 2'b00; // optional
   assign m_rdata = ram_rdata;
   assign m_rvalid = rdata_valid; 

   //assign ram_raddr = m_araddr;
   assign ram_raddr = araddr_in;
   //assign m_arready = 1'b1;  // single cycle ram, always ready
   assign ram_ren = busy | ar_enter;

   //
   //  AW W B
   //

   wire aw_busy;
   wire w_busy;
   
   assign aw_enter = m_awvalid & m_awready;
   assign w_enter = m_wvalid & m_wready;
   assign b_retire = m_bvalid & m_bready; // & m_wlast register 

   dffrle_s #(1) aw_busy_reg (
      .din   (aw_enter),
      .clk   (aclk),
      .rst_l (aresetn),
      .en    (aw_enter | b_retire),
      .q     (aw_busy), 
      .se(), .si(), .so());

   assign m_awready = ~aw_busy;

   dffe_s #(32) awaddr_reg (
      .din   (m_awaddr),
      .clk   (aclk),
      .en    (aw_enter),
      .q     (ram_waddr), 
      .se(), .si(), .so());
   
   
   dffrle_s #(1) w_busy_reg (
      .din   (w_enter),
      .clk   (aclk),
      .rst_l (aresetn),
      .en    (w_enter | b_retire),
      .q     (w_busy), 
      .se(), .si(), .so());

   assign m_wready = ~w_busy;
   
   wire [4+64+8-1:0] wpayload_in;
   wire [4+64+8-1:0] wpayload_q;
   wire [3:0] m_wid_q;
   wire [7:0] m_wstrb_q;

   assign wpayload_in = {m_wid, m_wdata, m_wstrb};
   assign {m_wid_q, ram_wdata, m_wstrb_q} = wpayload_q;


   dffe_s #(4+64+8) wpayload_reg (
      .din   (wpayload_in),
      .clk   (aclk),
      .en    (w_enter),
      .q     (wpayload_q), 
      .se(), .si(), .so());

   // enable ram write when both awaddr and wdata are received.
   assign ram_wen = {8{aw_busy & w_busy}} & m_wstrb_q;


   wire bresp_valid;
   wire bresp_valid_tmp;
   wire bresp_valid_next;
   wire bresp_valid_start;
   wire bresp_valid_end;

   
   assign bresp_valid_start = aw_busy & w_busy;
   assign bresp_valid_end   = m_bready;
   assign bresp_valid_next = (bresp_valid_tmp | bresp_valid_start) & (~bresp_valid_end);
   
   dffrl_s #(1) bresp_valid_reg (
      .din   (bresp_valid_next),
      .clk   (aclk),
      .rst_l (aresetn),
      .q     (bresp_valid_tmp),
      .se(), .si(), .so());

   assign bresp_valid = bresp_valid_tmp | bresp_valid_start;
   
   assign m_bid = m_wid_q;
   assign m_bresp = 2'b00;
   assign m_bvalid = bresp_valid;
   
endmodule // soc_axi_sram_bridge

   
