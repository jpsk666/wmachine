`timescale 1ns / 1ps

module admin(
    input on,clk,rst,
    p1,p2,
    (* DONT_TOUCH = "1" *) 
    input r_pos,m_pos,u_pos,d_pos,//按键
    input [11:0]dy_price_old,
    input [11:0]s_price_old,
    input [11:0]m_price_old,
    input [11:0]b_price_old,
    input [11:0]setfine_old,
    input [11:0]runtime,
    input [11:0]profit,
    output wire [7:0] led_r,
    output [3:0] ena_r,  
    output wire [7:0] led_l,  //左数码管信号
    output [3:0] ena_l,  //左数码管使能信号
    output reg [11:0]dy_price_new,
    output reg [11:0]s_price_new,
    output reg [11:0]m_price_new,
    output reg [11:0]b_price_new,
    output reg [11:0]setfine_new,
    output reg [11:0] new_profit,
    output reg time_rst,
    output reg next
);
reg [2:0] st = 3'b111;  
reg [27:0] t;  //0.66�?
reg [3:0] n1,n2,n3, n0, n5, n6, n7, n8;

parameter o = 1'b0;
parameter off = 4'hb;
parameter true = 1'b1;

wire next1;
assign next1 = ~(p1 | p2 );
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
    st <= 3'b111;
    {n1, n2,n3} <= {dy_price_old[3:0],dy_price_old[7:4],dy_price_old[11:8]};
    {n5, n6, n7, n8, n0} <= {off, off, off, off, off};
  end 
  else begin
    if (on) begin
      if(u_pos) begin //按上键中途�??出管理员模式
        st<=3'b111;
      end
      if(~(p1|p2)&((st==3'b110)||u_pos)) begin
        next<=1;
      end
      case (st)  
        3'b111:begin
          {n1, n2,n3} <= {dy_price_old[3:0],dy_price_old[7:4],dy_price_old[11:8]};
          dy_price_new<=dy_price_old;
          s_price_new<=s_price_old;
          m_price_new<=m_price_old;
          b_price_new<=b_price_old;
          setfine_new<=setfine_old;
          new_profit<=profit;
          st<=3'b000;
        end
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
            {dy_price_new[3:0], dy_price_new[7:4], dy_price_new[11:8]} <= {n1, n2, n3};
            {n1, n2, n3} <= {s_price_old[3:0], s_price_old[7:4], s_price_old[11:8]};
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
            {s_price_new[3:0], s_price_new[7:4], s_price_new[11:8]} <= {n1, n2, n3};
            {n1, n2, n3} <= {m_price_old[3:0], m_price_old[7:4], m_price_old[11:8]};
          end
          else st <= 3'b001;
        end
        3'b010: begin//设置中件价格
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
            st <= 3'b011;
            {m_price_new[3:0], m_price_new[7:4], m_price_new[11:8]} <= {n1, n2, n3};
            {n1, n2, n3} <= {b_price_old[3:0], b_price_old[7:4], b_price_old[11:8]};
          end
          else st <= 3'b010;
        end
        
        3'b011: begin//设置大件价格
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
            st <= 3'b100;
            {b_price_new[3:0], b_price_new[7:4], b_price_new[11:8]} <= {n1, n2, n3};
            {n1, n2, n3} <= {setfine_old[3:0], setfine_old[7:4], setfine_old[11:8]};
          end
          else st <= 3'b011;
        end

        3'b100: begin//设置超时罚款
          {n5, n6, n7} <= {off, off, off};
          n8<=4;
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
            {setfine_new[3:0], setfine_new[7:4], setfine_new[11:8]} <= {n1, n2, n3};
          end
          else st <= 3'b100;
        end
        3'b101: begin//显示收款�??
          {n5, n6, n7} <= {off, off, off};
          n8<=5;
          {n1, n2, n3} <= {new_profit[3:0], new_profit[7:4], new_profit[11:8]};
          if(d_pos) new_profit<=0;//重置盈利�?
          if (m_pos && next1) st <= 3'b110;
          else st <= 3'b101;
        end
        3'b110: begin//显示运行时间
          {n5, n6, n7} <= {off, off, off};
          n8<=6;
          {n1, n2, n3} <= {runtime[3:0], runtime[7:4], runtime[11:8]};
          if(d_pos) time_rst<=1;
          else time_rst<=0;
          if (m_pos && next1) begin
            st<=3'b111;
          end
          else st <= 3'b110;
        end
      endcase
    end
  end
end


endmodule
