`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:45:01 07/03/2012 
// Design Name: 
// Module Name:    transmitter 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module transmitter #(
	parameter WIDTH = 8,
	parameter IND = 3
)(
    input TxStart,
    input [WIDTH-1:0] DataIn,
    input clk,
    output reg TxD,
	 input reset,
	 output reg TxReady,
	 output reg TxDone
    );

	//FSM states
	localparam  IDLE = 0;		// Waiting
	localparam  TRANSMIT = 1;	// Transmitting


	//Signal declarations
	//State registers
	reg [1:0] currState;

	reg [IND-1:0] index;

	always @(posedge clk) begin
		if(reset) begin
		currState <= IDLE;
		TxD <= 0;
		index <= 0;
		TxReady <= 0;
		end
		else begin
			case(currState)
				IDLE: begin
					index <= 0;
					TxD <= 0;
					TxDone <=0;
					TxReady <= 0;
					if (TxStart == 1) begin
						 currState <= TRANSMIT;
						 TxReady <= 1;
					end
				end
				TRANSMIT: begin
					TxD <= DataIn[index];
					index <= index + 1;		
					TxReady <= 0;
					if (index == (WIDTH-1)) begin
						TxDone <= 1;
						currState <= IDLE;
					end
				end
			endcase
		end
	end


endmodule
