`timescale 1ns / 1ps

module instruction_rom_wrapper(input	    clk, 
			       input [31:0] addr,
			       input	    rst,
			       input	    en,
			       output reg [31:0] dout);

   initial dout = 0;
   reg [31:0] data[1023:0];

   always @(posedge clk) begin
      if (rst) begin
	 dout <= 0;
         dout <= data[addr >> 2];
      end else if (en) begin 
      end
   end
   //https://stackoverflow.com/questions/70151532/read-from-file-to-memory-in-verilog
endmodule
