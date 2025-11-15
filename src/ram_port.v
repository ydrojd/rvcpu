`timescale 1ns / 1ps

module ram_port #(parameter 		index_width = 10)
   (input	  clk,
     input [31:0]  addr,
     input [31:0]  din,
     output [31:0] dout,
     input en,
     input we);

   ram_wrapper ram_wrapper0(.clk(clk),
			    .addr(addr),
			    .din(din),
			    .we(we),
			    .en(en),
			    .dout(dout));
endmodule
