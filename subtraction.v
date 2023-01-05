`timescale 1ns / 1ps

module bcdtobin (
    input [11:0] num,//{n1,n2,n3}
    output [7:0] res
);
  wire [3:0]n1,n2,n3;
  assign n1=num[11:8];
  assign n2=num[7:4];
  assign n3=num[3:0];
  
  wire [9:0] n1_r,n2_r;
  wire [9:0] bint;
  assign n1_r=(n1<<6)+(n1<<5)+(n1<<2);
  assign n2_r=(n2<<3)+(n2<<1);
  assign bint=n1_r+n2_r+n3;
  assign res=bint[7:0];
endmodule

module cmp(
        input   [3:0]   data_in,
        output  [3:0]       data_out
);
 
    assign data_out = (data_in > 4'd4) ?(data_in + 3'd3):data_in;
endmodule

module left_shift(
        input   [19:0]  data_in,
        output  [19:0]  data_out
);
 
    wire [3:0]  a;
    wire [3:0]  b;
    wire [3:0]  c;
     
    cmp cmp_inst1(
        .data_in        (data_in[19:16]),
        .data_out   (a)
    );
     
    cmp cmp_inst2(
        .data_in        (data_in[15:12]),
        .data_out   (b)
    );
         
    cmp cmp_inst3(
        .data_in        (data_in[11:8]),
        .data_out   (c)
    );
     
    assign data_out = {a[2:0],b,c,data_in[7:0],1'b0};
endmodule

module bintobcd(
        input   [7:0]   data,
        output  [11:0]  bcd
);
 
    wire    [19:0] data_temp1;
    wire    [19:0] data_temp2;
    wire    [19:0] data_temp3;
    wire    [19:0] data_temp4;
    wire    [19:0] data_temp5;
    wire    [19:0] data_temp6;
    wire    [19:0] data_temp7;
    wire    [19:0] data_temp8; 
    wire    [19:0] data_temp9; 
     
    assign data_temp1 = {12'd0,data};
     
     
    left_shift  left_shift_inst_1(
        .data_in        (data_temp1),
        .data_out   (data_temp2)
    );
     
    left_shift  left_shift_inst_2(
        .data_in        (data_temp2),
        .data_out   (data_temp3)
    );
     
    left_shift  left_shift_inst_3(
        .data_in        (data_temp3),
        .data_out   (data_temp4)
    );
     
    left_shift  left_shift_inst_4(
        .data_in        (data_temp4),
        .data_out   (data_temp5)
    );
     
    left_shift  left_shift_inst_5(
        .data_in        (data_temp5),
        .data_out   (data_temp6)
    );
     
    left_shift  left_shift_inst_6(
        .data_in        (data_temp6),
        .data_out   (data_temp7)
    );
     
    left_shift  left_shift_inst_7(
        .data_in        (data_temp7),
        .data_out   (data_temp8)
    );
     
    left_shift  left_shift_inst_8(
        .data_in        (data_temp8),
        .data_out   (data_temp9)
    );
 
    assign bcd = data_temp9[19:8];
endmodule

module subtraction(
    input [3:0] sign,//n0
    input [11:0] num,//{n1,n2,n3}
    input [11:0] sub,
    output [15:0] res
);
  wire [7:0] numbin,subbin;
  bcdtobin btb1(num,numbin);
  bcdtobin btb2(sub,subbin);
  reg c4,c0;
  reg [7:0]s;
  reg [8:0]q;
  reg [3:0]sig;
  reg [7:0]resbin;
  always@(*)begin
    if(sign==4'd10)begin
      sig=4'd10;
      q={1'b0,numbin}+{1'b0,subbin};
      if(q[8]!=1'b0)begin
        resbin=8'b11111111;
      end
      else begin
        resbin=numbin+subbin;
      end
    end
    else begin
      c0=1;
      q={1'b0,numbin}+{1'b0,~subbin}+1;
      c4=q[8];
      s=q[7:0];
      if(c4==1)begin
        sig=4'd0;
        resbin=s;
      end
      else if(c4==0)begin
        sig=4'd10;
        resbin=(~s)+1;
      end
    end
  end
  wire [11:0]resbcd;
  bintobcd btb3(resbin,resbcd);
  assign res={sig,resbcd};
endmodule
