`timescale 1ns / 1ps

module dmem
    import riscv_pkg::*;
    import custom_pkg::*;
    #(
    parameter DMemInitFile
    )(
    input  logic [ 0:0] clk_i, 
    input  logic [ 2:0] ctrl_i,
    input  logic [31:0] addr_i,
    input  logic [31:0] din_i,
    output logic [31:0] dout_o
    );                      

    logic [31:0] RAM[RAM_LOWER:RAM_HIGHER];
    
    initial begin
        $readmemh(DMemInitFile, RAM);
    end
    
    always_ff@(posedge clk_i) begin
        unique case(ctrl_i)
            MEM_SB : RAM[addr_i[31:2]][ 7:0] <= din_i[ 7:0];
            MEM_SH : RAM[addr_i[31:2]][15:0] <= din_i[15:0];
            MEM_SW : RAM[addr_i[31:2]][31:0] <= din_i[31:0];
            default: RAM[addr_i[31:2]][31:0] <= RAM[addr_i[31:2]][31:0];
        endcase
    end
    
    always_comb begin
        unique case(ctrl_i)
            MEM_LB : dout_o = {{24{RAM[addr_i[31:2]][ 7]}}, RAM[addr_i[31:2]][ 7:0]};
            MEM_LH : dout_o = {{16{RAM[addr_i[31:2]][15]}}, RAM[addr_i[31:2]][15:0]};
            MEM_LW : dout_o =                               RAM[addr_i[31:2]]       ;
            MEM_LBU: dout_o = {{24{1'b0}},                  RAM[addr_i[31:2]][ 7:0]};
            MEM_LHU: dout_o = {{16{1'b0}},                  RAM[addr_i[31:2]][15:0]};
            default: dout_o = 32'd0;
        endcase
    end
    
endmodule
