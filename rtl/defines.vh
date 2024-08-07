//`define AXI64

`define BUS_WIDTH      32

`ifdef AXI128
 `define DATA_WIDTH     128
`elsif AXI64
 `define DATA_WIDTH     64
`else
 `define DATA_WIDTH     32
`endif

`define CPU_WIDTH      32



`define Lawcmd         4
`define Lawdirqid      4
`define Lawstate       2
`define Lawscseti      2
`define Lawid          4
// for amba_axi_m2s2, slave awid 5-bit
// for amba_axi_m2s3, two masters need 1 bit to distinguish, slave awid 5-bit
// 1 Channel ID + 4 Transaction ID
`define Ls_awid        5
`define Lawaddr       32
`define Lawlen         8
`define Lawsize        3
`define Lawburst       2
`define Lawlock        1
`define Lawcache       4
`define Lawprot        3
`define Lawvalid       1
`define Lawready       1
`define Lwid           4
`define Ls_wid         5 
`ifdef AXI128
 `define Lwdata      128
`elsif AXI64
 `define Lwdata       64
`else
 `define Lwdata       32
`endif
//`define Lwdata 32 
`ifdef AXI128
 `define Lwstrb       16
`elsif AXI64
 `define Lwstrb        8
`else
 `define Lwstrb        4
`endif
//`define Lwstrb 4
`define Lwlast         1
`define Lwvalid        1
`define Lwready        1
`define Lbid           4
`define Ls_bid         5
`define Lbresp         2
`define Lbvalid        1
`define Lbready        1
`define Larcmd         4
`define Larcpuno      10
`define Larid          4
`define Ls_arid        5
`define Laraddr       32
`define Larlen         8
`define Larsize        3
`define Larburst       2
`define Larlock        1
`define Larcache       4
`define Larprot        3
`define Larvalid       1
`define Larready       1
`define Lrstate        2
`define Lrscseti       2
`define Lrid           4
`define Ls_rid         5
`ifdef AXI128
 `define Lrdata      128
`elsif AXI64
 `define Lrdata       64
`else
 `define Lrdata       32
`endif
//`define Lrdata 32
`define Lrresp         2
`define Lrlast         1
`define Lrvalid        1
`define Lrready        1
`define Lrrequest      1



`define GRLEN         32
