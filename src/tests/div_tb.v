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
	   0: dout <=  32'hf0000137;
	   4: dout <=  32'hff010113;
	   8: dout <=  32'h0c400193;
	   12: dout <= 32'h00200213;
	   16: dout <= 32'h0241c1b3;
	   20: dout <= 32'h00312023;
	   default: dout <= 0;
	 endcase;
      end
   end
endmodule

module div_tb();
   reg clk = 0;
   
   base_pipeline base_pipeline0(clk);

   initial begin
      $dumpfile("div_tb.vcd");
      $dumpvars(0, div_tb);

      #10;
      for (integer i=0; i <= 31; i = i + 1)
        base_pipeline0.register_file0.data[i] = i;

      #10;
      for (integer i = 0; i < 100; i=i+1) begin
	 clk = 0;
	 #10;
	 clk = 1;
	 #10;
      end

      `verify(base_pipeline0.register_file0.data[2], 32'heffffff0);
      `verify(base_pipeline0.register_file0.data[3], 98);
      `verify(base_pipeline0.register_file0.data[4], 2);
      
      // `verify(base_pipeline0.register_file0.data[2], 12);
      // `verify(base_pipeline0.register_file0.data[3], 20);
      $finish;
   end
endmodule
