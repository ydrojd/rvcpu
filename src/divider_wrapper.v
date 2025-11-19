`timescale 1 ns / 1 ps

module divider_block_wrapper
  (M_AXIS_DOUT_0_tdata,
   M_AXIS_DOUT_0_tvalid,

   S_AXIS_DIVIDEND_0_tdata,
   S_AXIS_DIVIDEND_0_tvalid,

   S_AXIS_DIVISOR_0_tdata,
   S_AXIS_DIVISOR_0_tvalid,

   aclk_0,
   aclken_0);

   output [63:0]M_AXIS_DOUT_0_tdata;
   output	M_AXIS_DOUT_0_tvalid;

   input [31:0]	S_AXIS_DIVIDEND_0_tdata;
   input	S_AXIS_DIVIDEND_0_tvalid;
   input [31:0]	S_AXIS_DIVISOR_0_tdata;
   input	S_AXIS_DIVISOR_0_tvalid;
   input	aclk_0;
   input	aclken_0;

   wire [63:0]	M_AXIS_DOUT_0_tdata;
   wire		M_AXIS_DOUT_0_tvalid;
   wire [31:0]	S_AXIS_DIVIDEND_0_tdata;
   wire		S_AXIS_DIVIDEND_0_tvalid;
   wire [31:0]	S_AXIS_DIVISOR_0_tdata;
   wire		S_AXIS_DIVISOR_0_tvalid;
   wire		aclk_0;
   wire		aclken_0;

   parameter	LATENCY = 28;

   reg		valid[LATENCY-1:0];
   reg [31:0]	quotient[LATENCY-1:0];
   reg [31:0]	remainder[LATENCY-1:0];

   generate
      for (genvar i = 0; (i + 1) < LATENCY; i=i+1) begin
      always @(posedge aclk_0) begin
	 if (aclken_0) begin 
	       valid[i] <= valid[i + 1];
	       quotient[i] <= quotient[i + 1];
	       remainder[i] <= remainder[i + 1];
	    end
	 end
      end
   endgenerate

   always @(posedge aclk_0) begin
      if (aclken_0) begin
	 valid[LATENCY - 1] <= S_AXIS_DIVIDEND_0_tvalid && S_AXIS_DIVISOR_0_tvalid;
	 quotient[LATENCY - 1] <= S_AXIS_DIVIDEND_0_tdata / S_AXIS_DIVISOR_0_tdata;
	 remainder[LATENCY - 1] <= S_AXIS_DIVIDEND_0_tdata % S_AXIS_DIVISOR_0_tdata;
      end
   end

   assign M_AXIS_DOUT_0_tdata = {quotient[0], remainder[0]};
   assign M_AXIS_DOUT_0_tvalid = valid[0];
endmodule
