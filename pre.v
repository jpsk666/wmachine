`timescale 1ns / 1ps

module pre(
    input p1,
    input p2,
    input p3,
    input sign,
    input clk,
    output [1:0] mode,
    output [7:0] l0,
    output [7:0] l1,
    output [7:0] l2,
    output [7:0] l3
    );
    reg[27:0] t;
    reg[3:0] num;
    always @(posedge clk)begin
            if(t==66000000) begin t <= 0; num<=num+1;  end
            else t<= t+1;
    end
endmodule
//1asdfasdaaa