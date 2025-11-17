`timescale 1ns / 1ps
`include "alu_ops.v"

`define verify(value, expected) \
begin\
if (value != expected) $display(`"value`", " should be:", expected, ", but is: ", value);\
end

module instruction_rom_wrapper(input		 clk, 
			       input [31:0]	 addr,
			       input		 rst,
			       input		 en,
			       output reg [31:0] dout);

   initial dout = 0;
   reg [31:0] data[4095:0];

   always @(posedge clk) begin
      if (en) begin
	 case (addr)
	   0: dout <= 32'hF0000137;
	   4: dout <= 32'hFF010113;
	   8: dout <= 32'h06100193;
	   12: dout <= 32'h00312023;
	   default: dout <= 0;
	 endcase;
      end
   end
   
   //https://stackoverflow.com/questions/70151532/read-from-file-to-memory-in-verilog
endmodule

module bus_tb();
   reg clk = 0;
   cpu cpu0(clk);
   
   initial begin
      $dumpfile("bus_tb.vcd");
      $dumpvars(0, bus_tb);   
      clk = 0;
      
      #10;
      for (integer i=0; i <= 31; i = i + 1)
        cpu0.base_pipeline0.register_file0.data[i] = i;
      #10;

      for (integer i = 0; i < 10000; i=i+1) begin
	 clk = 0;
	 #10;
	 clk = 1;
	 #10;
      end

      `verify(cpu0.base_pipeline0.register_file0.data[2], 32'heffffff0);

      $finish;
   end
endmodule
