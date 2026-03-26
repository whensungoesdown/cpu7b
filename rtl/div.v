//x/y   //执行需要34个周期
module div(
    input div_clk, reset,
    input div,
    input div_signed,
    input [31:0] x, y,
    output [31:0] s, r,
    output complete
    );

reg [32:0] UnsignS;
reg [32:0] UnsignR;
reg [32:0] tmp_r;
reg [7:0] count;
wire [32:0] tmp_d;
wire [32:0] result_r;
wire [32:0] UnsignX, UnsignY;

// 保存输入值
reg  div_started;
reg  div_signed_saved;
reg  [31:0] x_saved;
reg  [31:0] y_saved;
reg  x_31_saved;
reg  y_31_saved;

wire complete_delay;

assign complete_delay = (count == 8'hf0);

always @(posedge div_clk or posedge reset) begin 
    if (reset) begin 
        div_started <= 1'b0;
        div_signed_saved <= 1'b0;
        x_saved <= 32'b0;
        y_saved <= 32'b0;
        x_31_saved <= 1'b0;
        y_31_saved <= 1'b0;
    end 
    else if (div && ~div_started) begin  // div上升沿，保存输入
        div_started <= 1'b1;
        div_signed_saved <= div_signed;
        x_saved <= x;
        y_saved <= y;
        x_31_saved <= x[31];
        y_31_saved <= y[31];
    end
    else if (complete_delay) begin  // 计算完成，清除启动标志
        div_started <= 1'b0;
    end
end

// 使用保存的值进行计算
assign UnsignX = {1'b0, (div_signed_saved ? (x_31_saved ? (~x_saved + 32'b1) : x_saved) : x_saved)};
assign UnsignY = {1'b0, (div_signed_saved ? (y_31_saved ? (~y_saved + 32'b1) : y_saved) : y_saved)};

always @(posedge div_clk or posedge reset) begin  //33位除法计算
    if (reset) begin
        count <= 8'd32;
        tmp_r <= 33'b0;
        UnsignS <= 33'b0;
        UnsignR <= 33'b0;
    end
    else if (~div_started || complete_delay) begin
        count <= 8'd32;     //计算33次
        tmp_r <= 33'b0;
    end
    else if (~(count[7])) begin
        if (tmp_d[32]) begin    //tmp_d为负数
            UnsignS <= {UnsignS[31:0], 1'b0};
            tmp_r <= result_r;
        end 
        else begin
            UnsignS <= {UnsignS[31:0], 1'b1};
            tmp_r <= tmp_d;
        end
        count <= count - 8'd1;
    end
    else begin
        UnsignR <= tmp_r;
        count   <= 8'hf0; //complete signal only maintain one clock
    end

end

// complete信号只持续一个周期
assign complete = (count == 8'hf0) && div_started;

assign result_r = {tmp_r[31:0], UnsignX[count]};
assign tmp_d = result_r - UnsignY;

wire [32:0] TmpS, TmpR;
assign TmpS = (div_signed_saved ? ((x_31_saved == y_31_saved) ? UnsignS : ~(UnsignS - 1)) : UnsignS);
assign TmpR = (div_signed_saved ? (x_31_saved ? ~(UnsignR - 1) : UnsignR) : UnsignR);

assign s = TmpS[31:0];
assign r = TmpR[31:0];

endmodule

//表达式的符号关系
//x[31]  y[31]  s[31]  r[31]
//  0      0      0      0
//  0      1      1      0
//  1      0      1      1
//  1      1      0      1
