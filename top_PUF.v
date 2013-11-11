`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Praveen Kumar Pendyala
//
// Create Date:    11/11/13
// Design Name:
// Module Name:    top_PUF
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
module top_PUF(
    input wire clk,

    //Configuration bits for PDL
    input wire	[124:0]	config1,
    input wire	[124:0]	config2,

    //Operands and output
    input  wire [31:0] a,
    input  wire [31:0] b,
    output wire [31:0] c
    );

wire [31:0] c_1;
wire [31:0] c_2;

//PDL output NETS
(* KEEP = "TRUE" *) wire out1, out2;


(* KEEP = "TRUE" *) adder_32 adder1(
		.a(a),
		.b(b),
		.c(c_1)//result
	);

(* KEEP = "TRUE" *) adder_32 adder2(
		.a(a),
		.b(b),
		.c(c_2)//result
	);

PDL pdl_1(
         .I(c_1),       //Input signal to the PDL module
         .C(config1),   //Control bits for each LUT in the PDL
         .O(out1)        //Output of the PDL line
     );

PDL pdl_2(
         .I(c_2),       //Input signal to the PDL module
         .C(config2),   //Control bits for each LUT in the PDL
         .O(out2)        //Output of the PDL line
     );

DFF_32 d32(
		c_1, // Data Input
		c_2, // LatchInput
		c        // Q output
	);


endmodule
