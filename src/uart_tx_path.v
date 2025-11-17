`timescale 1ns / 1ps

module uart_tx_path
  #( parameter FREQ = 100,
     parameter BAUD = 57600)
   (
     input wire [7:0] uart_tx_data_i,
     input wire	 clk_i,
     input wire	 uart_tx_en_i,

     output wire bussy,
     output wire uart_tx_o);
   
   // parameter [12:0] BAUD_TICKS = 13'd5207;	// 50Mhz/9600 - 1 = 5207
   parameter [15:0] BAUD_TICKS = (( FREQ * 1000 * 1000) / BAUD - 1);	// 50Mhz/9600 - 1 = 5207
   
   reg [8:0]	    tx_o_shift_reg = 9'b111111111;
   reg [15:0]	    baud_counter = 0;
   reg [9:0]	    bussy_shift_reg = 1;
   reg		    uart_tx_o_buff = 1;
   reg		    bussy_reg = 0;
   assign bussy = bussy_reg;

   always @(*) begin
      bussy_reg = !(bussy_shift_reg == 0);
   end
   
   always@(posedge clk_i)
     begin
	if (baud_counter == BAUD_TICKS)
	  begin
	     baud_counter <= 0;
	     tx_o_shift_reg <= {1'b1, tx_o_shift_reg[8:1]};
	     bussy_shift_reg <= {1'b0, bussy_shift_reg[9:1]};
	  end
	else
	  begin
	     baud_counter <= baud_counter + 1'b1;
	  end

	if (uart_tx_en_i && (bussy_shift_reg == 0))
	  begin
	     tx_o_shift_reg <= {uart_tx_data_i[7:0], 1'b0};
	     baud_counter <= 0;
	     bussy_shift_reg[9] <= 1'b1;
	  end

	uart_tx_o_buff <= tx_o_shift_reg[0];
     end // always@ (posedge clk_i)
   assign uart_tx_o = uart_tx_o_buff;
endmodule
