//`include "../rtl/defines.vh"

`timescale 1ns / 1ps
//`timescale 1ns / 1ns

module top_tb(
   );

   reg clk;
   reg resetn;
   wire dumb_output;

   integer seed;
   integer rand_val;

   initial
   begin

      // 从命令行获取种子
      if (!$value$plusargs("seed=%d", seed)) begin
              seed = 12345;
      end

      $display("RANDOM: Using seed: %0d", seed);

      // 设置随机种子 - 使用 $urandom 而不是 $random
      $urandom(seed);

      $display("Start ...");
      clk = 1'b1;
      resetn = 1'b0;
      u_top.ext_intr = 1'b0;

      #32;
      resetn = 1'b1;

      // 使用 $urandom_range 生成范围内的随机数
      rand_val = $urandom_range(100, 1000);
      $display("RANDOM: Random delay 1: %0d", rand_val);
      #(rand_val);

      u_top.ext_intr = 1'b1;
      $display("RANDOM: ext_intr asserted at time %0t", $time);

      rand_val = $urandom_range(100, 500);
      $display("RANDOM: Random delay 2: %0d", rand_val);
      #(rand_val);

      u_top.ext_intr = 1'b0;
      $display("RANDOM: ext_intr deasserted at time %0t", $time);
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
	 
	 if (32'h1c00006c === u_top.u_c7b.u_core.u_exu.pc_w)
	 begin
		 $display("regs[5] 0x%x\n", u_top.u_c7b.u_core.u_exu.u_rf.regs[5]);

		 if (32'h5a === u_top.u_c7b.u_core.u_exu.u_rf.regs[5]
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
