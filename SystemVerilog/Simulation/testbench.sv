`timescale 1ns / 1ps


module testbench();

    logic clock = 0;
    logic reset_n = 0;
    
    
    always begin
        #10 clock = ~clock;
    end


    initial begin
        #35 reset_n = 1;
    end
    
    
    cpu cpu_inst(
        .clk(clock),
        .reset_n(reset_n)
    );
    
endmodule
