`timescale 1ns / 1ps
module flash_led_ctrl (
    input clk,
    input [3:0] p1,
    input [3:0] p2,
    input rst,
    output reg [3:0] sig,  //数值信号，需经函数转化成8位信号
    output reg [3:0] enable  //直接连终端输出
);
  parameter x = 200000;//扫描必须降频，否则根本看不出来
  reg l_clk;
  reg [31:0] clk_cnt;

  reg [1:0] scan;
  always @(posedge clk,negedge rst) begin
    if(!rst) begin clk_cnt<=0; l_clk<=0;
    end
    else begin if(clk_cnt == (x>>2)-1) begin
    l_clk<= ~l_clk;
    clk_cnt<=0;
    end else clk_cnt = clk_cnt+1;

    
    end
  end
  always @(posedge l_clk) begin scan <= scan + 1'b1;
  end

  always @(scan, p1, p2) begin
    case (scan)
      2'b00: begin
        enable = 4'h01;
        sig = p1;
      end
      2'b01: begin
        enable = 4'h02;
        sig = p2;
      end
      2'b10: begin
        enable = 4'h04;
        sig = 4'b0;
      end
      2'b11: begin
        enable = 4'h08;
        sig = 4'b0;
      end
    endcase
  end



endmodule
