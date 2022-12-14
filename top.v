`timescale 1ns / 1ps

module top (
    input clk,
    input bt, l_bt,r_bt,u_bt,d_bt,//中间,左右按钮
    input rst,
    output reg [3:0] ena_r,ena_l,  //左右2组灯的使能
    output reg [3:0] l_light,r_light, //左右两组灯的显像
    output reg [7:0] led
);
  reg [2:0] mode;



endmodule
