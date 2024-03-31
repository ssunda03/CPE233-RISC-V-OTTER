`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/07/2022 09:23:51 PM
// Design Name: 
// Module Name: REG_FILE_WRAPPER
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


module REG_FILE_WRAPPER(
    input clk,
    input [31:0] ir,
    input [31:0] pc,
    input [31:0] csr,
    input [31:0] dout2,
    input [31:0] result,
    input [1:0] rf_wr_sel,
    input regWrite,
    output logic [31:0] rs1,
    output logic [31:0] rs2
    );
    
    logic [31:0] wd;
    
    always_comb begin
        case (rf_wr_sel)
            0: wd = pc + 4;
            1: wd = csr;
            2: wd = dout2;
            3: wd = result;
        endcase
    end
    
    RegFile my_regfile(
        .wd(wd),
        .clk(clk),
        .en(regWrite),
        .adr1(ir[19:15]),
        .adr2(ir[24:20]),
        .wa(ir[11:7]),
        .rs1(rs1),
        .rs2(rs2)
    );
endmodule