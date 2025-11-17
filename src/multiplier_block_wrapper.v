`timescale 1ns / 1ps

module multiplier_block_wrapper  (A_0,
				  B_0,
				  CE_0,
				  CLK_0,
				  P_0);
   input [32:0]A_0;
   input [32:0]	B_0;
   input	CE_0;
   input	CLK_0;
   output [65:0] P_0;

   wire [32:0]	 A_0;
   wire [32:0]	 B_0;
   wire		 CE_0;
   wire		 CLK_0;
   wire [65:0]	 P_0;

   reg [65:0] P1 = 0;
   reg [65:0] P2 = 0;
   reg [65:0] P3 = 0;
   assign P_0 = P3;
   
   always @(posedge CLK_0) begin
      if (CE_0) begin
	 P1 <= A_0 * B_0;
	 P2 <= P1;
	 P3 <= P2;
      end
   end

endmodule
