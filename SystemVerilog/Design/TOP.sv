`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/02/09 11:01:20
// Design Name: 
// Module Name: Top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module TOP(
    input logic clk_top,
    input logic reset_n_top,
    input logic io_rx_top,
    output logic indication_top
    );

    logic clk;
    logic reset_n;
    logic io_rx;
    logic indication;
    //input PADs

    CPAD_S_74x50u_IN clkPad(
            .PADIO(clk_top),
            .COREIO(clk)
    );

    CPAD_S_74x50u_IN iorxPad(
            .PADIO(io_rx_top),
            .COREIO(io_rx)
    );

    CPAD_S_74x50u_IN resetPad(
            .PADIO(reset_n_top),
            .COREIO(reset_n)
    );

    //output PADs
   

    CPAD_S_74x50u_OUT indicationPad(
            .COREIO(indication),
            .PADIO(indication_top)
    );

    cpu CPUInst(
        .clk(clk),
        .io_rx(io_rx),
        .reset_n(reset_n),
        .indication(indication)        
    );



endmodule
