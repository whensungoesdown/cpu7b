
   localparam AXI_RID_IFU = 4'b0000;
   localparam AXI_RID_LSU = 4'b0001;
   localparam AXI_RID_ICU = 4'b0010;

   localparam AXI_WID_IFU = 4'b0000;
   localparam AXI_WID_LSU = 4'b0001;

   localparam AXI_SIZE_BYTE = 3'b000;
   localparam AXI_SIZE_HALFWORD = 3'b001;
   localparam AXI_SIZE_WORD = 3'b010;
   localparam AXI_SIZE_DOUBLEWORD = 3'b011;


   localparam AXI_BURST_INCR = 2'b01;
   localparam AXI_BURST_WRAP = 2'b10;
