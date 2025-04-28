`timescale 1ns / 1ps

module reg_file    
    import riscv_pkg::*;
    import custom_pkg::*;
    (
    input  logic [ 0:0] clk_i,
    input  logic [ 0:0] rstn_i,
    input  logic [ 0:0] write_en_i,
    input  logic [ 4:0] addr_rs1_i, 
    input  logic [ 4:0] addr_rs2_i, 
    input  logic [ 4:0] addr_rd_i,
    input  logic [31:0] data_rd_i,
    output logic [31:0] data_rs1_o, 
    output logic [31:0] data_rs2_o
    );
    
    logic [31:0] x[0:31];
    
    always_ff@(negedge clk_i) begin
        if(!rstn_i) begin
            for(int i = 0; i < 32; i = i + 1) begin
                x[i] <= 32'd0;
            end
        end else if(write_en_i & (addr_rd_i != 5'b00000)) begin
            x[addr_rd_i] <= data_rd_i;
        end
    end

    assign data_rs1_o = x[addr_rs1_i];
    assign data_rs2_o = x[addr_rs2_i];

endmodule
