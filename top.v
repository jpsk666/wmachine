`timescale 1ns / 1ps

module top (
  input clk,
  input rst,//复位信号
  input bt,l_bt,r_bt,u_bt,d_bt,//中间,上下左右按钮
  input [3:0]sw,//右边4个拨码开关，从左到右
  output reg [7:0] led_r,led_l, //两组数码管的显像
  output reg [3:0] ena_r,ena_l,  //两组数码管的使能
  output reg [7:0] st_light, //8个状态灯
  output reg [7:0] wt_light, //8个水量灯
  output reg buzzer
);
reg [2:0] state; //三大状�??
reg [1:0] mode;
reg [11:0] bal; //余额
reg [11:0]dy_price_old={4'd0,4'd2,4'd3}; //价格
reg [11:0]s_price_old={4'd0,4'd4,4'd5};
reg [11:0]m_price_old={4'd0,4'd6,4'd7};
reg [11:0]b_price_old={4'd0,4'd8,4'd9};
reg [11:0]setfine_old={4'd0,4'd2,4'd8}; //超时罚款
reg [11:0]old_runtime;
reg [11:0]old_profit;
reg isAdmin; //是否管理员模�?


//按钮模块（中上下左右�?
wire m_pos,u_pos,l_pos,d_pos,r_pos;
button mid(clk,bt,m_pos);
button up(clk,u_bt,u_pos);
button down(clk,d_bt,d_pos);
button left(clk,l_bt,l_pos);
button right(clk,r_bt,r_pos);


//独立计时模块
wire[15:0] new_runtime;
reg [11:0] add_runtime=12'b000000000001;
addition addition0(
  old_runtime,
  add_runtime,
  new_runtime
);
reg [27:0] t;
always @(posedge clk) begin
  if(state==3'b010)begin
    if(t>100000000) begin //计时1�?
        t<=0;
        old_runtime<=new_runtime[11:0];
    end
    else t<=t + 1;
  end
end

//盈利累计例化
wire [15:0] new_profit;
reg [11:0] add_profit;
addition addition1(
  old_profit,
  add_profit,
  new_profit
);


//待机显示“stand by�?
wire [3:0] standby_ena_r;
wire [7:0] standby_led_r;
scan4_letter scan4_letter_r(
  clk,4'h6,4'h5,4'hb,4'h4,
  standby_ena_r,
  standby_led_r
);
wire [3:0] standby_ena_l;
wire [7:0] standby_led_l;
scan4_letter scan4_letter_l(
  clk,4'h3,4'h2,4'h1,4'h0,
  standby_ena_l,
  standby_led_l
);

//admin模块的例�?
reg admin_on;
wire admin_next;
wire [11:0] dy_price_new;
wire [11:0] s_price_new;
wire [11:0] m_price_new;
wire [11:0] b_price_new;
wire [11:0] setfine_new;
wire [7:0] admin_led_r,admin_led_l;
wire [3:0] admin_ena_r,admin_ena_l;
admin admin(
  admin_on,clk,rst,
  sw[0],sw[1],
  m_pos,u_pos,r_pos,
  dy_price_old,
  s_price_old,
  m_price_old,
  b_price_old,
  setfine_old,
  old_runtime,old_profit,
  admin_led_r,admin_ena_r,
  admin_led_l,admin_ena_l,
  dy_price_new,
  s_price_new,
  m_price_new,
  b_price_new,
  setfine_new,
  admin_next
);

//pre模块的例�?
reg pre_on;
wire pre_isOn;
wire [7:0] pre_led_r,pre_led_l;
wire [3:0] pre_ena_r,pre_ena_l;
wire [11:0] pre_bal;
wire [1:0] pre_mode;
wire [2:0] pre_st_light;
pre pre(
  pre_on,clk,rst,
  sw[0],sw[1],sw[2],sw[3],
  r_pos,m_pos,u_pos,
  pre_isOn,
  pre_led_r,
  pre_ena_r,
  pre_led_l,
  pre_ena_l,
  pre_bal,
  pre_mode,
  pre_st_light
);

//wash模块的例�?
reg wash_on;
wire [7:0] wash_led;
wire [3:0] wash_ena;
wire [7:0] wash_led_l;
wire [3:0] wash_ena_l;
wire [7:0] wash_st_light;
wire [7:0] wash_wt_light;
wire wash_next;
wash wash(
  wash_on, clk, rst,
  mode,
  m_pos,u_pos,
  wash_led,
  wash_led_l,
  wash_ena,
  wash_ena_l,
  wash_st_light,
  wash_wt_light,
  wash_next
);

//billing模块的例�?
reg billing_on;
wire [7:0] billing_led;
wire [3:0] billing_ena;
wire [7:0] billing_led_l;
wire [3:0] billing_ena_l;
wire [7:0] billing_st_light;
wire [7:0] billing_wt_light;
wire billing_buzzer;
wire billing_next;
wire [11:0] income;
billing billing(
  billing_on,clk,rst,
  m_pos,u_pos,d_pos,
  bal,mode,
  dy_price_old,s_price_old,m_price_old,b_price_old,setfine_old,
  billing_led,billing_led_l,
  billing_ena,billing_ena_l,
  billing_st_light,
  billing_wt_light,
  billing_buzzer,
  billing_next,
  income
);

//* * * * * * * * * * * * * * * * 分割�? * * * * * * * * * * * * * * * * *


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
    state<=3'b00;
    isAdmin<=0;
  end
  else begin
    case (state)
      3'b100:begin //管理员模�?
        admin_on<=1;
        led_l<=admin_led_l;
        led_r<=admin_led_r;
        ena_l<=admin_ena_l;
        ena_r<=admin_ena_r;
        if(u_pos & admin_next) begin//回到待机模式
          admin_on<=0;
          isAdmin<=0;
          dy_price_old<=dy_price_new;
          s_price_old<=s_price_new;
          m_price_old<=m_price_new;
          b_price_old<=b_price_new;
          setfine_old<=setfine_new;
          state<=3'b000;
        end
        if(r_pos & admin_next) begin //按右键，带着管理员身份进入pre
          admin_on<=0;
          isAdmin<=1;
          dy_price_old<=dy_price_new;
          s_price_old<=s_price_new;
          m_price_old<=m_price_new;
          b_price_old<=b_price_new;
          setfine_old<=setfine_new;
          state<=3'b001;
        end
        if(d_pos) begin
          old_profit<=0;
          old_runtime<=0;
        end
      end

      3'b000: begin //待机阶段
          pre_on<=0;
          wash_on<=0;
          billing_on<=0;
          st_light<=8'b00000000;
          bal<=12'b000000000000;
          mode<=2'b00;
          led_l<=standby_led_l;//待机显示花样
          led_r<=standby_led_r;
          ena_l<=standby_ena_l;
          ena_r<=standby_ena_r;
       
        if(u_pos) state<=3'b100;//按上键进入管理员模式
        if(r_pos) begin
          state<=3'b001;
          isAdmin<=1;
        end
        if(m_pos) state<=3'b001;
       
      end
      3'b001: begin //pre阶段
        pre_on<=1;
        led_l<=pre_led_l;
        led_r<=pre_led_r;
        ena_l<=pre_ena_l;
        ena_r<=pre_ena_r;
        
        st_light[2:0]<=pre_st_light;
        bal<=pre_bal;
        if(m_pos && pre_isOn) begin
          state<=3'b010;
          pre_on<=0;
          mode<=pre_mode;
          // if(pre_mode==2'b00) begin
          //   add_profit<=dy_price_old;
          // end
          // else if(pre_mode==2'b01) begin
          //   add_profit<=s_price_old;
          // end
          // else if(pre_mode==2'b10) begin
          //   add_profit<=m_price_old;
          // end
          // else if(pre_mode==2'b11) begin
          //   add_profit<=b_price_old;
          // end
        end
      end
      3'b010: begin //wash阶段
        wash_on<=1;
        led_r<=wash_led;
        led_l<=wash_led_l;
        ena_r<=wash_ena;
        ena_l<=wash_ena_l;
        wt_light<= wash_wt_light;
        st_light<=wash_st_light;
        if(wash_next) begin
          state<=3'b011;
          wash_on<=0;
        end
      end
      2'b11: begin //billing阶段
        billing_on<=1;
        led_r<=billing_led;
        ena_r<=billing_ena;
        led_l<=billing_led_l;
        ena_l<=billing_ena_l;
        st_light<=billing_st_light;
        wt_light<=billing_wt_light;
        buzzer<=billing_buzzer;
        add_profit<=income;
        if(billing_next) begin
          state<=2'b000;
          billing_on<=0;
          old_profit<=new_profit[11:0];
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
