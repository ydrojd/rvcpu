`timescale 1ns / 1ps
`include "alu_ops.v"

`define verify(value, expected) \
begin\
if (value != expected) $display(`"value`", " should be:", expected, ", but is: ", value);\
end

module instruction_rom_wrapper(input		 clk, 
			       input [31:0]	 addr,
			       input wire	 rst,
			       input		 en,
			       output reg [31:0] dout);

   initial dout = 0;
   reg [31:0] data[4095:0];

   always @(posedge clk) begin
      if (en) begin
	 case (addr)
	   0: dout <= 32'h023100b3; // mul x1, x2, x3
	   4: dout <= 32'h02418133; // mul x2, x3, x4
	   8: dout <= 32'h025201b3; // mul x3, x4, x5
	   default: dout <= 0;
	 endcase;
      end
   end
endmodule

module mp_tb();
   reg clk = 0;
   
   base_pipeline base_pipeline0(clk);

   initial begin
      $dumpfile("mp_tb.vcd");
      $dumpvars(0, mp_tb);

      #10;
      for (integer i=0; i <= 31; i = i + 1)
        base_pipeline0.register_file0.data[i] = i;

      #10;
      for (integer i = 0; i < 13; i=i+1) begin
	 clk = 0;
	 #10;
	 clk = 1;
	 #10;
      end

      `verify(base_pipeline0.register_file0.data[1], 6);
      `verify(base_pipeline0.register_file0.data[2], 12);
      `verify(base_pipeline0.register_file0.data[3], 20);
      $finish;
   end
endmodule
