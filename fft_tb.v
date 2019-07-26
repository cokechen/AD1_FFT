`timescale 1ns / 1ps

module fft_tb();

reg aclk, arst;
reg [11:0] input_data_ch1;
wire [18:0] fft_real, fft_imag;
wire fft_out_valid;
wire [42:0]   amp;
fft_test i1
(      
        .aclk(aclk),
        .aresetn(arst),

        .input_data_ch1(input_data_ch1),
        .fft_real(fft_real),
        .fft_imag(fft_imag),
        .amp(amp),
        .fft_out_valid(fft_out_valid)
);

parameter clk_period=20; //设置时钟信号周期（频率）
parameter period_data=clk_period*1;//数据周期
parameter clk_half_period=clk_period/2;
parameter data_half_period=period_data/2;
parameter data_num=4000;  //仿真数据长度


integer Pattern;
reg  [11:0] stimulus[1:data_num];
initial
begin
	aclk=0;
	input_data_ch1 = 12'd0;
	arst=0;
	#20 arst=1;
	//$readmemb("C:/Users/lenovo/Desktop/sin.txt",stimulus);
	//#10000 $stop;
end

always #clk_half_period aclk=~aclk;

//从外部TXT文件读入数据作为测试激励


initial
begin   
	Pattern=0;
	repeat(data_num)
		begin
			Pattern=Pattern+1;
			//input_data_ch1=stimulus[Pattern];
			input_data_ch1=12'hfff;
			#period_data;
		end	
end

endmodule
