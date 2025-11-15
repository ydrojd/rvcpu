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
	   0: dout <= 32'h01400093;
	   4: dout <= 32'h00402103;
	   8: dout <= 32'h002081b3;
	   default: dout <= 0;
	 endcase;
      end
   end // always @ (posedge clk)

// .text
// addi x1, x0, 20
// lw x2, 4(x0)
// add x3, x1, x2

endmodule

module mixed_fw_tb();

   reg clk = 0;
   base_pipeline pipeline(clk);

   initial begin
      $dumpfile("mixed_fw_tb.vcd");
      $dumpvars(0, mixed_fw_tb);

      for (integer i=0; i <= 10; i = i + 1)
        pipeline.register_file0.data[i] = i;

      for (integer i=0; i <= 31; i = i + 1)
        pipeline.ram_port0.ram_wrapper0.data[i] = i * 10;

      #10;

      for (integer i = 0; i < 20; i=i+1) begin
	 clk = 0;
	 #10;
	 clk = 1;
	 #10;
      end

      `verify(pipeline.register_file0.data[3], 30);
      `verify(pipeline.register_file0.data[2], 10);
      `verify(pipeline.register_file0.data[1], 20);
   end
endmodule
