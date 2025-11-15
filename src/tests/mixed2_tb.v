`timescale 1ns / 1ps

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
	   0: dout <= 32'h00210663;
	   4: dout <= 32'h00c000ef;
	   8: dout <= 32'h008000ef;
	   12: dout <= 32'h05000413;
	   16: dout <= 32'h05a00493;
	   default: dout <= 0;
	 endcase;
      end
   end // always @ (posedge clk)

// .text
//     beq x2, x2, next
//     jal x1, another
//     jal x1, another
// next:
// 	addi x8, x0, 80
// another:
//     addi x9, x0, 90 

endmodule

module mixed2_tb();
   reg clk = 0;

   base_pipeline pipeline(clk);

   initial begin
      $dumpfile("mixed2_tb.vcd");
      $dumpvars(0, mixed2_tb);

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

      `verify(pipeline.register_file0.data[8], 80);
      `verify(pipeline.register_file0.data[9], 90);
      
   end
endmodule
