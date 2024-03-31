`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/21/2022 12:39:44 PM
// Design Name: 
// Module Name: main
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

// finite state machine
module fsm (
    input clk,
    input btn,
    input rco,
    input lsb,
    output reg ld,
    output reg clr,
    output reg we,
    output reg up,
    output reg sel,
    output reg display_RAM
);

    // next state & present state
    reg [1:0] NS, PS;

    // states
    parameter [1:0] cycle = 2'b00, init_fib = 2'b01, write = 2'b10;

    //  REG
    always @(posedge clk) begin
        PS <= NS;
    end

    // NS/OUT DCR
    always @(*) begin
        NS = PS;
        ld = 0;
        clr = 0;
        up = 0;
        we = 0;
        sel = 0;
        display_RAM = 0;

        case (PS)
            cycle: begin
                up = 1;
                display_RAM = 1;

                if (btn) begin
                    clr = 1;
                    NS  = init_fib;
                end
            end

            init_fib: begin
                ld  = 1;
                sel = 1;
                NS  = write;
            end

            write: begin
                ld = 1;
                up = lsb;
                we = lsb;
                if (rco & lsb) NS = cycle;
            end
        endcase
    end

endmodule

// fibonacci generator
module fib (
    input clk,
    input ld,
    input sel,
    input clr,
    output reg [6:0] term1,
    output lsb
);

    reg  [6:0] term2;
    wire [6:0] sum;
    assign lsb = term1[0];


    always @(posedge clk) begin //posedge clr

        // btn
        if (clr) begin
            term1 <= 0;
            term2 <= 0;
        end

        // init_fib
        else if (ld & sel) begin
            term1 <= 0;
            term2 <= 1;
        end  // write
        
        else if (ld) begin
            term1 <= term2;
            term2 <= sum;
        end
    end

    rca_nb #(
        .n(7)
    ) fib_gen (
        .a  (term1),
        .b  (term2),
        .cin(0),
        .sum(sum),
        .co ()
    );

endmodule

module cntr_ram (
    input clk,
    input clr,
    input up,
    input [6:0] data_in,
    input we,
    output [6:0] data_out,
    output rco,
    output [3:0] addr
);

    wire [2:0] count;
    assign addr = count;

    cntr_up_clr_nb #(
        .n(3)
    ) MY_CNTR (
        .clk  (clk),
        .clr  (clr),
        .up   (up),
        .ld   (0),
        .D    (0),
        .count(count),
        .rco  (rco)
    );

    ram_single_port #(
        .n(3),
        .m(7)
    ) my_ram (
        .data_in (data_in),  // m spec
        .addr    (count),    // n spec 
        .we      (we),
        .clk     (clk),
        .data_out(data_out)
    );

endmodule

module main (
    input clk,
    input btn,
    output [3:0] an,
    output [7:0] seg,
    output [3:0] led
);

    wire clk_div, clr, up, we, rco, ld, sel, lsb, display_RAM;
    wire [6:0] data_in, data_out;
    reg [6:0] display;

    // display RAM when cycling only
    always @(*) begin
        if (display_RAM) begin
            display = data_out;
        end else begin
            display = data_in;
        end
    end

    cntr_ram CNTR_RAM (
        .clk(clk_div),
        .clr(clr),
        .up(up),
        .data_in(data_in),
        .we(we),
        .data_out(data_out),
        .rco(rco),
        .addr(led)
    );

    fib FIB (
        .clk(clk_div),
        .ld(ld),
        .sel(sel),
        .clr(clr),
        .term1(data_in),
        .lsb(lsb)
    );

    fsm FSM (
        .clk(clk_div),
        .btn(btn),
        .rco(rco),
        .lsb(lsb),
        .ld(ld),
        .clr(clr),
        .we(we),
        .up(up),
        .sel(sel),
        .display_RAM(display_RAM)
    );

    clk_2n_div_test #(
        .n(25)
    ) MY_DIV (
        .clockin  (clk),
        .fclk_only(0),
        .clockout (clk_div)
    );

    univ_sseg my_univ_sseg (
        .cnt1   (display),
        .cnt2   (0),
        .valid  (1),
        .dp_en  (0),
        .dp_sel (0),
        .mod_sel('b10),
        .sign   (0),
        .clk    (clk),
        .ssegs  (seg),
        .disp_en(an)
    );

endmodule
