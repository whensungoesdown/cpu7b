//`include "../rtl/defines.vh"

`timescale 1ns / 1ps
//`timescale 1ns / 1ns

module top_tb(
   );

   reg clk;
   reg resetn;

   initial
      begin
	 $display("Start ...");
	 clk = 1'b1;
	 resetn = 1'b0;
	 u_top.ext_intr = 1'b0;
 
	 #32;
	 resetn = 1'b1;

	 #250;
	 u_top.ext_intr = 1'b1;

	 #600;
	 u_top.ext_intr = 1'b0;

	 
      end

   always #5 clk=~clk;
   

   top u_top (
      .clk      (clk      ),
      .resetn   (resetn   )
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
	 
	 if (32'h1c00006c === u_top.u_cpu.cpu.ifu_exu_pc_w)
	 begin
		 $display("regs[5] 0x%x\n", u_top.u_cpu.cpu.exu.registers.regs[5]);

		 if (32'h5a === u_top.u_cpu.cpu.exu.registers.regs[5] 
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
