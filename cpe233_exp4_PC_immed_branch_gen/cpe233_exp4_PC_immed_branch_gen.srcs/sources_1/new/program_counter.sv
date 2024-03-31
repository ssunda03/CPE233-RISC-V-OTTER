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


module pc_mod (
    input clk,
    input rst,
    input pcWrite,
    input [31:0] jalr,
    input [31:0] branch,
    input [31:0] jal,
    input [1:0] pcSource,
    output logic [31:0] pc
);

    parameter [1:0] NEXT = 2'b00, JALR = 2'b01, BRANCH = 2'b10, JAL = 2'b11;
    logic [31:0] next_pc;

    always_ff @(posedge clk) begin
        if (rst) pc <= 0;
        else if (pcWrite) pc <= next_pc;
    end

    always_comb begin
        case (pcSource)
            NEXT:       next_pc = pc + 4;
            JALR:       next_pc = jalr;
            BRANCH:     next_pc = branch;
            JAL:        next_pc = jal;
            default:    next_pc = pc;
        endcase
    end
endmodule

module top_level (
    input clk,
    input rst,
    input pcWrite,
    input [1:0] pcSource,
    output logic signed [31:0] s_type_imm,
    output logic signed [31:0] u_type_imm
);

    logic [31:0] pc; // current PC value
    logic [31:0] ir; // instruction from memory

    // IMMED_GEN outputs
    logic signed [31:0] i_imm, b_imm, j_imm;

    // IMMED_GEN block
    always_comb begin
        i_imm       =   { {21{ir[31]}}, ir[30:25], ir[24:20] };
        s_type_imm  =   { {21{ir[31]}}, ir[30:25], ir[11:7] };
        b_imm       =   { {20{ir[31]}}, ir[7], ir[30:25], ir[11:8], 1'b0 };
        u_type_imm  =   { ir[31:12], 12'b0 };
        j_imm       =   { {12{ir[31]}}, ir[19:12], ir[20], ir[30:21], 1'b0 };
    end
    
    // BRANCH_ADDR_GEN inputs
    logic [31:0] pc_prev;
    logic [31:0] rs = 32'h0000_000C;
    
    // BRANCH_ADDR_GEN outputs
    logic [31:0] jal, branch, jalr;

    // BRANCH_ADDR_GEN block
    always_comb begin
        pc_prev =   pc - 4;
        jal     =   pc_prev + j_imm;
        jalr    =   rs + i_imm;
        branch  =   pc_prev + b_imm;
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
    
    Memory MEM1 (
        .MEM_CLK   (clk),
        .MEM_RDEN1 (1'b1),
        .MEM_RDEN2 (1'b0),
        .MEM_WE2   (1'b0),
        .MEM_ADDR1 (pc[15:2]),
        .MEM_ADDR2 (0),
        .MEM_DIN2  (0),
        .MEM_SIZE  (2'b10),
        .MEM_SIGN  (1'b0),
        .IO_IN     (0),
        .MEM_DOUT1 (ir)
    );

endmodule
