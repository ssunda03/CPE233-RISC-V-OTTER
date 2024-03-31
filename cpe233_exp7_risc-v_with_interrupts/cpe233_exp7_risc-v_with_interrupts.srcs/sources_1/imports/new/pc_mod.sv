`timescale 1ns / 1ps

module PROGRAM_COUNTER_WRAPPER (
    input clk,
    input rst,
    input pcWrite,
    input [31:0] jalr,
    input [31:0] branch,
    input [31:0] jal,
    input [31:0] mtvec,
    input [31:0] mepc,
    input [2:0] pcSource,
    output logic [31:0] pc = 0
);

    parameter [2:0] NEXT = 3'b000,
                    JALR = 3'b001,
                    BRANCH = 3'b010,
                    JAL = 3'b011,
                    INTR = 3'b100,
                    MRET = 3'b101;
                    
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
            INTR:       next_pc = mtvec;
            MRET:       next_pc = mepc;
            default:    next_pc = 'hDEADBEEF;
        endcase
    end
endmodule