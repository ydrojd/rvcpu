`timescale 1ns / 1ps

module uart_dev(input wire	 clk,
		output wire	 tx_ready,
		input wire	 tx_valid,
		input wire [7:0] tx_data,
		output wire	 tx_o
		);

   reg [7:0] tx_data_buff = 0;
   reg	     tx_data_buff_filled = 0;

   wire	     uart_tx_en;
   wire	     uart_bussy;

   uart_tx_path uart_tx_path0(.clk_i(clk),
			      .uart_tx_data_i(tx_data_buff),
			      .uart_tx_en_i(uart_tx_en),
			      .bussy(uart_bussy),
			      .uart_tx_o(tx_o));

   assign uart_tx_en = tx_data_buff_filled;
   assign tx_ready = (!tx_data_buff_filled || (uart_tx_en && !uart_bussy));

   always @(posedge clk) begin
      if (tx_ready) begin
	 if (tx_valid) begin
	    tx_data_buff <= tx_data;
	    tx_data_buff_filled <= 1;
	 end else begin
	    tx_data_buff_filled <= 0;
	 end
      end
   end
endmodule
