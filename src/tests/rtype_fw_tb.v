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
	   // 0: dout <= 32'h00108663;      //beq x1, x1, c
	   0: dout <= 32'h009403b3;      //add x7, x8, x9
	   4: dout <= 32'h00838333;	 //add x6, x7, x8
	   8: dout <= 32'h007302b3;	 //add x5, x6, x7
	   12: dout <= 32'h00628233;	 //add x4, x5, x6
	   16: dout <= 32'h006281b3;	 //add x4, x5, x6
	   default: dout <= 0;
	 endcase;
      end
   end
   
   //https://stackoverflow.com/questions/70151532/read-from-file-to-memory-in-verilog
endmodule

module rtype_fw_tb();
   reg clk = 0;
   
   base_pipeline pipeline(clk);

   typedef struct packed {
      logic [4:0]	rd;
      logic [4:0]	rs1;
      logic [4:0]	rs2;
      logic [31:0]	rs1_value;
      logic [31:0]	rs2_value;
      logic [31:0]	alu_y;
      logic [7:0]	alu_op;
      logic [31:0]	instruction;
   } inst;

   inst [4:0] insts;

   integer num_instructions = 5;
   initial begin
      #10;
      
      for (integer i=0; i <= 31; i = i + 1)
        pipeline.register_file0.data[i] = i;
      #10;

      insts[0] = '{5'd7, 5'd8, 5'd9, 32'd8, 32'd9, 32'd17, `ALU_CTRL_ADD, 31'h009403b3};   //add x7, x8, x9
      insts[1] = '{5'd6, 5'd7, 5'd8, 32'd17, 32'd8, 32'd25, `ALU_CTRL_ADD, 31'h00838333};  //add x6, x7, x8
      insts[2] = '{5'd5, 5'd6, 5'd7, 32'd25, 32'd17, 32'd42, `ALU_CTRL_ADD, 31'h007302b3}; //add x5, x6, x7
      insts[3] = '{5'd4, 5'd5, 5'd6, 32'd42, 32'd25, 32'd67, `ALU_CTRL_ADD, 31'h00628233}; //add x4, x5, x6
      insts[4] = '{5'd3, 5'd5, 5'd6, 32'd42, 32'd25, 32'd67, `ALU_CTRL_ADD, 31'h006281b3}; //add x4, x5, x6

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
	    `verify(pipeline.rd_en_ex, 1);
	    `verify(pipeline.b_is_immediate_ex, 0);
	    `verify(pipeline.rd_is_ram_dout_ex, 0);
	    `verify(pipeline.ram_we_ex, 0);

	    `verify(pipeline.rd_addr_ex, insts[i - 1].rd);
	    `verify(pipeline.rs1_addr_ex, insts[i - 1].rs1);
	    `verify(pipeline.rs2_addr_ex, insts[i - 1].rs2);
	    `verify(pipeline.rs1_value_fw_ex, insts[i - 1].rs1_value);
	    `verify(pipeline.rs2_value_fw_ex, insts[i - 1].rs2_value);
	 end

	 //---execute stage---//
	 if (i >= 2 && (i < (num_instructions + 2))) begin
	    $display("");
	    $display("execute cycle = %d, inst = %d", i, i - 2);
	    `verify(pipeline.rd_en_stl, 1);
	    `verify(pipeline.rd_is_ram_dout_stl, 0);
	    `verify(pipeline.ram_we_stl, 0);

	    `verify(pipeline.rd_addr_stl, insts[i - 2].rd);
	    `verify(pipeline.alu_y_stl, insts[i - 2].alu_y);
	    `verify(pipeline.rd_value_stl, insts[i - 2].alu_y);
	 end

	 //---store and load stage---//
	 if (i >= 3 && (i < (num_instructions + 3))) begin
	    $display("");
	    $display("store and load cycle = %d, inst = %d", i, i - 3);
	    `verify(pipeline.rd_en_wb, 1);
	    `verify(pipeline.rd_is_ram_dout_wb, 0);
	    
	    `verify(pipeline.rd_addr_wb, insts[i - 3].rd);
	    `verify(pipeline.rd_value_wb, insts[i - 3].alu_y);
	 end

	 //---write back stage---//
	 if (i >= 4 && (i < (num_instructions + 4))) begin
	    $display("");
	    $display("write back cycle = %d, inst = %d", i, i - 4);
	    `verify(pipeline.register_file0.data[insts[i - 4].rd], insts[i - 4].alu_y);
	 end
      end // for (integer i = 0; i < (5 + num_instructions); i=i+1)

      $finish;
   end
endmodule
