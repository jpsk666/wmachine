`timescale 1ns / 1ps

module top (
    input clk,
    input bt, l_bt,r_bt,u_bt,d_bt,//中间,上下左右按钮
    input rst,//复位信号
    input [3:0]sw,//右边4个拨码开关
    output reg [3:0] ena_r,ena_l,  //左右2组灯的使能
    output reg [3:0] r_light,l_light, //左右两组灯的显像
    output reg [7:0]led
);
  reg [2:0] mode;
  reg isFine;//是否罚款
  reg [8:0] dy_price,s_price,m_price,b_price;//甩干,小中大模式价格
  reg o_price; //是否按默认价格收费
  reg [9:0] bal; //目前用户余额，接输出




endmodule
