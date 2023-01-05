`timescale 1ns / 1ps

module billing (
    input on, clk,rst,
    input [11:0] bal,
    input [1:0] mode,
    output wire [7:0] led,  //数码管信号
    output [3:0] ena,  //数码管使能信号
    output reg [7:0] st_light //接灯
    );
parameter o = 1'b0;//显示0
parameter n = 4'd11;//熄灯
reg [26:0]t;//计时1秒
reg [3:0] n1=o;//数码管初始化
reg [3:0] n2=n;
reg [3:0] n3=4'd9;
reg [3:0] n0=4'd9;
reg st = 0;  //2种状态

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
        {n1,n2,n3,n0}<={o,n,4'd9,4'd9};
    end 
    else begin
        if(on) begin
            if(tpst==1'b0)begin
                case(mode)
                    2'b00:begin//甩干
                        settot<=15;
                        setn0<=4'd1;
                        setn3<=4'd5;
                        tcur<=0;
                        tpst<=2'b11;//直接进入脱水阶段
                    end
                    2'b01:begin//小
                        settot<=30;
                        setn0<=4'd3;
                        setn3<=4'd0;
                        setseq<=10;
                        tcur<=0;
                        tpst<=2'b01;//进入正常洗衣阶段
                    end
                    2'b10:begin//中
                        settot<=45;
                        setn0<=4'd4;
                        setn3<=4'd5;
                        setseq<=15;
                        tcur<=0;
                        tpst<=2'b01;
                    end
                    2'b11:begin//大
                        settot<=60;
                        setn0<=4'd6;
                        setn3<=4'd0;
                        setseq<=20;
                        tcur<=0;
                        tpst<=2'b01;
                    end
                    default:begin
                        settot<=60;
                        setn0<=4'd6;
                        setn3<=4'd0;
                        setseq<=20;
                        tcur<=0;
                        tpst<=2'b01;
                    end
                endcase
            end
        end
    end
end
endmodule