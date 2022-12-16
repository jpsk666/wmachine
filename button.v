`timescale 1ns / 1ps

module button (//接受一个按钮的端口，按钮按下1次(clk为原始时钟)时pos在瞬间为1, 输出需放在时序always内
    input clk,
    input bt,
    output pos
  
);
  reg [1:0] trig=2'b00;  //中按键模拟上升沿
  always @(posedge clk) begin 
        trig[0] <= bt;
        trig[1] <=trig[0];
  end
  assign pos = trig[0] & ~trig[1];
endmodule
