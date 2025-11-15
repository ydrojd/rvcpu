`timescale 1ns / 1ps

module cpu(input wire clk,
	   output wire tx);
   
   wire	ext_ex_en;
   wire [31:0] ext_ex_a;
   wire [31:0] ext_ex_b;
   wire [31:0] ext_ex_c;
   wire [9:0]  ext_ex_operation;
   reg	       ext_ex_bussy = 0;
   reg [31:0]  ext_ex_y = 0; 

   wire [31:0] bus_dout;
   wire [31:0] bus_addr;
   wire	       bus_we;
   wire	       bus_read_en;
   reg [31:0]  bus_din = 0;
   reg	       bus_bussy = 0;
   
   base_pipeline base_pipeline0(.clk(clk),
				.ext_ex_en(ext_ex_en),
				.ext_ex_a(ext_ex_a),
				.ext_ex_b(ext_ex_b),
				.ext_ex_c(ext_ex_c),
				.ext_ex_operation(ext_ex_operation),
				.ext_ex_bussy(ext_ex_bussy),
				.ext_ex_y(ext_ex_y),
				
				.bus_dout(bus_dout),
				.bus_addr(bus_addr),
				.bus_we(bus_we),
				.bus_read_en(bus_read_en),
				.bus_din(bus_din),
				.bus_bussy(bus_bussy)
				);
   
   reg	tx_valid = 0;
   wire tx_ready; 

   uart_dev uart_dev0(.clk(clk),
		      .tx_ready(tx_ready),
		      .tx_valid(tx_valid),
		      .tx_data(ext_ex_b[7:0]),
		      .tx_o(tx));


   wire [31:0] div_ans;
   wire	       div_done;
   reg	       div_valid;
   divider divider0(clk, ext_ex_a, ext_ex_b, div_valid, ext_ex_operation[1:0], div_ans, div_done);
   
   always @(*) begin
      tx_valid = 0;
      ext_ex_bussy = 0;
      ext_ex_y = 0;
      div_valid = 0;
      if (ext_ex_operation[9]) begin
	 case(ext_ex_operation[8:6])
	   1: begin // send tx
	      tx_valid = 1;
	      ext_ex_bussy = !tx_ready;
	   end

	   3: begin // div/rem
	      div_valid = 1;
	      ext_ex_bussy = !div_done;
	      ext_ex_y = div_ans;
	   end

	   default:;
	 endcase;
      end // if (ext_ex_operation[9])
   end // always @ (*)
endmodule
