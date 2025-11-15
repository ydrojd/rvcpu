`timescale 1ns / 1ps

module alu(input [31:0]	     a, b,
	   input [7:0]	     ctrl,
	   output reg [31:0] y);
   
   wire			  y_neg_ctrl    = ctrl[7];
   wire [2:0]		  sel_ctr       = ctrl[6:4];

   wire [1:0]		  gated_b_ctrl  = ctrl[3:2];
   wire [1:0]		  gated_a_ctrl  = ctrl[1:0];

   wire [2:0]		  comp_ctrl     = ctrl[2:0];
   wire [1:0]		  shift_op_ctrl = ctrl[1:0];
   
   //---gated input---//
   reg [31:0]		  gated_a;
   reg [31:0]		  gated_b;
   always @(*) begin
      gated_a = (gated_a_ctrl[0]) ? 0 : a;
      gated_a = (gated_a_ctrl[1]) ? ~a : a;

      gated_b = (gated_b_ctrl[0]) ? 0 : b;
      gated_b = (gated_b_ctrl[1]) ? ~b : b;
   end // always @ (*)

   //---bitwse---//
   wire [31:0] and_ans;
   wire [31:0] xor_ans;
   assign and_ans = gated_a & gated_b;
   assign xor_ans = gated_a ^ gated_b;
   
   //---addition---//nnn
   wire [31:0] add_ans;
   assign add_ans = gated_a + gated_b;

   //---shifts---//
   reg [31:0]  shift_ans;
   wire [4:0]  shift_num;
   assign shift_num = b[4:0];
   
   always @(*) begin
      case(shift_op_ctrl)
	0: //none
	  shift_ans = a;
	1: //lsft
	  shift_ans = a << shift_num;
	2: //rsft
	  shift_ans = a >> shift_num;
	3: //rsfta
	  shift_ans = a >>> shift_num;
      endcase
   end // always @ (*)
   
   //---comparison---//
   wire signed [31:0] signed_a;
   wire signed [31:0] signed_b;
   assign signed_a = a;
   assign signed_b = b;
   
   reg comp_ans;
   
   always @(*) begin
      case (comp_ctrl)
        3'b000: comp_ans = (signed_a < signed_b);
        default: comp_ans = (a < b);
      endcase
   end
   
   //---set output---//
   always @(*) begin
	case (sel_ctr)
	  0: //add
	    y = add_ans;
	  1: //and
	    y = and_ans;
	  2: //xor
	    y = xor_ans;
	  4: //shift
	    y = shift_ans;
	  default: //compare (5)
	    y = {31'b0, comp_ans};
	endcase

      if (y_neg_ctrl)
	y = ~y;
   end
endmodule
