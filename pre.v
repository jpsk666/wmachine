`timescale 1ns / 1ps

module pre (
    input p1,  //4个拨码开关，从右到左
    p2,
    p3,
    sign,
    input ri_bt,  //右按键,选模式
    input clk,
    input rst,
    (* DONT_TOUCH = "1" *) input bt,  //确定按钮,进入下一状态
    // output isOn,//按下按钮能否进入洗衣阶段
    output wire [7:0] light,  //灯信号
    output [3:0] ena,  //4个灯使能信号
    // output reg [9:0] bal,//余额，最大999
    // output reg [1:0] mode//模式
    output reg [2:0] state  //接灯
);
  reg [27:0] t;  //0.66秒计数
  reg [3:0] n1, n2, n3, n0;  //1~3 个位至百位,0:符号位

  parameter o = 1'b0;
  wire next1;
  assign next1= ~(p1 | p2 | p3 | sign) & (n0 != 10);
  //四个开关一个都不能上拨，且第一位不能是负数，才能下一阶段
  reg [1:0] st = 1'b0;
  reg [1:0] r_trig=2'b00;  //右按键模拟上升沿
  wire r_pos = r_trig[0] & ~r_trig[1];
  reg [1:0] m_trig=2'b00;  //中按键模拟上升沿
  wire m_pos = m_trig[0] & ~m_trig[1];

  scan4 scanner (
      clk,
      n1,
      n2,
      n3,
      n0,
      ena,
      light
  );  //没写完
  always @(*) begin
    case (st)
      2'b00:  begin state = 3'b001; end
      2'b01: begin
        state = 3'b010;   
      end
      2'b10: begin state = 3'b100;  end
      default: begin state = 3'b0;  end
    endcase

  end
  always @(posedge clk, negedge rst) begin
    if(!rst) begin
      st<=1'b0;
    end else begin
      case (bt)
      1'b1: m_trig[0] <= 1'b1;
      0: m_trig[0] <= 0;
    endcase
    case (m_trig[0])
      1'b1: m_trig[1] <= 1'b1;
      0: m_trig[1] <= 0;
    endcase

    case (st) //状态判断
      2'b0: begin
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
        if(m_pos) begin
          if(next1) begin
            st<= 2'b01;
            n1<=0; //可行，转化状态时直接赋值0
          end else st<= 1'b0;
        end else st<= 1'b0;
      end
      2'b01: begin
        {n2, n3, n0} <= {o, o, o};
        
        case (ri_bt)
          1'b1: r_trig[0] <= 1'b1;
          0: r_trig[0] <= 0;
        endcase
        case (r_trig[0])
          1'b1: r_trig[1] <= 1'b1;
          0: r_trig[1] <= 0;
        endcase
        if (r_pos) 
          if(n1<4'd3) n1 <= n1 + 1;
          else n1<= 0;
        else n1 <= n1;     
      end
    endcase
    end
    
  end

endmodule

