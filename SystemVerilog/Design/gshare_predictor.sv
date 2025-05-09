`timescale 1ns / 1ps


module gshare_predictor#(
    parameter GHR_BITS = 8,
    parameter BHT_SIZE = 256
    )(
    input logic clk,
    input logic reset_n,
    input logic [31:0] pc,
    input logic [31:0] branch_offset,
    input logic update,            // 是否更新预测器
    input logic actual_taken,      // 实际是否跳转
    output logic prediction        // 预测结果（跳转 or 不跳转）
    );

    logic [GHR_BITS-1:0] ghr,ghr_d;  // Global History Register    
    logic [1:0] bht [0:BHT_SIZE-1];  // Branch History Table   
    logic [$clog2(BHT_SIZE)-1:0] index;// BHT index
    logic [1:0] counter;  // counter now
    logic [7:0]pc_part;
    logic [31:0] pc_generating_branch;


    assign pc_generating_branch = pc-branch_offset -4; //when current EXE is branch,update ==1, the pc is  not the pc generating branch 
    assign pc_part = pc_generating_branch[GHR_BITS+1:2]; //hash bit[1:0] only used for alignment in regular instruction，
    assign index = pc_part ^ ghr_d; 
    assign counter = bht[index];
    assign prediction = counter[1];
    
 always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            ghr <= '0;
            ghr_d <= '0;
          //  index_d <= '0;
        end else begin
            ghr_d <= ghr;
        //    index_d <= index;
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
                bht[i] <= 2'b10; // 默认弱不跳转
            end
        end 
        else begin
            // 更新预测器
            if (update) begin
                // 更新 BHT 饱和计数器
                case (bht[index])
                    2'b00: bht[index] <= actual_taken ? 2'b01 : 2'b00;// strong not taken
                    2'b01: bht[index] <= actual_taken ? 2'b10 : 2'b00;// weak not taken
                    2'b10: bht[index] <= actual_taken ? 2'b11 : 2'b01;// weak taken
                    2'b11: bht[index] <= actual_taken ? 2'b11 : 2'b10;//strong taken
                endcase

                // 更新 GHR（移位寄存器）
        //       ghr <= {ghr[GHR_BITS-2:0], actual_taken};
            end
        end
    end
       
endmodule

//module gshare_predictor (
//    input  logic [31:0] pc,     // 来自指令 data[6:0]
//    output logic prediction        // 预测跳转 or 不跳转
//);

//    // 假设 B_type = 7'b1100011
//    localparam B_TYPE = 7'b1100011;

//    always_comb begin
//        if (pc[6:0] == B_TYPE)
//            prediction = 1'b1; // 总是预测跳转
//        else
//            prediction = 1'b0; // 非分支指令默认顺序执行
//    end

//endmodule
