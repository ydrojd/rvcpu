`timescale 1ns / 1ps

module instruction_fetcher(
			    input	  clk,
			    input	  en,
			    input	  reset,
			    input [31:0]  addr,
			    output [31:0] inst_data);

   instruction_rom_wrapper instruction_rom_wrapper0(.clk(clk),
						    .en(en),
						    .rst(reset),
						    .addr(addr),
						    .dout(inst_data));
endmodule
