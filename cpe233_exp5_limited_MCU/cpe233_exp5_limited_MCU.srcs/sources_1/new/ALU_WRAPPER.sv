`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/07/2022 09:09:44 PM
// Design Name: 
// Module Name: ALU_WRAPPER
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


module ALU_WRAPPER(
    input [31:0] rs1,
    input [31:0] rs2,
    input [31:0] u_imm,
    input [31:0] i_imm,
    input [31:0] s_imm,
    input [31:0] pc,
    input alu_srcA,
    input [1:0] alu_srcB,
    input [3:0] alu_fun,
    output logic [31:0] result
    );
    
    logic [31:0] srcA, srcB;
    always_comb begin
        case (alu_srcA)
            0: srcA = rs1;
            1: srcA = u_imm;
        endcase
        
        case (alu_srcB)
            0: srcB = rs2;
            1: srcB = i_imm;
            2: srcB = s_imm;
            3: srcB = pc;
        endcase
    end
    
    ALU my_alu(
        .op1(srcA),
        .op2(srcB),
        .sel(alu_fun),
        .result(result)
    );
    
endmodule
