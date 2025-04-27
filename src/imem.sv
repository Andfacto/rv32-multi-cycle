`timescale 1ns / 1ps

module imem
    import riscv_pkg::*;
    import custom_pkg::*;
    #(
    parameter IMemInitFile
    )(
    input  logic [31:0] addr_i,
    output logic [31:0] dout_o
    );
    
    logic [31:0] ROM[ROM_LOWER:ROM_HIGHER];

    initial begin
        $readmemh(IMemInitFile, ROM);
    end

    assign dout_o = ROM[addr_i[31:2]];

endmodule
