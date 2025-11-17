`timescale 1ns / 1ps

module cpu(input wire clk,
	   output wire tx);

   wire [31:0] bus_dout;
   wire [31:0] bus_addr;
   wire	       bus_write_valid;
   reg	       bus_write_ready = 1;
   
   base_pipeline base_pipeline0(.clk(clk),
				.bus_dout(bus_dout),
				.bus_addr(bus_addr),
				.bus_write_valid(bus_write_valid),
				.bus_write_ready(bus_write_ready)
				);


   //---bus_write_ready---//
   // target device
   reg is_uart_dev = 0;
   reg tx_valid = 0;
   wire tx_ready;
   always @(*) begin
      is_uart_dev = bus_addr[27:4] == 28'hFF_FFFF;
      tx_valid = is_uart_dev && bus_write_valid;

      bus_write_ready = 1;
      if (tx_valid && !tx_ready) begin
	 bus_write_ready = 0;
      end
   end
   
   uart_dev uart_dev0(.clk(clk),
		      .tx_ready(tx_ready),
		      .tx_valid(tx_valid),
		      .tx_data(bus_dout[7:0]),
		      .tx_o(tx));
endmodule
