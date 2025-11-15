`timescale 1ns / 1ps

module multiplier_pipeline(input wire	     clk,
			   input wire	     stall,
			   
			   input wire [31:0] rs1_value,
			   input wire [31:0] rs2_value,
			   
			   input wire [2:0]  ctrl,
			   input wire [4:0]  rd_addr,
			   input wire	     rd_en,

			   output reg [4:0]  rd_addr_st1,
			   output reg	     rd_en_st1,

			   output reg [4:0]  rd_addr_st2,
			   output reg	     rd_en_st2,

			   output reg [4:0]  rd_addr_st3,
			   output reg	     rd_en_st3,
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
   
   multiplier_block_wrapper multiplier_block_wrapper0(rs1_value, rs2_value, !stall, clk, P);
   
   reg [2:0] ctrl_st1 = 0;
   reg [2:0] ctrl_st2 = 0;
   reg [2:0] ctrl_st3 = 0;

   always @(posedge clk) begin
      if (!stall) begin
	 rd_en_st1 <= rd_en;
	 rd_addr_st1 <= rd_addr;
	 ctrl_st1 <= ctrl;

	 rd_en_st2 <= rd_en_st1;
	 rd_addr_st2 <= rd_addr_st1;
	 ctrl_st2 <= ctrl_st1;

	 rd_en_st3 <= rd_en_st2;
	 rd_addr_st3 <= rd_addr_st2;
	 ctrl_st3 <= ctrl_st2;

	 ans <= ctrl_st2[2] ? P[61:32] : P[31:0];
      end
   end
endmodule
