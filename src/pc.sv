`timescale 1ns / 1ps

module pc
    import riscv_pkg::*;
    import custom_pkg::*;
    (
    input  logic [ 0:0] clk_i,
    input  logic [ 0:0] rstn_i,
    input  logic [ 0:0] en_i,
    input  logic [31:0] pc_i,
    output logic [31:0] pc_o
    );
    
    always_ff@(posedge clk_i)
        if(!rstn_i)    pc_o <= PC_INIT; 
        else if(!en_i) pc_o <= pc_i;
    
endmodule
