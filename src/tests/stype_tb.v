`timescale 1ns / 1ps
`include "alu_ops.v"

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
      if (en) begin
	 case (addr)
	   0: dout <= 32'h01002223; //sw x16, 4(x0)
	   4: dout <= 32'hfeaa2e23; //sw x10, -4(x20)
	   default: dout <= 0;
	 endcase;
      end
   end
   
   //https://stackoverflow.com/questions/70151532/read-from-file-to-memory-in-verilog
endmodule

module stype_tb();
   reg clk = 0;
   
   base_pipeline pipeline(clk);

   typedef struct packed {
      logic [4:0]	rs1;
      logic [4:0]	rs2;
      logic [31:0]	rs1_value;
      logic [31:0]	rs2_value;
      logic [31:0]	immediate_value;
      logic [31:0]	instruction;
   } inst;

   inst [1:0] insts;

   integer num_instructions = 2;
   initial begin
      #10;
      
      for (integer i=0; i <= 31; i = i + 1)
        pipeline.register_file0.data[i] = i;
      #10;
      
      insts[0] = '{5'd0, 5'd16, 5'd0, 5'd16, 32'b0100, 32'h01002223}; //sw x16, 4(x0)
      insts[1] = '{5'd20, 5'd10, 5'd20, 5'd10, -32'd4, 32'hfeaa2e23}; //sw x10, -4(x20)

      for (integer i = 0; i < (5 + num_instructions); i=i+1) begin
	 `verify(pipeline.inst_addr_fetch, i * 4);

	 clk = 0;
	 #10;
	 clk = 1;
	 #10;

	 //---fetch stage---//
	 if ((i >= 0) && (i < num_instructions)) begin
	    `verify(pipeline.instruction_dec, insts[i].instruction);
	    $display("");
	    $display("fetch cycle = %d, inst = %d", i, i);
	 end

	 //---decode stage---//
	 if (i >= 1 && (i < (num_instructions + 1))) begin
	    $display("");
	    $display("decode cycle = %d, inst = %d", i, i - 1);
	    `verify(pipeline.rs1_en_ex, 1);
	    `verify(pipeline.rs2_en_ex, 1);
	    `verify(pipeline.rd_en_ex, 0);

	    `verify(pipeline.b_is_immediate_ex, 1);
	    `verify(pipeline.rd_is_ram_dout_ex, 0);
	    `verify(pipeline.ram_we_ex, 1);

	    `verify(pipeline.rs1_addr_ex, insts[i - 1].rs1);
	    `verify(pipeline.rs2_addr_ex, insts[i - 1].rs2);

	    `verify(pipeline.rs1_value_ex, insts[i - 1].rs1_value);
	    `verify(pipeline.rs2_value_ex, insts[i - 1].rs2_value);
	    `verify(pipeline.immediate_value_ex, insts[i - 1].immediate_value);

	    `verify(pipeline.ex_operation_ex, `ALU_CTRL_ADD);
	    `verify(pipeline.a_value_ex, insts[i - 1].rs1_value);
	    `verify(pipeline.b_value_ex, insts[i - 1].immediate_value);
	 end

	 //---execute stage---//
	 if (i >= 2 && (i < (num_instructions + 2))) begin
	    $display("");
	    $display("execute cycle = %d, inst = %d", i, i - 2);
	    `verify(pipeline.ex_stall, 0);
	    `verify(pipeline.rs2_en_stl, 1);
	    `verify(pipeline.rd_en_stl, 0);
	    `verify(pipeline.rd_is_ram_dout_stl, 0);
	    `verify(pipeline.ram_we_stl, 1);

	    `verify(pipeline.rs2_addr_stl, insts[i - 2].rs2);
	    `verify(pipeline.rs2_value_stl, insts[i - 2].rs2_value);

	    `verify(pipeline.alu_y_stl, (insts[i - 2].immediate_value + insts[i - 2].rs1_value));
	    `verify(pipeline.ram_din_stl, insts[i - 2].rs2_value);
	 end

	 //---store and load stage---//
	 if (i >= 3 && (i < (num_instructions + 3))) begin
	    $display("");
	    $display("store and load cycle = %d, inst = %d", i, i - 3);
	    `verify(pipeline.rd_en_wb, 0);
	    `verify(pipeline.rd_is_ram_dout_wb, 0);
	    `verify(pipeline.ram_port0.ram_wrapper0.data[(insts[i - 3].immediate_value + insts[i - 3].rs1_value) >> 2], insts[i - 3].rs2_value);
	 end

	 //---write back stage---//
	 if (i >= 4 && (i < (num_instructions + 4))) begin
	    $display("");
	    $display("write back cycle = %d, inst = %d", i, i - 4);
	 end
      end // for (integer i = 0; i < (5 + num_instructions); i=i+1)

      $finish;
   end
endmodule
