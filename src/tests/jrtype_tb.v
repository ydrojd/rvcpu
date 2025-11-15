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
	   0: dout <= 32'h00c200e7;	//jalr x1, x4, 12
	   4: dout <= 32'h00310133;	//add x2, x2, x3
	   8: dout <= 32'h002181b3;	//add x3, x3, x2
	   12: dout <= 32'h04000093;	//addi x1, x0, 64
	   16: dout <= 32'h003282b3;	//add x5, x5, x3
	   20: dout <= 32'h000087e7;	//jalr x15, x1, 0
	   default: dout <= 0;
	 endcase;
      end
      end // always @ (posedge clk)
   
   //https://stackoverflow.com/questions/70151532/read-from-file-to-memory-in-verilog
endmodule

module jrtype_tb();
   reg clk = 0;
   
   base_pipeline pipeline(clk);

   initial begin

      $dumpfile("jrtype_tb.vcd");
      $dumpvars(0, jrtype_tb);

      #10;
      for (integer i=0; i <= 31; i = i + 1)
        pipeline.register_file0.data[i] = i;

      #10;

      for (integer i = 0; i < 40; i=i+1) begin
	 clk = 0;
	 #10;
	 clk = 1;
	 #10;
      end

      `verify(pipeline.register_file0.data[3], 8);
      `verify(pipeline.register_file0.data[5], 16);
      $display(pipeline.register_file0.data[1]);
      $finish;
   end
endmodule
