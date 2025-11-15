`timescale 1ns / 1ps
`include "alu_ops.v"

`define verify(value, expected) \
begin\
if (value != expected) $display(`"value`", " should be:", expected, ", but is: ", value);\
end

module instruction_rom_wrapper(input		 clk, 
			       input [31:0]	 addr,
			       input wire	 rst,
			       input		 en,
			       output reg [31:0] dout);

   initial dout = 0;
   reg [31:0] data[4095:0];

   always @(posedge clk) begin
      if (en) begin
	 case (addr)
	   0: dout <= 32'h011800b3;
	   4: dout <= 32'h41288133;
	   8: dout <= 32'h013911b3;
	   12: dout <= 32'h0149a233;
	   16: dout <= 32'h015a32b3;
	   20: dout <= 32'h016ac333;
	   24: dout <= 32'h017b53b3;
	   28: dout <= 32'h418bd433;
	   32: dout <= 32'h019c64b3;
	   36: dout <= 32'h01acf533;
	   default: dout <= 0;
	 endcase;
      end
   end
   
   //https://stackoverflow.com/questions/70151532/read-from-file-to-memory-in-verilog
endmodule

module rtype_tb();
   reg clk = 0;
   
   base_pipeline base_pipeline0(clk);

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

   inst [11:0] insts;

   integer num_instructions = 10;
   initial begin
      #10;
      
      for (integer i=0; i <= 31; i = i + 1)
        base_pipeline0.register_file0.data[i] = i;
      #10;
      
      insts[0] = '{5'd1, 5'd16, 5'd17, 32'd16, 32'd17, (16 + 17), `ALU_CTRL_ADD, 32'h011800b3}; // add x1, x16, x17
      
      insts[1] = '{5'd2, 5'd17, 5'd18, 32'd17, 32'd18, (17 - 18), `ALU_CTRL_SUB, 32'h41288133}; // sub x2, x17, x18

      insts[2] = '{5'd3, 5'd18, 5'd19, 32'd18, 32'd19, (18 << 19), `ALU_CTRL_LSFT, 32'h013911b3}; // sll x3, x18, x19


      insts[3] = '{5'd4, 5'd19, 5'd20, 32'd19, 32'd20, (19 < 20), `ALU_CTRL_LESS_SIGN, 32'h0149a233}; // slt x4, x19, x20
      
      insts[4] = '{5'd5, 5'd20, 5'd21, 32'd20, 32'd21, (20 < 21), `ALU_CTRL_LESS, 32'h015a32b3}; // sltu x5, x20, x21

      insts[5] = '{5'd6, 5'd21, 5'd22, 32'd21, 32'd22, (21 ^ 22), `ALU_CTRL_XOR, 32'h016ac333}; // xor x6, x21, x22
      
      insts[6] = '{5'd7, 5'd22, 5'd23, 32'd22, 32'd23, (22 >> 23), `ALU_CTRL_RSFT, 32'h017b53b3}; // srl x7, x22, x23

      insts[7] = '{5'd8, 5'd23, 5'd24, 32'd23, 32'd24, (23 >>> 24), `ALU_CTRL_RSFTA, 32'h418bd433}; // sra x8, x23, x24

      insts[8] = '{5'd9, 5'd24, 5'd25, 32'd24, 32'd25, (24 | 25), `ALU_CTRL_OR, 32'h019c64b3}; // or x9, x24, x25

      insts[9] = '{5'd10, 5'd25, 5'd26, 32'd25, 32'd26, 32'(25 & 26), `ALU_CTRL_AND, 32'h01acf533}; // and x10, x25, x26
      
      for (integer i = 0; i < (5 + num_instructions); i=i+1) begin
	 `verify(base_pipeline0.pc, i * 4);

	 clk = 0;
	 #10;
	 clk = 1;
	 #10;

	 //---fetch stage---//
	 if ((i >= 0) && (i < num_instructions)) begin
	    `verify(base_pipeline0.instruction_dec, insts[i].instruction);
	    $display("");
	    $display("fetch cycle = %d, inst = %d", i, i);
	 end

	 //---decode stage---//
	 if (i >= 1 && (i < (num_instructions + 1))) begin
	    $display("");
	    $display("decode cycle = %d, inst = %d", i, i - 1);
	    `verify(base_pipeline0.rs1_en_ex, 1);
	    `verify(base_pipeline0.rs2_en_ex, 1);
	    `verify(base_pipeline0.rd_en_ex, 1);
	    `verify(base_pipeline0.b_is_immediate_ex, 0);
	    `verify(base_pipeline0.rd_is_ram_dout_ex, 0);
	    `verify(base_pipeline0.ram_we_ex, 0);

	    `verify(base_pipeline0.rd_addr_ex, insts[i - 1].rd);
	    `verify(base_pipeline0.rs1_addr_ex, insts[i - 1].rs1);
	    `verify(base_pipeline0.rs2_addr_ex, insts[i - 1].rs2);

	    `verify(base_pipeline0.rs1_value_ex, insts[i - 1].rs1_value);
	    `verify(base_pipeline0.rs2_value_ex, insts[i - 1].rs2_value);
	 end

	 //---execute stage---//
	 if (i >= 2 && (i < (num_instructions + 2))) begin
	    $display("");
	    $display("execute cycle = %d, inst = %d", i, i - 2);
	    `verify(base_pipeline0.rd_en_stl, 1);
	    `verify(base_pipeline0.rd_is_ram_dout_stl, 0);
	    `verify(base_pipeline0.ram_we_stl, 0);

	    `verify(base_pipeline0.rd_addr_stl, insts[i - 2].rd);
	    `verify(base_pipeline0.rd_value_stl, insts[i - 2].alu_y);
	 end

	 //---store and load stage---//
	 if (i >= 3 && (i < (num_instructions + 3))) begin
	    $display("");
	    $display("store and load cycle = %d, inst = %d", i, i - 3);
	    `verify(base_pipeline0.rd_en_wb, 1);
	    `verify(base_pipeline0.rd_is_ram_dout_wb, 0);
	    
	    `verify(base_pipeline0.rd_addr_wb, insts[i - 3].rd);
	    `verify(base_pipeline0.rd_value_wb, insts[i - 3].alu_y);
	 end

	 //---write back stage---//
	 if (i >= 4 && (i < (num_instructions + 4))) begin
	    $display("");
	    $display("write back cycle = %d, inst = %d", i, i - 4);
	    `verify(base_pipeline0.register_file0.data[insts[i - 4].rd], insts[i - 4].alu_y);
	 end
      end // for (integer i = 0; i < (5 + num_instructions); i=i+1)

      $finish;
   end
endmodule
