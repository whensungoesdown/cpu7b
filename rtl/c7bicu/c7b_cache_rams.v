// icache
// cacheline 256-bit, ramline 64-bit
// 256 entries (tag, data)
// 64-bit x 256 entries = 16KB

module c7b_cache_rams
(
   input                 clk,

   // icache TAG
   input  [1:0]          icu_ram_tag_en,
   input                 icu_ram_tag_wr,
   input  [9:0]          icu_ram_tag_addr, // 256 entries, ignore [9:8]
   input  [21:0]         icu_ram_tag_wdata0,
   input  [21:0]         icu_ram_tag_wdata1,
   output [21:0]         ram_icu_tag_rdata0,
   output [21:0]         ram_icu_tag_rdata1,

   // icache DATA
   input  [1:0]          icu_ram_data_en,
   input                 icu_ram_data_wr,
   input  [11:0]         icu_ram_data_addr0, // 256 cache lines, 1024 ram lines, ignore [11:10]
   input  [11:0]         icu_ram_data_addr1,
   input  [63:0]         icu_ram_data_wdata0,
   input  [63:0]         icu_ram_data_wdata1,
   output [63:0]         ram_icu_data_rdata0,
   output [63:0]         ram_icu_data_rdata1
);

   // icache tag 21-bit tag + 1-bit V

   ram22 u_itag0( 
      .clock             (clk                    ),
      .rden              (icu_ram_tag_en[0]      ),
      .rdaddress         (icu_ram_tag_addr[7:0]  ),
      .q                 (ram_icu_tag_rdata0     ),
      .wren              (icu_ram_tag_en[0] & icu_ram_tag_wr),
      .wraddress         (icu_ram_tag_addr[7:0]  ),
      .data              (icu_ram_tag_wdata0     )
   );

   // use ram22_way1 for test purpose, so that it can have a different
   //ram22 u_itag1(
   ram22_way1 u_itag1(
      .clock             (clk                    ),
      .rden              (icu_ram_tag_en[1]      ),
      .rdaddress         (icu_ram_tag_addr[7:0]  ),
      .q                 (ram_icu_tag_rdata1     ),
      .wren              (icu_ram_tag_en[1] & icu_ram_tag_wr),
      .wraddress         (icu_ram_tag_addr[7:0]  ),
      .data              (icu_ram_tag_wdata1     )
   );


   // icache data
   
   ram64 u_idata0(
      .clock             (clk                     ),
      .rden              (icu_ram_data_en[0]      ),
      .rdaddress         (icu_ram_data_addr0[9:0] ),
      .q                 (ram_icu_data_rdata0     ),
      .wren              (icu_ram_data_en[0] & icu_ram_data_wr),
      .wraddress         (icu_ram_data_addr0[9:0] ),
      .data              (icu_ram_data_wdata0     )
   );

   ram64_way1 u_idata1(
      .clock             (clk                     ),
      .rden              (icu_ram_data_en[1]      ),
      .rdaddress         (icu_ram_data_addr1[9:0] ),
      .q                 (ram_icu_data_rdata1     ),
      .wren              (icu_ram_data_en[1] & icu_ram_data_wr),
      .wraddress         (icu_ram_data_addr1[9:0] ),
      .data              (icu_ram_data_wdata1     )
   );

endmodule
