`timescale 1ns / 1ps
`include "alu_ops.v"

`define verify(value, expected) \
begin\
if (value != expected) $display(`"value`", " should be:", expected, ", but is: ", value);\
end

module instruction_rom_wrapper(input clk, 
				input		  en,
				input [31:0]	  addr,
				output reg [31:0] dout);

   initial dout = 0;
   reg [31:0] data[4095:0];

   always @(posedge clk) begin
      if (en) begin
	 case (addr)
	   0: dout <= 32'h00a22e23;
	   4: dout <= 32'h01c22583;
	   8: dout <= 32'h00a580b3;
	   12: dout <= 32'h0040a103;
	   16: dout <= 32'h0020a423;
	   default: dout <= 0;
	 endcase;
      end
   end
   
   //https://stackoverflow.com/questions/70151532/read-from-file-to-memory-in-verilog
endmodule

module mixed_tb();
   reg clk = 0;
   
   cpu cpu0(clk);

   initial begin
      $dumpfile("mixed_tb.vcd");
      $dumpvars(0, mixed_tb);

      #10;
      for (integer i=0; i <= 31; i = i + 1)
        cpu0.register_file0.data[i] = i;

      for (integer i=0; i <= 31; i = i + 1)
        cpu0.data_port0.data[i] = i;

      #10;
      for (integer i = 0; i < 13; i=i+1) begin
	 clk = 0;
	 #10;
	 clk = 1;
	 #10;
      end

      $finish;
   end
endmodule
