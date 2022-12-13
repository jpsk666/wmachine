`timescale 1ns / 1ps

module pre (
    input p1,//4个拨码开关，从右到左
    p2,
    p3,
    sign,
    input ri_bt,//右按键
    input clk,
    input bt,//确定按钮
    output isOn,//按下按钮能否进入洗衣阶段
    output wire [7:0] light,//灯信号
    output reg [3:0] ena,  //4个灯使能信号
    output reg [9:0] bal,//余额，最大999
    output reg [1:0] mode//模式
);
  reg [27:0] t;  //0.66秒计数
  reg [3:0] n1, n2, n3, n0; //1~3 个位至百位,0:符号位
  reg [3:0] sc;
  
  parameter o =1'b0;
  wire next1 = ~(p1 | p2 | p3 | sign) & (n0 != 10); 
  //四个开关一个都不能上拨，且第一位不能是负数，才能下一阶段
  reg [1:0] st;

  scan4(clk,n1,n2,n3,n0,ena,light);//没写完

  always @(posedge clk) begin
    sc <= sc + 1; 
    //扫描不会停
    case (st)  //状态判断
      2'b0:
      if (t >= 66000000) begin
        t <= 0;
        if (p1) begin  //拨上去时才加1,是否要写拨回去时的分支？
          if (n1 != 4'd9) n1 <= n1 + 1;
          else n1 <= 0;
        end
        if (p2) begin
          if (n2 != 4'd9) n2 <= n2 + 1;
          else n2 <= 0;
        end
        if (p3) begin
          if (n3 != 4'd9) n3 <= n3 + 1;
          else n3 <= 0;
        end
        if (sign) begin
          if (n0 != 4'd10) n0 <= 4'd10;  //10代表负号
          else n0 <= 0;
        end
      end else t <= t + 1;

      2'b01: if(t== 75000000)begin
      t<=0;
      end else t <=t+1;
    endcase
  end

  always @(posedge bt) begin //按钮控制状态迁移
    case (st)
      2'b0:
      if (next1) begin
        st <= st + 1;
        bal <=100*n3 + 10*n2 +n1; 
      end else begin
        {n1,n2,n3}={o,o,o};
        st <= st;
      end
      

    endcase
  end
endmodule

