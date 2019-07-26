module ad1_tb();
        reg clk;
        reg  ADC_sdata0, ADC_sdata1;
        wire  ADC_sclk,ADC_csn;
        wire  [11:0] data0;
        wire [11:0] data1;
    
    
     initial
        begin
            clk=0;
            ADC_sdata0=1;
            ADC_sdata1=1;
        end         
     always #10 clk=~clk;  
    
     wire clk35M;
      
    design_1_wrapper uu(
                    .clk_in1( clk ) ,      
                   .clk_out1(clk35M)
         );
         
      pmodad    uut(
        .clk(clk35M),
        .ADC_sdata0(ADC_sdata0),
         .ADC_sdata1(ADC_sdata1),
        .ADC_sclk(ADC_sclk),
        .ADC_csn(ADC_csn),
         .data0(data0),
        .data1(data1)
    );              
         
endmodule        
  
