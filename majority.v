`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:02:13 07/09/2012 
// Design Name: 
// Module Name:    majority 
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
module majority(
    input [2:0] i,
    output o
    );

wire im1;
wire im2;
wire im3;
       
and a1	( im1, i[0], i[1] );
and a2 	( im2, i[1], i[2] );
and a3	( im3, i[2], i[0] );   
or  o1	( o, im1, im2, im3 );
          
endmodule 
