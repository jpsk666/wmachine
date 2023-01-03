`timescale 1ns / 1ps
//test
module pre (
    input on,  //使能
    input p1,
    p2,
    p3,
    sign,  //4个拨码开关，从右到左
    input m_pos,  //右按键,选模式
    input clk,
    input rst,
    (* DONT_TOUCH = "1" *) input r_pos,  //确定按钮,进入下一状态
    output reg isOn,  //按下按钮能否进入洗衣阶段
    output wire [7:0] light,  //数码管信号
    output [3:0] ena,  //数码管使能信号
    output wire [7:0] light_l,  //左数码管信号
    output [3:0] ena_l,  //左数码管使能信号
    output reg [12:1] bal,  //余额，最大999
    output reg [1:0] mode,  //模式 //有4个
    output reg [2:0] st_light  //接左边3小灯表示状态
);
  reg [27:0] t;  //0.66秒计数
  reg [3:0] n1, n2, n3, n0;  //1~3：个位至百位; 0:符号位
  reg [3:0] n5, n6, n7, n8;  //1~3：个位至百位; 0:符号位
  reg [29:0] alarm_t; //2.5s

  parameter o = 1'b0;
  parameter off = 4'hb;
  parameter true = 1'b1;
  wire next1;
  assign next1 = ~(p1 | p2 | p3 | sign) & (n0 != 10);
  //四个开关一个都不能上拨，且第一位不能是负数，才能下一阶段

  reg [1:0] st = 1'b0;  //3种状态


  scan4 scanner (
      clk,
      n1,
      n2,
      n3,
      n0,
      ena,
      light
  );
  scan4 scanner2 (
      clk,
      n5,
      n6,
      n7,
      n8,
      ena_l,
      light_l
  );

  always @(*) begin  //小灯
    case (st)
      2'b00: begin
        st_light = 3'b001;
        isOn = 0;
      end
      2'b01: begin
        st_light = 3'b010;
        isOn = 0;
      end
      2'b10: begin  //状态3
        st_light = 3'b100;
        case (mode)
          2'b01: begin
            if (n2 == 0) isOn = true;
            else isOn = 0;
          end
          2'b10: begin
            if (n2 != 3'b000x) isOn = 0;
            else isOn = true;
          end
          default: isOn = true;
        endcase
      end
      default: begin
        st_light = 3'b0;
        isOn = 0;
      end
    endcase
  end



  always @(posedge clk, negedge rst) begin

    if (!rst) begin
      st <= 1'b0;
      {n1, n2, n3, n0} <= {o, o, o, o};
      {n5, n6, n7, n8} <= {off, off, off, off};
    end else begin
      if (on) begin
        case (st)  //状态判断
          2'b0: begin
            {n5, n6, n7, n8} <= {off, off, off, off};
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
              end else begin
                st <= 1'b0;
                {n0, n1, n2, n3} <= {o, o, o, o};
              end
            end else st <= 1'b0;
          end

          2'b01: begin
            {n5, n6, n7, n8} <= {off, off, off, off};
            {n2, n3, n0} <= {o, o, o};
            if (r_pos)
              if (n1 < 4'd3) n1 <= n1 + 1;
              else n1 <= 0;
            else n1 <= n1;

            if (m_pos) begin
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
            // if(m_pos)begin
            //   if(~isOn)
            //   case (mode)
            //   2'b00:

            //   2'b01:

            //   endcase

            // end


          end

        endcase
      end
    end
  end
endmodule

