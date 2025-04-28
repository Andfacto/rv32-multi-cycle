`timescale 1ns / 1ps

module decode
    import riscv_pkg::*;
    import custom_pkg::*;
    (
    input  logic [ 0:0] clk_i,
    input  logic [ 0:0] rstn_i,
    input  hazard_t     hazard_i,
    input  control_t    control_i,
    input  logic [31:0] pc_i,
    input  logic [31:0] pc_plus4_i,
    input  instr_t      imem_i,
    input  logic [ 4:0] addr_rd_i,
    input  logic [31:0] data_wb_i,
    input  logic [31:0] data_ex_i,
    input  logic [31:0] data_alu_mem_i,
    input  logic [31:0] data_dmem_i,
    output logic [ 0:0] branch_EX_o,
    output logic [ 4:0] addr_rs1_ID_o,
    output logic [ 4:0] addr_rs2_ID_o,
    output control_t    control_o,
    output logic [31:0] pc_plus4_o,
    output logic [31:0] source_mux1_o,
    output logic [31:0] source_mux2_o,
    output logic [ 4:0] addr_rd_o,
    output logic [31:0] branch_in2_o,
    output logic [31:0] pc_o
    );
    
    logic [ 0:0] branch_out;
    control_t    control;
    logic [31:0] data_rs1;
    logic [31:0] data_rs2;
    logic [31:0] imm_out;
    logic [31:0] branch_in1;
    logic [31:0] branch_in2;
    logic [31:0] source_mux1;
    logic [31:0] source_mux2;
    
    always_comb begin
        addr_rs1_ID_o = imem_i.rs1;
        addr_rs2_ID_o = imem_i.rs2;
        
        if(imem_i.opcode == OP_LUI)
            source_mux1 = 32'd0;
        else if(control.operand1 == OPERAND_PCIMM)
            source_mux1 = pc_i;
        else
            source_mux1 = branch_in1;
        
        if(control.operand2 == OPERAND_PCIMM)
            source_mux2 = imm_out;
        else
            source_mux2 = branch_in2;
    end
    
    always_comb begin
        case(hazard_i.forward_a)
            DATA_REG    : branch_in1 = data_rs1;
            DATA_ALU    : branch_in1 = data_ex_i;
            DATA_ALU_MEM: branch_in1 = data_alu_mem_i;
            DATA_DMEM   : branch_in1 = data_dmem_i;
            DATA_WB     : branch_in1 = data_wb_i;
            default     : branch_in1 = data_rs1;
        endcase
        case(hazard_i.forward_b)
            DATA_REG    : branch_in2 = data_rs2;
            DATA_ALU    : branch_in2 = data_ex_i;
            DATA_ALU_MEM: branch_in2 = data_alu_mem_i;
            DATA_DMEM   : branch_in2 = data_dmem_i;
            DATA_WB     : branch_in2 = data_wb_i;
            default     : branch_in2 = data_rs2;
        endcase
    end
    
    reg_file reg_file_dut(
        .clk_i     (clk_i            ),
        .rstn_i    (rstn_i           ),
        .write_en_i(control_i.regfile),
        .addr_rs1_i(imem_i.rs1       ),
        .addr_rs2_i(imem_i.rs2       ),
        .addr_rd_i (addr_rd_i        ),
        .data_rd_i (data_wb_i        ),
        .data_rs1_o(data_rs1         ),
        .data_rs2_o(data_rs2         )
    );
    
    imm_gen imm_gen_dut(
        .sel_imm_i  (control.imm_type),
        .instr_i    (imem_i[31:7]    ),
        .imm_o      (imm_out         )
    );
    
    branch_comp branch_comp_dut(
        .branch_type_i(control.branch),
        .data_rs1_i   (branch_in1    ),
        .data_rs2_i   (branch_in2    ),
        .branch_o     (branch_out    )
    );
    
    always_comb begin
        casez({imem_i.funct7, imem_i.rs2, imem_i.funct3, imem_i.opcode})
            LUI    : control = MI_LUI;
            AUIPC  : control = MI_AUIPC;
            JAL    : control = MI_JAL;
            JALR   : control = MI_JALR;
            BEQ    : control = MI_BEQ;
            BNE    : control = MI_BNE;
            BLT    : control = MI_BLT;
            BGE    : control = MI_BGE;
            BLTU   : control = MI_BLTU;
            BGEU   : control = MI_BGEU;
            LB     : control = MI_LB;
            LH     : control = MI_LH;
            LW     : control = MI_LW;
            LBU    : control = MI_LBU;
            LHU    : control = MI_LHU;
            SB     : control = MI_SB;
            SH     : control = MI_SH;
            SW     : control = MI_SW;
            ADDI   : control = MI_ADDI;
            SLTI   : control = MI_SLTI;
            SLTIU  : control = MI_SLTIU;
            XORI   : control = MI_XORI;
            ORI    : control = MI_ORI;
            ANDI   : control = MI_ANDI;
            SLLI   : control = MI_SLLI;
            CTZ    : control = MI_CTZ;
            CLZ    : control = MI_CLZ;
            CPOP   : control = MI_CPOP;
            SRLI   : control = MI_SRLI;
            SRAI   : control = MI_SRAI;
            ADD    : control = MI_ADD;
            SUB    : control = MI_SUB;
            SLL    : control = MI_SLL;
            SLT    : control = MI_SLT;
            SLTU   : control = MI_SLTU;
            XOR    : control = MI_XOR;
            SRL    : control = MI_SRL;
            SRA    : control = MI_SRA;
            OR     : control = MI_OR;
            AND    : control = MI_AND;
            default: control = MI_ADDI;
        endcase
    end
    
    always_ff@(posedge clk_i) begin
        if(!rstn_i) begin
            branch_EX_o   <= 1'd0;
            addr_rd_o     <= 5'd0;
            control_o     <= MI_ADDI;
            source_mux1_o <= 32'd0;
            source_mux2_o <= 32'd0;
            pc_o          <= 32'd0;
            pc_plus4_o    <= 32'd0;
            branch_in2_o  <= 32'd0;
        end else if(hazard_i.flush_ex) begin
            branch_EX_o   <= 1'd0;
            addr_rd_o     <= 5'd0;
            control_o     <= MI_ADDI;
            source_mux1_o <= 32'd0;
            source_mux2_o <= 32'd0;
            pc_o          <= 32'd0;
            pc_plus4_o    <= 32'd0;
            branch_in2_o  <= 32'd0;
        end else begin
            branch_EX_o   <= branch_out;
            control_o     <= control;
            source_mux1_o <= source_mux1;
            source_mux2_o <= source_mux2;
            pc_plus4_o    <= pc_plus4_i;
            pc_o          <= pc_i;
            addr_rd_o     <= imem_i.rd;
            branch_in2_o  <= branch_in2;
        end
    end
        
endmodule
