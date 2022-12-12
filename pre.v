`timescale 1ns / 1ps

module pre (
    input p1,
    input p2,
    input p3,
    input sign,
    input clk,
    input next,
    output isOn,
    output wire[7:0] light,
    output reg[3:0] ena //最高位是符号
);
  reg[3:0] l;
  reg [27:0] t;
  reg [3:0] n1, n2, n3, n0; 
  reg [3:0] sc;
  
  assign ok= ~(p1|p2|p3|sign)&(n0!=10);
  reg [1:0]st;

  num_to_signal signal(l,light);

  always @(posedge clk) begin
    sc <= sc + 1;
    //扫描不会停
    case(st)
    2'b0:
      if (t == 66000000) begin
      t <= 0;
      if (p1) begin
        if (n1 != 4'd9) n1 <= n1 + 1;
        else n1 <= 0;
      end
      if (p2) begin
        if (n2 != 4'd9) n2 <= n2 + 1;
        else n2 <= 0;
      end
      if (p3) begin
        if (n3 != 4'd9) n3 <= n3 + 1;
        else n1 <= 0;
      end
      if (sign) begin
        if (n0 != 4'd10) n0 <= 4'd10; //10代表符号
        else n0 <= 0;
      end
    end else t <= t + 1;
   
  endcase
  
    
  end
  always @(*) begin
    if(st==0)begin
    case(sc)
    2'b00: begin ena=4'b0001; l=n1; end
    2'b01: begin ena=4'b0010; l=n2; end
    2'b10: begin ena=4'b0100; l=n3; end
    2'b11: begin ena=4'b1000; l=n0; end
  endcase
     end

end
endmodule

