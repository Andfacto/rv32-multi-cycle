module tb;
    import riscv_pkg::XLEN;
    import custom_pkg::*;

    logic            clk;
    logic            rstn;
    logic [XLEN-1:0] if_pc;
    logic [XLEN-1:0] id_pc;
    logic [XLEN-1:0] ex_pc;
    logic [XLEN-1:0] mem_pc;
    logic [XLEN-1:0] wb_pc;
    
    logic print_en;
    
    int file;
    int cycle = 0;
    
    riscv_multicycle core_top_dut(
        .clk_i   (clk     ),
        .rstn_i  (rstn    ),
        .if_pc_o (if_pc   ), 
        .id_pc_o (id_pc   ), 
        .ex_pc_o (ex_pc   ), 
        .mem_pc_o(mem_pc  ),
        .wb_pc_o (wb_pc   )  
    );
    
    always begin
        #1 clk = ~clk;
    end
    
    always@(posedge clk) begin
        if(print_en) begin
            cycle <= cycle + 1;
            $fwrite(file, "| %5d | ", cycle);
            if (if_pc == 32'd0) $fwrite(file, "Flushed   ");
            else                $fwrite(file, $sformatf("0x%8h", if_pc));
            $fwrite(file, " | ");
            if(id_pc == 32'd0) $fwrite(file, "Flushed   ");
            else               $fwrite(file, $sformatf("0x%8h", id_pc));
            $fwrite(file, " | ");
            if(ex_pc == 32'd0) $fwrite(file, "Flushed   ");
            else               $fwrite(file, $sformatf("0x%8h", ex_pc));
            $fwrite(file, " | ");    
            if(mem_pc == 32'd0) $fwrite(file, "Flushed   ");
            else                $fwrite(file, $sformatf("0x%8h", mem_pc));
            $fwrite(file, " | ");
            if(wb_pc == 32'd0) $fwrite(file, "Flushed   ");
            else               $fwrite(file, $sformatf("0x%8h", wb_pc));
            $fwrite(file, " |\n");
        end
    end
    
    initial begin
        file = $fopen("pipe.log", "w");
        
        $fdisplay(file, "| %-4s | %-10s | %-10s | %-10s | %-10s | %-10s |", "Cycle", "F", "D", "E", "M", "WB");
        $fdisplay(file, "|-------|------------|------------|------------|------------|------------|");
        
        rstn     = 1'b0;
        clk      = 1'b0;
        print_en = 1'b0;
        #4
        rstn = 1'b1;
        
        print_en = 1;
    end
    
endmodule
