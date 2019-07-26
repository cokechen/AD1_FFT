`timescale 1ns / 1ps
module cal_tb( );
    reg clk;
    reg [23:0] x_re,x_im;
    reg [23:0] y_re,y_im;
    reg  fft_out_valid; //fft_out_valid
    reg [23:0] gain;
    reg calvalid;
    
//    cal uut_cal(
//        .clk(clk),
//        .x_re(x_re),
//        .x_im(x_im),
//        .y_re(y_re),
//        .y_im(y_im),
//        .fft_out_valid(fft_out_valid),
//        .gain(gain),
//        .calvalid(calvalid)
//    );
      parameter data_num=9000;
    integer Pattern;
   reg[23:0] simulus1[1:data_num];
   reg[23:0] simulus2[1:data_num];
   reg[23:0] simulus3[1:data_num];
   reg[23:0] simulus4[1:data_num];
    initial begin
       clk=0;
       fft_out_valid=0;  
       #20  fft_out_valid=1; 
        Pattern=0;
         
            $readmemb("C:/Users/lenovo/Desktop/sin.txt",simulus1);
            $readmemb("C:/Users/lenovo/Desktop/sin.txt",simulus2);
            $readmemb("C:/Users/lenovo/Desktop/sin.txt",simulus3);
            $readmemb("C:/Users/lenovo/Desktop/sin.txt",simulus4);       
	
    end
       always #5 clk=~clk;
  always@(posedge clk)begin
      if(fft_out_valid==1)begin	   
			Pattern=Pattern+1;	
			x_re=simulus1[Pattern];
	        x_im=simulus2[Pattern];    	
	        y_re=simulus3[Pattern];
	        y_im=simulus4[Pattern]; 			
			#30;
	end	
   end
   
   always@(posedge clk) begin
        if(Pattern%2048==0) begin
            fft_out_valid<=0;
            #30000;
        end
        else if(Pattern<data_num)begin
          fft_out_valid<=1;
       end
//       if(Pattern==data_num) begin
            
       
//       end
   end
   
endmodule
