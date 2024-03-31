`timescale 1ns / 1ps

module PROGRAM_COUNTER_WRAPPER (
    input clk,
    input rst,
    input pcWrite,
    input [31:0] jalr,
    input [31:0] branch,
    input [31:0] jal,
    input [1:0] pcSource,
    output logic [31:0] pc = 0
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
        endcase
    end
endmodule