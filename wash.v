`timescale 1ns / 1ps

module wash (
    input on, clk,rst,
    input [1:0] mode,
    (* DONT_TOUCH = "1" *) input bt,
    output wire [7:0] light,  //数码管信号
    output [3:0] ena,  //数码管使能信号
    output reg [7:0] st_light //接灯
    );
parameter o = 1'b0;//显示0
parameter n = 4'd11;//熄灯
reg [26:0]t;//计时1秒
reg [26:0]tnow=0;//当前时间
reg [26:0]tcur=0;//当前状态持续时间
reg [3:0] n1=o;//数码管初始化
reg [3:0] n2=n;
reg [3:0] n3=4'd9;
reg [3:0] n0=4'd9;
reg [1:0] tpst=1'b0;  //4种状态：机器设定，水洗，冲洗，脱水
reg [2:0] st = 1'b0;  //6种状态:rotate，stew，addwater，drain，fspin，rspin

wire m_pos;
  button mid (      clk,      bt,      m_pos  );

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
    case (tpst)
      2'b00: begin//setup
        st_light = 8'b00000100;
      end
      2'b01: begin//main washing
        st_light = 8'b00001000;
      end
      2'b10: begin//rinsing
        st_light = 8'b00010000;
      end
      2'b11: begin//dehydration
        st_light = 8'b00100000;
      end
      default: begin
        st_light = 8'b0;
      end
    endcase
  end
always @(posedge clk, negedge rst) begin
    if (!rst) begin
        st <= 1'b0;
        {n1,n2,n3,n0}={o,n,4'd9,4'd9};
    end 
    else begin
        if(on) begin
            if (t >= 100000000) begin //降频到1秒
                t <= 0;
                tnow<=tnow+1;
                tcur<=tcur+1;
                if (n3 != 4'd0) begin
                    n0 <= n0;
                    n3 <= n3 - 1;//倒计时100秒
                end
                else begin
                    if(n0!= 4'd0) begin
                        n3 <= 9;
                        n0 <= n0 - 1;
                    end
                    else begin
                        n3 <= n3;
                        n0 <= n0;
                    end
                end
            end 
            else begin 
                t <= t + 1;
            end

            if(st==3'b111)begin
                if(m_pos)begin
                    if(mode==2'b00)begin//甩干
                        tcur<=0;
                        tpst<=2'b11;//直接进入脱水阶段
                    end
                    else begin
                        tcur<=0;
                        tpst<=2'b00;//进入正常洗衣阶段
                    end
                end
                else begin
                    st<=3'b111;
                end
            end
            else begin
                case (tpst)
                    2'b00: begin//setup
                        if(tcur<=10)begin
                            
                        end
                        else begin
                        
                        end
                    end
                    2'b01: begin//main washing
                        st_light = 8'b00001000;
                    end
                    2'b10: begin//rinsing
                        st_light = 8'b00010000;
                    end
                    2'b11: begin//dehydration
                        st_light = 8'b00100000;
                    end
                    default: begin
                        st_light = 8'b0;
                    end
                endcase
            end

        end
    end
end

endmodule