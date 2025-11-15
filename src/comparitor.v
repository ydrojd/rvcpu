`timescale 1ns / 1ps

module comparitor(input wire unsigned [31:0] a, b,
		  input wire [2:0]	     ctrl,
		  output reg		     y);
   
   wire signed [31:0] signed_a;
   wire signed [31:0] signed_b;
   assign signed_a = a;
   assign signed_b = b;
   
   //---gated input---//
   always @(*) begin
      case (ctrl)
        3'b000: y = (a == b); // beq
        3'b001: y = (a != b); // bne
        3'b100: y = (signed_a < signed_b); // blt
        3'b101: y = (signed_a >= signed_b); //bge
        3'b110: y = (a < b); //bltu
        3'b111: y = (a >= b); //bgeu
	default: y = (a == b); // beq;
      endcase
   end
endmodule
