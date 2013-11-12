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
    input wire	[127:0]	config1,
    input wire	[127:0]	config2,

    //Operands and output
    input  wire a,//[31:0] a,
    input  wire b,//[31:0] b,
    output wire c //[31:0] c
    );


//To trigger the addition operation. This is to ensure that operands have reached regs a_0, a_1, b_0, b_1 before the addition process started.
(* KEEP = "TRUE" *) reg trig;   //Analyse again if this is actually needed.

(* KEEP = "TRUE" *)reg a_0, b_0, a_1, b_1;
//(* KEEP = "TRUE" *)reg [31:0] a_0, b_0, a_1, b_1;

always @(posedge clk) begin
    a_0 <= a;
    a_1 <= a;
    b_0 <= b;
    b_1 <= b;
end

(* KEEP = "TRUE" *) wire c_0;//[31:0] c_0;
(* KEEP = "TRUE" *) wire c_1;//[31:0] c_1;

//PDL output NETS
(* KEEP = "TRUE" *) wire out1, out2;

(* KEEP = "TRUE" *) adder_32 adder1(
        .trig(trig),
		.a(a_0),
		.b(b_0),
		.c(c_0)//result
	);

(* KEEP = "TRUE" *) adder_32 adder2(
        .trig(trig),
		.a(a_1),
		.b(b_1),
		.c(c_1)//result
	);


(* KEEP = "TRUE" *) PDL pdl_1(
         .I(c_0),       //Input signal to the PDL module
         .C(config1),   //Control bits for each LUT in the PDL
         .O(out1)        //Output of the PDL line
     );

(* KEEP = "TRUE" *) PDL pdl_2(
         .I(c_1),       //Input signal to the PDL module
         .C(config2),   //Control bits for each LUT in the PDL
         .O(out2)        //Output of the PDL line
     );


(* KEEP = "TRUE" *) DFF_32 d32(
		out1, // Data Input
		out2, // LatchInput
		c        // Q output
	);


endmodule
