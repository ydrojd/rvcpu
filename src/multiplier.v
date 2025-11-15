`timescale 1ns / 1ps

module multiplier(input wire	     clk,
		  input wire [31:0]  a,
		  input wire [31:0]  b,
		  input wire [2:0]   ctrl,
		  output wire [31:0] y
		  );

   reg signed [32:0] mult_a = 0;
   reg signed [32:0] mult_b = 0;
   
   always @(*) begin
      mult_a [31:0] = a;
      mult_a [32] = ctrl[0] ? a[31] : 0;
      mult_b [31:0] = b;
      mult_b [32] = ctrl[1] ? b[31] : 0;
   end

   wire signed [65:0] ans;
   multiplier_block_wrapper multiplier_block_wrapper0(mult_a, mult_b, clk, ans);
   
   assign y = ctrl[2] ? ans[63:32] : ans[31:0];
endmodule
