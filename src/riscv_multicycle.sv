`timescale 1ns / 1ps

module riscv_multicycle
    import riscv_pkg::*;
    import custom_pkg::*;
    #(
    parameter DMemInitFile = "./dmem.mem",
    parameter IMemInitFile = "./imem.mem"
    )(
    input  logic            clk_i,       // system clock
    input  logic            rstn_i,      // system reset
    output logic [XLEN-1:0] if_pc_o,
    output logic [XLEN-1:0] id_pc_o,
    output logic [XLEN-1:0] ex_pc_o,
    output logic [XLEN-1:0] mem_pc_o,
    output logic [XLEN-1:0] wb_pc_o
    );
    
    //IF signals
    logic [31:0] imem_out;
    
    //ID signals
    logic [ 4:0] addr_rs1_ID;
    logic [ 4:0] addr_rs2_ID;
    logic [31:0] pc_plus4_ID;
    logic [31:0] execute_in1;
    logic [31:0] execute_in2;
    logic [31:0] MEM_in;
    
    //EX signals
    logic [ 0:0] branch_EX;
    logic [ 4:0] addr_rd_EX;
    control_t    control_EX;
    logic [31:0] pc_plus4_EX;
    logic [31:0] execute_out_EX;
    
    //MEM signals
    logic [31:0] execute_out_MEM;
    control_t    control_MEM;
    logic [31:0] pc_plus4_MEM;
    logic [ 4:0] addr_rd_MEM;
    logic [31:0] mem_data_out;
    logic [31:0] dmem_out_MEM;
    
    //WB signals
    control_t    control_WB;
    logic [31:0] execute_out_WB;
    logic [31:0] wb_out;
    logic [31:0] pc_plus4_WB;
    logic [31:0] dmem_out_WB;
    logic [ 4:0] addr_rd_WB;
    
    //hazard signals
    logic [ 9:0] hazard_out;
        
    fetch fetch(
        .clk_i      (clk_i         ),
        .rstn_i     (rstn_i        ),    
        .branch_EX_i(branch_EX     ),
        .execute_i  (execute_out_EX),  
        .hazard_i   (hazard_out    ),
        .pc_o       (id_pc_o       ),
        .pc_if_o    (if_pc_o       ),      
        .pc_plus4_o (pc_plus4_ID   ),
        .imem_o     (imem_out      )       
    );
    
    decode decode(
        .clk_i         (clk_i           ),   
        .rstn_i        (rstn_i          ),     
        .hazard_i      (hazard_out      ),
        .control_i     (control_WB      ),
        .pc_i          (id_pc_o         ),         
        .pc_plus4_i    (pc_plus4_ID     ),   
        .imem_i        (imem_out        ),       
        .addr_rd_i     (addr_rd_WB      ),     
        .data_wb_i     (wb_out          ),    
        .data_ex_i     (execute_out_EX  ),
        .data_alu_mem_i(execute_out_MEM),    
        .data_dmem_i   (dmem_out_MEM    ),
        .branch_EX_o   (branch_EX       ),   
        .addr_rs1_ID_o (addr_rs1_ID     ),
        .addr_rs2_ID_o (addr_rs2_ID     ), 
        .control_o     (control_EX      ),            
        .pc_plus4_o    (pc_plus4_EX     ),   
        .source_mux1_o (execute_in1     ),
        .source_mux2_o (execute_in2     ),
        .addr_rd_o     (addr_rd_EX      ),    
        .branch_in2_o  (MEM_in          ),
        .pc_o          (ex_pc_o         )   
    );
    
    execute execute(
        .clk_i     (clk_i          ),  
        .rstn_i    (rstn_i         ),
        .pc_i      (ex_pc_o        ),       
        .control_i (control_EX     ),  
        .unit_in1_i(execute_in1    ), 
        .unit_in2_i(execute_in2    ),
        .mem_data_i(MEM_in         ),      
        .pc_plus4_i(pc_plus4_EX    ), 
        .addr_rd_i (addr_rd_EX     ),     
        .addr_rd_o (addr_rd_MEM    ),  
        .control_o (control_MEM    ),  
        .pc_plus4_o(pc_plus4_MEM   ),  
        .mem_data_o(mem_data_out   ),    
        .alu_o     (execute_out_MEM),  
        .execute_o (execute_out_EX ),
        .pc_o      (mem_pc_o       )
    );
    
    memory memory(
        .clk_i     (clk_i          ),
        .rstn_i    (rstn_i         ),
        .pc_i      (mem_pc_o       ),
        .control_i (control_MEM    ),
        .pc_plus4_i(pc_plus4_MEM   ),
        .addr_rd_i (addr_rd_MEM    ),
        .alu_i     (execute_out_MEM),
        .mem_data_i(mem_data_out   ),
        .addr_rd_o (addr_rd_WB     ),
        .control_o (control_WB     ),
        .pc_plus4_o(pc_plus4_WB    ),
        .alu_o     (execute_out_WB ),
        .dmem_MEM_o(dmem_out_MEM   ),
        .dmem_WB_o (dmem_out_WB    ),
        .pc_o      (wb_pc_o        )
    );
    
    writeback writeback( 
        .control_i  (control_WB    ),  
        .dmem_i     (dmem_out_WB   ),
        .alu_i      (execute_out_WB),     
        .pc_plus4_i (pc_plus4_WB   ),    
        .writeback_o(wb_out        )
    );
    
    hazard_unit hazard_unit(
        .addr_rs1_ID_i     (addr_rs1_ID         ),
        .addr_rs2_ID_i     (addr_rs2_ID         ),
        .addr_rd_EX_i      (addr_rd_EX          ),
        .addr_rd_MEM_i     (addr_rd_MEM         ),
        .addr_rd_WB_i      (addr_rd_WB          ),
        .branch_EX_i       (branch_EX           ),
        .sel_wb_EX_i       (control_EX.writeback),
        .sel_wb_MEM_i      (control_WB.writeback),
        .reg_write_en_EX_i (control_EX.regfile  ),
        .reg_write_en_MEM_i(control_MEM.regfile ),
        .reg_write_en_WB_i (control_WB.regfile  ),
        .hazard_o          (hazard_out          )
    );

endmodule
