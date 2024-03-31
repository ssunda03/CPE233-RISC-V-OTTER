`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:  CPE 233
// Engineer: Srinivas Sundararaman, Alex Liu
// 
// Create Date: 10/12/2022 12:52:05 PM
// Design Name: Top-Level ALU
// Module Name: ALU
// Project Name: RISC-V
// Target Devices: Basys3
// Tool Versions: Check documentation.
// Description: Arithmetic Logic Unit for RISC-V MCU
// 
// Dependencies: StackOverflow
// 
// Revision: 1
// Revision 0.01 - File Created
// Additional Comments: DEAD. BEEF.
// 
//////////////////////////////////////////////////////////////////////////////////


module alu(
    input [31:0] op1,
    input [31:0] op2,
    input [3:0] sel,
    output logic [31:0] result
    );
    
    parameter o_add  = 'b0000,
              o_sub  = 'b1000,
              o_or   = 'b0110,
              o_and  = 'b0111,
              o_xor  = 'b0100,
              o_srl  = 'b0101,
              o_sll  = 'b0001,
              o_sra  = 'b1101,
              o_slt  = 'b0010,
              o_sltu = 'b0011,
              o_lui  = 'b1001;
    
    always_comb begin        
        case (sel)
            o_add:  result = op1 + op2;
            o_sub:  result = op1 - op2;
            o_or:   result = op1 | op2;
            o_and:  result = op1 & op2;
            o_xor:  result = op1 ^ op2;
            o_srl:  result = op1 >> op2[4:0];
            o_sll:  result = op1 << op2[4:0];
            o_sra:  result = $signed(op1) >>> op2[4:0];
            o_slt:  result = $signed(op1) < $signed(op2);
            o_sltu: result = op1 < op2;
            o_lui:  result = op1;
            
            default: result = 'hDEADBEEF;
        endcase
    end
endmodule
