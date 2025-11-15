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
      if (rst) begin
	 dout <= 0;
      end else if (en) begin
	 case (addr)
	   0: dout <= 32'h00000013;     //nop
	   4: dout <= 32'h008000ef;     //jal x1, 8
	   8: dout <= 32'h00a00113;	//addi x2, x0, 10
	   12: dout <= 32'h01400193;	//addi x3, x0, 20
	   default: dout <= 0;
	 endcase;
      end
   end // always @ (posedge clk)
   
   //https://stackoverflow.com/questions/70151532/read-from-file-to-memory-in-verilog
endmodule

module jtype_tb();
   reg clk = 0;
   
   base_pipeline pipeline(clk);

   initial begin
      $dumpfile("jtype_tb.vcd");
      $dumpvars(0, jtype_tb);

      #10;
      for (integer i=0; i <= 10; i = i + 1)
        pipeline.register_file0.data[i] = i;

      #10;

      for (integer i = 0; i < 15; i=i+1) begin
	 clk = 0;
	 #10;
	 clk = 1;
	 #10;
      end

      `verify(pipeline.register_file0.data[1], 8);
      `verify(pipeline.register_file0.data[2], 2);
      `verify(pipeline.register_file0.data[3], 20);
      $finish;
   end
endmodule
