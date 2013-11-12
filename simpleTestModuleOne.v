//////////////////////////////////////////////////////////////////////////////////
//
// Author 			:	Praveen Kumar Pendyala
// **Modified the code from HW example for SIRC by Ken Eguro
//
// Create Date		:  10/11/13
// Modify Date		:  11/11/13
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
//NOTE: If the # of memory reads were to be changed (say an increase in the # of LUTs in PDL) then change localparam accordingly.
//
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps
`default_nettype none

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
	input		wire 	clk,
	input		wire 	reset,

	//A user application can only check the status of the run register and reset it to zero
	input		wire 	userRunValue,	//Read run register value
	output		reg		userRunClear,	//Reset run register

	//Parameter register file connections
	output 	reg				register32CmdReq,				//Parameter register handshaking request signal - assert to perform read or write
	input	wire 			register32CmdAck,				//Parameter register handshaking acknowledgment signal - when the req and ack ar both true fore 1 clock cycle, the request has been accepted
	output 	wire 	[31:0]	register32WriteData,			//Parameter register write data
	output 	reg		[7:0]	register32Address,				//Parameter register address
	output	wire 			register32WriteEn,				//When we put in a request command, are we doing a read or write?
	input 	wire 			register32ReadDataValid,		//After a read request is accepted, this line indicates that the read has returned and that the data is ready
	input 	wire 	[31:0]	register32ReadData,				//Parameter register read data

	//Input memory connections
	output 	reg												inputMemoryReadReq,				//Input memory handshaking request signal - assert to begin a read request
	input	wire 											inputMemoryReadAck,				//Input memory handshaking acknowledgement signal - when the req and ack are both true for 1 clock cycle, the request has been accepted
	output	reg		[(INMEM_ADDRESS_WIDTH - 1):0] 			inputMemoryReadAdd,				//Input memory read address - can be set the same cycle that the req line is asserted
	input 	wire 											inputMemoryReadDataValid,		//After a read request is accepted, this line indicates that the read has returned and that the data is ready
	input	wire 	[((INMEM_BYTE_WIDTH * 8) - 1):0] 		inputMemoryReadData,			//Input memory read data

	//Output memory connections
	output 	reg											outputMemoryWriteReq,			//Output memory handshaking request signal - assert to begin a write request
	input 	wire 										outputMemoryWriteAck,			//Output memory handshaking acknowledgement signal - when the req and ack are both true for 1 clock cycle, the request has been accepted
	output	reg		[(OUTMEM_ADDRESS_WIDTH - 1):0] 		outputMemoryWriteAdd,			//Output memory write address - can be set the same cycle that the req line is asserted
	output	reg		[((OUTMEM_BYTE_WIDTH * 8) - 1):0]	outputMemoryWriteData,			//Output memory write data
	output 	wire 	[(OUTMEM_BYTE_WIDTH - 1):0]			outputMemoryWriteByteMask,		//Allows byte-wise writes when multibyte words are used - each of the OUTMEM_USER_BYTE_WIDTH line can be 0 (do not write byte) or 1 (write byte)

	//8 optional LEDs for visual feedback & debugging
	output	reg [7:0]	LED
);
	//FSM states
	localparam  IDLE = 0;					// Waiting
	localparam  READING_IN_PARAMETERS = 1;	// Get operands from the 32-bit parameter registers
	localparam  READ = 2;					// Read configuration for 64 bits. Total read: 64*125 bits
	localparam  WAIT_READ = 3;				// A supporting stage for READ
	localparam  COMPUTE = 4;				// Sending operands to PUF and recording delays
	localparam  WRITE = 5;					// Write back the results to PC

	//READ_LENGTH (# of addresses) to which data has to be read
	//WRITE_LENGTH (# of address) to which data has to written back. Usually this is 32-bit
	//Calculation of READ_LENGTH:
	//Size of each read = 8-bits; # of bits config bits for each bit = 128 (125 but last 3 will be ignored after read) => 8*32 (32 reads for each bits config);
	//So total reads = 16(total # bits) * 32(# reads/bit) = 512. Addressing starts from 0 so length will 511 : Currently using only 8-bits
	localparam READ_LENGTH = 511;
	localparam WRITE_LENGTH = 31;

	//Signal declarations
	//State registers
	reg [2:0] currState;

	//Operands to the adder
	reg [31:0] a;
	reg [31:0] b;

	//32 two-dimensional arrays to hold the configuration values of each bit
	//We only need 125-bits. 128-bit declaration is because we get configuration values from PC
	//in 32-bit registers and so, a multiple of 32 will make it easy to read values by looping
	//reg [127:0]	config_core0 [0:31];
	//reg [127:0]	config_core1 [0:31];
	reg [31:0] test;

	//Outputs register
	wire [31:0] results;
	reg [31:0] resultsReg;

	//Counter
	reg paramCount;
	reg [31:0] rlength;
	reg [31:0] wlength;

	// We don't write to the register file and we only write whole bytes to the output memory
	assign register32WriteData = 32'd0;
	assign register32WriteEn = 0;
	assign outputMemoryWriteByteMask = {OUTMEM_BYTE_WIDTH{1'b1}};

	//Variables for execution
	reg inputDone;
	reg [2:0] regCount;	//For reading in 128 config-bits for a bit in a loop
	reg [7:0] bitCount;	//For looping through bits

	//PUF execution variables
	reg PUFExStart;
	wire PUFExDone;

	reg PUFExDoneReg; // Temporary reg for inital testing. Remove later


	initial begin
		currState = IDLE;
		rlength = READ_LENGTH;
		wlength = WRITE_LENGTH;

		userRunClear = 0;

		register32Address = 0;

		inputMemoryReadReq = 0;
		inputMemoryReadAdd = 0;

		outputMemoryWriteReq = 0;
		outputMemoryWriteAdd = 0;
		outputMemoryWriteData = 0;

		paramCount = 0;

		inputDone = 0;
		bitCount = 0;
	end

	always @(posedge clk) begin
		if(reset) begin
			currState <= IDLE;

			userRunClear <= 0;

			register32Address <= 0;

			inputMemoryReadReq <= 0;
			inputMemoryReadAdd <= 0;

			outputMemoryWriteReq <= 0;
			outputMemoryWriteAdd <= 0;
			outputMemoryWriteData <= 0;

			paramCount <= 0;

			inputDone <= 0;

		end
		else begin
			case(currState)
				IDLE: begin
					//Stop trying to clear the userRunRegister
					userRunClear <= 0;
					inputMemoryReadReq <= 0;
					LED <= 8'b00000000;

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
					//Order of reading is a, b
					if(register32ReadDataValid) begin
							a <= b;
							b <= register32ReadData;
							paramCount <= 1;

							//The above block act as a shift register for operands a and b
							if(paramCount == 1)begin
								//Start requesting input data and execution
								currState <= READ;
								inputMemoryReadReq <= 1;
								inputMemoryReadAdd <= 0;
								outputMemoryWriteAdd <= 0;
								inputDone <= 0;
							end
					end
				end
				READ: begin
					//Read for length of length obtained from params
					if(inputDone == 0) begin
						inputMemoryReadReq <= 1;
					end
					else begin
						inputMemoryReadReq <= 0;
					end

					//If the input memory accepted the last read, we can increment the address
					if(inputMemoryReadReq == 1 && inputMemoryReadAck == 1 && inputMemoryReadAdd != rlength[(INMEM_ADDRESS_WIDTH - 1):0])begin
						inputMemoryReadAdd <= inputMemoryReadAdd + 1;
						currState <= WAIT_READ;
					end
					else if(inputMemoryReadReq == 1 && inputMemoryReadAck == 1 && inputMemoryReadAdd == rlength[(INMEM_ADDRESS_WIDTH - 1):0])begin
						inputDone <= 1;
						LED[0] <= 1;
						currState <= WAIT_READ;
					end
				end

				WAIT_READ: begin
					if (inputMemoryReadDataValid == 1) begin

						//Change core after reading for 32 bits in core0
						if(bitCount <= 3) begin
							/*
							config_core0[bitCount][127:96] <= inputMemoryReadData;
							config_core0[bitCount][95:64]	<= config_core0[bitCount][127:96];
							config_core0[bitCount][63:32]	<= config_core0[bitCount][95:64];
							config_core0[bitCount][31:0]	<= config_core0[bitCount][63:32];

							//Change bit after every 4 reads
							if(regCount == 3) begin
								regCount  <= 0;
								bitCount <= bitCount+1;
							end
							else begin
								regCount <= regCount+1;
							end
							*/
							test[7:0] <= inputMemoryReadData;
							bitCount <= bitCount+1;

							currState <= READ;
						end
						/*
						else if(bitCount <= 63) begin
							//An offset for bitCount is needed as we are not resetting it after reading for core0
							/*
							config_core1[bitCount-32][127:96] <= inputMemoryReadData;
							config_core1[bitCount-32][95:64]	<= config_core1[bitCount-32][127:96];
							config_core1[bitCount-32][63:32]	<= config_core1[bitCount-32][95:64];
							config_core1[bitCount-32][31:0]	<= config_core1[bitCount-32][63:32];

							//Change bit after every 4 reads
							if(regCount == 3) begin
								regCount  <= 0;
								bitCount <= bitCount+1;
							end
							else begin
								regCount <= regCount+1;
							end


							test <= inputMemoryReadData;
							bitCount <= bitCount+1;

							currState <= READ;
						end
						*/

						else begin
							currState <= COMPUTE;
							regCount <= 0;
							bitCount <= 0;
						end
					end
				end

				COMPUTE: begin
					PUFExStart <= 1;
					PUFExDoneReg <= 1;
					if(PUFExDoneReg == 1) begin
						currState <= WRITE;
						outputMemoryWriteAdd <= 0;
						resultsReg <= results;
					end

				end

				WRITE: begin
					outputMemoryWriteReq <= 1;

					if(outputMemoryWriteAdd <= 3) begin
						//resultsReg[16:23] <= resultsReg[24:31];
						//resultsReg[8:15] <= resultsReg[16:23];
						//resultsReg[0:7] <= resultsReg[8:15];
						outputMemoryWriteData <= resultsReg[7:0];

					end

					//If we just wrote a value to the output memory this cycle, increment the address
					//NOTE : Due to bug described above we write on bit more by using length instead of lengthMinus1 (Needed here ?)
					if(outputMemoryWriteReq == 1  && outputMemoryWriteAck == 1 && outputMemoryWriteAdd != wlength[(OUTMEM_ADDRESS_WIDTH - 1):0]) begin
						outputMemoryWriteAdd <= outputMemoryWriteAdd + 1;
						currState <= WRITE;
					end

					//Stop writing and go back to IDLE state if writing reached length of data
					if(outputMemoryWriteReq == 1  && outputMemoryWriteAck == 1 && outputMemoryWriteAdd == wlength[(OUTMEM_ADDRESS_WIDTH - 1):0]) begin
						outputMemoryWriteReq <= 0;
						currState <= IDLE;
						userRunClear <= 1;
					end
				end

			endcase
		end
   end


   //PUF module
	top_PUF PUF(
		.clk(clk),
		.a(a),
		.b(b),
		.c(results),
		.config1(test),		//config_core0[0]),	//For testing just one bit's config data is used
		.config2(test)		//config_core1[0])	//For testing just one bit's config data is used
    );

endmodule
