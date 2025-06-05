`timescale 1ns / 1ps

module gshare_predictor #(
    parameter GHR_BITS = 8,
    parameter BHT_SIZE = 256
    )(
    input logic clk,
    input logic reset_n,
    input logic [31:0] pc,
    // input logic [31:0] branch_offset,
    input logic update,            // Whether to update predictor
    input logic actual_taken,      // Actual branch result (taken or not)
    output logic prediction        // Prediction result (taken or not taken)
    );

    logic [GHR_BITS - 1:0] ghr, ghr_d;  // Global History Register    
    logic [1:0] bht [0:BHT_SIZE - 1];  // Branch History Table   
    logic [$clog2(BHT_SIZE) - 1:0] index;// BHT index
    logic [1:0] counter;  // counter now
    logic [7:0] pc_part;
    logic [31:0] pc_generating_branch;


    // assign pc_generating_branch = pc-branch_offset -4; //when current EXE is branch,update ==1, the pc is not the pc generating branch 
    assign pc_part = pc[GHR_BITS + 1 : 2]; //hash bit[1:0] only used for alignment in regular instruction，
    assign index = pc_part ^ ghr_d; 
    assign counter = bht[index];
    assign prediction = counter[1];
    
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n)
        begin
            ghr <= '0;
            ghr_d <= '0;

            for (int i = 0; i < BHT_SIZE; i ++) begin
                bht[i] <= 2'b01; // Initialize BHT to weakly taken
            end
        end
        else begin
            ghr_d <= ghr; // Store previous GHR value
            
            if (update) begin
                // Update GHR with the actual branch result
                ghr <= {ghr[GHR_BITS - 2 : 0], actual_taken};
                
                // Update BHT based on the actual branch result
                case (bht[index])
                    2'b00: bht[index] <= actual_taken ? 2'b01 : 2'b00; // Strong not taken
                    2'b01: bht[index] <= actual_taken ? 2'b10 : 2'b00; // Weak not taken
                    2'b10: bht[index] <= actual_taken ? 2'b11 : 2'b01; // Weak taken
                    2'b11: bht[index] <= actual_taken ? 2'b11 : 2'b10; // Strong taken
                endcase
            end
        end
    end
       
endmodule

//module gshare_predictor (
//    input  logic [31:0] pc,     // From instruction data[6:0]
//    output logic prediction        // Predict taken or not taken
//);

//    // Assume B_type = 7'b1100011
//    localparam B_TYPE = 7'b1100011;

//    always_comb begin
//        if (pc[6:0] == B_TYPE)
//            prediction = 1'b1; // Always predict taken
//        else
//            prediction = 1'b0; // Non-branch instructions default to sequential execution
//    end

//endmodule