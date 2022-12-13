`timescale 1ns / 1ps
module flash_led_top (
    input clk,
    input rst,
    output [7:0] led,
    output [3:0] ena
);
  wire [3:0] p1, p2;
  wire [3:0] num_signal;  //先提取信号
  
  counter cnt1 (
      .clk(clk),
      .rst_n(rst),
      .p1(p1),
      .p2(p2)
  );
  num_to_signal signal (
      num_signal,
      led
  );
  flash_led_ctrl fled_ctrl (
      clk,
      p1,
      p2,
      rst,
      num_signal,
      ena
  );
endmodule
