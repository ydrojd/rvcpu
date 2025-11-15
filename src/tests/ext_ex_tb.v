`timescale 1ns / 1ps

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
	   0: dout <= 32'h07800093; //addi x1, x0, 120
	   4: dout <= 32'b0000000_00001_00000_000_00000_1111111; //0010007F
	   default: dout <= 0;
	 endcase;
      end
   end // always @ (posedge clk)
endmodule

module ext_ex_tb();
   reg clk = 0;
   wire	tx;
   
   cpu cpu0(.clk(clk),
	    .tx(tx));

   initial begin
      #10;

      $dumpfile("ext_ex_tb.vcd");
      $dumpvars(0, ext_ex_tb);

      for (integer i = 0; i < 10000; i=i+1) begin
	 clk = 0;
	 #10;
	 clk = 1;
	 #10;
      end

      while(cpu0.uart_dev0.uart_bussy) begin 
	 clk = 0;
	 #10;
	 clk = 1;
	 #10;
      end
      
      for (integer i = 0; i < 5207 * 40; i=i+1) begin
	 clk = 0;
	 #10;
	 clk = 1;
	 #10;
      end
   end
endmodule
