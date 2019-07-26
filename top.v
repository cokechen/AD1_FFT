`timescale 1ns / 1ps
module top(
        input clk,
        input ADC_sdata0, ADC_sdata1,
        input aresetn,  //fft reset
        output  ADC_sclk,ADC_csn,
        output  wire[11:0] data0,
        output  wire [11:0] data1,

        output  wire[23:0]   fft_real1,
         output  wire[23:0] fft_real2,
        output   wire[23:0]   fft_imag1,
         output  wire[23:0] fft_imag2,
        output  wire[46:0]   amp1,
         output  wire[46:0] amp2,
        output  wire fft_out_valid1,
         output  wire fft_out_valid2
    );
    
    wire clk35M;
    design_1_wrapper uu(
                    .clk_in1( clk ) ,      
                   .clk_out1(clk35M)
         );
                        
    pmodad   uad(
        .clk(clk35M),
        .ADC_sdata0(ADC_sdata0), 
        .ADC_sdata1(ADC_sdata1),
        .ADC_sclk(ADC_sclk),
        .ADC_csn(ADC_csn),
        .data0(data0),
        .data1(data1)
    );  
   
    
    fft_test ufft1(
        .aclk(clk35M),
        .aresetn(aresetn),
        .input_data_ch1(data0),
        .fft_real(fft_real1),
        .fft_imag(fft_imag1),
        .amp(amp1),
        .fft_out_valid(fft_out_valid1)    
    );
    
     fft_test ufft2(
        .aclk(clk35M),
        .aresetn(aresetn),
        .input_data_ch1(data1),
        .fft_real(fft_real2),
        .fft_imag(fft_imag2),
        .amp(amp2),
        .fft_out_valid(fft_out_valid2)    
    );
    
endmodule
