`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:  Ratner Surf Designs
// Engineer: James Ratner
// 
// Create Date: 01/07/2020 09:12:54 PM
// Design Name: 
// Module Name: top_level
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Control Unit Template/Starter File for RISC-V OTTER
//
//     //- instantiation template 
//     CU_FSM my_fsm(
//        .intr     (xxxx),
//        .clk      (xxxx),
//        .RST      (xxxx),
//        .opcode   (xxxx),   // ir[6:0]
//        .pcWrite  (xxxx),
//        .regWrite (xxxx),
//        .memWE2   (xxxx),
//        .memRDEN1 (xxxx),
//        .memRDEN2 (xxxx),
//        .reset    (xxxx)   );
//   
// Dependencies: 
// 
// Revision:
// Revision 1.00 - File Created - 02-01-2020 (from other people's files)
//          1.01 - (02-08-2020) switched states to enum type
//          1.02 - (02-25-2020) made PS assignment blocking
//                              made rst output asynchronous
//          1.03 - (04-24-2020) added "init" state to FSM
//                              changed rst to reset
//          1.04 - (04-29-2020) removed typos to allow synthesis
//          1.05 - (10-14-2020) fixed instantiation comment (thanks AF)
//          1.06 - (12-10-2020) cleared most outputs, added commentes
// 
//////////////////////////////////////////////////////////////////////////////////

module CU_FSM(
    input intr,
    input clk,
    input RST,
    input [6:0] opcode,
    input [2:0] func3,
    output logic pcWrite,
    output logic regWrite,
    output logic memWE2,
    output logic memRDEN1,
    output logic memRDEN2,
    output logic reset,
    output logic csr_WE,
    output logic int_taken,
    output logic mret_exec
  );
    
    typedef  enum logic [2:0] {
       st_INIT,
	   st_FET,
       st_EX,
       st_WB,
       st_INTR
    }  state_type; 
    state_type  NS,PS; 
      
    //- datatypes for RISC-V opcode types
    typedef enum logic [6:0] {
        LUI    = 7'b0110111,
        AUIPC  = 7'b0010111,
        JAL    = 7'b1101111,
        JALR   = 7'b1100111,
        BRANCH = 7'b1100011,
        LOAD   = 7'b0000011,
        STORE  = 7'b0100011,
        OP_IMM = 7'b0010011,
        OP_RG3 = 7'b0110011,
        SYS    = 7'b1110011
    } opcode_t;
	opcode_t OPCODE;    //- symbolic names for instruction opcodes
     
	assign OPCODE = opcode_t'(opcode); //- Cast input as enum 
	 

	//- state registers (PS)
	always @ (posedge clk)  
        if (RST == 1)
            PS <= st_INIT;
        else
            PS <= NS;

    always_comb
    begin              
        //- schedule all outputs to avoid latch
        pcWrite = 1'b0;    regWrite = 1'b0;    reset = 1'b0;  
		memWE2 = 1'b0;     memRDEN1 = 1'b0;    memRDEN2 = 1'b0;
		csr_WE = 1'b0;     int_taken = 1'b0;   mret_exec = 1'b0;
                   
        case (PS)

            st_INIT: //waiting state  
            begin
                reset = 1;                   
                NS = st_FET; 
            end

            st_FET: //waiting state  
            begin
                memRDEN1 = 1;                
                NS = st_EX; 
            end
              
            st_EX: //decode + execute
            begin
                pcWrite = 1;
                NS = intr ? st_INTR : st_FET;
                
				case (OPCODE)
				    AUIPC: regWrite = 1;
				    
				    LOAD: 
                       begin
                          pcWrite = 0;
                          memRDEN2 = 1;
                          NS = st_WB;
                       end
                    
					STORE: memWE2 = 1;
					
					BRANCH: begin end // default execute control signals
					
					LUI: regWrite = 1;
					
					OP_IMM: regWrite = 1; // addi
					
	                JAL, JALR: regWrite = 1;
	                
					OP_RG3: regWrite = 1;
					
					SYS:
					begin
					   case(func3)
					       3'b001, 3'b011, 3'b010: // CSRRW, CSRRC, CSRRS
					       begin
					           csr_WE = 1;
					           regWrite = 1;
					       end
					       					       
					       3'b000: // MRET
					       begin
					           csr_WE = 0;
					           regWrite = 0;
					           pcWrite = 1;
					           mret_exec = 1;
					       end
					   endcase
					end
                endcase
            end
               
            st_WB:
            begin
               pcWrite = 1;
               regWrite = 1; 
               NS = intr ? st_INTR : st_FET;
            end
            
            st_INTR:
            begin
                int_taken = 1;
                pcWrite = 1;
                NS = st_FET;
            end
            default: NS = st_FET;
           
        endcase //- case statement for FSM states
    end
           
endmodule
