module riscv_multicycle_tb;
    import riscv_pkg::XLEN;
    import custom_pkg::*;

    logic            clk;
    logic            rstn;
    logic            update;
    logic [XLEN-1:0] addr;
    logic [XLEN-1:0] data;
    logic [XLEN-1:0] pc;
    logic [XLEN-1:0] instr;
    logic [     4:0] reg_addr;
    logic [XLEN-1:0] reg_data;
    logic [XLEN-1:0] mem_addr;
    logic [XLEN-1:0] mem_data;
    
    integer file;
    integer print;

    riscv_multicycle core_top_dut(
        .clk_i     (clk     ),
        .rstn_i    (rstn    ),
        .addr_i    (addr    ),
        .update_o  (update  ),
        .data_o    (data    ),
        .pc_o      (pc      ),
        .instr_o   (instr   ),
        .reg_addr_o(reg_addr),
        .reg_data_o(reg_data),
        .mem_addr_o(mem_addr),
        .mem_data_o(mem_data)
    );
    
    logic [31:0] instr1_pc = 32'd0;
    logic [31:0] instr2_pc = 32'd0;
    logic [31:0] instr3_pc = 32'd0;
    logic [31:0] instr4_pc = 32'd0;
    logic [31:0] instr5_pc = 32'd0;
    
    logic [31:0] instr1_imem = 32'd0;
    logic [31:0] instr2_imem = 32'd0;
    logic [31:0] instr3_imem = 32'd0;
    logic [31:0] instr4_imem = 32'd0;
    logic [31:0] instr5_imem = 32'd0;
    
    logic [ 4:0] instr1_rd = 32'd0;
    logic [ 4:0] instr2_rd = 32'd0;
    logic [ 4:0] instr3_rd = 32'd0;
    logic [ 4:0] instr4_rd = 32'd0;
    logic [ 4:0] instr5_rd = 32'd0;
    
    logic [31:0] instr1_mem_in = 32'd0;
    logic [31:0] instr2_mem_in = 32'd0;
    
    logic [31:0] instr1_alu = 32'd0;
    logic [31:0] instr2_alu = 32'd0;
    logic [31:0] instr3_alu = 32'd0;
    
    logic [31:0] instr1_mem_out = 32'd0;
    logic [31:0] instr2_mem_out = 32'd0;
    
    logic [31:0] instr1_wb = 32'd0;
    
    logic [ 0:0] instr1_bubble = 1'b0;
    logic [ 0:0] instr2_bubble = 1'b0;
    logic [ 0:0] instr3_bubble = 1'b0;
    logic [ 0:0] instr4_bubble = 1'b0;
    logic [ 0:0] instr5_bubble = 1'b0;
    
    always@(posedge clk) begin
        if(rstn) begin
            if(instr5_imem === 32'hXXXX_XXXX) begin
                $fclose(file);
                $finish;
            end
            
            if(core_top_dut.hazard_unit.branch_EX_i) begin
                instr1_bubble <= 1;
                instr2_bubble <= 1;
            end else begin
                instr1_bubble <= 0;
                instr2_bubble <= instr1_bubble;
            end
            instr3_bubble <= instr2_bubble;
            instr4_bubble <= instr3_bubble;
            instr5_bubble <= instr4_bubble;    
            
            instr1_pc <= core_top_dut.fetch.pc_out;
            instr2_pc <= instr1_pc;
            instr3_pc <= instr2_pc;
            instr4_pc <= instr3_pc;
            instr5_pc <= instr4_pc;
            
            instr1_imem <= core_top_dut.fetch.imem_out;
            instr2_imem <= instr1_imem;
            instr3_imem <= instr2_imem;
            instr4_imem <= instr3_imem;
            instr5_imem <= instr4_imem;
            
            instr1_rd <= core_top_dut.fetch.imem_out[11:7];
            instr2_rd <= instr1_rd;
            instr3_rd <= instr2_rd;
            instr4_rd <= instr3_rd;
            instr5_rd <= instr4_rd;
            
            instr1_alu <= core_top_dut.execute.alu_out;
            instr2_alu <= instr1_alu;
            instr3_alu <= instr2_alu;
            
            instr1_mem_in <= core_top_dut.memory.mem_data_i;
            instr2_mem_in <= instr1_mem_in;
            
            instr1_mem_out <= core_top_dut.memory.dmem_out;
            instr2_mem_out <= instr1_mem_out;
            
            instr1_wb <= core_top_dut.writeback.writeback_o;
            
            if(!instr5_bubble && print) begin
                
                if(instr5_imem[6:0] == OP_BRANCH) begin
                   
                    $fwrite(file, "core   0: 3 0x%8h (0x%8h) \n", instr5_pc, instr5_imem);
    
                end else if(instr5_imem[6:0] == OP_STORE) begin
                
                    $fwrite(file, "core   0: 3 0x%8h (0x%8h) mem 0x%8h 0x%8h \n", instr5_pc, instr5_imem, instr3_alu, instr2_mem_in);
                    
                end else if(instr5_imem[6:0] == OP_LOAD) begin
                    
                    if(instr5_rd > 9)
                        $fwrite(file, "core   0: 3 0x%8h (0x%8h) x%0d 0x%8h mem 0x%8h \n", instr5_pc, instr5_imem, instr5_rd, instr2_mem_out, instr3_alu);
                    else if(instr5_rd != 0)
                        $fwrite(file, "core   0: 3 0x%8h (0x%8h) x%0d  0x%8h mem 0x%8h \n", instr5_pc, instr5_imem, instr5_rd, instr2_mem_out, instr3_alu);
                    else
                        $fwrite(file, "core   0: 3 0x%8h (0x%8h)", instr5_pc, instr5_imem);
                        
                end else if(instr5_imem[6:0] == OP_LUI || instr5_imem[6:0] == OP_AUIPC || instr5_imem[6:0] == OP_JAL || instr5_imem[6:0] == OP_JALR) begin
                
                    if(instr5_rd > 9)
                        $fwrite(file, "core   0: 3 0x%8h (0x%8h) x%0d 0x%8h \n", instr5_pc, instr5_imem, instr5_rd, instr1_wb);
                    else if(instr5_rd != 0)
                        $fwrite(file, "core   0: 3 0x%8h (0x%8h) x%0d  0x%8h \n", instr5_pc, instr5_imem, instr5_rd, instr1_wb);
                    else
                        $fwrite(file, "core   0: 3 0x%8h (0x%8h)\n", instr5_pc, instr5_imem);
                        
                end else begin
                
                    if(instr5_rd > 9)
                        $fwrite(file, "core   0: 3 0x%8h (0x%8h) x%0d 0x%8h \n", instr5_pc, instr5_imem, instr5_rd, instr3_alu);
                    else if(instr5_rd != 0)
                        $fwrite(file, "core   0: 3 0x%8h (0x%8h) x%0d  0x%8h \n", instr5_pc, instr5_imem, instr5_rd, instr3_alu);
                    else
                        $fwrite(file, "core   0: 3 0x%8h (0x%8h)\n", instr5_pc, instr5_imem);
                        
                end
            end
        end
    end
    
    always begin
        #1 clk = ~clk;
    end
    
    initial begin
        file = $fopen("output.log", "w");
        $dumpfile("dump.vcd");
        $dumpvars();
        
        repeat(50) $display("");
        
        rstn  = 1'b0;
        clk   = 1'b0;
        print = 1'b0;
        
        repeat(2) @(posedge clk);
        
        rstn = 1'b1;
        
        repeat(4) @(posedge clk);
        
        print = 1'b1;
    end
    
endmodule