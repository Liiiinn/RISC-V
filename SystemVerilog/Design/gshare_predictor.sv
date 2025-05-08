`timescale 1ns / 1ps
// not finished , still some problems ( prediction works for static 1bit predictor)

module gshare_predictor#(
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

    logic [GHR_BITS-1:0] ghr,ghr_d;  // Global History Register    
    logic [1:0] bht [0:BHT_SIZE-1];  // Branch History Table   
    logic [$clog2(BHT_SIZE)-1:0] index, index_d;// BHT index
    logic [1:0] counter;  // counter now
    logic [7:0]pc_part;

    assign pc_part = pc[GHR_BITS+1:2];
    assign index = pc_part ^ ghr_d; //hash 低两位是为了对齐，都是0。
    assign counter = bht[index];
    assign prediction = counter[1];
    
 always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            ghr <= '0;
            ghr_d <= '0;
            index_d <= '0;
        end else begin
            ghr_d <= ghr;
            index_d <= index;
            if (update) begin
                ghr <= {ghr[GHR_BITS-2:0], actual_taken};
 //               index <= (pc[GHR_BITS+1:2]) ^ ghr;
            end
        end
    end
  
  integer i;
  
    
    // 初始化和读出当前计数器值
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
      //     ghr <= '0;
            for (int i = 0; i < BHT_SIZE; i++) begin
                bht[i] <= 2'b01; // 默认弱不跳转
            end
        end 
        else begin
            // 更新预测器
            if (update) begin
                // 更新 BHT 饱和计数器    use old index_d, it's matched with the instruction generating acual_taken,otherwise the bht will not change 
                // becuase of the updated index and ghr
                case (bht[index_d])
                    2'b00: bht[index_d] <= actual_taken ? 2'b01 : 2'b00;// strong not taken
                    2'b01: bht[index_d] <= actual_taken ? 2'b10 : 2'b00;// weak not taken
                    2'b10: bht[index_d] <= actual_taken ? 2'b11 : 2'b01;// weak taken
                    2'b11: bht[index_d] <= actual_taken ? 2'b11 : 2'b10;//strong taken
                endcase

                // 更新 GHR（移位寄存器）
        //       ghr <= {ghr[GHR_BITS-2:0], actual_taken};
            end
        end
    end
    

    
endmodule
