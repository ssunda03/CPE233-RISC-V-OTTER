`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:   Ratner Surf Designs
// Engineer:  James Ratner
// 
// Create Date: 03/08/2020 02:46:31 PM
// Design Name: 
// Module Name: OTTER_Wrapper
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Otter Wrapper for timer-counter reference design. 
//
// Dependencies: 
// 
// Revision:
// Revision 1.00 - (03-08-2020) first released version; fully tested
// Revision 1.01 - (07-22-2022) fixed a few typos; added comments
//
// Additional Comments: modified/extended version of Exp 5 Otter Wrapper 
//      to include instantiation and connections for timer-counter module
// 
//////////////////////////////////////////////////////////////////////////////////

module OTTER_Wrapper(
   input clk,
   input [4:0] buttons,
   input [15:0] sw,
   output logic [15:0] led,
   output logic [7:0] seg,
   output logic [3:0] an    );
       
   //- INPUT PORT IDS ---------------------------------------------------------
   localparam SWITCHES_PORT_ADDR = 32'h11008000;  // 0x1100_8000
   localparam BUTTONS_PORT_ADDR  = 32'h11008004;  // 0x1100_8004
   
   //- timer-counter input support
   localparam TMR_CNTR_CNT_OUT  = 32'h11008008;   // 0x1100_8004
                 
   //- OUTPUT PORT IDS --------------------------------------------------------
   localparam LEDS_PORT_ADDR     = 32'h1100C000;  // 0x1100_C000 
   localparam SEGS_PORT_ADDR     = 32'h1100C004;  // 0x1100_C004
   localparam ANODES_PORT_ADDR   = 32'h1100C008;  // 0x1100_C008
   
   //- timer-counter output support
   localparam TMR_CNTR_CSR_ADDR     = 32'h1100D000;   // 0x1100_D000
   localparam TMR_CNTR_CNT_IN_ADDR  = 32'h1100D004;   // 0x1100_D004
   	
   //- Signals for connecting OTTER_MCU to OTTER_wrapper 
   logic s_interrupt;
   logic s_reset; 
   logic s_clk = 0;
   
   //- register for dev board output devices ---------------------------------
   logic [7:0]  r_segs;   //  register for segments (cathodes)
   logic [15:0] r_leds;   //  register for LEDs
   logic [3:0]  r_an;     //  register for display enables (anodes)
      
   logic [7:0]  r_tc_csr;    // timer-counter count input
   logic [31:0] r_tc_cnt_in; // timer-counter count input
   
   
   logic [31:0] IOBUS_out;
   logic [31:0] IOBUS_in;
   logic [31:0] IOBUS_addr;
   logic IOBUS_wr;
   
   logic [31:0] s_tc_cnt_out; 
   logic s_tc_intr; 
   
   assign s_interrupt = buttons[4];
   assign s_reset = buttons[3];

   //- Instantiate RISC-V OTTER MCU 
   OTTER_MCU  my_otter(
      .RST         (s_reset),
      .intr        (s_tc_intr),
      .clk         (s_clk),
      .iobus_in    (IOBUS_in),
      .iobus_out   (IOBUS_out), 
      .iobus_addr  (IOBUS_addr), 
      .iobus_wr    (IOBUS_wr)   );
   
   // instantiate the timer-counter module  
   timer_counter #(.n(3))  my_tc (
      .clk        (s_clk), 
      .tc_cnt_in  (r_tc_cnt_in),
      .tc_csr     (r_tc_csr),
      .tc_intr    (s_tc_intr),
      .tc_cnt_out (s_tc_cnt_out)  );

    //- Divide clk by 2 
    always_ff @ (posedge clk)
	    s_clk <= ~s_clk;
  
    //- Drive dev board output devices with registers 
    always_ff @ (posedge s_clk)
    begin
       if (IOBUS_wr == 1)
       begin
          case(IOBUS_addr)
             LEDS_PORT_ADDR:       r_leds <= IOBUS_out[15:0];    
             SEGS_PORT_ADDR:       r_segs <= IOBUS_out[7:0];
             ANODES_PORT_ADDR:     r_an  <= IOBUS_out[3:0];
             TMR_CNTR_CSR_ADDR:    r_tc_csr  <= IOBUS_out[7:0];
             TMR_CNTR_CNT_IN_ADDR: r_tc_cnt_in <= IOBUS_out[31:0]; 
             default:  	r_leds <= 0; 
          endcase
       end
    end
   
    //- MUX to route input devices to I/O Bus
	//-   IOBUS_addr is the select signal to the MUX
	always_comb
    begin
        IOBUS_in=32'b0;
        case(IOBUS_addr)
           SWITCHES_PORT_ADDR: IOBUS_in[15:0] = sw;
           BUTTONS_PORT_ADDR:  IOBUS_in[4:0]  = buttons;
           TMR_CNTR_CNT_OUT:   IOBUS_in[31:0] = s_tc_cnt_out;
           default: IOBUS_in=32'b0;
        endcase
    end
	
	//- assign registered outputs to actual outputs 
	assign led = r_leds; 
	assign seg = r_segs; 
	assign an = r_an; 
	
endmodule


