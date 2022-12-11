`timescale 1ns / 1ps

module counter (
    input clk,
    input rst_n,
    output reg [3:0] p1,
    p2
);
//01
  reg [13:0] cnt_first, cnt_second;

  always @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      cnt_first <= 14'd0;
      p1 <= 4'b0;
      p2 <= 4'b0;
      cnt_second <= 14'd0;
    end else begin
      if (cnt_first == 14'd10000) begin
        cnt_first  <= 14'd0;
        cnt_second <= cnt_second + 1;
        if (cnt_second == 14'd10000) begin
          cnt_second <= 14'd0;
          if (p1 != 4'd9) p1 <= p1 + 1'b1;
          else begin
            p1 <= 4'd0;

            if (p2 != 4'd9) p2 <= p2 + 1'b1;  //
            else p2 <= 4'd0;
          end
        end
      end else begin
        cnt_first  <= cnt_first + 1'b1;
        cnt_second <= cnt_second;
      end
    end
  end





endmodule
