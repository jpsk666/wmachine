`timescale 1ns / 1ps

module wash (
    input on, clk,rst,
    input [1:0] mode,
    (* DONT_TOUCH = "1" *) input m_pos,u_pos,
    output wire [7:0] led,  //数码管信号
    output wire [7:0] led_l,
    output [3:0] ena,  //数码管使能信号
    output [3:0] ena_l,  //左数码管使能信号
    output reg [7:0] st_light, //接灯
    output reg [7:0] wt_light,//水灯
    output reg nxt
    );
parameter o = 1'b0;//显示0
parameter n = 4'd11;//熄灯
reg [26:0]t;//计时1秒
reg [26:0]tnow=0;//当前时间
reg [26:0]tcur=0;//当前状态持续时间
reg [26:0]tt=0;
reg [3:0] n1=o;//数码管初始化
reg [3:0] n2=n;
reg [3:0] n3=4'd0;
reg [3:0] n0=4'd6;
reg [1:0] tpst=2'b00;  //4种状态：机器设定，水洗，冲洗，脱水
reg [2:0] st = 3'b000;  //6种状态:rotate，stew，addwater，drain，fspin，rspin

reg [26:0]setseq=20;
reg [26:0]settot=60;
reg [7:0]setn3=4'd0;
reg [7:0]setn0=4'd6;

scan4 scanner (
      clk,
      n1,
      n2,
      n3,
      n0,
      ena,
      led
  ); 

reg [3:0] n5, n6, n7, n8;  //5~8 从右到左
scan4 scanner2 (
      clk,
      n5,
      n6,
      n7,
      n8,
      ena_l,
      led_l
  );
reg errflag;
reg [26:0] errt;
reg [26:0] errcnt;
// always @(posedge clk) begin
    
// end
always @(*) begin//状态灯
    case (tpst)
      2'b00: begin//setup
        st_light <= 8'b00000100;
      end
      2'b01: begin//main washing
        st_light <= 8'b00001000;
      end
      2'b10: begin//rinsing
        st_light <= 8'b00010000;
      end
      2'b11: begin//dehydration
        st_light <= 8'b00100000;
      end
      default: begin
        st_light <= 8'b0;
      end
    endcase
end
always @(*) begin//小灯
    if(tpst==2'b01)begin
        wt_light<=8'b11111111;
    end
    else begin
        if(n1==4'd3)begin//addwater
            if(t<=10000000)begin
                wt_light<=8'b00000000;
            end
            else if(t<=20000000)begin
                wt_light<=8'b00000001;
            end
            else if(t<=30000000)begin
                wt_light<=8'b00000011;
            end
            else if(t<=40000000)begin
                wt_light<=8'b00000111;
            end
            else if(t<=50000000)begin
                wt_light<=8'b00001111;
            end
            else if(t<=60000000)begin
                wt_light<=8'b00011111;
            end
            else if(t<=70000000)begin
                wt_light<=8'b00111111;
            end
            else if(t<=80000000)begin
                wt_light<=8'b01111111;
            end
            else begin
                wt_light<=8'b11111111;
            end
        end
        else if(n1==4'd4)begin//draining
            if(t<=10000000)begin
                wt_light<=8'b11111111;
            end
            else if(t<=20000000)begin
                wt_light<=8'b01111111;
            end
            else if(t<=30000000)begin
                wt_light<=8'b00111111;
            end
            else if(t<=40000000)begin
                wt_light<=8'b00011111;
            end
            else if(t<=50000000)begin
                wt_light<=8'b00001111;
            end
            else if(t<=60000000)begin
                wt_light<=8'b00000111;
            end
            else if(t<=70000000)begin
                wt_light<=8'b00000011;
            end
            else if(t<=80000000)begin
                wt_light<=8'b00000001;
            end
            else begin
                wt_light<=8'b00000000;
            end
        end
        else begin
            wt_light<=wt_light; 
        end
    end
end
always @(posedge clk, negedge rst) begin
    if (!rst) begin
        st <= 1'b0;
        tpst<=2'b00;
        tnow<=0;
        tt<=0;
        t<=0;
        errflag<=0;
        nxt<=0;
        {n1,n2}<={o,n};
        n3<=setn3;
        n0<=setn0;
    end 
    else begin
        if(on) begin

            if(u_pos)begin
                errt<=0;
                errcnt<=5;
                errflag<=1;
            end
            if(errt>=50000000)begin
                errt<=0;
                errcnt<=errcnt-1;
            end
            else begin
                errt<=errt+1;
            end
            if(errcnt<=0)begin
                errflag<=0;
            end
            if(errflag==1&&(errcnt%2==1))begin
                {n8,n7,n6,n5}<={4'hc,4'hd,4'he,4'he};
            end
            else begin
                {n8,n7,n6,n5}<={4'hc,4'hb,4'hb,4'hb};
            end

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
                nxt<=0;
                tnow<=0;
                case(mode)
                    2'b00:begin//甩干
                        settot<=15;
                        setn0<=4'd1;
                        setn3<=4'd5;
                        tcur<=0;
                    end
                    2'b01:begin//小
                        settot<=30;
                        setn0<=4'd3;
                        setn3<=4'd0;
                        setseq<=10;
                        tcur<=0;
                    end
                    2'b10:begin//中
                        settot<=45;
                        setn0<=4'd4;
                        setn3<=4'd5;
                        setseq<=15;
                        tcur<=0;
                    end
                    2'b11:begin//大
                        settot<=60;
                        setn0<=4'd6;
                        setn3<=4'd0;
                        setseq<=20;
                        tcur<=0;
                    end
                    default:begin
                        settot<=60;
                        setn0<=4'd6;
                        setn3<=4'd0;
                        setseq<=20;
                        tcur<=0;
                    end
                endcase
                if(m_pos)begin
                    case(mode)
                        2'b00:begin//甩干
                            tpst<=2'b11;//直接进入脱水阶段
                        end
                        2'b01:begin//小
                            tpst<=2'b01;//进入正常洗衣阶段
                        end
                        2'b10:begin//中
                            tpst<=2'b01;
                        end
                        2'b11:begin//大
                            tpst<=2'b01;
                        end
                        default:begin
                            tpst<=2'b01;
                        end
                    endcase
                end
                else begin
                    {n1,n2}<={o,n};
                    n3<=setn3;
                    n0<=setn0;  
                end
            end
            else begin
                case (tpst)
                    2'b01: begin//main washing
                        nxt<=0;
                        if(tcur<=setseq)begin
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
                        nxt<=0;
                        if(tcur<=setseq)begin
                            if(tt%3==0)begin
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
                        if(tnow<=settot)begin
                            nxt<=0;
                            if(tt%4==0)begin
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
                            tpst<=2'b00;
                            tnow<=0;
                            n1<=4'd10;
                            errflag<=0;
                            {n5,n6,n7,n8}<={4'hb,4'hb,4'hb,4'hb};
                            nxt<=1;
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