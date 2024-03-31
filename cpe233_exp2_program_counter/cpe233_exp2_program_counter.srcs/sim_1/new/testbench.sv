`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/03/2022 12:56:03 PM
// Design Name: 
// Module Name: testbench
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


module testbench;
    logic clk = 0, reset, pcWrite;
    logic [1:0] pcSource;
    logic [31:0] pc;

    // Allow storing previous pc
    logic [31:0] last_pc;
    // Keep track of test items
    logic [3:0] test_count = 0;
    logic [3:0] test_total = 8;

    // Generate 10MHz clock signal
    initial begin
        forever #5 clk <= ~clk;
    end

    pc_mod PC1 (
        .clk      (clk),
        .reset    (reset),
        .pcWrite  (pcWrite),
        .pcSource (pcSource),
        .pc       (pc)
    );

    // signal list: reset, pcWrite, pcSource
    initial begin
        // RESET TEST
        reset = 1; pcWrite = 0; pcSource = 0;
        #10 test_count++;
        if (pc != 0) begin
            $display("(%d/%d) FAIL: RESET", test_count, test_total);
        end else begin
            $display("(%d/%d) PASS: RESET", test_count, test_total);
        end

        // PC HOLD TEST
        reset = 0; pcWrite = 0; pcSource = 0;
        last_pc = pc;   // Remember previous pc
        #10 test_count++;
        if (pc != last_pc) begin
            $display("(%d/%d) FAIL: PC HOLD", test_count, test_total);
        end else begin
            $display("(%d/%d) PASS: PC HOLD", test_count, test_total);
        end
        
        // PC + 4 TEST
        reset = 0; pcWrite = 1; pcSource = 0;
        for (int i = 0; i < 3; i++) begin
            #10 test_count++;
            if (pc != last_pc + 4) begin
                $display("(%d/%d) FAIL: PC + 4", test_count, test_total);
                $display("        pc = %h, last_pc = %h", pc, last_pc);
            end else begin
                $display("(%d/%d) PASS: PC + 4", test_count, test_total);
            end
            last_pc = pc;
        end

        // JALR TEST
        reset = 0; pcWrite = 1; pcSource = 1;
        #10 test_count++;
        if (pc != 'h0000_4444) begin
            $display("(%d/%d) FAIL: JALR", test_count, test_total);
        end else begin
            $display("(%d/%d) PASS: JALR", test_count, test_total);
        end
        
        // BRANCH TEST
        reset = 0; pcWrite = 1; pcSource = 2;
        #10 test_count++;
        if (pc != 'h0000_8888) begin
            $display("(%d/%d) FAIL: BRANCH", test_count, test_total);
        end else begin
            $display("(%d/%d) PASS: BRANCH", test_count, test_total);
        end

        // JAL TEST
        reset = 0; pcWrite = 1; pcSource = 3;
        #10 test_count++;
        if (pc != 'h0000_CCCC) begin
            $display("(%d/%d) FAIL: JAL", test_count, test_total);
        end else begin
            $display("(%d/%d) PASS: JAL", test_count, test_total);
        end
    end
endmodule
