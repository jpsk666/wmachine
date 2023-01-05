`timescale 1ns / 1ps

module sub_sim;

    reg [3:0] sign=4'd10;
    reg     [11:0]      bcd;
    reg     [11:0]      sub={4'd0,4'd9,4'd9};
    wire [15:0] res;

 subtraction u(
    .sign(sign),.num(bcd),.sub(sub),.res(res)
);

    reg clk;
     
    reg [3:0]   a;
    reg [3:0]   b;
    reg [3:0]   c;
     
    initial begin
        repeat(20000)begin
            a = {$random}%3;
            b = {$random}%10;
            c = {$random}%10;  
             
            if((a*100+b*10+c)>255)begin
                b = 5;
                c = 5;
            end
            bcd = {a,b,c};
            #50;
        end
    end

endmodule