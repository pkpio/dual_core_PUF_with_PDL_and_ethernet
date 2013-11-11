//////////////////////////////////////////////////////////////////////////////////
//
// Author 			:	Praveen Kumar Pendyala
// **Modified the code from HW example for SIRC by Ken Eguro
//
// Create Date		:  10/11/13
// Modify Date		:  10/11/13
// Module Name		:  simpleTestModuleOne
// Project Name     :  SIRC_HW
// Target Devices	: 	Xilinx Vertix 5, XUPV5 110T
// Tool versions	: 	13.2 ISE
//
// Description      :   This module is user end code of SIRC. This module listens to data from the PC and uses them to evaluate or calibrate
// dual core PUF. Two parameter are passed through registers, which are operand A and operand B (operands are 32-bit each). Corresponding to
// the output of the sum is a 32-bit number which is evaluated on two cores which gives total 64-bits to deal with. Corresponding to each bit
// in the 64-bits total, there is a 125-bit configuration data to be given to the PDL. A total of 125*64 bits of data of configuration bits is
// sent from PC during the calibration phase.
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
`default_nettype none

//This module demonstrates how a user can read from the parameter register file,
//	read from the input memory buffer, and write to the output memory buffer.
//We also show the basics of how the user's circuit should interact with
// userRunValue and userRunClear.
module simpleTestModuleOne #(
	//************ Input and output block memory parameters
	//The user's circuit communicates with the input and output memories as N-byte chunks
	//This should be some power of 2 >= 1.
	parameter INMEM_BYTE_WIDTH = 1,
	parameter OUTMEM_BYTE_WIDTH = 1,

	//How many N-byte words does the user's circuit use?
	parameter INMEM_ADDRESS_WIDTH = 17,
	parameter OUTMEM_ADDRESS_WIDTH = 13
)(
	input		wire 					clk,
	input		wire 					reset,
																														//A user application can only check the status of the run register and reset it to zero
	input		wire 					userRunValue,																//Read run register value
	output	reg					userRunClear,																//Reset run register

	//Parameter register file connections
	output 	reg															register32CmdReq,					//Parameter register handshaking request signal - assert to perform read or write
	input		wire 															register32CmdAck,					//Parameter register handshaking acknowledgment signal - when the req and ack ar both true fore 1 clock cycle, the request has been accepted
	output 	reg 		[31:0]											register32WriteData,				//Parameter register write data
	output 	reg		[7:0]												register32Address,				//Parameter register address
	output	reg 															register32WriteEn,				//When we put in a request command, are we doing a read or write?
	input 	wire 															register32ReadDataValid,		//After a read request is accepted, this line indicates that the read has returned and that the data is ready
	input 	wire 		[31:0]											register32ReadData,				//Parameter register read data

	//Input memory connections
	output 	reg															inputMemoryReadReq,				//Input memory handshaking request signal - assert to begin a read request
	input		wire 															inputMemoryReadAck,				//Input memory handshaking acknowledgement signal - when the req and ack are both true for 1 clock cycle, the request has been accepted
	output	reg		[(INMEM_ADDRESS_WIDTH - 1):0] 			inputMemoryReadAdd,				//Input memory read address - can be set the same cycle that the req line is asserted
	input 	wire 															inputMemoryReadDataValid,		//After a read request is accepted, this line indicates that the read has returned and that the data is ready
	input		wire 		[((INMEM_BYTE_WIDTH * 8) - 1):0] 		inputMemoryReadData,				//Input memory read data

	//Output memory connections
	output 	reg															outputMemoryWriteReq,			//Output memory handshaking request signal - assert to begin a write request
	input 	wire 															outputMemoryWriteAck,			//Output memory handshaking acknowledgement signal - when the req and ack are both true for 1 clock cycle, the request has been accepted
	output	reg		[(OUTMEM_ADDRESS_WIDTH - 1):0] 			outputMemoryWriteAdd,			//Output memory write address - can be set the same cycle that the req line is asserted
	output	reg		[((OUTMEM_BYTE_WIDTH * 8) - 1):0]		outputMemoryWriteData,			//Output memory write data
	output 	wire 		[(OUTMEM_BYTE_WIDTH - 1):0]				outputMemoryWriteByteMask,		//Allows byte-wise writes when multibyte words are used - each of the OUTMEM_USER_BYTE_WIDTH line can be 0 (do not write byte) or 1 (write byte)

	//8 optional LEDs for visual feedback & debugging
	output	wire 		[7:0]												LED
);
	//FSM states
	localparam  IDLE = 0;							// Waiting
	localparam  READING_IN_PARAMETERS = 1;	// Get values from the reg32 parameters
	localparam  RUN = 2;							// Run (read from input, compute and write to output)

	//Signal declarations
	//State registers
	reg [1:0] currState;

	//Counter
	reg paramCount;

	//Message parameters
	//two 32-bit operators for 32-bit adder
	reg [31:0] opt_a;
	reg [31:0] opt_b;


	// We don't write to the register file and we only write whole bytes to the output memory
	//assign register32WriteData = 32'd0;
	//assign register32WriteEn = 0;
	//assign outputMemoryWriteByteMask = {OUTMEM_BYTE_WIDTH{1'b1}};


	//Variables for execution
	reg [1:0] lastPendingReads;
	wire [1:0] currPendingReads;
	wire [((INMEM_BYTE_WIDTH * 8) - 1):0] inputFifoDataOut;
	wire inputFifoEmpty;
	wire [1:0] inputFifoCount;
	wire fifoRead;
	wire	[(INMEM_ADDRESS_WIDTH - 1):0] nextInputAddress;
	reg inputDone;
	wire [31:0] PUF_result;



	initial begin
		currState = IDLE;
		opt_a = 0;
		opt_b = 0;

		register32WriteEn = 0;

		userRunClear = 0;

		register32WriteData = 0;
		register32Address = 0;

		inputMemoryReadReq = 0;
		inputMemoryReadAdd = 0;

		outputMemoryWriteReq = 0;
		outputMemoryWriteAdd = 0;
		outputMemoryWriteData = 0;

		paramCount = 0;

		lastPendingReads = 0;
		inputDone = 0;
	end

	always @(posedge clk) begin
		if(reset) begin
			currState <= IDLE;
			opt_a <= 0;

			register32WriteEn <= 0;

			userRunClear <= 0;

			register32Address <= 0;

			paramCount <= 0;

			lastPendingReads <= 0;
			inputDone <= 0;
		end
		else begin
			case(currState)
				IDLE: begin
					//Stop trying to clear the userRunRegister
					userRunClear <= 0;


					//Wait till the run register goes high
					if(userRunValue == 1 && userRunClear != 1) begin
						//Start reading from the register file
						currState <= READING_IN_PARAMETERS;
						register32Address <= 0;
						register32CmdReq <= 1;
						paramCount <= 0;
					end
				end
				READING_IN_PARAMETERS: begin
					//We need to read 2 values from the parameter register file.
					//If the register file accepted the read, increment the address
					if(register32CmdAck == 1 && register32CmdReq == 1) begin
						register32Address <= register32Address + 1;
					end

					//If we just accepted a read from address 1, stop requesting reads
					if(register32CmdAck == 1 && register32Address == 8'd1)begin
						register32CmdReq <= 0;
					end


					//If a read came back, shift in the value from the register file
					if(register32ReadDataValid) begin
							/*
							length <= multiplier;
							multiplier <= register32ReadData;
							paramCount <= 1;
							*/
							//we are reading two operators from register file
							opt_a <= opt_b;
							opt_b <= register32ReadData;


							paramCount <= 1;
							//Have we recieved the read for the second register?
							if(paramCount == 1)begin
								//Start requesting input data and execution
								currState <= RUN;
								//address of register to write results back
								register32Address <= 2;
								//enable register write
								register32WriteEn	<= 1;


							end
					end
				end
				RUN: begin

					// first cycle we are updating output registers
					if (register32CmdReq == 0) begin
						//update register
						register32WriteData <= PUF_result;
						//request write
						register32CmdReq <= 1;
					end

					//if we have just written back to register we
					// 1) stop write enable
					// 2) stop requesting write
					// 3) switch current state to IDLE
					// 4) tell the Ethernet controller that we've completed execution

					if (register32CmdAck == 1 && register32CmdReq == 1) begin
						register32WriteEn <= 0;
						register32CmdReq <= 0;
						currState <= IDLE;
						userRunClear <= 1;
					end
				end
			endcase
		end
	end



	top_PUF PUF(
		.a(opt_a),
		.b(opt_b),
		.c(PUF_result)
    );


endmodule
