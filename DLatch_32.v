`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    14:12:23 03/31/2013
// Design Name:
// Module Name:    DLatch_32
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
(* KEEP_HIERARCHY = "TRUE" *)
(* equivalclkt_register_removal="no" *)
(* keep="true" *)

module DFF_32 #(parameter DATA_WIDTH = 32)(
data   , // Data Input
clk     , // LatchInput
q        // Q output
    );
input [DATA_WIDTH-1:0] data, clk;
output [DATA_WIDTH-1:0] q;

DFF d0 (
 data[0],
 clk[0],
 q[0] );
DFF d1 (
 data[1],
 clk[1],
 q[1] );
DFF d2 (
 data[2],
 clk[2],
 q[2] );
DFF d3 (
 data[3],
 clk[3],
 q[3] );
DFF d4 (
 data[4],
 clk[4],
 q[4] );
DFF d5 (
 data[5],
 clk[5],
 q[5] );
DFF d6 (
 data[6],
 clk[6],
 q[6] );
DFF d7 (
 data[7],
 clk[7],
 q[7] );
DFF d8 (
 data[8],
 clk[8],
 q[8] );
DFF d9 (
 data[9],
 clk[9],
 q[9] );
DFF d10 (
 data[10],
 clk[10],
 q[10] );
DFF d11 (
 data[11],
 clk[11],
 q[11] );
DFF d12 (
 data[12],
 clk[12],
 q[12] );
DFF d13 (
 data[13],
 clk[13],
 q[13] );
DFF d14 (
 data[14],
 clk[14],
 q[14] );
DFF d15 (
 data[15],
 clk[15],
 q[15] );
DFF d16 (
 data[16],
 clk[16],
 q[16] );
DFF d17 (
 data[17],
 clk[17],
 q[17] );
DFF d18 (
 data[18],
 clk[18],
 q[18] );
DFF d19 (
 data[19],
 clk[19],
 q[19] );
DFF d20 (
 data[20],
 clk[20],
 q[20] );
DFF d21 (
 data[21],
 clk[21],
 q[21] );
DFF d22 (
 data[22],
 clk[22],
 q[22] );
DFF d23 (
 data[23],
 clk[23],
 q[23] );
DFF d24 (
 data[24],
 clk[24],
 q[24] );
DFF d25 (
 data[25],
 clk[25],
 q[25] );
DFF d26 (
 data[26],
 clk[26],
 q[26] );
DFF d27 (
 data[27],
 clk[27],
 q[27] );
DFF d28 (
 data[28],
 clk[28],
 q[28] );
DFF d29 (
 data[29],
 clk[29],
 q[29] );
DFF d30 (
 data[30],
 clk[30],
 q[30] );
DFF d31 (
 data[31],
 clk[31],
 q[31] );



endmodule


//Old DLAtch_32 code
/*
(* KEEP_HIERARCHY = "TRUE" *)
(* equivalent_register_removal="no" *)
(* keep="true" *)

module dlatch_32 #(parameter DATA_WIDTH = 32)(
data   , // Data Input
en     , // LatchInput
q        // Q output
    );
input [DATA_WIDTH-1:0] data, en;
output [DATA_WIDTH-1:0] q;
dlatch d0 (
 data[0],
 en[0],
 q[0] );
dlatch d1 (
 data[1],
 en[1],
 q[1] );
dlatch d2 (
 data[2],
 en[2],
 q[2] );
dlatch d3 (
 data[3],
 en[3],
 q[3] );
dlatch d4 (
 data[4],
 en[4],
 q[4] );
dlatch d5 (
 data[5],
 en[5],
 q[5] );
dlatch d6 (
 data[6],
 en[6],
 q[6] );
dlatch d7 (
 data[7],
 en[7],
 q[7] );
dlatch d8 (
 data[8],
 en[8],
 q[8] );
dlatch d9 (
 data[9],
 en[9],
 q[9] );
dlatch d10 (
 data[10],
 en[10],
 q[10] );
dlatch d11 (
 data[11],
 en[11],
 q[11] );
dlatch d12 (
 data[12],
 en[12],
 q[12] );
dlatch d13 (
 data[13],
 en[13],
 q[13] );
dlatch d14 (
 data[14],
 en[14],
 q[14] );
dlatch d15 (
 data[15],
 en[15],
 q[15] );
dlatch d16 (
 data[16],
 en[16],
 q[16] );
dlatch d17 (
 data[17],
 en[17],
 q[17] );
dlatch d18 (
 data[18],
 en[18],
 q[18] );
dlatch d19 (
 data[19],
 en[19],
 q[19] );
dlatch d20 (
 data[20],
 en[20],
 q[20] );
dlatch d21 (
 data[21],
 en[21],
 q[21] );
dlatch d22 (
 data[22],
 en[22],
 q[22] );
dlatch d23 (
 data[23],
 en[23],
 q[23] );
dlatch d24 (
 data[24],
 en[24],
 q[24] );
dlatch d25 (
 data[25],
 en[25],
 q[25] );
dlatch d26 (
 data[26],
 en[26],
 q[26] );
dlatch d27 (
 data[27],
 en[27],
 q[27] );
dlatch d28 (
 data[28],
 en[28],
 q[28] );
dlatch d29 (
 data[29],
 en[29],
 q[29] );
dlatch d30 (
 data[30],
 en[30],
 q[30] );
dlatch d31 (
 data[31],
 en[31],
 q[31] );



endmodule
*/
