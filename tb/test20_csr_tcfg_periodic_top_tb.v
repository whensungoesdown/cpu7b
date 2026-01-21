//`include "../rtl/defines.vh"

`timescale 1ns / 1ps
//`timescale 1ns / 1ns

module top_tb(
   );

   reg clk;
   reg resetn;
   wire dumb_output;

   initial
      begin
	 $display("Start ...");
	 clk = 1'b1;
	 resetn = 1'b0;
 
	 #32;
	 resetn = 1'b1;

	 
      end

   always #5 clk=~clk;
   

   top u_top (
      .clk                             (clk),
      .resetn                          (resetn),
      .dumb_output                     (dumb_output)
      );

   always @(negedge clk)
      begin
	 $display("+");
	 $display("reset %b", resetn);


	 //if (1'b1 === u_top.fake_cpu.axi_rd_ret)
	 //   begin
	 //      $display("read back data 0x%x", u_top.fake_cpu.rdata);
	 //      $display("\nPASS!\n");
	 //      $finish;
	 //   end
	 
	 if (32'h1c000030 === u_top.u_c7b.u_core.u_exu.pc_w)
	 begin
		 $display("regs[5] 0x%x\n", u_top.u_c7b.u_core.u_exu.u_rf.regs[5]);
                 // 1c000020:       02816806        addi.w  $r6,$r0,90(0x5a)
                 // 1c000024:       5ffffca6        bne     $r5,$r6,-4(0x3fffc) # 1c000020 <loop>
                 // 1c000028:       02800000        addi.w  $r0,$r0,0
                 // 1c00002c:       02800000        addi.w  $r0,$r0,0
                 // 1c000030:       02800000        addi.w  $r0,$r0,0

		 // when the r5 is added up to 0x5a, 1c000024 branch not
		 // taken, so the control flow goes down to 1c000028,
		 // 1c00002c ...
		 // right at 1c00002c, another timer interrupt, the r5 is
		 // added another 0x10.
		 // So for this test, under current design, the r5 should be
		 // 0x6a.
		 // But if the design changes, the timing may not be as the
		 // same.

		 if (32'h6a === u_top.u_c7b.u_core.u_exu.u_rf.regs[5]
	            )
		 begin
			 $display("\nPASS!\n");
			 $display("\033[0;32m");
	                 $display("**************************************************");
	                 $display("*                                                *");
	                 $display("*      * * *       *        * * *     * * *      *");
	                 $display("*      *    *     * *      *         *           *");
	                 $display("*      * * *     *   *      * * *     * * *      *");
	                 $display("*      *        * * * *          *         *     *");
	                 $display("*      *       *       *    * * *     * * *      *");
	                 $display("*                                                *");
	                 $display("**************************************************");
	                 $display("\n");
	                 $display("\033[0m");
			 $finish;
		 end
		 else
		 begin
			 $display("\nFAIL!\n");
			 $display("\033[0;31m");
	                 $display("**************************************************");
	                 $display("*                                                *");
	                 $display("*      * * *       *         ***      *          *");
	                 $display("*      *          * *         *       *          *");
	                 $display("*      * * *     *   *        *       *          *");
	                 $display("*      *        * * * *       *       *          *");
	                 $display("*      *       *       *     ***      * * *      *");
	                 $display("*                                                *");
	                 $display("**************************************************");
	                 $display("\n");
	                 $display("\033[0m");
			 $finish;
		 end
	 end

	
      end
   
endmodule // top_tb
