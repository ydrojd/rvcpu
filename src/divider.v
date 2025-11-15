`timescale 1ns / 1ps

module divider(input wire	  clk,
	       input wire [31:0]  divisor,
	       input wire [31:0]  dividend,

	       input wire	  in_valid,

	       output wire [1:0]  ctrl,
	       output wire [31:0] y,
	       output wire	  done
	       );

   wire [31:0] quotient;
   wire [31:0] remainder;
   
   reg	       in_ready = 0;
   wire	       div_en = in_valid && in_ready;
   
   always @(posedge clk) begin
      if (div_en) begin 
	 in_ready <= 0;
      end else if (done) begin
	 in_ready <= 1;
      end
   end

   divider_wrapper divider_wrapper0({quotient, remainder}, done, dividend, div_en, divisor, div_en, clk);
   assign y = ctrl[1] ? remainder : quotient;
endmodule
