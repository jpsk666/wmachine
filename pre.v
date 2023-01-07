`timescale 1ns / 1ps

module pre (
    input on,
    clk,
    rst,
    input p1,
    p2,
    p3,
    sign,  //4个拨码开关，从右到左
    (* DONT_TOUCH = "1" *)
    // input r_pos,
    // m_pos,
    // u_pos,
    // d_pos,  //按键
    input r_pos,
    m_pos,
    u_pos,
    output reg isOn,  //按下按钮能否进入洗衣阶段
    output wire [7:0] led_r,  //数码管信号
    output [3:0] ena_r,  //数码管使能信号
    output wire [7:0] led_l,  //左数码管信号
    output [3:0] ena_l,  //左数码管使能信号
    output reg signed [12:1] bal,  //余额，最大999

    output reg [1:0] mode,  //模式 //有4个

    output reg [2:0] st_light  //接左边3小灯表示状态
);
  reg [27:0] t;  //0.66秒计数
  reg [28:0] alarm_t;  //0.5s计数
  
  reg [ 2:0] alarm_cnt = 0;
  reg [3:0] n1, n2, n3, n0;  //1~3：个位至百位; 0:符号位
  reg [3:0] n5, n6, n7, n8;  //5~8 从右到左
  reg open = 0;  //盖子是否打开状态
  reg [3:0] lid_state;
  reg [3:0] warn[4:1];
  parameter o = 1'b0;
  parameter off = 4'hb;
  wire next1;
  assign next1 = ~(p1 | p2 | p3 | sign) & (n0 != 10);
  //四个开关一个都不能上拨，且第一位不能是负数，才能下一阶段
  reg [1:0] st = 1'b0;  //3种状态

  scan4 scanner (
      clk,
      n1,
      n2,
      n3,
      n0,
      ena_r,
      led_r
  );
  scan4 scanner2 (
      clk,
      n5,
      n6,
      n7,
      n8,
      ena_l,
      led_l
  );

  always @(*) begin  //小灯
    if (open) lid_state = 0;
    else lid_state = 4'hc;

    case (st)
      2'b00: begin  //输入余额
        st_light = 3'b001;
        isOn = 0;
      end
      2'b01: begin  //选择模式
        st_light = 3'b010;
        isOn = 0;
      end
      2'b10: begin  //输入重量
        st_light = 3'b100;
        case (mode)
          2'b01: begin
            if (n2 == 0 && ~open) isOn = 1'b1;
            else isOn = 0;
          end
          2'b10: begin
            if ((n2 == 4'b0001||n2==0) && ~open) isOn = 1'b1;
            else isOn = 0;
          end
          default: begin
            if (~open) isOn = 1'b1;
            else isOn = 0;
          end
        endcase

      end
      default: begin
        st_light = 3'b000;
        isOn = 0;
      end
    endcase
  end

  always @(posedge clk, negedge rst) begin
    if (!rst) begin
      st <= 1'b0;
      {n1, n2, n3, n0} <= {o, o, o, o};
      {n5, n6, n7, n8} <= {off, off, off, off};
      open <= 0;
      warn[1] <= 0;
      warn[2] <= 0;
      warn[3] <= 0;
      warn[4] <= 0;
      alarm_cnt <= 0;
      alarm_t <= 0;
    end else begin
      if (on) begin
        case (st)  //状态判断
          2'b00: begin
            {n5, n6, n7} <= {off, off, off};
            n8 <= 4'hc;

            if (t >= 66000000) begin
              t <= 0;
              if (p1) begin  //拨上去时才加1,是否要写拨回去时的分支？
                if (n1 != 4'd9) n1 <= n1 + 1;
                else n1 <= 0;
              end else n1 <= n1;
              if (p2) begin
                if (n2 != 4'd9) n2 <= n2 + 1;
                else n2 <= 0;
              end else n2 <= n2;
              if (p3) begin
                if (n3 != 4'd9) n3 <= n3 + 1;
                else n3 <= 0;
              end else n3 <= n3;
              if (sign) begin
                if (n0 != 4'd10) n0 <= 4'd10;  //10代表负号
                else n0 <= 0;
              end else n0 <= n0;
            end else t <= t + 1;

            if (m_pos) begin  //如果按按钮就判断是否下一阶段
              if (next1) begin
                st <= 2'b01;
                n1 <= 0;  //可行，转化状态时直接赋值0
                {bal[4:1], bal[8:5], bal[12:9]} <= {n1, n2, n3};
                //可以这么做？
              end else begin
                st <= 1'b0;
                {n0, n1, n2, n3} <= {o, o, o, o};
              end
            end else st <= 1'b0;
          end

          2'b01: begin
            {n5, n6, n7} <= {off, off, off};
            {n2, n3, n0} <= {off, off, off};
            n8 <= 4'hc;  //始终关盖
            if (r_pos)
              if (n1 < 4'd3) n1 <= n1 + 1;
              else n1 <= 0;
            else n1 <= n1;

            if (m_pos) begin
              st <= 2'b10;
              mode <= n1[1:0];  //确定模式
              n6 <= n1;  //放在第三个数码灯处显示
              n8 <= lid_state;
              {n0, n1, n2, n3} <= {o, o, o, o};
              alarm_cnt <= 0;
              alarm_t <= 0;
              open <= 1'b1;
            end else st <= 2'b01;
          end
          2'b10: begin  //状态3
            //仍然是右按键增大 
            //根据模式决定警告闪烁的信息
            warn[1] <= 4'h9;
            warn[3] <= 4'ha;
            warn[4] <= 4'h0;
            case (mode)
              2'b01: warn[2] <= 4'h0;
              2'b10: warn[2] <= 4'h1;
            endcase
            //没写default

            //开关盖操作
          if(u_pos)begin
            open<=~open;
          end
                    

            if (r_pos) begin
              if (open) begin
                if (p1) begin  //最右侧拨码开关上拨时表示十位数
                  if (n2 > 4'd1)  //十位最多为20
                    n2 <= 0;
                  else n2 <= n2 + 1;
                end else begin
                  if (n1 < 4'd9) n1 <= n1 + 1;
                  else n1 <= 0;
                end
              end else begin
                n2 <= n2;
                n1 <= n1;
              end
            end else begin
              n2 <= n2;
              n1 <= n1;
            end
            //确定键
            if (m_pos) begin
              if (~isOn) begin
                if (~open) begin  //不是未关盖问题
                  alarm_t <= alarm_t + 1;  //警报计时由0变1
                end
              end else st <= 2'b00;
            end else st <= st;

            if (alarm_t!= 0) begin
              if (alarm_t == 50000000) begin
                if (alarm_cnt <= 3'd4) begin
                  alarm_cnt <= alarm_cnt + 1;
                  alarm_t   <= 29'h1;
                end else begin
                  alarm_t   <= 0;
                  alarm_cnt <= 0;
                  st<=2'b01;
                  n1<=0;
                end

                if (alarm_cnt[0] == 0) {n5, n6, n7, n8} <= {off, off, off, off};
                else {n5, n6, n7, n8} <= {warn[1],warn[2], warn[3], warn[4]};
              end else alarm_t<=alarm_t+1;
            end else {n5, n6, n7, n8} <= {off, {2'b00, mode}, off, lid_state};
          end
        endcase
      end
    end
  end
endmodule

