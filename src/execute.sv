`timescale 1ns / 1ps

module execute
    import riscv_pkg::*;
    import custom_pkg::*;
    (
    input  logic [ 0:0] clk_i,
    input  logic [ 0:0] rstn_i,
    input  control_t    control_i,
    input  logic [31:0] unit_in1_i,
    input  logic [31:0] unit_in2_i, 
    input  logic [31:0] mem_data_i,
    input  logic [31:0] pc_plus4_i,
    input  logic [ 4:0] addr_rd_i,
    output logic [ 4:0] addr_rd_o,
    output control_t    control_o,
    output logic [31:0] mem_data_o,
    output logic [31:0] pc_plus4_o,
    output logic [31:0] alu_o,
    output logic [31:0] execute_o
    );
    
    logic [31:0] alu_out;
    
    assign execute_o = alu_out;
    
    ALU ALU_dut(
        .sel_i   (control_i.alu_op),
        .op1_i   (unit_in1_i      ),
        .op2_i   (unit_in2_i      ),
        .result_o(alu_out         )
    );
    
    always_ff@(posedge clk_i) begin
        if(!rstn_i) begin
            addr_rd_o  <= 5'd0;
            control_o  <= MI_ADDI;
            pc_plus4_o <= 32'd0;
            mem_data_o <= 32'd0;
            alu_o      <= 32'd0;
        end else begin
            addr_rd_o  <= addr_rd_i;
            control_o  <= control_i;
            pc_plus4_o <= pc_plus4_i;
            mem_data_o <= mem_data_i;
            alu_o      <= alu_out;
        end
    end
    
endmodule