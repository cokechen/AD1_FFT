 module pmodad(
        input clk,
        input  ADC_sdata0, ADC_sdata1,
        output  ADC_sclk,ADC_csn,
        output reg [11:0] data0,
        output reg [11:0] data1
  
    );
  
     wire     adc_valid;
    // wire clk35M ;
     wire [11:0]adc_res0;
     wire [11:0]adc_res1;
     
   always@(posedge clk) begin
     if (adc_valid) begin
            data0<=adc_res0[11:0];
            data1<=adc_res1[11:0];
      end
   end
                      
//    always @ (posedge clk35M)if (adc_valid) LED <= ( sw0 == 1 )  ?  adc_res0[11:8]   :  adc_res1[11:8]  ;
    
    ad7476_sample  u1(
                       .clk( clk )  ,
                       .rst( 1'b0 )  ,
                       .ADC_sdata0(ADC_sdata0  )  ,
                       .ADC_sdata1(ADC_sdata1  )  ,
                       .ADC_sclk(ADC_sclk  )  ,
                       .ADC_csn(ADC_csn  )  ,
                       .adc_res0(adc_res0  )  ,
                       .adc_res1(adc_res1  )  ,
                       .adc_valid(adc_valid  )
                   );                 
        
endmodule
 