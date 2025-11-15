`timescale 1ns / 1ps
`include "alu_ops.v"
module alu_tb();
   reg clk = 0;
   reg en = 0;
   reg [31:0] a, b;
   reg [7:0]  ctrl;
   wire [31:0] y;
   
   alu alu1(clk, en, a, b, ctrl, y);

   reg [31:0] seed;
   reg [31:0] expected_ans;
   reg signed [31:0] s_expected_ans;
   reg [4:0]	     shift_value;

   reg signed [31:0] s_a;
   reg signed [31:0] s_b;

   initial begin
      seed = 50;
      en = 1;

      ctrl = `ALU_CTRL_ADD; // add
      for (integer i = 0; i < 100; i++) begin
	 a = $random(seed);
	 b = $random(seed);
	 expected_ans = a + b;

	 clk = 0;
	 #10;
	 clk = 1;
	 #10;
	 
	 if (y != expected_ans) begin
	    $display("add failed: ", "y=", y, ", exp_y=", expected_ans);
	 end
      end

      ctrl = `ALU_CTRL_SUB;
      for (integer i = 0; i < 100; i++) begin
	 a = $random(seed);
	 b = $random(seed);
	 expected_ans = a - b;
	 clk = 0;
	 #10;
	 clk = 1;
	 #10;
	 ;
	 if (y != expected_ans) begin
	    $display("sub failed: ", "y=", y, ", exp_y=", expected_ans, ", a=", a, ", b=", b);
	 end
      end

      ctrl = `ALU_CTRL_SUB2;
      for (integer i = 0; i < 100; i++) begin
	 a = $random(seed);
	 b = $random(seed);
	 expected_ans = b - a;
	 clk = 0;
	 #10;
	 clk = 1;
	 #10;
	 ;
	 if (y != expected_ans) begin
	    $display("sub2 failed: ", "y=", y, ", exp_y=", expected_ans, ", a=", a, ", b=", b);
	 end
      end

      ctrl = `ALU_CTRL_AND;
      for (integer i = 0; i < 100; i++) begin
	 a = $random(seed);
	 b = $random(seed);
	 expected_ans = a & b;
	 clk = 0;
	 #10;
	 clk = 1;
	 #10;
	 ;
	 if (y != expected_ans) begin
	    $display("and failed: ", "y=", y, ", exp_y=", expected_ans, ", a=", a, ", b=", b);
	 end
      end

      ctrl = `ALU_CTRL_OR;
      for (integer i = 0; i < 100; i++) begin
	 a = $random(seed);
	 b = $random(seed);
	 expected_ans = a | b;
	 clk = 0;
	 #10;
	 clk = 1;
	 #10;
	 ;
	 if (y != expected_ans) begin
	    $display("or failed: ", "y=", y, ", exp_y=", expected_ans, ", a=", a, ", b=", b);
	 end
      end

      ctrl = `ALU_CTRL_XOR;
      for (integer i = 0; i < 100; i++) begin
	 a = $random(seed);
	 b = $random(seed);
	 expected_ans = a ^ b;
	 clk = 0;
	 #10;
	 clk = 1;
	 #10;
	 ;
	 if (y != expected_ans) begin
	    $display("xor failed: ", "y=", y, ", exp_y=", expected_ans, ", a=", a, ", b=", b);
	 end
      end

      ctrl = `ALU_CTRL_LSFT;
      for (integer i = 0; i < 100; i++) begin
	 a = $random(seed);
	 shift_value = $random(seed);
	 b = shift_value;

	 expected_ans = a << shift_value;
	 clk = 0;
	 #10;
	 clk = 1;
	 #10;
	 ;
	 if (y != expected_ans) begin
	    $display("left shift failed: ", "y=", y, ", exp_y=", expected_ans, ", a=", a, ", b=", b);
	 end
      end

      ctrl = `ALU_CTRL_RSFT;
      for (integer i = 0; i < 100; i++) begin
	 a = $random(seed);
	 shift_value = $random(seed);
	 b = shift_value;

	 expected_ans = a >> shift_value;
	 clk = 0;
	 #10;
	 clk = 1;
	 #10;
	 ;
	 if (y != expected_ans) begin
	    $display("right shift failed: ", "y=", y, ", exp_y=", expected_ans, ", a=", a, ", b=", b);
	 end
      end

      ctrl = `ALU_CTRL_RSFTA;
      for (integer i = 0; i < 100; i++) begin
	 a = $random(seed);
	 shift_value = $random(seed);
	 b = shift_value;
	 
	 expected_ans = a >>> shift_value;
	 clk = 0;
	 #10;
	 clk = 1;
	 #10;

	 if (y != expected_ans) begin
	    $display("right shift arithmatic failed: ", "y=", y, ", exp_y=", expected_ans, ", a=", a, ", b=", b);
	 end
      end

      ctrl = `ALU_CTRL_LESS_SIGN;
      for (integer i = 0; i < 100; i++) begin
	 a = $random(seed); s_a = a;
	 b = $random(seed); s_b = b;
	 s_expected_ans = s_a < s_b;
	 clk = 0;
	 #10;
	 clk = 1;
	 #10;
	 ;
	 if (y != s_expected_ans) begin
	    $display("less signed failed: ", "y=", y, ", exp_y=", s_expected_ans, ", a=", a, ", b=", b);
	 end
      end

      ctrl = `ALU_CTRL_GRTEQ_SIGN;
      for (integer i = 0; i < 100; i++) begin
	 a = $random(seed); s_a = a;
	 b = $random(seed); s_b = b;
	 s_expected_ans = s_a >= s_b;
	 clk = 0;
	 #10;
	 clk = 1;
	 #10;
	 ;
	 if (y != s_expected_ans) begin
	    $display("greater equal signed failed: ", "y=", y, ", exp_y=", s_expected_ans, ", a=", a, ", b=", b);
	 end
      end

      ctrl = `ALU_CTRL_LESS;
      for (integer i = 0; i < 100; i++) begin
	 a = $random(seed);
	 b = $random(seed);
	 expected_ans = a < b;
	 clk = 0;
	 #10;
	 clk = 1;
	 #10;
	 ;
	 if (y != expected_ans) begin
	    $display("less failed: ", "y=", y, ", exp_y=", expected_ans, ", a=", a, ", b=", b);
	 end
      end

      ctrl = `ALU_CTRL_GRTEQ;
      for (integer i = 0; i < 100; i++) begin
	 a = $random(seed);
	 b = $random(seed);
	 expected_ans = a >= b;
	 clk = 0;
	 #10;
	 clk = 1;
	 #10;
	 ;
	 if (y != expected_ans) begin
	    $display("greater equal failed: ", "y=", y, ", exp_y=", expected_ans, ", a=", a, ", b=", b);
	 end
      end

      ctrl = `ALU_CTRL_EQ;
      for (integer i = 0; i < 100; i++) begin
	 a = $random(seed);
	 b = (a[0]) ? a : $random(seed);
	 expected_ans = a == b;
	 clk = 0;
	 #10;
	 clk = 1;
	 #10;
	 ;
	 if (y != expected_ans) begin
	    $display("equal failed: ", "y=", y, ", exp_y=", expected_ans, ", a=", a, ", b=", b);
	 end
      end

      ctrl = `ALU_CTRL_NEQ;
      for (integer i = 0; i < 100; i++) begin
	 a = $random(seed);
	 b = (a[0]) ? a : $random(seed);
	 expected_ans = a != b;
	 clk = 0;
	 #10;
	 clk = 1;
	 #10;
	 ;
	 if (y != expected_ans) begin
	    $display("not equal failed: ", "y=", y, ", exp_y=", expected_ans, ", a=", a, ", b=", b);
	 end
      end // for (integer i = 0; i < 100; i++)

      a = 25;
      b = 26;
      ctrl = `ALU_CTRL_AND;
      clk = 0;
      #10;
      clk = 1;
      #10;
      $display("y:", y);
      
   end 
endmodule
