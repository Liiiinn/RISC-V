`timescale 1ns / 1ps


module gshare_prediction#(
    parameter GHR_BITS = 8,
    parameter BHT_SIZE = 256
    )(
    input logic clk,
    input logic reset_n,

    input logic [31:0] pc,
    input logic update,            // 是否更新预测器
    input logic actual_taken,      // 实际是否跳转
    output logic prediction        // 预测结果（跳转 or 不跳转）
    );

    logic [GHR_BITS-1:0] ghr;  // Global History Register    
    logic [1:0] bht [0:BHT_SIZE-1];  // Branch History Table   
    logic [$clog2(BHT_SIZE)-1:0] index;// BHT index
    logic [1:0] counter;  // counter now

    
    // 初始化和读出当前计数器值
    always_ff @(posedge clk or posedge reset_n) begin
        if (!reset_n) begin
            ghr <= '0;
            for (int i = 0; i < BHT_SIZE; i++) begin
                bht[i] <= 2'b01; // 默认弱不跳转
            end
        end 
        else begin
            // 更新预测器
            if (update) begin
                // 更新 BHT 饱和计数器
                case (bht[index])
                    2'b00: bht[index] <= actual_taken ? 2'b01 : 2'b00;
                    2'b01: bht[index] <= actual_taken ? 2'b10 : 2'b00;
                    2'b10: bht[index] <= actual_taken ? 2'b11 : 2'b01;
                    2'b11: bht[index] <= actual_taken ? 2'b11 : 2'b10;
                endcase

                // 更新 GHR（移位寄存器）
                ghr <= {ghr[GHR_BITS-2:0], actual_taken};
            end
        end
    end


    assign index = (pc[7:0]) ^ ghr; //hash
    assign counter = bht[index];
    assign prediction = counter[1];
endmodule
