`timescale 1ns / 1ps

module branch_comp
    import riscv_pkg::*;
    import custom_pkg::*;
    (
    input  logic [ 2:0] branch_type_i,
    input  logic [31:0] data_rs1_i,
    input  logic [31:0] data_rs2_i,
    output logic [ 0:0] branch_o
    );
    
    logic [0:0] branch_uns;
    logic [0:0] branch_eq;
    logic [0:0] branch_low;
    
    always_comb begin
        case(branch_type_i)
            BRANCH_LTU: branch_uns = 1'b1;
            BRANCH_GEU: branch_uns = 1'b1;
            default   : branch_uns = 1'b0;
        endcase
    end
    
    always_comb begin
        case(branch_type_i)
            BRANCH_JAL : branch_o = 1'b1;
            BRANCH_EQ  : branch_o = branch_eq;
            BRANCH_NE  : branch_o = ~branch_eq;
            BRANCH_LT  : branch_o = branch_low;
            BRANCH_GE  : branch_o = ~branch_low;
            BRANCH_LTU : branch_o = branch_low;
            BRANCH_GEU : branch_o = ~branch_low;
            BRANCH_NONE: branch_o = 1'b0;
            default    : branch_o = 1'b0;
        endcase
    end
    
    always_comb begin
        branch_eq  = data_rs1_i == data_rs2_i;
        
        branch_low = branch_uns ? data_rs1_i  <         data_rs2_i :             
                          $signed(data_rs1_i) < $signed(data_rs2_i);
    end
    
endmodule