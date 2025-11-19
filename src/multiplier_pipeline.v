`timescale 1ns / 1ps

module multiplier_pipeline(input wire	     clk,
			   input wire	     stall,
			   input wire [31:0] rs1_value,
			   input wire [31:0] rs2_value,
			   input wire [2:0]  ctrl,
			   output reg [31:0] ans
			   );

   wire signed [65:0] P;
   wire signed [32:0] A;
   assign A[32] = ctrl[0] ? rs1_value[31] : 0;
   assign A[31:0] = rs1_value;

   wire signed [32:0] B;
   assign B[32] = ctrl[1] ? rs2_value[31] : 0;
   assign B[31:0] = rs2_value;
   
   multiplier_block_wrapper multiplier_block_wrapper0(A, B, !stall, clk, P);
   
   reg [2:0] ctrl_st1 = 0;
   reg [2:0] ctrl_st2 = 0;

   always @(posedge clk) begin
      if (!stall) begin
	 ctrl_st1 <= ctrl;
	 ctrl_st2 <= ctrl_st1;
      end
   end

   always @(*) begin
      ans = ctrl_st2[2] ? P[63:32] : P[31:0];
   end
endmodule
