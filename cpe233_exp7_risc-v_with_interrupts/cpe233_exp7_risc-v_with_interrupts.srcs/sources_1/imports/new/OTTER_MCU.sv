`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/07/2022 12:00:11 PM
// Design Name: 
// Module Name: OTTER_MCU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module OTTER_MCU(
    input wire RST,
    input wire intr,
    input wire clk,
    input wire [31:0] iobus_in,
    output logic [31:0] iobus_out,
    output logic [31:0] iobus_addr,
    output logic iobus_wr
    );
    
    logic rst, pcWrite;
    logic [2:0] pcSource;
    logic [31:0] jalr, branch, jal, pc;
    
    logic rden1, rden2, we2;
    logic [31:0] ir, dout2;
    
    logic signed [31:0] i_imm, u_imm, s_imm, j_imm, b_imm;
    
    logic [1:0] rf_wr_sel;
    logic regWrite;
    logic [31:0] wd, rs1, rs2, result; 
    
    logic [1:0] alu_srcA;
    logic [2:0] alu_srcB;
    logic [3:0] alu_fun;
    
    
    logic br_eq, br_lt, br_ltu;
    
    logic unmasked_intr, int_taken, mret_exec, csr_we, mie;
    logic [31:0] mepc, mtvec, csr_rd;
    
    assign unmasked_intr = intr & mie;
    assign iobus_addr = result;
    assign iobus_out = rs2;    
    
    PROGRAM_COUNTER_WRAPPER my_pc (
        .clk        (clk),
        .rst        (rst),
        .pcWrite    (pcWrite),
        .jalr       (jalr),
        .branch     (branch),
        .jal        (jal),
        .mtvec      (mtvec),
        .mepc       (mepc),
        .pcSource   (pcSource),
        .pc         (pc)
    );

    Memory OTTER_MEMORY (
        .MEM_CLK   (clk),
        .MEM_RDEN1 (rden1), 
        .MEM_RDEN2 (rden2), 
        .MEM_WE2   (we2),
        .MEM_ADDR1 (pc[15:2]),
        .MEM_ADDR2 (result),
        .MEM_DIN2  (rs2),  
        .MEM_SIZE  (ir[13:12]),
        .MEM_SIGN  (ir[14]),
        .IO_IN     (iobus_in),
        .IO_WR     (iobus_wr),
        .MEM_DOUT1 (ir),
        .MEM_DOUT2 (dout2)
    );
    
    // IMMED_GEN
    always_comb begin
        i_imm  =   { {21{ir[31]}}, ir[30:25], ir[24:20] };
        s_imm  =   { {21{ir[31]}}, ir[30:25], ir[11:7] };
        b_imm  =   { {20{ir[31]}}, ir[7], ir[30:25], ir[11:8], 1'b0 };
        u_imm  =   { ir[31:12], 12'b0 };
        j_imm  =   { {12{ir[31]}}, ir[19:12], ir[20], ir[30:21], 1'b0 };
    end
    
    // BRANCH_ADDR_GEN
    always_comb begin
        jal     =   pc + j_imm;
        jalr    =   rs1 + i_imm;
        branch  =   pc + b_imm;
    end
    
    REG_FILE_WRAPPER my_reg_file_wrapper (
        .clk        (clk),
        .ir         (ir),
        .pc         (pc),
        .csr        (csr_rd),
        .dout2      (dout2),
        .result     (result),
        .rf_wr_sel  (rf_wr_sel),
        .regWrite   (regWrite),
        .rs1        (rs1),
        .rs2        (rs2)
    );
    
    ALU_WRAPPER my_alu_wrapper (
        .rs1        (rs1),
        .rs2        (rs2),
        .u_imm      (u_imm),
        .i_imm      (i_imm),
        .s_imm      (s_imm),
        .pc         (pc),
        .csr_rd     (csr_rd),
        .alu_srcA   (alu_srcA),
        .alu_srcB   (alu_srcB),
        .alu_fun    (alu_fun),
        .result     (result)
    );

    // BRANCH_COND_GEN
    always_comb begin
        br_eq = 0; br_lt = 0; br_ltu = 0;
        if (rs1 == rs2) br_eq = 1;
        if (rs1 < rs2) br_ltu = 1;
        if ($signed(rs1) < $signed(rs2)) br_lt = 1;
    end
    
    CSR  my_csr (
        .CLK        (clk),
        .RST        (rst),
        .MRET_EXEC  (mret_exec),
        .INT_TAKEN  (int_taken),
        .ADDR       (ir[31:20]),
        .PC         (pc),
        .WD         (result),
        .WR_EN      (csr_we), 
        .RD         (csr_rd),
        .CSR_MEPC   (mepc),  
        .CSR_MTVEC  (mtvec), 
        .CSR_MSTATUS_MIE (mie)    ); 
    
    CU_DCDR my_cu_dcdr(
        .br_eq     (br_eq),
        .br_lt     (br_lt),
        .br_ltu    (br_ltu),
        .opcode    (ir[6:0]),
        .func7     (ir[30]),
        .func3     (ir[14:12]),
        .int_taken (int_taken),
        .alu_fun   (alu_fun),
        .pcSource  (pcSource),
        .alu_srcA  (alu_srcA),
        .alu_srcB  (alu_srcB), 
        .rf_wr_sel (rf_wr_sel)
    );
    
    CU_FSM my_fsm(
        .intr     (unmasked_intr),
        .clk      (clk),
        .RST      (RST),
        .opcode   (ir[6:0]),
        .func3    (ir[14:12]),
        .pcWrite  (pcWrite),
        .regWrite (regWrite),
        .memWE2   (we2),
        .memRDEN1 (rden1),
        .memRDEN2 (rden2),
        .reset    (rst),
        .csr_WE   (csr_we),
        .int_taken(int_taken),
        .mret_exec(mret_exec)
    );

endmodule
`default_nettype wire