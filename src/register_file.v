`timescale 1ns / 1ps

// 1 clock latency
module register_file ( input		 clk,
		       input		 wen,
		      
		       input [4:0]	 rs1_addr,
		       input [4:0]	 rs2_addr,
		       input [4:0]	 rd_addr,
		       input [31:0]	 rd_value,
		       output reg [31:0] rs1_value,
		       output reg [31:0] rs2_value);

   reg [31:0]		    data[31:0];

   always @(posedge clk) begin 
      if (wen == 1)
	data[rd_addr] <= rd_value;
   end

   always @(*) begin
      rs1_value = (rs1_addr == 0) ? 0 : data[rs1_addr];
      rs2_value = (rs2_addr == 0) ? 0 : data[rs2_addr];
      
      if (wen && (rs1_addr == rd_addr)) begin
         rs1_value = rd_value;
      end
      
      if (wen && (rs2_addr == rd_addr)) begin
         rs2_value = rd_value;
      end
   end
endmodule
