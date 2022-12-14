`timescale 1ns / 1ps
module num_to_signal (//最高位绑A位
    input [3:0] num,
    output reg [7:0] seg_out
);
  always @*
    case (num)
      4'h0: seg_out = 8'b1111_1100;  //0
      4'h1: seg_out = 8'b0110_0000;  //1
      4'h2: seg_out = 8'b1101_1010;  //2
      4'h3: seg_out = 8'b1111_0010;  //3
      4'h4: seg_out = 8'b0110_0110;  //4
      4'h5: seg_out = 8'b1011_0110;  //5
      4'h6: seg_out = 8'b1011_1110;  //6
      4'h7: seg_out = 8'b1110_0000;  //7
      4'h8: seg_out = 8'b1111_1110;  //8
      4'h9: seg_out = 8'b1110_0110;  //9
      4'ha: seg_out = 8'b0000_0010;  //负号
      default: seg_out = 8'b0000_0000;
    endcase
endmodule
