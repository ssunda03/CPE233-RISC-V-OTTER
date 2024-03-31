`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/03/2022 12:17:06 PM
// Design Name: 
// Module Name: program_counter
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

module PC_MEM_IMM_ADDR_GEN (
    // PC
    input clk,
    input rst,
    input pcWrite,
    input [1:0] pcSource,
    output logic [31:0] pc,
    
    // MEM
    input [31:0] addr2,
    input [31:0] din2,
    input rden1,
    input rden2,
    input we2,
    input [31:0] iobus_in,
    output iobus_wr,
    output logic [31:0] ir,
    output logic [31:0] dout2,
    
    // IMMED_GEN
    output logic signed [31:0] u_imm,
    output logic signed [31:0] i_imm,
    output logic signed [31:0] s_imm,
    
    // BRANCH_GEN
    input [31:0] rs1
);

    // IMMED_GEN outputs
    logic signed [31:0] b_imm, j_imm;

    // IMMED_GEN block
    always_comb begin
        i_imm  =   { {21{ir[31]}}, ir[30:25], ir[24:20] };
        s_imm  =   { {21{ir[31]}}, ir[30:25], ir[11:7] };
        b_imm  =   { {20{ir[31]}}, ir[7], ir[30:25], ir[11:8], 1'b0 };
        u_imm  =   { ir[31:12], 12'b0 };
        j_imm  =   { {12{ir[31]}}, ir[19:12], ir[20], ir[30:21], 1'b0 };
    end
    
    // BRANCH_ADDR_GEN outputs
    logic [31:0] jal, branch, jalr;

    // BRANCH_ADDR_GEN block
    always_comb begin
        jal     =   pc + j_imm;
        jalr    =   rs1 + i_imm;
        branch  =   pc + b_imm;
    end
    
    pc_mod PC1 (
        .clk      (clk),
        .rst      (rst),
        .pcWrite  (pcWrite),
        .jalr     (jalr),
        .branch   (branch),
        .jal      (jal),
        .pcSource (pcSource),
        .pc       (pc)
    );
    
    Memory OTTER_MEMORY (
        .MEM_CLK   (clk),
        .MEM_RDEN1 (rden1), 
        .MEM_RDEN2 (rden2), 
        .MEM_WE2   (we2),
        .MEM_ADDR1 (pc[15:2]),
        .MEM_ADDR2 (addr2),
        .MEM_DIN2  (din2),  
        .MEM_SIZE  (ir[13:12]),
        .MEM_SIGN  (ir[14]),
        .IO_IN     (iobus_in),
        .IO_WR     (iobus_wr),
        .MEM_DOUT1 (ir),
        .MEM_DOUT2 (dout2)  
    );

endmodule
