`timescale 1ns / 1ps

module button (//接受一个按钮的端口，按钮按下1次(clk为原始时钟)时pos在瞬间为1, 输出需放在时序always内
    input  clk,
    input  bt,
    output pos

);
  reg [ 1:0] trig = 2'b00;  //中按键模拟上升沿
  reg [28:0] cnt_1s;  //
  always @(posedge clk) begin
    trig[0] <= bt;
    trig[1] <= trig[0];
    if (trig[0] & ~trig[1]) begin
      cnt_1s <= cnt_1s + 1;
    end else begin
      if (cnt_1s != 0)
        if (cnt_1s <= 25000000) cnt_1s <= cnt_1s + 1;
        else cnt_1s <= 0;
      else cnt_1s<=0;

    end
  end
  assign pos = (trig[0] & ~trig[1]) && (cnt_1s == 0);
endmodule
