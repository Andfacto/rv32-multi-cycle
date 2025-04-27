`timescale 1ns / 1ps

module fetch
    import riscv_pkg::*;
    import custom_pkg::*;
    #(
    parameter IMemInitFile = "./imem.mem"
    )(
    input  logic [ 0:0] clk_i,
    input  logic [ 0:0] rstn_i,
    input  logic [ 0:0] branch_EX_i,
    input  hazard_t     hazard_i,
    input  logic [31:0] execute_i,
    output logic [31:0] pc_o,
    output logic [31:0] pc_plus4_o,
    output instr_t      imem_o
    );
    
    logic [31:0] imem_out;
    logic [31:0] pc_in;
    logic [31:0] pc_out;
    logic [31:0] pc_plus4;
    
    assign pc_plus4 = pc_out + 4;
    assign pc_in    = branch_EX_i ? execute_i : pc_plus4;
    
    pc pc_dut(
        .en_i  (hazard_i.stall_if),
        .clk_i (clk_i            ),
        .rstn_i(rstn_i           ),
        .pc_i  (pc_in            ),
        .pc_o  (pc_out           )
    );
    
    imem #(
        .IMemInitFile(IMemInitFile)
    ) imem_dut(
        .addr_i(pc_out  ),
        .dout_o(imem_out)
    );
    
    always_ff@(posedge clk_i) begin
        if(!rstn_i) begin
            imem_o     <= 32'd0;
            pc_o       <= 32'd0;
            pc_plus4_o <= 32'd0; 
        end else if(hazard_i.stall_id) begin
            imem_o     <= imem_o;
            pc_o       <= pc_o;
            pc_plus4_o <= pc_plus4_o; 
        end else if(hazard_i.flush_id) begin
            imem_o     <= 32'd0;
            pc_o       <= 32'd0;
            pc_plus4_o <= 32'd0;
        end else begin
            imem_o     <= imem_out;
            pc_o       <= pc_out;
            pc_plus4_o <= pc_plus4;
        end
    end
    
endmodule
