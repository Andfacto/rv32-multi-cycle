`timescale 1ns / 1ps

module ALU
    import riscv_pkg::*;
    import custom_pkg::*;
    (
    input  logic [ 3:0] sel_i,
    input  logic [31:0] op1_i,
    input  logic [31:0] op2_i,
    output logic [31:0] result_o
    );
    
    always_comb begin
        unique case(sel_i)
            ALU_ADD : result_o = op1_i + op2_i;
            ALU_SUB : result_o = op1_i - op2_i;
            ALU_OR  : result_o = op1_i | op2_i;
            ALU_AND : result_o = op1_i & op2_i;
            ALU_XOR : result_o = op1_i ^ op2_i;
            ALU_SLL : result_o = op1_i <<  op2_i[4:0];
            ALU_SRL : result_o = op1_i >>  op2_i[4:0];
            ALU_SRA : result_o = $signed(op1_i) >>> op2_i[4:0];
            ALU_SLT : result_o = $signed(op1_i) < $signed(op2_i); 
            ALU_SLTU: result_o =         op1_i  <         op2_i;
            ALU_CTZ : result_o = ctz(op1_i);
            ALU_CLZ : result_o = clz(op1_i);
            ALU_CPOP: result_o = cpop(op1_i);
            default : result_o = 32'd0;
        endcase
    end
        
endmodule