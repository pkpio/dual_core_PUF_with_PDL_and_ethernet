`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    13:00:19 03/31/2013
// Design Name:
// Module Name:    DLatch
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

module DFF(
    data,// Data Input
    clk, // LatchInput
    q    // Q output
);
//-----------Input Ports---------------
input data, clk;

//-----------Output Ports---------------
output reg q;


//-------------Code Starts Here---------
always @ (posedge clk)
begin
  q <= data;
end

endmodule //End Of Module dlatch_reset


//Old Dlatch code
/*
module dlatch (
data   , // Data Input
en     , // LatchInput
q        // Q output
);
//-----------Input Ports---------------
input data, en;

//-----------Output Ports---------------
output q;

//------------Internal Variables--------
reg q;

//-------------Code Starts Here---------
always @ ( en or data)
if (en) begin
  q <= data;
end

endmodule //End Of Module dlatch_reset

*/
