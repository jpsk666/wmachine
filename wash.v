`timescale 1ns / 1ps

module wash (
    input on, clk,rst,
    // input [1:0] mode,
    (* DONT_TOUCH = "1" *) input bt,
    output wire [7:0] light,  //数码管信号
    output [3:0] ena,  //数码管使能信号
    output reg [7:0] st_light //接灯
    );
parameter o = 1'b0;//显示0
parameter n = 4'd11;//熄灯
reg [1:0]mode=2'b01;
reg [26:0]t;//计时1秒
reg [26:0]tnow=0;//当前时间
reg [26:0]tcur=0;//当前状态持续时间
reg [26:0]tt=0;
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
        tpst<=2'b00;
        {n1,n2,n3,n0}={o,n,4'd0,4'd6};
    end 
    else begin
        if(on) begin
            if(tpst!=2'b00)begin
                if (t >= 100000000) begin //降频到1秒
                    t <= 0;
                    tnow<=tnow+1;
                    tt<=tt+1;
                    tcur<=tcur+1;
                    if (n3 != 4'd0) begin
                        n0 <= n0;
                        n3 <= n3 - 1;
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
            end

            if(tpst==2'b00)begin
                if(m_pos)begin
                    case(mode)
                        2'b00:begin//甩干
                            tcur<=0;
                            tpst<=2'b11;//直接进入脱水阶段
                        end
                        2'b01:begin//小
                            tcur<=0;
                            tpst<=2'b01;//进入正常洗衣阶段
                        end
                        2'b10:begin//中
                            tcur<=0;
                            tpst<=2'b01;
                        end
                        2'b11:begin//大
                            tcur<=0;
                            tpst<=2'b01;
                        end
                        default:begin
                            tcur<=0;
                            tpst<=2'b01;
                        end
                    endcase
                end
                else begin
                    st<=3'b111;
                end
            end
            else begin
                case (tpst)
                    2'b01: begin//main washing
                        if(tcur<=20)begin
                            if(tt%2==0)begin
                                n1<=4'd1;
                            end
                            else begin
                                n1<=4'd2;
                            end
                        end
                        else begin
                            tt<=0;
                            tcur<=0;
                            tpst<=2'b10;
                        end
                    end
                    2'b10: begin//rinsing
                        if(tcur<=20)begin
                            if(tt%3==0)begin
                                tt<=0;
                                n1<=4'd3;
                            end
                            else if(tt%3==1) begin
                                n1<=4'd1;
                            end
                            else if(tt%3==2)begin
                                n1<=4'd4;
                            end
                            else begin
                                tt<=0;
                                n1<=4'd3;
                            end
                        end
                        else begin
                            tt<=0;
                            tcur<=0;
                            tpst<=2'b11;
                        end
                    end
                    2'b11: begin//dehydration
                        if(tnow<=60)begin
                            if(tt%4==0)begin
                                tt<=0;
                                n1<=4'd5;
                            end
                            else if(tt%4==1) begin
                                n1<=4'd4;
                            end
                            else if(tt%4==2)begin
                                n1<=4'd6;
                            end
                            else if(tt%4==3)begin
                                n1<=4'd4;
                            end
                            else begin
                                tt<=0;
                                n1<=4'd5;
                            end
                        end
                        else begin
                            tt<=0;
                            tcur<=0;
                            tpst<=2'b11;
                            n1<=4'd10;
                        end
                    end
                    default: begin
                        tt<=0;
                    end
                endcase
            end

        end
    end
end

endmodule