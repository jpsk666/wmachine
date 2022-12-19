`timescale 1ns / 1ps

module wash (
    input on, clk,rst
    output wire [7:0] light,  //数码管信号
    output [3:0] ena,  //数码管使能信号
    output reg [7:0] st_light //接灯
    )
parameter o = 1'b0;//显示0
parameter n = 4'd11;//熄灯
reg [26:0]t;//计时1秒
reg [3:0] n1=o;//数码管初始化
reg [3:0] n2=n;
reg [3:0] n3=4'd9;
reg [3:0] n0=4'd9;
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
        {n1,n2,n3,n0}={o,n,4'd9,4'd9};
    end 
    else begin
        if(on) begin
            if (t >= 100000000) begin //降频到1秒
                t <= 0;
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
                        n0 <= n0
                    end
                end
            end 
            else begin 
                t <= t + 1;
            end

            case (st)  //放水脱水阶段
                2'b0: begin
                    if (t >= 100000000) begin
                        if(n0==4'd9 && n3<9) n1 <= n1 + 1;
                        else begin
                            n1 <= n1;
                            st <= st + 1;
                        end
                    end
                end
                2'b01: begin
                    if (n0==2) st <= st + 1;
                end
                
                2'b10: begin
                    if (t >= 100000000) begin
                        if(n0==2 && n3>0) n1 <= n1 - 1;
                        else begin
                            n1 <= n1;
                            st <= st;
                        end
                    end
                end
            endcase
        end
    end
end

endmodule