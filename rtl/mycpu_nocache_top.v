`include "common.vh"

module mycpu_nocache_top (
    input [7:0] intrpt,   //high active

    input aclk,
    input aresetn,   //low active

    //axi
    //ar
    output [ 3:0] arid   ,
    output [`PABITS-1:0] araddr , // 40  paddr length
    output [ 3:0] arlen  ,
    output [ 2:0] arsize ,
    output [ 1:0] arburst,
    output [ 1:0] arlock ,
    output [ 3:0] arcache,
    output [ 2:0] arprot ,
    output [ 3:0] arcmd  ,
    output [ 9:0] arcpuno,
    output        arvalid,
    input         arready,
    //r              
    input  [ 3:0] rid    ,
    input  [63:0] rdata  ,
    input  [ 1:0] rresp  ,
    input         rlast  ,
    input         rvalid ,
    output        rready ,
    //aw     
    output [ 3:0] awcmd   ,
    output [ 1:0] awstate ,
    output [ 3:0] awdirqid,
    output [ 3:0] awscway ,
    output [ 3:0] awid   ,
    output [`PABITS-1:0] awaddr , // 40  paddr length
    output [ 3:0] awlen  , 
    output [ 2:0] awsize ,
    output [ 1:0] awburst,
    output [ 1:0] awlock ,
    output [ 3:0] awcache,
    output [ 2:0] awprot ,
    output        awvalid,
    input         awready,
    //w          
    output [  3:0] wid    ,
    output [63 :0] wdata  ,
    output [  7:0] wstrb  ,
    output         wlast  ,
    output         wvalid ,
    input          wready ,
    //b              
    input  [ 3:0] bid    ,
    input  [ 1:0] bresp  ,
    input         bvalid ,
    output        bready 

);

   wire                   inst_req      ;
   wire [`GRLEN-1:0]      inst_addr     ;
   wire                   inst_cancel   ;
   wire                   inst_addr_ok  ;
   wire [127:0]           inst_rdata    ;
   wire                   inst_recv     ;
   wire                   inst_valid    ;
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

   wire [`GRLEN-1:0]      data_rdata;
   wire                   data_addr_ok;
   wire                   data_data_ok;
   wire [ 5:0]            data_exccode;




   cpu7_nocache cpu(
        .clk              (aclk                 ),
        .resetn           (aresetn              ),
        .intrpt	          (intrpt               ),

        .inst_req         (inst_req             ),
        .inst_addr        (inst_addr            ),
        .inst_cancel      (inst_cancel          ),
        .inst_addr_ok     (inst_addr_ok         ),
        .inst_rdata       (inst_rdata           ),
        .inst_valid       (inst_valid           ),
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
                                          
        .data_rdata       (data_rdata           ),
        .data_addr_ok     (data_addr_ok         ),
        .data_data_ok     (data_data_ok         ),
        .data_exccode     (data_exccode         )


    );
