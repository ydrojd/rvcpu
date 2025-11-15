`timescale 1ns / 1ps

module multiplier_block_wrapper  (A_0,
				  B_0,
				  CE_0,
				  CLK_0,
				  P_0);
   input [31:0]A_0;
   input [31:0]	B_0;
   input	CE_0;
   input	CLK_0;
   output [31:0] P_0;

   wire [31:0]	 A_0;
   wire [31:0]	 B_0;
   wire		 CE_0;
   wire		 CLK_0;
   wire [31:0]	 P_0;

   reg [31:0]	 P_0_reg = 0;
   assign P_0 = P_0_reg;

   always @(posedge CLK_0) begin
      if (CE_0)
	P_0_reg <= A_0 * B_0;
   end

endmodule
