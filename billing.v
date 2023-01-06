`timescale 1ns / 1ps

module billing (
    input on, clk,rst,
    input u_pos,d_pos,
    input [11:0] bal,
    input [1:0] mode,
    input [11:0] set0,//传入甩干价格
    input [11:0] set1,//小
    input [11:0] set2,//中
    input [11:0] set3,//大
    output wire [7:0] led,  //数码管信号
    output [3:0] ena,  //数码管使能信号
    output reg [7:0] st_light //接灯
    output reg next;
    );
parameter o = 4'd0;//显示0
parameter n = 4'd11;//熄灯
reg [26:0]t;//计时1秒
reg [3:0] n1=o;//数码管初始化
reg [3:0] n2=n;
reg [3:0] n3=4'd9;
reg [3:0] n0=4'd9;
reg st = 0;  //2种状态
reg [15:0]setini={n,n,n,n};

scan4 scanner (
      clk,
      n1,
      n2,
      n3,
      n0,
      ena,
      led
  ); 

always @(*) begin//状态灯
    case (st)
      1'b0: begin
        st_light <= 8'b01000000;
      end
      1'b1: begin
        st_light <= 8'b10000000;
      end
      default: begin
        st_light <= 8'b0;
      end
    endcase
end

always @(posedge clk, negedge rst) begin
    if (!rst) begin
        st <= 1'b0;
        {n1,n2,n3,n0}<=setini;
    end 
    else begin
        if(on) begin
            if(st==1'b0)begin
                case(mode)
                    2'b00:begin//甩干
                        setini<={set0,n};
                    end
                    2'b01:begin//小
                        setini<={set1,n};
                    end
                    2'b10:begin//中
                        
                    end
                    2'b11:begin//大
                        
                    end
                    default:begin
                        
                    end
                endcase
            end
        end
    end
end
endmodule