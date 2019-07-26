`timescale 1ns / 1ps
module top_tb();

        reg clk;
        reg ADC_sdata0, ADC_sdata1;
        reg aresetn;  //fft reset
        wire  ADC_sclk,ADC_csn;
        wire [11:0]  data0;
        wire [11:0] data1;
        wire  [23:0]   fft_real1,fft_real2;
        wire  [23:0]   fft_imag1,fft_imag2;
        wire [46:0]   amp1,amp2;
        wire fft_out_valid1,fft_out_valid2;
        
        top top_test(
         .clk(clk),
          .ADC_sdata0(ADC_sdata0), 
          .ADC_sdata1(ADC_sdata1),
           .aresetn(aresetn),  //fft reset
           .ADC_sclk(ADC_sclk),
           .ADC_csn(ADC_csn),
            .data0(data0),
            .data1(data1),
        .fft_real1(fft_real1),
        .fft_real2(fft_real2),
        .fft_imag1(fft_imag1),
        .fft_imag2(fft_imag2),
        .amp1(amp1),
        .amp2(amp2),
        .fft_out_valid1(fft_out_valid1),
        .fft_out_valid2(fft_out_valid2)       
        );
        
 initial
begin
	clk=0;
	aresetn=0;
	#20 aresetn=1;
	ADC_sdata0=1;
    ADC_sdata1=0;
end  
parameter clk_period=10;  
parameter clk_half_period=clk_period/2;  
parameter period_data=clk_period*1;//数据周期    
parameter data_num=4096;

reg [11:0] stimulus1[1:data_num];
reg  [11:0] stimulus2[1:data_num];
integer Pattern,count;

always #clk_half_period clk=~clk; 
initial
begin
	$readmemb("C:/Users/lenovo/Desktop/sin.txt",stimulus1);
	$readmemb("C:/Users/lenovo/Desktop/cos.txt",stimulus2);
	//fp_real=$fopen("C:/Users/lenovo/Desktop/fft_real.txt","w");   
	Pattern=0;count=0;
	repeat(data_num)
		begin
			Pattern=Pattern+1;	
			ADC_sdata0=stimulus1[Pattern];
	        ADC_sdata1=stimulus2[Pattern];    				
			#35;
		end
	
end        
//always @(posedge ADC_sclk)begin
//      if(count<data_num)begin
//       count=count+1;
//       ADC_sdata0=stimulus1[count];
//	   ADC_sdata1=stimulus2[count];       
//      end
//end


                
endmodule
