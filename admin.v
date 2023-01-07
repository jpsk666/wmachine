`timescale 1ns / 1ps

module admin(
    input on,clk,rst,
    p1,p2,//两个拨码开关
    (* DONT_TOUCH = "1" *) 
    input r_pos,m_pos,u_pos,d_pos,//按键
    input [11:0]dy_price,
    input [11:0]s_price,
    input [11:0]m_price,
    input [11:0]b_price,
    input [11:0]setfine,
    input [11:0]runtime,
    input [11:0]profit,
    output wire [7:0] led_r,  //数码管信号
    output [3:0] ena_r,  //数码管使能信号
    output wire [7:0] led_l,  //左数码管信号
    output [3:0] ena_l,  //左数码管使能信号
    output reg [11:0]dy_price,
    output reg [11:0]s_price,
    output reg [11:0]m_price,
    output reg [11:0]b_price,
    output reg [11:0]setfine,
    output reg next
);
reg [2:0] st = 3'b000;  //状态
reg [27:0] t;  //0.66秒计数
reg [3:0] n1, n2, n3, n0, n5, n6, n7, n8;//显像管变量

parameter o = 1'b0;
parameter off = 4'hb;
parameter true = 1'b1;

wire next1;
assign next1 = ~(p1 | p2 );//确认开关复位

scan4 scanner (
    clk,
    n1,
    n2,
    n3,
    n0,
    ena_r,
    led_r
);
scan4 scanner2 (
    clk,
    n5,
    n6,
    n7,
    n8,
    ena_l,
    led_l
);


always @(posedge clk, negedge rst) begin
  if (!rst) begin
    st <= 3'b000;
    {n1, n2} <= {o, o};
    {n5, n6, n7, n8, n3, n0} <= {off, off, off, off, off, off};
  end else begin
    if (on) begin
      case (st)  //状态判断
        3'b000: begin//设置甩干价格
          {n5, n6, n7} <= {off, off, off};
          n8<=0;
          if (t >= 66000000) begin
            t <= 0;
            if (p1) begin  
              if (n1 != 4'd9) n1 <= n1 + 1;
              else n1 <= 0;
            end else n1 <= n1;
            if (p2) begin
              if (n2 != 4'd9) n2 <= n2 + 1;
              else n2 <= 0;
            end else n2 <= n2;
          end else t <= t + 1;

          if (m_pos && next1) begin 
            st <= 3'b001;
            {dy_price[3:0], dy_price[7:4], dy_price[11:8]} <= {n1, n2, n3};
            {n1, n2, n3} <= {s_price[3:0], s_price[7:4], s_price[11:8]};
          end
          else st <= 3'b000;
        end
        3'b001: begin//设置小件价格
          {n5, n6, n7} <= {off, off, off};
          n8<=1;
          if (t >= 66000000) begin
            t <= 0;
            if (p1) begin  
              if (n1 != 4'd9) n1 <= n1 + 1;
              else n1 <= 0;
            end else n1 <= n1;
            if (p2) begin
              if (n2 != 4'd9) n2 <= n2 + 1;
              else n2 <= 0;
            end else n2 <= n2;
          end else t <= t + 1;

          if (m_pos && next1) begin 
            st <= 3'b010;
            {s_price[3:0], s_price[7:4], s_price[11:8]} <= {n1, n2, n3};
            {n1, n2, n3} <= {m_price[3:0], m_price[7:4], m_price[11:8]};
          end
          else st <= 3'b001;
        end
        3'b010: begin//设置中件价格
          {n5, n6, n7} <= {off, off, off};
          n8<=1;
          if (t >= 66000000) begin
            t <= 0;
            if (p1) begin  
              if (n1 != 4'd9) n1 <= n1 + 1;
              else n1 <= 0;
            end else n1 <= n1;
            if (p2) begin
              if (n2 != 4'd9) n2 <= n2 + 1;
              else n2 <= 0;
            end else n2 <= n2;
          end else t <= t + 1;

          if (m_pos && next1) begin 
            st <= 3'b011;
            {m_price[3:0], m_price[7:4], m_price[11:8]} <= {n1, n2, n3};
            {n1, n2, n3} <= {b_price[3:0], b_price[7:4], b_price[11:8]};
          end
          else st <= 3'b010;
        end
        
        3'b011: begin//设置大件价格
          {n5, n6, n7} <= {off, off, off};
          n8<=2;
          if (t >= 66000000) begin
            t <= 0;
            if (p1) begin  
              if (n1 != 4'd9) n1 <= n1 + 1;
              else n1 <= 0;
            end else n1 <= n1;
            if (p2) begin
              if (n2 != 4'd9) n2 <= n2 + 1;
              else n2 <= 0;
            end else n2 <= n2;
          end else t <= t + 1;

          if (m_pos && next1) begin 
            st <= 3'b100;
            {b_price[3:0], b_price[7:4], b_price[11:8]} <= {n1, n2, n3};
            {n1, n2, n3} <= {setfine[3:0], setfine[7:4], setfine[11:8]};
          end
          else st <= 3'b011;
        end

        3'b100: begin//设置超时罚款
          {n5, n6, n7} <= {off, off, off};
          n8<=3;
          if (t >= 66000000) begin
            t <= 0;
            if (p1) begin  
              if (n1 != 4'd9) n1 <= n1 + 1;
              else n1 <= 0;
            end else n1 <= n1;
            if (p2) begin
              if (n2 != 4'd9) n2 <= n2 + 1;
              else n2 <= 0;
            end else n2 <= n2;
          end else t <= t + 1;

          if (m_pos && next1) begin 
            st <= 3'b101;
            {setfine[3:0], setfine[7:4], setfine[11:8]} <= {n1, n2, n3};
          end
          else st <= 3'b100;
        end
        3'b101: begin//显示收款数
          {n5, n6, n7} <= {off, off, off};
          n8<=4;
          {n1, n2, n3} <= {profit[3:0], profit[7:4], profit[11:8]}
          if (m_pos && next1) st <= 3'b110;
          else st <= 3'b101;
        end
        3'b110: begin//显示运行时间
          {n5, n6, n7} <= {off, off, off};
          n8<=4;
          {n1, n2, n3} <= {runtime[3:0], runtime[7:4], runtime[11:8]}
          if (m_pos && next1) begin
            next<=1;
          end
          else st <= 3'b110;
        end
      endcase
    end
  end
end


endmodule
