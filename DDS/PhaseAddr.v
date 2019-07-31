module PhaseAdder(
    input clk,
    input rst,
    input [9:0] FreqCtrl,   
    output [12:0]phase
    );
    
    reg [12:0]phase_reg = 0;
    assign phase = phase_reg;
    always@(posedge rst or posedge clk)
    begin
        if(rst)
            phase_reg <= 13'd0;
        else
            phase_reg <= phase_reg + FreqCtrl;  
    end
endmodule
