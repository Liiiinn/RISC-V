`timescale 1ns / 1ps


module fetch_stage(
    input clk,
    input reset_n,
    input is_branch,   
    input flush,  
    input [31:0] data,
    input [31:0] branch_address,
//    input pc_src,
    input pc_write
    output logic [31:0] address,
);

    logic [31:0] pc_next, pc_reg,pc_temp_reg,pc_temp_reg_next;
//    logic [31:0] branch_offset;
    
    
    always_ff @(posedge clk) begin
        if (!reset_n) begin
            pc_reg <= 0;
        end
        else begin
            pc_reg <= pc_next;
            pc_temp_reg <= pc_temp_reg_next ;
        end 
    end


//    always_comb begin
 //       if (pc_write) begin
 //           pc_next = pc_src ? pc_reg + branch_offset : pc_reg + 4;
 //       end
 //       else begin
 //           pc_next = pc_reg;
//        end
//    end
        
        
 //   always_comb begin
 //       case (data[6:0])
 //           7'b1100011: begin
 //               branch_offset = {{19{data[31]}}, data[31], data[7], data[30:25], data[11:8], 1'b0}; //Btype
//            end
//            7'b1101111: begin
//                branch_offset = {{11{data[31]}}, data[31], data[19:12], data[20], data[30:21], 1'b0}; //Jal
//            end
//            7'b1100111: begin
//                branch_offset = {{20{data[31]}}, data[31:20]}; //Jalr
//            end
//            default: begin
//                branch_offset = 0;
//            end
//        endcase
//    end
   always_comb begin
       if(is_branch) 
        begin
          pc_temp_reg_next = pc_reg;
          pc_next = branch_address;           
        end 
       else if(flush)
        begin
          pc_next = pc_temp_reg + 4 ;
        end
        else 
           pc_next = data;
           pc_temp_reg_next = 32'b0;
    end
       
    assign address = pc_reg;  
    
//    assign address = pc_reg;
    //assign pc_next = pc_src? pc_reg + branch_offset : pc_reg + 4;
    
endmodule
