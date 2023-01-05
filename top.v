`timescale 1ns / 1ps

module top (
  input clk,
  input bt, l_bt,r_bt,u_bt,d_bt,//中间,上下左右按钮
  input rst,//复位信号
  input [3:0]sw,//右边4个拨码开关，从左到右
  output reg [3:0] ena_r,ena_l,  //左右两组数码管的使能
  output reg [7:0] led_r,led_l, //数码管的显像
  output reg [7:0] st_light //下方8个状态灯
);
reg [1:0] state;
reg [2:0] mode;
reg signed [11:0] bal; //目前用户余额，接输出
reg isFine;//是否罚款
reg [8:0] dy_price,s_price,m_price,b_price;//甩干,小中大模式价格
reg o_price; //是否按默认价格收费


//按钮模块（中上下左右）
wire m_pos,u_pos,l_pos,d_pos,r_pos;
button mid(clk,bt,m_pos);
button up(clk,u_bt,u_pos);
button down(clk,d_bt,d_pos);
button left(clk,l_bt,l_pos);
button right(clk,r_bt,r_pos);

//pre模块的例化
reg pre_on;
reg pre_isOn;
wire [7:0] pre_led_r,pre_led_l;
[3:0] pre_ena_r,pre_ena_l;
reg signed [11:0] pre_bal;
reg [1:0] pre_mode;
reg [2:0] pre_st_light;
pre pre(
  pre_on,
  sw[0],sw[1],sw[2],sw[3],
  r_pos,m_pos,
  clk,rst,
  pre_isOn,
  pre_led_r,pre_ena_r,
  pre_led_l,pre_ena_l,
  pre_bal,
  pre_mode,
  pre_st_light
);

//wash模块的例化
reg wash_on;
wire [7:0] wash_led;
[3:0] wash_ena;
reg [7:0] wash_st_light;
reg [7:0] wash_wt_light;
reg wash_next;
wash wash(
  wash_on, clk, rst,
  mode,
  m_pos,
  wash_led,
  wash_ena,
  wash_st_light,
  wash_wt_light,
  wash_next
);

//billing模块的例化
reg billing_on;
wire [7:0] billing_led;
[3:0] billing_ena;
reg [7:0] billing_st_light;
reg billing_next;
billing billing(
  billing_on,
  clk,rst,
  bal,mode,
  billing_led,
  billing_ena,
  billing_st_light,
  billing_next
);

always @(posedge clk, negedge rst) begin
  if (!rst) begin
    pre_on<=0;
    wash_on<=0;
    billing_on<=0;
    st_light<=8'b00000000;
    bal<=12'b000000000000;
    mode<=2'b00;
    led_l<=8'b00000000;
    led_r<=8'b00000000;
    ena_l<=4'b0000;
    ena_r<=4'b0000;
  end
  else begin
    case (state)
      2'b00; begin //待机阶段
        pre_on<=0;
        wash_on<=0;
        billing_on<=0;
        st_light<=8'b00000000;
        bal<=12'b000000000000;
        mode<=2'b00;
        led_l<=8'b00000000;
        led_r<=8'b00000000;
        ena_l<=4'b0000;
        ena_r<=4'b0000;
        if(m_pos) begin
          state<=2'b10;
        end
      end
      2'b01: begin //pre阶段
        pre_on<=1;
        led_l<=pre_led_l;
        led_r<=pre_led_r;
        ena_l<=pre_ena_l;
        ena_r<=pre_ena_r;
        mode<=pre_mode;
        st_light[2:0]<=pre_st_light;
        bal<=pre_bal;
        if(m_pos && pre_isOn==1) begin
          state<=2'b10;
          pre_on<=0;
        end
      end
      2'b10: begin //wash阶段
        wash_on<=1;
        led_r<=wash_led;
        ena_r<=wash_ena;
        led_l<=8'b00000000;
        ena_l<=4'b0000;
        st_light<=wash_st_light;
        if(m_pos && wash_next) begin
          state<=2'b11;
          wash_on<=0;
        end
      end
      2'b11: begin //billing阶段
        billing_on<=1;
        led_r<=billing_led;
        ena_r<=billing_ena;
        led_l<=8'b00000000;
        ena_l<=4'b0000;
        st_light<=billing_st_light;
        if(m_pos && wash_next) begin
          state<=2'b00;
          billing_on<=0;
        end
      end
      default: begin
        pre_on<=0;
        wash_on<=0;
        billing_on<=0;
        st_light<=8'b00000000;
      end
    endcase
  end
end
endmodule
