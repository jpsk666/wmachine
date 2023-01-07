<<<<<<< HEAD
=======
`timescale 1ns / 1ps

module admin(
    input on,clk,rst,
    p1,p2,p3,sign,
    (* DONT_TOUCH = "1" *) 
    input r_pos,m_pos,u_pos,d_pos,//按键
    output wire [7:0] led_r,  //数码管信号
    output [3:0] ena_r,  //数码管使能信号
    output wire [7:0] led_l,  //左数码管信号
    output [3:0] ena_l,  //左数码管使能信号
    output reg [11:0]dy_price,
    output reg [11:0]s_price,
    output reg [11:0]m_price,
    output reg [11:0]b_price,
    output reg [11:0]setfine
);
reg [27:0] t;  //0.66秒计数
reg [29:0] alarm_t; //2.5s
reg [3:0] n1, n2, n3, n0;  //1~3：个位至百位; 0:符号位
reg [3:0] n5, n6, n7, n8;  //5~8 从右到左
reg open = 0;//盖子是否打开状态
reg [3:0] lid_state;


parameter o = 1'b0;
parameter off = 4'hb;
parameter true = 1'b1;
wire next1;
assign next1 = ~(p1 | p2 | p3 | sign) & (n0 != 10);
//四个开关一个都不能上拨，且第一位不能是负数，才能下一阶段
reg [1:0] st = 2'b00;  //3种状态
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
    st <= 1'b0;
    {n1, n2, n3, n0} <= {o, o, o, o};
    {n5, n6, n7, n8} <= {off, off, off, off};
  end else begin
    if (on) begin
      case (st)  //状态判断
        2'b00: begin
          {n5, n6, n7} <= {off, off, off};
          n8<=0;

          if (t >= 66000000) begin
            t <= 0;
            if (p1) begin  //拨上去时才加1,是否要写拨回去时的分支？
              if (n1 != 4'd9) n1 <= n1 + 1;
              else n1 <= 0;
            end else n1 <= n1;
            if (p2) begin
              if (n2 != 4'd9) n2 <= n2 + 1;
              else n2 <= 0;
            end else n2 <= n2;
            if (p3) begin
              if (n3 != 4'd9) n3 <= n3 + 1;
              else n3 <= 0;
            end else n3 <= n3;
            if (sign) begin
              if (n0 != 4'd10) n0 <= 4'd10;  //10代表负号
              else n0 <= 0;
            end else n0 <= n0;
          end else t <= t + 1;

          if (m_pos) begin  //如果按按钮就判断是否下一阶段
            if (next1) begin
              st <= 2'b01;
              n1 <= 0;  //可行，转化状态时直接赋值0
              {bal[4:1], bal[8:5], bal[12:9]} <= {n1, n2, n3};
              //可以这么做？
            end 
            else begin
              st <= 1'b0;
              {n0, n1, n2, n3} <= {o, o, o, o};
            end
          end else st <= 1'b0;
        end

        2'b01: begin
          {n5, n6, n7} <= {off, off, off};
          {n2, n3, n0} <= {o, o, o};
          n8<=0;
          if (r_pos)
            if (n1 < 4'd3) n1 <= n1 + 1;
            else n1 <= 0;
          else n1 <= n1;

          if (u_pos) begin //开盖，进入下一状态
            st <= 2'b10;
            mode <= n1[1:0];//确定模式
            n8 <= n1;//放在最左侧显示
            {n0, n1, n2, n3} <= {o, o, o, o};
          end
        end
        2'b10: begin  //状态3
          //仍然是右按键增大 
          if (r_pos) begin
            if (p1)//最右侧拨码开关上拨时表示十位数
              if (n2 > 4'd2)  //十位最多为20
                n2 <= 0;
              else n2 <= n2 + 1;
            else begin
              if (1 < 4'd9) n1 <= n1 + 1;
              else n1 <= 0;
            end
          end
          //确认输入
          if(m_pos)begin
            if(~isOn) begin
             
              end
          end
        end
      endcase
    end
  end
end


endmodule
>>>>>>> d25c47f386867feb475f56fd5feeccbfa8d46e3d
