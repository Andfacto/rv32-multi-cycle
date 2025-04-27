`timescale 1ns / 1ps

module writeback
    import riscv_pkg::*;
    import custom_pkg::*;
    (
    input  control_t control_i,
    input  logic [31:0] dmem_i,
    input  logic [31:0] alu_i,
    input  logic [31:0] pc_plus4_i,
    output logic [31:0] writeback_o
    );
 
    always_comb begin
        case(control_i.writeback)
            WB_MEM : writeback_o = dmem_i;
            WB_ALU : writeback_o = alu_i;
            WB_PC4 : writeback_o = pc_plus4_i;
            default: writeback_o = 32'd0;
        endcase
    end
    
endmodule

