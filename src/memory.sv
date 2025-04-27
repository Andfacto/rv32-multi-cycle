`timescale 1ns / 1ps

module memory
    import riscv_pkg::*;
    import custom_pkg::*;
    #(
    parameter DMemInitFile = "./dmem.mem"
    )(
    input  logic [ 0:0] clk_i,
    input  logic [ 0:0] rstn_i,
    input  control_t    control_i,
    input  logic [31:0] pc_plus4_i,
    input  logic [ 4:0] addr_rd_i,
    input  logic [31:0] alu_i,
    input  logic [31:0] mem_data_i,
    output logic [ 4:0] addr_rd_o,
    output control_t    control_o,
    output logic [31:0] pc_plus4_o,
    output logic [31:0] alu_o,
    output logic [31:0] dmem_MEM_o,
    output logic [31:0] dmem_WB_o
    );
    
    logic [31:0] dmem_out;
    
    assign dmem_MEM_o = dmem_out;
    
    dmem #(
        .DMemInitFile(DMemInitFile)
    ) dmem_dut(
        .clk_i (clk_i           ),
        .ctrl_i(control_i.mem_op),
        .addr_i(alu_i           ),
        .din_i (mem_data_i      ),
        .dout_o(dmem_out        )
    );
    
    always_ff@(posedge clk_i) begin
        if(!rstn_i) begin
            addr_rd_o  <= 5'd0;
            control_o  <= MI_ADDI;
            pc_plus4_o <= 32'd0;
            alu_o      <= 32'd0;
            dmem_WB_o  <= 32'd0;
        end else begin
            addr_rd_o  <= addr_rd_i;
            control_o  <= control_i;
            pc_plus4_o <= pc_plus4_i;
            alu_o      <= alu_i;
            dmem_WB_o  <= dmem_out;
        end
    end
        
endmodule