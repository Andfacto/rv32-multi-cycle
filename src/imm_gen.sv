`timescale 1ns / 1ps

module imm_gen 
    import riscv_pkg::*;
    import custom_pkg::*;
    (
    input  logic [ 2:0] sel_imm_i,
    input  logic [31:7] instr_i,
    output logic [31:0] imm_o
    );
    
    always_comb begin
        unique case(sel_imm_i)
            IMM_U  : imm_o = {instr_i[31], instr_i[30:12], {12{1'b0}}};
            IMM_J  : imm_o = {{12{instr_i[31]}}, instr_i[19:12], instr_i[20], instr_i[30:21], 1'b0};
            IMM_I  : imm_o = {{21{instr_i[31]}}, instr_i[30:20]};
            IMM_B  : imm_o = {{20{instr_i[31]}}, instr_i[7], instr_i[30:25], instr_i[11:8], 1'b0};
            IMM_S  : imm_o = {{21{instr_i[31]}}, instr_i[30:25], instr_i[11:7]};
            default: imm_o = 32'd0;   
        endcase   
    end
    
endmodule