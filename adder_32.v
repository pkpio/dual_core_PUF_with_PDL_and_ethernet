`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:33:20 06/27/2013 
// Design Name: 
// Module Name:    adder_32 
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
module adder_32(
a,
b,
c//result
    );

input [31:0] a;
input [31:0] b;

output wire [31:0] c;
assign c = a + b;

endmodule
