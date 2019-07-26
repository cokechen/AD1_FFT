module ad7476_sample(
        input clk,rst,
        input  ADC_sdata0, ADC_sdata1,
        output reg ADC_sclk = 0,
        output reg ADC_csn = 0,
        output reg [11:0]  adc_res0 = 0, 
        output reg [11:0] adc_res1 = 0,
        output reg   adc_valid =0
    );
 
    reg [7:0] cntr = 0;
    always @ (posedge clk) //clk 35MHZ
        if (rst)cntr<=0;else if (cntr == 34) cntr<=0;else cntr<=cntr+1;
    always @ (posedge clk)
    case (cntr )
        0:  ADC_csn <= 0;
        33:  ADC_csn <= 1;
    endcase
    always @ (posedge clk)
    case (cntr)
        //0,1,3,5,7,9,11,13,15,17,19,21,23,25,27,29,31,33,34 :
        34,0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,33 :ADC_sclk<=1;
        default ADC_sclk<=0;
    endcase
    always @ (posedge clk)
    case (cntr )
        10: adc_res0[11] <= ADC_sdata0 ;
        12:adc_res0[10] <= ADC_sdata0 ;
        14:adc_res0[9] <= ADC_sdata0 ;
        16:adc_res0[8] <= ADC_sdata0 ;
        18:adc_res0[7] <= ADC_sdata0 ;
        20:adc_res0[6] <= ADC_sdata0 ;
        22:adc_res0[5] <= ADC_sdata0 ;
        24:adc_res0[4] <= ADC_sdata0 ;
        26:adc_res0[3] <= ADC_sdata0 ;
        28:adc_res0[2] <= ADC_sdata0 ;
        30:adc_res0[1] <= ADC_sdata0 ;
        32:adc_res0[0] <= ADC_sdata0 ;
    endcase
    always @ (posedge clk)
    case (cntr )
        10: adc_res1[11] <= ADC_sdata1 ;
        12:adc_res1[10] <= ADC_sdata1 ;
        14:adc_res1[9] <= ADC_sdata1 ;
        16:adc_res1[8] <= ADC_sdata1 ;
        18:adc_res1[7] <= ADC_sdata1 ;
        20:adc_res1[6] <= ADC_sdata1 ;
        22:adc_res1[5] <= ADC_sdata1 ;
        24:adc_res1[4] <= ADC_sdata1 ;
        26:adc_res1[3] <= ADC_sdata1 ;
        28:adc_res1[2] <= ADC_sdata1 ;
        30:adc_res1[1] <= ADC_sdata1 ;
        32:adc_res1[0] <= ADC_sdata1 ;
    endcase
    always @ (posedge clk)adc_valid <= cntr == 32 ;
endmodule