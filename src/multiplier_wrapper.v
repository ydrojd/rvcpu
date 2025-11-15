`timescale 1ns / 1ps

module multiplier_block_wrapper(input wire signed [17:0]  a,
				 input wire signed [17:0]  b,
				 input wire		   ce,
				 input wire		   clk,
				 output wire signed [35:0] y
				);
   reg signed [35:0]  y_1 = 0;
   
   always @(posedge clk) begin
      if (ce) begin
	 y_1 <= a * b;
      end
   end

   assign y = y_1;
endmodule
