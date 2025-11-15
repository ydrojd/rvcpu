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
	   0: dout <= 32'h00100113;	 //addi x2, x0, 1
	   4: dout <= 32'h00208663;      //beq x1, x2, c
	   8: dout <= 32'h009403b3;      //add x7, x8, x9
	   12: dout <= 32'h00838333;	 //add x6, x7, x8
	   16: dout <= 32'h007302b3;	 //add x5, x6, x7
	   20: dout <= 32'h00628233;	 //add x4, x5, x6
	   24: dout <= 32'h00b51463;	 //bne x10, x11, end
	   28: dout <= 32'h006281b3;	 //add x3, x5, x6
	   default: dout <= 0;
	 endcase;
      end
      end // always @ (posedge clk)
   
   //https://stackoverflow.com/questions/70151532/read-from-file-to-memory-in-verilog
endmodule

module btype_tb();
   reg clk = 0;
   
   base_pipeline pipeline(clk);

   initial begin

      $dumpfile("btype_tb.vcd");
      $dumpvars(0, btype_tb);

      #10;
      for (integer i=0; i <= 31; i = i + 1)
        pipeline.register_file0.data[i] = i;

      #10;

      for (integer i = 0; i < 20; i=i+1) begin
	 clk = 0;
	 #10;
	 clk = 1;
	 #10;
      end

      `verify(pipeline.register_file0.data[7], 7);
      `verify(pipeline.register_file0.data[6], 6);
      `verify(pipeline.register_file0.data[4], 19);
      `verify(pipeline.register_file0.data[5], 13);
      `verify(pipeline.register_file0.data[3], 3);
      $finish;
   end
endmodule
