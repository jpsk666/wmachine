`timescale 1ns / 1ps

module top (
  input clk,
  input bt, l_bt,r_bt,u_bt,d_bt,//中间,上下左右按钮
  input rst,//复位信号
  input [3:0]sw,//右边4个拨码开关，从左到右
  output reg [3:0] ena_r,ena_l,  //左右两组数码管的使能
  output reg [3:0] led_r,led_l, //左右数码管的显像
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
wash wash(
  wash_on,
  clk,rst,
  mode,
  m_pos,
  wash_led,
  wash_ena,
  wash_st_light
);

//billing模块的例化
reg billing_on;
wire [7:0] billing_led;
[3:0] billing_ena;
reg [7:0] billing_st_light;
billing billing(
  billing_on,
  clk,rst,
  bal,
  billing_led,
  billing_ena,
  billing_st_light
);

always @(posedge clk, negedge rst) begin
  if (!rst) begin
    
  end
  else begin
    case (state)
      2'b00: begin //pre阶段
        pre_on<=1;
        led_l<=pre_led_l;
        led_r<=pre_led_r;
        ena_l<=pre_ena_l;
        ena_r<=pre_ena_r;
        mode<=pre_mode;
        st_light[2:0]<=pre_st_light;
        bal<=pre_bal;
        if(pre_isOn==1 && m_pos) begin
          state<=2'b01;
        end
      end
      2'b01: begin //wash阶段
        
      end
      2'b10: begin //billing阶段
        
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
