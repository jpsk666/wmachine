`timescale 1ns / 1ps

module wash (
    input on, clk,
    output wire [7:0] light,  //数码管信号
    output [3:0] ena,  //数码管使能信号
    output reg [2:0] st_light //接灯
    )

reg [30:0]t;
reg [3:0] n1, n2, n3, n0;
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
always @(*) begin
    case (st)
      2'b00: begin
        st_light = 3'b001;
      end
      2'b01: begin
        st_light = 3'b010;
      end
      2'b10: begin
        st_light = 3'b100;
      end
      default: begin
        st_light = 3'b0;
      end
    endcase
  end


endmodule