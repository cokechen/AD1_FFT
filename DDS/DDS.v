`timescale 1ns / 1ps
module DDS( 
    input clk,  //输入100M
    input rst,
  //  input [9:0] FreqCtrl,
    output [11:0] waveform
    );
    reg [9:0] FreqCtrl=1;
    wire [12:0] phase;
    reg [9:0] fpoint[1:50];
    
    
     //clk应为20*8192=163840Hz
   //得到的基频才为20Hz
   wire clk_4096;
    clk40_96M clk_div(
        .clk_in1(clk),      
        .clk_out1(clk_4096)
    );
   reg [7:0] time_count=0;
   reg clk_20;//40.96M的250分频163840Hz
   always @(posedge clk_4096)begin
         time_count=time_count+1;
         if(time_count==251)
             time_count<=0;
         if( time_count<=125)
             clk_20<=0;
         else if(time_count<=250)
             clk_20<=1;  
   end
    
    
    
    
   //main 
    PhaseAdder u_PhaseAdder
    (
        .clk(clk_20),
        .rst(rst),
        .FreqCtrl(FreqCtrl),
        .phase(phase)
    );
   DDS_ROM u_DDS_ROM
   (
       .a (phase[12:0]),
       .spo (waveform)
   );
   
   reg [16:0] count=0;
   integer sample=1;
   reg new_freq=1;
   always@(posedge clk_20)begin   //这里的时钟为163840Hz
          count=count+1;
        if(count==17'd98304)begin   //count代表每个频点持续时间相同，为98304/163840=0.6s
        // if(count==6'h3f)begin   //减少仿真时间，一个周期20ms
              sample<=sample+1;
              FreqCtrl<=fpoint[sample];
              count<=0;
              new_freq=1;
        end
       if(sample==51)  sample=1;
       if(count==10)   new_freq=0; //新频率标志信号
   end
    
  
   
   //频点初始化
   //实际单个频率最少持续50ms
    always @(posedge clk)begin
        if(!rst)begin
            fpoint[1]=1;
            fpoint[2]=1;
            fpoint[3]=1;
            fpoint[4]=1;
            fpoint[5]=1;
            fpoint[6]=2;
            fpoint[7]=2;
            fpoint[8]=3;
            fpoint[9]=3;
            fpoint[10]=3;
             fpoint[11]=4;
            fpoint[12]=5;
            fpoint[13]=6;
            fpoint[14]=6;
            fpoint[15]=7;
            fpoint[16]=9;
            fpoint[17]=10;
            fpoint[18]=12;
            fpoint[19]=13;
            fpoint[20]=15;
             fpoint[21]=18;
            fpoint[22]=20;
            fpoint[23]=23;
            fpoint[24]=27;
            fpoint[25]=31;
            fpoint[26]=36;
            fpoint[27]=41;
            fpoint[28]=47;
            fpoint[29]=54;
            fpoint[30]=63;
             fpoint[31]=72;
            fpoint[32]=83;
            fpoint[33]=95;
            fpoint[34]=109;
            fpoint[35]=125;
            fpoint[36]=144;
            fpoint[37]=165;
            fpoint[38]=190;
            fpoint[39]=218;
            fpoint[40]=251;
            fpoint[41]=288;
            fpoint[42]=330;
            fpoint[43]=379;
            fpoint[44]=436;
            fpoint[45]=500;
            fpoint[46]=575;
            fpoint[47]=660;
            fpoint[48]=758;
            fpoint[49]=870;
            fpoint[50]=999;             
        end   
    end
endmodule
