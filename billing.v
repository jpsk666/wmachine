`timescale 1ns / 1ps

module wash (
    input on, clk,rst,
    input signed [11:0] bal,
    output wire [7:0] led,  //数码管信号
    output [3:0] ena,  //数码管使能信号
    output reg [7:0] st_light //接灯
    )
st_light = 8'b11111111;
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

always @(posedge clk, negedge rst) begin
    if (!rst) begin
        st <= 1'b0;
        {n1,n2,n3,n0}={o,n,4'd9,4'd9};
    end 
    else begin
        if(on) begin
            if (t >= 100000000) begin //降频到1秒
                t <= 0;
            end 
            else begin 
                t <= t + 1;
            end

            case (st)  //放水脱水阶段
                0: begin
                    if (t >= 100000000) begin
                        if(n0==4'd9 && n3<9) n1 <= n1 + 1;
                        else begin
                            n1 <= n1;
                            st <= st + 1;
                        end
                    end
                end
                1: begin
                    if (n0==2) st <= st + 1;
                end
            endcase
        end
    end
end

endmodule