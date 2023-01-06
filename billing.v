`timescale 1ns / 1ps

module billing (
    input on, clk,rst,
    (* DONT_TOUCH = "1" *)
    input m_pos,u_pos,d_pos,
    input [11:0] bal,
    input [1:0] mode,
    input [11:0] set0,//传入甩干价格
    input [11:0] set1,//小
    input [11:0] set2,//中
    input [11:0] set3,//大
    input [11:0]setfine,//空转罚款
    output wire [7:0] led,  //数码管信号
    output [3:0] ena,  //数码管使能信号
    output reg [7:0] st_light, //接灯
    output reg [7:0] wt_light//水灯
    output reg next
    );

parameter o = 4'd0;//显示0
parameter n = 4'd11;//熄灯
reg [26:0]t;//计时1秒
reg [26:0]tt;//计时1秒
reg [1:0] st = 0;  //等待收款，确认收费（等待取衣），收取空转费
reg [3:0] n1=o;//数码管初始化
reg [3:0] n2=n;
reg [3:0] n3=4'd9;
reg [3:0] n0=4'd9;
reg [11:0]setini={n,n,n};
reg [26:0]flag=0;


scan4 scanner (
      clk,
      n1,
      n2,
      n3,
      n0,
      ena,
      led
  ); 

reg [3:0] nowsign=4'd0;
reg [11:0] num;
reg [11:0] sub; 
wire[15:0] res;
subtraction sb(nowsign,num,sub,res);

reg [26:0] countdown=8;

always @(*) begin//状态灯
    if(countdown>=8)begin
        wt_light<=8'b11111111;
    end
    else if(countdown>=7)begin
        wt_light<=8'b01111111;
    end
    else if(countdown>=6)begin
        wt_light<=8'b00111111;
    end
    else if(countdown>=5)begin
        wt_light<=8'b00011111;
    end
    else if(countdown>=4)begin
        wt_light<=8'b00001111;
    end
    else if(countdown>=3)begin
        wt_light<=8'b00000111;
    end
    else if(countdown>=2)begin
        wt_light<=8'b00000011;
    end
    else if(countdown>=1)begin
        wt_light<=8'b00000001;
    end
    else begin
        wt_light<=8'b00000000;
    end
end

always @(*) begin//状态灯
    case (st)
      2'b00: begin
        st_light <= 8'b01000000;
      end
      2'b01: begin
        st_light <= 8'b10000000;
      end
      default: begin
        st_light <= 8'b0;
      end
    endcase
end

always @(posedge clk, negedge rst) begin
    if (!rst) begin
        st <= 2'b00;
        nowsign<=4'd0;
        flag<=0;
        t<=0;
        tt<=0;
        countdown<=8;
        {n0,n3,n2,n1}<={4'd10,setini};
    end 
    else begin
        if(on) begin
            if(st==2'b00)begin
                case(mode)
                    2'b00:begin//甩干
                        setini<=set0;
                    end
                    2'b01:begin//小
                        setini<=set1;
                    end
                    2'b10:begin//中
                        setini<=set2;
                    end
                    2'b11:begin//大
                        setini<=set3;
                    end
                    default:begin
                        setini<={o,o,o};
                    end
                endcase
                if(t>=100000000)begin
                    flag<=!flag;
                    t<=0;
                end
                else begin
                    t<=t+1;
                end
                if(flag==0)begin
                    {n0,n3,n2,n1}<={4'd11,bal};
                end
                else begin
                    {n0,n3,n2,n1}<={4'd10,setini};
                end
                if(m_pos)begin
                    t<=0;
                    countdown<=8;
                    st<=2'b01;
                end
            end
            else if(st==2'b01)begin
                if(countdown<=0)begin
                    countdown<=0;
                    st<=2'b10;
                end
                if(t>=100000000)begin
                    countdown<=countdown-1;
                    t<=0;
                end
                else begin
                    t<=t+1;
                end
                if(flag==0)begin
                    nowsign<=4'd0;
                    num<=bal;
                    sub<=setini;
                    flag<=1;
                end
                else begin
                    {n0,n3,n2,n1}<=res;
                    flag<=0;
                end
                if(u_pos)begin
                    tt<=0;
                    t<=0;
                    st<=2'b11;
                end
            end
            else if(st==2'b10) begin
                countdown<=0;
                if(t>=100000000)begin
                    nowsign<=res[15:12];
                    num<=res[11:0];
                    sub<=setfine;
                    t<=0;
                end
                else begin
                    {n0,n3,n2,n1}<=res;
                    t<=t+1;
                end
                if(u_pos)begin
                    tt<=0;
                    t<=0;
                    st<=2'b11;
                end
            end
            else begin
                if(t>=100000000)begin
                    tt<=tt+1;
                    t<=0;
                end
                else begin
                    t<=t+1;
                end
                if(tt%4==0)begin
                    {n0,n3,n2,n1}<={4'd8,n,n,n};
                end
                else if(tt%4==1)begin
                    {n0,n3,n2,n1}<={n,4'd8,n,n};
                end
                else if(tt%4==2)begin
                    {n0,n3,n2,n1}<={n,n,4'd8,n};
                end
                else begin
                    {n0,n3,n2,n1}<={n,n,n,4'd8};
                end
                if(d_pos) next<=1;
            end
        end
    end
end
endmodule