
module ram_wrapper #(parameter 		index_width = 10)
		   (input	      clk,
		    input [31:0]      addr,
		    input	      we,
		    input [31:0]      din,
		    input	      en,
		    output reg [31:0] dout);

   reg [31:0]			data [(1 << index_width) - 1:0];
   wire [index_width-1:0]	ram_index = addr[index_width + 1 :2];
   
   always @(posedge clk) begin
      if (en) begin
	 if(we) begin
	    data[ram_index] <= din;
	 end else begin 
	    dout <= data[ram_index];
	 end
      end
   end
endmodule
