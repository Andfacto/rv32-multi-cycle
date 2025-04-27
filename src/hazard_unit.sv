`timescale 1ns / 1ps

module hazard_unit
    import riscv_pkg::*;
    import custom_pkg::*;
    (
    input  logic [4:0] addr_rs1_ID_i,
    input  logic [4:0] addr_rs2_ID_i,
    
    input  logic [4:0] addr_rd_EX_i,
    input  logic [4:0] addr_rd_MEM_i,
    input  logic [4:0] addr_rd_WB_i,
    
    input  logic [0:0] branch_EX_i,
    
    input  logic [1:0] sel_wb_EX_i,
    input  logic [1:0] sel_wb_MEM_i,
    
    input  logic [0:0] reg_write_en_EX_i,
    input  logic [0:0] reg_write_en_MEM_i,
    input  logic [0:0] reg_write_en_WB_i,
    
    output hazard_t hazard_o
    );
    
    logic load_stall;

    always_comb begin
        if((addr_rs1_ID_i == addr_rd_EX_i) && reg_write_en_EX_i && (addr_rs1_ID_i != 0)) begin
            hazard_o.forward_a = DATA_ALU;
        end else if((addr_rs1_ID_i == addr_rd_MEM_i) && reg_write_en_MEM_i && (addr_rs1_ID_i != 0) && (sel_wb_MEM_i != 2'b00)) begin
            hazard_o.forward_a = DATA_ALU_MEM;
        end else if((addr_rs1_ID_i == addr_rd_MEM_i) && reg_write_en_MEM_i && (addr_rs1_ID_i != 0) && (sel_wb_MEM_i == 2'b00)) begin
            hazard_o.forward_a = DATA_DMEM;
        end else if((addr_rs1_ID_i == addr_rd_WB_i) && reg_write_en_WB_i && (addr_rs1_ID_i != 0)) begin
            hazard_o.forward_a = DATA_WB;
        end else begin
            hazard_o.forward_a = DATA_REG;
        end
    end
    
    always_comb begin
        if((addr_rs2_ID_i == addr_rd_EX_i) && reg_write_en_EX_i && (addr_rs2_ID_i != 0)) begin
            hazard_o.forward_b = DATA_ALU;
        end else if((addr_rs2_ID_i == addr_rd_MEM_i) && reg_write_en_MEM_i && (addr_rs2_ID_i != 0) && (sel_wb_MEM_i != 2'b00)) begin
            hazard_o.forward_b = DATA_ALU_MEM;
        end else if((addr_rs2_ID_i == addr_rd_MEM_i) && reg_write_en_MEM_i && (addr_rs2_ID_i != 0) && (sel_wb_MEM_i == 2'b00)) begin
            hazard_o.forward_b = DATA_DMEM;
        end else if((addr_rs2_ID_i == addr_rd_WB_i) && reg_write_en_WB_i && (addr_rs2_ID_i != 0)) begin
            hazard_o.forward_b = DATA_WB;
        end else begin
            hazard_o.forward_b = DATA_REG;
        end
    end
    
    assign load_stall = (sel_wb_EX_i == WB_MEM) && ((addr_rs1_ID_i == addr_rd_EX_i) || (addr_rs2_ID_i == addr_rd_EX_i));
    
    assign hazard_o.stall_if = load_stall;
    assign hazard_o.stall_id = load_stall;
    
    assign hazard_o.flush_id = branch_EX_i;
    assign hazard_o.flush_ex = branch_EX_i | load_stall;
    
endmodule