`timescale 1ns / 1ps
module cal(
    input clk,
    input signed [23:0] x_re,
    input signed [23:0] x_im,
    input signed [23:0] y_re,
    input signed [23:0] y_im,
    input  fft_out_valid, //fft_out_valid
    output reg [11:0] gain,
  //  output reg [23:0] phase_shift,//位宽待改
    output reg calvalid
    );
   wire signed [12:0] h_re,h_im;//最高位符号位
   wire signed [48:0] h_re_temp,h_im_temp;
   wire signed [48:0] sumx;
   parameter Nfft=2048;
  
    wire signed [47:0] temp1,temp2,temp3,temp4,temp5,temp6;
   assign temp1=x_re*y_re;
   assign temp2=x_im*y_im;
   assign temp3=x_im*y_re; 
   assign temp4=x_re*y_im;
   assign temp5=x_re*x_re;
   assign temp6=x_im*x_im;

 
   assign h_re_temp=temp1+temp2;
   assign h_im_temp=temp4-temp3;
   assign sumx=temp5+temp6;
   reg  s_axis_dividend_tvalid=0;
   wire  div_out_valid_re,div_out_valid_im;
   wire [111:0] div_out_re,div_out_im;
   //7.29添加，有符号数除法未完成，修改IP核
   //无符号数见github
   reg [55:0] s_axis_divisor_tdata;
   reg [55:0] s_axis_dividend_tdata_re,s_axis_dividend_tdata_im;
   always @(posedge clk) begin
       if(sumx!==0) begin
            s_axis_dividend_tvalid<=1'b1;
       end    
       else  begin
             s_axis_dividend_tvalid<=1'b0;
       end     
   end
   div_gen_0 divide_re(
        .aclk(clk),
        .aclken(1'b1),
        .s_axis_divisor_tdata(s_axis_divisor_tdata),
        .s_axis_dividend_tvalid( s_axis_dividend_tvalid),
        .s_axis_dividend_tdata(s_axis_dividend_tdata_re),
        .m_axis_dout_tvalid( div_out_valid_re),
        .m_axis_dout_tdata(div_out_re)
   );
    div_gen_0 divide_im(
        .aclk(clk),
        .aclken(1'b1),
        .s_axis_divisor_tdata(s_axis_divisor_tdata),
        .s_axis_dividend_tvalid( s_axis_dividend_tvalid),
        .s_axis_dividend_tdata(s_axis_dividend_tdata_im),
        .m_axis_dout_tvalid( div_out_valid_im),
        .m_axis_dout_tdata(div_out_im)
   );
   
   
     assign h_re = div_out_re[68:56];
     assign h_im = div_out_im[68:56];//取13位
    integer iter=0;
    wire  [23:0] hre_square,him_square;
	assign hre_square = h_re * h_re;
	assign him_square = h_im * h_im;     
   
   reg  [24:0]  h_amp=0; 
 // reg  [31:0]  h_amp; 
   wire  [11:0]  h_aver;
    reg [12:0]  sqrt=0; //13+11
    reg [23:0] sum_avr=0;
    
   reg [31:0] s_axis_cartesian_tdata=0;
    reg s_axis_cartesian_tvalid=1'b1;
    wire [15:0] m_axis_dout_tdata;
    wire m_axis_dout_tvalid;
    
    always @(posedge clk)begin
        s_axis_cartesian_tdata<={7'b000_0000,h_amp};
        s_axis_divisor_tdata<={7'b000_0000,sumx};
        if(h_re_temp>0)  s_axis_dividend_tdata_re<={7'b000_0000,h_re_temp};
        if(h_re_temp<0)  s_axis_dividend_tdata_re<={7'b111_1111,h_re_temp};
        if(h_im_temp>0)  s_axis_dividend_tdata_im<={7'b000_0000,h_im_temp};
        if(h_im_temp<0)  s_axis_dividend_tdata_im<={7'b111_1111,h_im_temp};       
   end
    
    
    cordic_0 sqrt_root(
            .aclk(clk),
            .s_axis_cartesian_tdata(s_axis_cartesian_tdata),
            .s_axis_cartesian_tvalid(1),
            .m_axis_dout_tdata(m_axis_dout_tdata),
            .m_axis_dout_tvalid(m_axis_dout_tvalid)
    );
    
   reg [12:0]average;
   
   reg sym=0;
   reg div2_clk;  //二分频
   always @(posedge clk) begin
        sym<=sym+1;
      if(sym==1) 
         div2_clk<=0;
      else
         div2_clk<=1;
   end
   
   always@(posedge div2_clk) begin  
       if(m_axis_dout_tvalid & m_axis_dout_tvalid!==4095)begin
             //h_amp<=hre_square+him_square;
             h_amp<=hre_square+him_square;
             sqrt<=m_axis_dout_tdata[12:0]; 
              
             sum_avr<=sum_avr+sqrt; 
       end
        if(sqrt!==0) begin
             iter=iter+1;  
        end 
   end  
   
   always@(negedge clk) begin
        if(iter==Nfft) begin
              calvalid<=1'b1;
              average<=(sum_avr>>>11); //再取低12位
              // h_aver<=average[11:0]; 
               iter<=0;   
        end
   end 
   assign h_aver=average[11:0];
   
   always @(posedge clk) begin
        if(calvalid==1'b1) begin
            gain<=h_aver;     
        end
   end
   always @(negedge fft_out_valid)begin
            calvalid<=1'b0;
   end
endmodule
