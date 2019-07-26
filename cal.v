`timescale 1ns / 1ps
module cal(
    input clk,
    input [23:0] x_re,x_im,
    input [23:0] y_re,y_im,
    input  fft_out_valid, //fft_out_valid
    output reg [23:0] gain,
  //  output reg [23:0] phase_shift,//位宽待改
    output reg calvalid
    );
  wire [48:0] h_re,h_im;
   reg [48:0] h_re_temp,h_im_temp,sumx;
   parameter Nfft=2048;
  
    reg [47:0] temp1,temp2,temp3,temp4,temp5,temp6;

    mult uut1(
        .clk(clk),
        .a(x_re),
        .b(y_re),
        .P(temp1),
        .CE(fft_out_valid)   
    );
      mult uut2(
        .clk(clk),
        .a(x_im),
        .b(y_im),
        .P(temp2), 
        .CE(fft_out_valid)    
    );
      mult uut3(
        .clk(clk),
        .a(x_im),
        .b(y_re),
        .P(temp3),
         .CE(fft_out_valid)     
    );
      mult uut4(
        .clk(clk),
        .a(x_re),
        .b(y_im),
        .P(temp4) ,
         .CE(fft_out_valid)    
    );
      mult xre(
        .clk(clk),
        .a(x_re),
        .b(x_re),
        .P(temp5),
         .CE(fft_out_valid)      
      );
       mult xim(
        .clk(clk),
        .a(x_im),
        .b(x_im),
        .P(temp6),
         .CE(fft_out_valid)       
      );
   always @(posedge clk) begin
      //这里应让乘法器有输出时进行
         h_re_temp<=temp1+temp2;
         h_im_temp<=temp4-temp3;
         sumx<=temp5+temp6;                  
         //这里可以不除   
         //h_re<=h_re_temp[48:25];
       //  h_im<=h_im_temp[48:25];    
   end   
   //除法

   wire  div_out_valid_re,div_out_valid_im;
   wire [111:0] div_out_re,div_out_im;
   div_gen_0 divide_re(
        .aclk(clk),
        .aclken(1'b1),
        .s_axis_divisor_tdata(sumx),
        .s_axis_dividend_tvalid(1'b1),
        .s_axis_dividend_tdata(h_re_temp),
        .m_axis_dout_tvalid( div_out_valid_re),
        .m_axis_dout_tdata(div_out_re)
   );
    div_gen_0 divide_im(
        .aclk(clk),
        .aclken(1'b1),
        .s_axis_divisor_tdata(sumx),
        .s_axis_dividend_tvalid(1'b1),
        .s_axis_dividend_tdata(h_im_temp),
        .m_axis_dout_tvalid( div_out_valid_im),
        .m_axis_dout_tdata(div_out_im)
   );
//   assign h_re = div_out_re[104:56];
//   assign h_im = div_out_im[104:56];
     assign h_re = div_out_re[79:56];
     assign h_im = div_out_im[79:56];//取24位
    integer count=0;
    wire  [47:0] hre_square,him_square;
	assign hre_square = h_re * h_re;
	assign him_square = h_im * h_im;     
   
    reg  [48:0]  h_amp;
    reg  [59:0] amp_sum=0;//49+11
    reg  [48:0]  h_aver_square;
    
   always@(posedge clk) begin  
        if(div_out_valid_re==1'b1)begin   
            h_amp<=hre_square+him_square;
            amp_sum<=h_amp+amp_sum;  
             count=count+1; 
        end     
   end
   //real =sqrt(h_amp)
   
   always@(posedge clk) begin
        if(count==Nfft) begin
            calvalid<=1'b1;
            h_aver_square<=amp_sum>>>11; //得到结果为增益的平方
        end
        if(fft_out_valid==1'b0)begin
            count<=0;
        end
   end 
   always @(posedge clk) begin
        if(calvalid==1'b1) begin
            gain<=h_aver_square[48:25];          //结果为增益的平方较高位，任然不知道几位
        end
   end
endmodule
