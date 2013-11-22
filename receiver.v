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
module receiver #(
	parameter WIDTH = 8,
	parameter IND = 3
)(
    input RxStart,
    output reg [WIDTH-1:0] DataOut,
    input clk,
    input RxD,
	 input reset,
	 output reg RxDone
    );
	 
	//FSM states
	localparam  IDLE = 0;							// Waiting
	localparam  RECEIVE = 1;	// Transmitting


	//Signal declarations
	//State registers
	reg [1:0] currState;
	reg [IND-1:0] index;

	always @(posedge clk) begin
		if(reset) begin
		currState <= IDLE;
		index <= 0;
		RxDone <= 0;
		DataOut <= 0;
		end
		else begin
			case(currState)
				IDLE: begin
					index <= 0;
					RxDone <= 0;
					//DataOut <= 0;
					if (RxStart == 1) begin
						currState <= RECEIVE;
					end
				end
				RECEIVE: begin
					DataOut[index] <= RxD;
					index <= index + 1;
					if (index == (WIDTH-1)) begin
						RxDone <= 1;
						currState <= IDLE;
					end
				end
			endcase
		end
	end


endmodule
