`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:33:47 07/03/2012 
// Design Name: 
// Module Name:    serialCommInterface 
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
module system(
   input clk,
	//input clk_n,
   //input clk_p,
	input reset,
	input a,
	input b,
	//input RxStart,
	//input RxD,
	//output TxStart,
	//output TxD
	//output reg [15:0] led
	output reg [7:0] led
    );
	 
	 
	parameter INMEM_BYTE_WIDTH = 16;
	parameter OUTMEM_BYTE_WIDTH = 2;
	wire mp_done;
	wire flag5;
	wire data_ready1;
	wire [((INMEM_BYTE_WIDTH * 8) - 1):0] mapping_dataIn;
	wire [((OUTMEM_BYTE_WIDTH * 8) - 1):0] mapping_dataOut;
	//wire clk;
	
	/*
	wire RxStart;
	wire RxD;
	wire TxStart;
	wire TxD;
	*/

	(* KEEP = "TRUE" *) reg [((INMEM_BYTE_WIDTH * 8) - 1):0] dataInReg = 128'hFFFF0000;
	(* KEEP = "TRUE" *) reg data_readyReg;
	
	assign mapping_dataIn = dataInReg;
	assign data_ready1 = data_readyReg;

//	IBUFGDS #(
//	.DIFF_TERM("FALSE"), // Differential Termination
//	.IOSTANDARD("LVDS_25") // Specify the input I/O standard
//	) IBUFGDS_inst (
//	.O(clk), // Clock buffer output
//	.I(clk_n), // Diff_p clock buffer input (connect directly to top-level port)
//	.IB(clk_p) // Diff_n clock buffer input (connect directly to top-level port)
//	);
	
	//receiver #(.WIDTH(INMEM_BYTE_WIDTH * 8),.IND(7)) rx_xup1 (.RxStart(RxStart),.DataOut(mapping_dataIn),.clk(clk),.RxD(RxD),.reset(reset),.RxDone(data_ready1));		
	mapping #(.IN_WIDTH(INMEM_BYTE_WIDTH * 8),.OUT_WIDTH(OUTMEM_BYTE_WIDTH * 8)) mp (.clk(clk),.reset(reset),.trigger(data_ready1),.dataIn(mapping_dataIn),.done(mp_done),.dataOut(mapping_dataOut),.flag(flag5));	
   //transmitter  #(.WIDTH(OUTMEM_BYTE_WIDTH * 8),.IND(4)) tx_xup1 (.TxStart(mp_done),.DataIn(mapping_dataOut),.clk(clk),.TxD(TxD),.reset(reset),.TxReady(TxStart),.TxDone(flag5));	


	/*
	reg [9:0] count;  

	always@(posedge clk) 
	begin
		count <= count+1 ; 
		if (count == 0)
			begin  
				led <= led + 1;
			end 
	end
	*/
	
	reg [9:0] count;
	reg [6:0] dCount = 0;
	always@(posedge clk) begin
		dCount <= dCount+1;
		
		if(count <= 63) begin
			dataInReg[dCount] <= a;
		end
		
		if(count <= 127) begin
			dataInReg[dCount] <= b;
		end
	
		if(count < 3) begin
			count <= count+1; 
		end
		
		if (count == 3) begin
			data_readyReg <= 1;
			count <= count+1; 
		end
		
		if (count == 4) begin
			data_readyReg <= 0;
			//count <= count+1; 
		end
		
		if (mp_done) begin
			led <= mapping_dataOut[7:0];
		end
		
		
	end

endmodule
