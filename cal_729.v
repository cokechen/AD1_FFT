`timescale 1ns / 1ps
module cal(
    input clk,
    input [23:0] x_re,
    input [23:0] x_im,
    input [23:0] y_re,
    input [23:0] y_im,
    input  fft_out_valid, //fft_out_valid
    output reg [11:0] gain,
  //  output reg [23:0] phase_shift,//位宽待改
    output reg calvalid
    );
   wire [11:0] h_re,h_im;
   wire [48:0] h_re_temp,h_im_temp;
   wire [48:0] sumx;
   parameter Nfft=2048;
  
    wire [47:0] temp1,temp2,temp3,temp4,temp5,temp6;
//   assign temp1=x_re*y_re;
//   assign temp2=x_im*y_im;
//   assign temp3=x_im*y_re;
//   assign temp4=x_re*y_im;
//   assign temp5=x_re*x_re;
//   assign temp6=x_im*x_im;
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

//   always @(posedge clk) begin
//      //这里应让乘法器有输出时进行
//         h_re_temp<=temp1+temp2;
//         h_im_temp<=temp4-temp3;
//         sumx<=temp5+temp6;                  
//   end   
 
   assign h_re_temp=temp1+temp2;
   assign h_im_temp=temp4-temp3;
   assign sumx=temp5+temp6;
   reg  s_axis_dividend_tvalid=0;
   wire  div_out_valid_re,div_out_valid_im;
   wire [104:0] div_out_re,div_out_im;
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
        .s_axis_divisor_tdata(sumx),
        .s_axis_dividend_tvalid( s_axis_dividend_tvalid),
        .s_axis_dividend_tdata(h_re_temp),
        .m_axis_dout_tvalid( div_out_valid_re),
        .m_axis_dout_tdata(div_out_re)
   );
    div_gen_0 divide_im(
        .aclk(clk),
        .aclken(1'b1),
        .s_axis_divisor_tdata(sumx),
        .s_axis_dividend_tvalid( s_axis_dividend_tvalid),
        .s_axis_dividend_tdata(h_im_temp),
        .m_axis_dout_tvalid( div_out_valid_im),
        .m_axis_dout_tdata(div_out_im)
   );

     assign h_re = div_out_re[67:56];
     assign h_im = div_out_im[67:56];//取12位
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
   end
    
    cordic_0 sqrt_root(
            .aclk(clk),
            .s_axis_cartesian_tdata(s_axis_cartesian_tdata),
            .s_axis_cartesian_tvalid(1),
            .m_axis_dout_tdata(m_axis_dout_tdata),
            .m_axis_dout_tvalid(m_axis_dout_tvalid)
    );
    
   reg [12:0]average;
   always@(posedge clk) begin  
       if(m_axis_dout_tvalid & m_axis_dout_tvalid!==4095)begin
             //h_amp<=hre_square+him_square;
             h_amp<=hre_square;
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
