`timescale 1ns / 1ps

module divider(input wire	  clk,
		input wire	   stall,
		input wire [31:0]  divisor,
		input wire [31:0]  dividend,
		input wire	   in_valid,
		input wire [1:0]   ctrl,
		output wire [31:0] ans,
		output wire out_valid
	       );

   wire [31:0] quotient;
   wire [31:0] remainder;
   
   divider_block_wrapper divider_block_wrapper0({quotient, remainder}, out_valid, dividend, in_valid, divisor, in_valid, clk, !stall);

   parameter	LATENCY = 28;
   reg [1:0]	ctrl_reg[LATENCY-1:0];

   generate
      for (genvar i = 0; (i + 1) < LATENCY; i=i+1) begin
	 always @(posedge clk) begin
	    if (!stall) begin 
	       ctrl_reg[i] <= ctrl_reg[i + 1];
	    end
	 end
      end
   endgenerate

   always @(posedge clk) begin
      if (!stall) begin
	 ctrl_reg[LATENCY - 1] <= ctrl;
      end
   end

   assign ans = ctrl_reg[0][1] ? remainder : quotient;
endmodule
