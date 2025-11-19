`timescale 1ns / 1ps

module base_pipeline(input wire		clk,
		     output wire [31:0]	bus_dout,
		     output wire [31:0]	bus_addr,
		     output wire	bus_write_valid,
		     input wire		bus_write_ready
);

   //---forwarding and hazard controll---//
   reg        main_pipeline_stall = 0;

   reg	      div_wait = 0;
   reg	      bus_wait = 0;

   reg	      bus_stall = 0;
   reg	      mp_stall = 0;
   reg	      div_stall = 0;

   reg	      pc_stall = 0;
   reg	      fetch_stall = 0;
   reg	      decode_stall = 0;
   reg	      ex_stall = 0;
   reg	      stl_stall = 0;
   reg	      wb_stall = 0;

   reg	      ex_reset = 0;
   reg	      stl_reset = 0;
   reg	      decode_reset = 0;
   reg	      fw_hazard = 0;

   //forward predictor
   reg [1:0]  rs1_fw_ctrl_ex = 0;
   reg [1:0]  rs2_fw_ctrl_ex = 0;

   reg	      ram_din_fw_ctrl_ex = 0;
   reg	      ram_din_fw_ctrl_stl = 0;

   always @(posedge clk) begin
      if (!decode_stall) begin 
	 if (rd_en_ex && (rs1_addr == rd_addr_ex)) begin
	    rs1_fw_ctrl_ex <= 1; // rs1_value_fw_ex = rd_value_stl
	 end else if ((rs1_addr == rd_addr_stl) && rd_en_stl) begin
	    rs1_fw_ctrl_ex <= 2; // rs1_value_fw_ex = rd_value_wb
	 end else begin
	    rs1_fw_ctrl_ex <= 0;
	 end

	 if (rd_en_ex && (rs2_addr == rd_addr_ex)) begin
	    rs2_fw_ctrl_ex <= 1; // rs2_value_fw_ex = rd_value_stl
	 end else if ((rs2_addr == rd_addr_stl) && rd_en_stl) begin
	    rs2_fw_ctrl_ex <= 2; // rs2_value_fw_ex = rd_value_wb
	 end else begin
	    rs2_fw_ctrl_ex <= 0;
	 end

	 //---ram input---//
	 if (ram_we && rd_en_ex && (rs2_addr == rd_addr_ex)) begin
	    ram_din_fw_ctrl_ex <= 1; //ram_din_stl = rd_value_wb;
	 end else begin
	    ram_din_fw_ctrl_ex <= 0; //ram_din_stl = rs2_value_stl;
	 end
      end 

      if (!ex_stall) begin
	 ram_din_fw_ctrl_stl <= ram_din_fw_ctrl_ex;
      end
   end
   
   always @(*) begin
      if (rs1_fw_ctrl_ex == 1) begin
	 rs1_value_fw_ex = rd_value_stl; //forward from end of execution stage
      end else if(rs1_fw_ctrl_ex == 2) begin
	 rs1_value_fw_ex = rd_value_wb; //forward from writeback stage 
      end else begin
	 rs1_value_fw_ex = rs1_value_ex;
      end

      if (rs2_fw_ctrl_ex == 1) begin
	 rs2_value_fw_ex = rd_value_stl; //forward from end of execution stage 
      end else if(rs2_fw_ctrl_ex == 2) begin
	 rs2_value_fw_ex = rd_value_wb; //forward from writeback stage 
      end else begin
	 rs2_value_fw_ex = rs2_value_ex;
      end

      //---ram input---//
      if (ram_din_fw_ctrl_stl) begin
	 ram_din_stl = rd_value_wb;
      end else begin
	 ram_din_stl = rs2_value_stl;
      end
   end

   always @(*) begin
      div_wait = rd_is_div_wb && !div_valid;
      bus_stall = div_wait;
   end
   
   always @(*) begin
      //---external execute---//
      bus_wait = bus_write_valid && !bus_write_ready;
      div_stall = bus_wait;

      main_pipeline_stall = div_wait || bus_wait;

      fw_hazard = (rs1_en && (rd_is_ram_dout_ex || rd_is_multiplier_ex || rd_is_div_ex ) && (rs1_addr == rd_addr_ex)) || 
		  (rs2_en && (rd_is_ram_dout_ex || rd_is_multiplier_ex || rd_is_div_ex ) && !ram_we && (rs2_addr == rd_addr_ex));

      pc_stall = fw_hazard || main_pipeline_stall;
      fetch_stall = fw_hazard || main_pipeline_stall;
      decode_stall = main_pipeline_stall;

      ex_stall = main_pipeline_stall;
      mp_stall = main_pipeline_stall;
      stl_stall = main_pipeline_stall;
      wb_stall = main_pipeline_stall;
      
      ex_reset = branch_taken_stl || fw_hazard;
      stl_reset = branch_taken_stl;

      decode_reset = is_jal_inst;
   end

   //---stage 0: pc---//
   reg [31:0] pc = 0;
   reg [31:0] inst_addr_fetch = 0;
   reg [31:0] next_inst_addr_fetch = 0;
   
   always @(*) begin
      inst_addr_fetch = branch_taken_stl ? (alu_y_stl & ~32'b1) : pc;
      next_inst_addr_fetch = inst_addr_fetch + 4;
   end

   always @(posedge clk) begin
      if (!pc_stall) begin 
	 if (is_jal_inst && !branch_taken_stl) begin // give priority to branch and jalr over jal
	    pc <= jal_target;
	 end else begin
	    pc <= next_inst_addr_fetch;
	 end
      end
   end

   //---stage 1: fetch---//
   wire [31:0] instruction_dec;
   reg [31:0]  inst_addr_dec = 0;
   reg [31:0]  next_inst_addr_dec = 0;
   instruction_fetcher instruction_fetcher0(.clk(clk),
					    .en(!fetch_stall),
					    .reset(decode_reset),
					    .addr(inst_addr_fetch),
					    .inst_data(instruction_dec));

   always @(posedge clk) begin
      if (!fetch_stall) begin
	 inst_addr_dec <= (decode_reset) ? 0 : inst_addr_fetch;
	 next_inst_addr_dec <= (decode_reset) ? 0 : next_inst_addr_fetch;
      end
   end
   
   //---stage 2: decode---//
   wire [4:0] rs1_addr;
   wire	      rs1_en;
   wire [4:0] rs2_addr;
   wire	      rs2_en;

   wire [4:0] rd_addr;
   wire	      rd_en;
   
   wire [31:0] immediate_value;
   wire	       b_is_immediate; 
   wire	       a_is_inst_addr; 
   wire	       rd_is_link_addr;
   wire	       rd_is_ram_dout;

   wire [9:0]  ex_operation;
   wire	       ram_we;
   wire	       is_branch_inst;
   wire [2:0]  comparitor_operation;
   wire	       is_jalr_inst;
   wire	       is_jal_inst;

   wire [31:0] j_immediate = {instruction_dec[31] ? (-12'b1) : (12'b0), instruction_dec[19:12], instruction_dec[20], instruction_dec[30:21], 1'b0};

   reg [31:0]	jal_target = 0;
   always @(*) begin
      jal_target = inst_addr_dec + j_immediate;
   end
   
   instruction_decoder instruction_decoder0(.instruction(instruction_dec),
					    .rs1_addr(rs1_addr),
					    .rs1_en(rs1_en),
					    .rs2_addr(rs2_addr),
					    .rs2_en(rs2_en),
					    .rd_addr(rd_addr),
					    .rd_en(rd_en),

					    .immediate_value(immediate_value),

					    .b_is_immediate(b_is_immediate),
					    .a_is_inst_addr(a_is_inst_addr),
					    .rd_is_link_addr(rd_is_link_addr),
					    .rd_is_ram_dout(rd_is_ram_dout),
					    .ex_operation(ex_operation),
					    .ram_we(ram_we),
					    .is_branch_inst(is_branch_inst),
					    .is_jalr_inst(is_jalr_inst),
					    .is_jal_inst(is_jal_inst),
					    .comparitor_operation(comparitor_operation));

   reg [4:0]	rs1_addr_ex = 0;
   reg		rs1_en_ex = 0;
   reg [4:0]	rs2_addr_ex = 0;
   reg		rs2_en_ex = 0;
   reg [4:0]	rd_addr_ex = 0;
   reg		rd_en_ex = 0;

   reg [31:0]	immediate_value_ex = 0;
   reg		b_is_immediate_ex = 0; 
   reg		a_is_inst_addr_ex = 0; 
   reg [9:0]	ex_operation_ex = 0;
   reg		rd_is_ram_dout_ex = 0;
   reg		rd_is_link_addr_ex = 0;

   wire [31:0]	rs1_value;
   wire [31:0]	rs2_value;

   reg [31:0]	rs1_value_ex = 0;
   reg [31:0]	rs2_value_ex = 0;
   reg		ram_we_ex = 0;

   reg		is_branch_inst_ex = 0;
   reg [2:0]	comparitor_operation_ex = 0;
   reg [31:0]	inst_addr_ex = 0;
   reg [31:0]	next_inst_addr_ex = 0;
   
   reg		is_jalr_inst_ex = 0;

   always @(posedge clk) begin
      if (!decode_stall) begin
	 rs1_en_ex <= (ex_reset) ? 0 : rs1_en;
	 rs2_en_ex <= (ex_reset) ? 0 : rs2_en;
	 rd_addr_ex <= (ex_reset) ? 0 : rd_addr;
	 rd_en_ex <= (ex_reset) ? 0 : rd_en;
	 rd_is_ram_dout_ex <= (ex_reset) ? 0 : rd_is_ram_dout;
	 ram_we_ex <= (ex_reset) ? 0 : ram_we;
	 is_branch_inst_ex <= (ex_reset) ? 0 : is_branch_inst;
	 rd_is_link_addr_ex <= (ex_reset) ? 0 : rd_is_link_addr;
	 is_jalr_inst_ex <= (ex_reset) ? 0 : is_jalr_inst;
	 inst_addr_ex <= inst_addr_dec;
	 next_inst_addr_ex <= next_inst_addr_dec;
	 rs1_addr_ex <= rs1_addr;
	 rs2_addr_ex <= rs2_addr;
	 rd_addr_ex <= rd_addr;
	 immediate_value_ex <= immediate_value;
	 b_is_immediate_ex <= b_is_immediate;
	 a_is_inst_addr_ex <= a_is_inst_addr;
	 ex_operation_ex <= ex_operation;
	 rs1_value_ex <= rs1_value;
	 rs2_value_ex <= rs2_value;
	 comparitor_operation_ex <= comparitor_operation;
      end
   end
   
   register_file register_file0(.clk(clk),
			       .wen(rd_en_wb && !wb_stall),
			       .rs1_addr(rs1_addr),
			       .rs2_addr(rs2_addr),
			       .rd_addr(rd_addr_wb),
			       .rd_value(rd_value_wb),
			       .rs1_value(rs1_value),
			       .rs2_value(rs2_value));
   
   //---stage 3: execute---//
   reg [31:0]  rs1_value_fw_ex = 0;
   reg [31:0]  rs2_value_fw_ex = 0;
   reg [31:0]  rd_value_ex = 0;
   reg [31:0]  a_value_ex = 0;
   reg [31:0]  b_value_ex = 0;

   wire [31:0] alu_y_ex;
   wire	       comp_y_ex;

   always @(*) begin
      a_value_ex = (a_is_inst_addr_ex) ? inst_addr_ex : rs1_value_fw_ex;
      b_value_ex = (b_is_immediate_ex) ? immediate_value_ex : rs2_value_fw_ex;
   end

   always @(*) begin
      rd_value_ex = (rd_is_link_addr_ex) ? next_inst_addr_ex : alu_y_ex;
   end

   comparitor comparitor0(.a(rs1_value_fw_ex),
			  .b(rs2_value_fw_ex),
			  .ctrl(comparitor_operation_ex),
			  .y(comp_y_ex));
   
   alu alu0(.a(a_value_ex),
	    .b(b_value_ex),
	    .ctrl(ex_operation_ex[7:0]),
	    .y(alu_y_ex));

   reg [4:0]	rs2_addr_stl = 0;
   reg		rs2_en_stl = 0;
   reg [31:0]	rs2_value_stl = 0;
   reg [4:0]	rd_addr_stl = 0;
   reg		rd_en_stl = 0;
   reg [31:0]	rd_value_stl = 0;
   reg [31:0]	alu_y_stl = 0;
   reg		ram_we_stl = 0;
   reg		rd_is_ram_dout_stl = 0;
   reg		branch_taken_stl = 0;
   reg		rd_is_multiplier_stl = 0;
   reg		rd_is_div_stl = 0;

   wire		rd_is_multiplier_ex = ex_operation_ex[8];
   wire		rd_is_div_ex = ex_operation_ex[7] && rd_en_ex;
   

   wire [31:0] rd_value_mp;
   wire [31:0] rd_value_div;

   multiplier_pipeline multiplier_pipeline0(.clk(clk),
					    .stall(mp_stall),
					    .rs1_value(rs1_value_fw_ex),
					    .rs2_value(rs2_value_fw_ex),
					    .ctrl(ex_operation_ex[2:0]),
					    .ans(rd_value_mp)
					    );

   wire div_valid;
   divider divider_pipeline(.clk(clk),
			    .stall(div_stall),
			    .dividend(rs1_value_fw_ex),
			    .divisor(rs2_value_fw_ex),
			    .in_valid(rd_is_div_ex),
			    .ctrl(ex_operation_ex[2:1]),
			    .ans(rd_value_div),
			    .out_valid(div_valid));

   always @(posedge clk) begin
      if (!ex_stall) begin
	 rs2_en_stl <= (stl_reset) ? 0 : rs2_en_ex;
	 rd_en_stl <= (stl_reset) ? 0 : rd_en_ex;
	 ram_we_stl <= (stl_reset) ? 0 : ram_we_ex;
	 rd_is_ram_dout_stl <= (stl_reset) ? 0 : rd_is_ram_dout_ex;
	 branch_taken_stl <= (stl_reset) ? 0 : is_jalr_inst_ex || (is_branch_inst_ex && comp_y_ex);
	 rd_is_multiplier_stl <= (stl_reset) ? 0 : rd_is_multiplier_ex;
	 rd_is_div_stl <= (stl_reset) ? 0 : rd_is_div_ex;
	 rs2_addr_stl <= rs2_addr_ex;
	 rd_addr_stl <= rd_addr_ex;
	 rs2_value_stl <= rs2_value_fw_ex;
	 rd_value_stl <= rd_value_ex;
	 alu_y_stl <= alu_y_ex;
      end
   end
   
   //---stage 4: store/load---//
   wire is_bus_addr_stl = bus_addr[31:28] == 4'hE;

   assign bus_addr = alu_y_stl;
   assign bus_dout = ram_din_stl;
   assign bus_write_valid = is_bus_addr_stl && ram_we_stl && !bus_stall;

   reg [31:0] ram_din_stl = 0;
   ram_port ram_port0(.clk(clk),
			.addr(alu_y_stl),
			.we(ram_we_stl && !is_bus_addr_stl),
			.din(ram_din_stl),
			.en(!stl_stall),
			.dout(ram_dout_wb));
   
   reg [4:0]	rd_addr_wb = 0;
   reg		rd_en_wb = 0;
   reg [31:0]	rd_value_pre_wb = 0;
   reg [31:0]	rd_value_wb = 0;
   wire [31:0]	ram_dout_wb;
   reg		rd_is_ram_dout_wb = 0;
   reg		rd_is_multiplier_wb = 0;
   reg		rd_is_div_wb = 0;

   always @(posedge clk) begin
      if (!stl_stall) begin
	 rd_addr_wb <= rd_addr_stl;
	 rd_en_wb <= rd_en_stl;
	 rd_value_pre_wb <= rd_value_stl;
	 rd_is_ram_dout_wb <= rd_is_ram_dout_stl;
   	 rd_is_multiplier_wb = rd_is_multiplier_stl;
   	 rd_is_div_wb = rd_is_div_stl;
      end
   end

   //---stage 5: write back---//
   always @(*) begin
      if (rd_is_ram_dout_wb) begin
	 rd_value_wb = ram_dout_wb;
      end else if (rd_is_multiplier_wb) begin
	 rd_value_wb = rd_value_mp;
      end else if (rd_is_div_wb) begin
	 rd_value_wb = rd_value_div;
      end else begin
	 rd_value_wb = rd_value_pre_wb;
      end
   end
endmodule
