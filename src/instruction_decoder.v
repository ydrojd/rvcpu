`timescale 1ns / 1ps

`include "alu_ops.v"
`include "opcodes.v"

module instruction_decoder(input wire [31:0] instruction,
			    output wire [4:0] rs1_addr,
			    output reg	      rs1_en,
			    output wire [4:0] rs2_addr,
			    output reg	      rs2_en,
			    output wire [4:0] rd_addr,
			    output reg	      rd_en,
			    output reg	      rd_is_link_addr,
			    output reg	      rd_is_ram_dout,
			    output reg [31:0] immediate_value,
			    output reg	      b_is_immediate,
			    output reg	      a_is_inst_addr,
			    output reg	      ram_we,
			    output reg [9:0]  ex_operation,
			    output wire [2:0] comparitor_operation,

			    output reg is_branch_inst,
			    output reg is_jalr_inst,
			    output reg is_jal_inst);

   wire [6:0] opcode = instruction[6:0];
   assign rd_addr = instruction[11:7];
   wire [2:0] funct3 = instruction[14:12];
   assign comparitor_operation = funct3;
   assign rs1_addr = instruction[19:15];
   assign rs2_addr = instruction[24:20];
   wire [6:0] funct7 = instruction[31:25];
   
   wire [31:0] i_immediate = {instruction[31] ? (-21'b1) : (21'b0), instruction[30:20]};
   wire [31:0] s_immediate = {instruction[31] ? (-21'b1) : (21'b0), instruction[30:25], instruction[11:7]};
   wire [31:0] b_immediate = {instruction[31] ? (-20'b1) : (20'b0), instruction[7], instruction[30:25], instruction[11:8], 1'b0};
   wire [31:0] u_immediate = {instruction[31:12], 12'b0};

   always @(*) begin
      ex_operation = 0;
      is_jalr_inst = 0;
      is_jal_inst = 0;
      rd_is_link_addr = 0;
      a_is_inst_addr = 0;
      rd_is_ram_dout = 0;
      ram_we = 0;
      is_branch_inst = 0;
      b_is_immediate = 0;
      rs1_en = 0;
      rs2_en = 0;
      rd_en = 0;

      case(opcode)
	`TX_OPCODE: begin
	   rs2_en = 1;
	   ex_operation[9:0] = 10'b1_001_000000;
	end

	`OP_OPCODE: begin // r-type
	   rs1_en = 1;
	   rs2_en = 1;
	   rd_en = 1;
	   immediate_value = i_immediate;

	   case({funct7[5], funct7[0], funct3})
	     5'b01_000: ex_operation[9:0] = {10'b0_100_000_011}; //mul
	     // 5'b01_000: ex_operation[9:0] = {10'b1_010_000_011}; //mul
	     // 5'b01_001: ex_operation[9:0] = {10'b1_010_000_111}; //mulh
	     // 5'b01_011: ex_operation[9:0] = {10'b1_010_000_100}; //mulhu

	     5'b01_100: ex_operation[9:0] = {10'b1_011_000_001}; //div
	     5'b01_101: ex_operation[9:0] = {10'b1_011_000_000}; //divu

	     5'b01_110: ex_operation[9:0] = {10'b1_011_000_011}; //rem
	     5'b01_111: ex_operation[9:0] = {10'b1_011_000_010}; //remu

	     5'b00_000: ex_operation[7:0] = `ALU_CTRL_ADD;
	     5'b10_000: ex_operation[7:0] = `ALU_CTRL_SUB;
	     5'b00_001: ex_operation[7:0] = `ALU_CTRL_LSFT;
	     5'b00_010: ex_operation[7:0] = `ALU_CTRL_LESS_SIGN;
	     5'b00_011: ex_operation[7:0] = `ALU_CTRL_LESS;
	     5'b00_100: ex_operation[7:0] = `ALU_CTRL_XOR;
	     5'b00_101: ex_operation[7:0] = `ALU_CTRL_RSFT;
	     5'b10_101: ex_operation[7:0] = `ALU_CTRL_RSFTA;
	     5'b00_110: ex_operation[7:0] = `ALU_CTRL_OR;
	     5'b00_111: ex_operation[7:0] = `ALU_CTRL_AND;
	     default: ex_operation[7:0] = `ALU_CTRL_ADD;
	   endcase;
	end

	`LOAD_OPCODE: begin
	   //only LW is implemented
	   rs1_en = 1;
	   rd_en = 1;
	   immediate_value = i_immediate;
	   b_is_immediate = 1;
	   ex_operation[7:0] = `ALU_CTRL_ADD;
	   rd_is_ram_dout = 1;
	end
	
	`STORE_OPCODE: begin
	   //only SW is implemented
	   rs1_en = 1;
	   rs2_en = 1;
	   immediate_value = s_immediate;
	   b_is_immediate = 1;
	   ex_operation[7:0] = `ALU_CTRL_ADD;
	   ram_we = 1;
	end
	
	`BRANCH_OPCODE: begin
	   rs1_en = 1;
	   rs2_en = 1;
	   immediate_value = b_immediate;
	   b_is_immediate = 1;
	   ex_operation[7:0] = `ALU_CTRL_ADD;
	   is_branch_inst = 1;
	   a_is_inst_addr = 1;
	end

	`JALR_OPCODE: begin
	   rs1_en = 1;
	   rd_en = 1;
	   immediate_value = i_immediate;
	   b_is_immediate = 1;
	   ex_operation[7:0] = `ALU_CTRL_ADD;
	   is_jalr_inst = 1;
	   rd_is_link_addr = 1;
	end

	`OP_IMM_OPCODE: begin
	   rs1_en = 1;
	   rd_en = 1;
	   immediate_value = i_immediate;
	   b_is_immediate = 1;

	   case(funct3)
	     0: ex_operation[7:0] = `ALU_CTRL_ADD;
	     2: ex_operation[7:0] = `ALU_CTRL_LESS_SIGN;
	     3: ex_operation[7:0] = `ALU_CTRL_LESS;
	     4: ex_operation[7:0] = `ALU_CTRL_XOR;
	     6: ex_operation[7:0] = `ALU_CTRL_OR;
	     7: ex_operation[7:0] = `ALU_CTRL_AND;
	     default: ex_operation[7:0] = `ALU_CTRL_ADD;
	   endcase;
	end

	`LUI_OPCODE: begin
	   rd_en = 1;
	   immediate_value = u_immediate;
	   b_is_immediate = 1;
	   ex_operation[7:0] = `ALU_CTRL_B;
	end

	`AUIPC_OPCODE: begin
	   rd_en = 1;
	   immediate_value = u_immediate;
	   b_is_immediate = 1;
	   ex_operation[7:0] = `ALU_CTRL_ADD;
	   a_is_inst_addr = 1;
	end

	`JAL_OPCODE: begin
	   rd_en = 1;
	   immediate_value = i_immediate;
	   ex_operation[7:0] = `ALU_CTRL_ADD;
	   is_jal_inst = 1;
	   rd_is_link_addr = 1;
	end
	
	default: begin
	   immediate_value = i_immediate;
	   ex_operation[7:0] = `ALU_CTRL_ADD;
	end
      endcase;
   end
endmodule // inst_decoder
