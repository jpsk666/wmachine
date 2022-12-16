`timescale 1ns / 1ps

module scan4 (
    input clk,
    input [3:0] l0,
    l1,
    l2,
    l3,  //4个灯的数字，从右到左，取值0~9
    output reg [3:0] ena,  //使能信号
    output [7:0] light  //显像
);
  reg clk_2;//降频后时钟
  reg [1:0] scan = 0;
  parameter x = 200000;
  reg [17:0] cnt = 0;
  reg [ 3:0] num;
  
  num_to_signal f (
      num,
      light
  );
  //降频
  always @(posedge clk) begin
    if (cnt == (x >> 1) - 1) begin
      clk_2 <= ~clk_2;
      cnt   <= 0;
    end else cnt = cnt + 1;
  end
  
  always @(posedge clk_2) begin
    scan <= scan + 1;
  end
  always @(*) begin
    case (scan)
      2'b00: begin //最右边灯亮
        ena = 4'h01;
        num = l0;
      end  
      2'b01: begin
        ena = 4'h02;
        num = l1;
      end
      2'b10: begin
        ena = 4'h04;
        num = l2;
      end
      2'b11: begin
        ena = 4'h08;
        num = l3;
      end
    endcase
  end
endmodule
