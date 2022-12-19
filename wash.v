`timescale 1ns / 1ps

module wash (
    input on, clk,rst
    output wire [7:0] light,  //数码管信号
    output [3:0] ena,  //数码管使能信号
    output reg [7:0] st_light //接灯
    )

reg [33:0]t;//计时100秒
reg [3:0] n1, n2, n3, n0; //1~3：个位至百位; 0:符号位
parameter o = 1'b0;
reg [1:0] state = 1'b0;  //3种状态

scan4 scanner (
      clk,
      n1,
      n2,
      n3,
      n0,
      ena,
      light
  ); 
always @(*) begin//小灯
    case (st)
      2'b00: begin
        st_light = 8'b00001111;
      end
      2'b01: begin
        st_light = 8'b00111111;
      end
      2'b10: begin
        st_light = 8'b01111111;
      end
      default: begin
        st_light = 8'b0;
      end
    endcase
  end
always @(posedge clk, negedge rst) begin
    
    if (!rst) begin
      st <= 1'b0;
      {n1,n2,n3,n0}={o,o,o,o};
    end 
    else begin
      if(on) begin
      case (st)  //状态判断
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
        end
        2'b01: begin
          {n2, n3, n0} <= {o, o, o};
          if (r_pos)
            if (n1 < 4'd3) n1 <= n1 + 1;
            else n1 <= 0;
          else n1 <= n1;
        end
      endcase
    end
    end
  end

endmodule