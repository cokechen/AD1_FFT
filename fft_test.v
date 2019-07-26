`timescale 1ns / 1ps
module fft_test(      
        
        input aclk,
        input aresetn,

        input [11:0]    input_data_ch1,
        output reg [23:0]   fft_real,
        output reg  [23:0]   fft_imag,
        output reg [46:0]   amp,
        output reg fft_out_valid
);
    reg [11:0] input_data_ch1_reg;//作一级寄存器输入    
    wire [7:0] s_axis_config_tdata;
    reg s_axis_config_tvalid;
//    wire s_axis_config_tready;
    wire s_axis_data_tready;
    reg [31:0] s_axis_data_tdata;
    reg s_axis_data_tvalid;
    reg s_axis_data_tlast;
    
    wire [47:0] m_axis_data_tdata;
    wire [15:0] m_axis_data_tuser;
    wire m_axis_data_tvalid;
    wire m_axis_data_tlast;
    reg [7:0]   cfg_cnt;
    reg [13:0]  sink_ctl_cnt;   
  //  reg [23:0]  fft_real,fft_imag; 
  //  reg fft_out_valid;
    wire    event_frame_started;// : OUT STD_LOGIC;
    wire    event_tlast_unexpected;// : OUT STD_LOGIC;
    wire    event_tlast_missing;// : OUT STD_LOGIC;
    wire    event_status_channel_halt;// : OUT STD_LOGIC;
    wire    event_data_in_channel_halt;// : OUT STD_LOGIC;
    wire    event_data_out_channel_halt;
        
    xfft_1 usr_FFT(
    
            .aclk(aclk),
            .aresetn(aresetn),
            
            .s_axis_config_tdata(s_axis_config_tdata),
            .s_axis_config_tvalid(s_axis_config_tvalid),
            .s_axis_config_tready(),
            
            .s_axis_data_tdata(s_axis_data_tdata),
            .s_axis_data_tvalid(s_axis_data_tvalid),
            .s_axis_data_tready(),
            .s_axis_data_tlast(s_axis_data_tlast),
            
            .m_axis_data_tdata(m_axis_data_tdata),
            .m_axis_data_tuser(m_axis_data_tuser),
            .m_axis_data_tvalid(m_axis_data_tvalid),
            .m_axis_data_tready(1'b1),
            .m_axis_data_tlast(m_axis_data_tlast),
            
            .event_frame_started(event_frame_started),// : OUT STD_LOGIC;
            .event_tlast_unexpected(event_tlast_unexpected),// : OUT STD_LOGIC;
            .event_tlast_missing(event_tlast_missing),// : OUT STD_LOGIC;
            .event_status_channel_halt(event_status_channel_halt),// : OUT STD_LOGIC;
            .event_data_in_channel_halt(event_data_in_channel_halt),// : OUT STD_LOGIC;
            .event_data_out_channel_halt(event_data_out_channel_halt)// : OUT STD_LOGIC
    );       
//////////////////////////////fft core config////////////////////////
    always@(posedge aclk or negedge aresetn)
    begin
        if(!aresetn)
            cfg_cnt <= 8'd0;
        else
        begin
            if(cfg_cnt < 8'd200)
                cfg_cnt <= cfg_cnt + 1'b1;
            else
                cfg_cnt <= cfg_cnt;
        end
    end

    always@(posedge aclk or negedge aresetn)
    begin
        if(!aresetn)
            s_axis_config_tvalid <= 1'b0;
        else
        begin
            if(cfg_cnt < 8'd200)
                s_axis_config_tvalid <= 1'b1;
            else
                s_axis_config_tvalid <= 1'b0;
        end
    end
assign s_axis_config_tdata = 8'd1;
//////////////////////////////fft core config////////////////////////
    
/////////////////////////////fft sink_in ctl/////////////////////////
    always@(posedge aclk or negedge aresetn)
    begin
        if(!aresetn)
            s_axis_data_tdata <= 32'b0;
        else
            s_axis_data_tdata <= {20'd0,input_data_ch1};
    end
    
    always@(posedge aclk or negedge aresetn)
    begin
        if(!aresetn)
            sink_ctl_cnt <= 14'd8194;
        else if(s_axis_config_tvalid)
            sink_ctl_cnt <= 14'd0;
        else if(sink_ctl_cnt == 14'd8192)
            sink_ctl_cnt <= 14'd1;
        else
            sink_ctl_cnt <= sink_ctl_cnt + 1'b1;
    end 
    
    //s_axis_data_tvalid
    always@(posedge aclk or negedge aresetn)
    begin
        if(!aresetn)
            s_axis_data_tvalid <= 1'b0;
        else if(sink_ctl_cnt < 14'd1)
            s_axis_data_tvalid <= 1'b0;
        else if(sink_ctl_cnt < 14'd2049)
            s_axis_data_tvalid <= 1'b1;
        else
            s_axis_data_tvalid <= 1'b0;
    end
    
    //s_axis_data_tlast
    always@(posedge aclk or negedge aresetn)
        begin
        if(!aresetn)
            s_axis_data_tlast <= 1'b0;
        else
        begin
            if(sink_ctl_cnt == 14'd2048)
                s_axis_data_tlast <= 1'b1;
            else
                s_axis_data_tlast <= 1'b0;
        end
    end
/////////////////////////////fft sink_in ctl/////////////////////////    
    always@(posedge aclk)
    begin
        fft_real <= m_axis_data_tdata[23:0];
    end
    
    always@(posedge aclk)
    begin
        fft_imag <= m_axis_data_tdata[47:24];
    end
    
    always@(posedge aclk)
    begin
        fft_out_valid <= m_axis_data_tvalid;
    end

    /********** 计算频谱的幅值信号 **********/
	
	wire signed [45:0] xkre_square, xkim_square;
	assign xkre_square = fft_real * fft_real;
	assign xkim_square = fft_imag * fft_imag;
	
	always @(posedge aclk)begin
      amp <= xkre_square + xkim_square;
    end
endmodule
