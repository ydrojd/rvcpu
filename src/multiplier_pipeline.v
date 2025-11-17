`timescale 1ns / 1ps

module multiplier_pipeline(input wire	     clk,
			   input wire	     stall,
			   input wire	     valid_in,
			   input wire [31:0] rs1_value,
			   input wire [31:0] rs2_value,
			   input wire [2:0]  ctrl,
			   output wire	     valid_out,
			   output reg [31:0] ans
			   );

   // wire signed [17:0] B = rs2_value[17:0];
   wire signed [65:0] P;
   wire signed [32:0] A;
   assign A[32] = ctrl[0] ? rs1_value[31] : 0;
   assign A[31:0] = rs1_value;

   wire signed [32:0] B;
   assign B[32] = ctrl[1] ? rs2_value[31] : 0;
   assign B[31:0] = rs2_value;
   
   // multiplier_block_wrapper multiplier_block_wrapper0(rs1_value, rs2_value, !stall, clk, P);
   multiplier_block_wrapper multiplier_block_wrapper0(A, B, !stall, clk, P);
   
   reg [2:0] ctrl_st1 = 0;
   reg [2:0] ctrl_st2 = 0;
   reg [2:0] ctrl_st3 = 0;

   reg	     valid1 = 0;
   reg	     valid2 = 0;
   reg	     valid3 = 0;
   assign valid_out = valid3;

   always @(posedge clk) begin
      if (!stall) begin
	 ctrl_st1 <= ctrl;
	 ctrl_st2 <= ctrl_st1;
	 ctrl_st3 <= ctrl_st2;

	 valid1 <= valid_in;
	 valid2 <= valid1;
	 valid3 <= valid2;
      end
   end

   always @(*) begin
      ans = ctrl_st3[2] ? P[63:32] : P[31:0];
   end
endmodule
