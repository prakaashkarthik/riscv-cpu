module rv32i_decode_block # (parameter INSTRUCTION_WIDTH = 32) (
	input clk, 
	input rst_n, 
	input [INSTRUCTION_WIDTH - 1 : 0] inst, 

	input [31:0] rs1_data_in,
	input [31:0] rs2_data_in,

	output [4:0] rs1_num_o,
	output [4:0] rs2_num_o, 

	output [`DECODE_PIPE_MSB : 0] decode_pipe
);

	logic [4:0] rd_num, rs1_num, rs2_num;
	logic [6:0] opcode;
	logic [2:0] funct3;

	logic [31:0] rs1_data, rs2_data;
	logic [11:0] imm_data;

	assign opcode = inst[6:0];
	assign funct3 = inst[14:12];

	// Register number assignments
	always_comb begin
		if (opcode == 'h37 || opcode == 'h17 || opcode == 'h6f || opcode == 'h67 || opcode == 'h3 || opcode == 'h13 || opcode == 'h33 || opcode == 'h73) 
			rd_num = inst[11:7];
		else 
			rd_num = 0;
	end

	always_comb begin
		if (opcode == 'h67 || opcode == 'h63 || opcode == 'h3 || opcode == 'h13 || opcode == 'h23 || opcode == 'h33)
			rs1_num = inst[19:15];
	        else if (opcode == 'h73 && (funct3 == 'h1 || funct3 == 'h2 || funct3 == 'h3))
			rs1_num = inst[19:15];
		else
			rs1_num = 0;
	end

	always_comb begin
		if (opcode == 'h63 || opcode == 'h23 || opcode == 'h33)
			rs2_num = inst[24:20];
		else
			rs2_num = 0;
	end
	

	// Output signals to main register file
	assign rs1_num_o = rs1_num;
	assign rs2_num_o = rs2_num;

	// Input signals from main register file
	assign rs1_data = rs1_data_in;
	assign rs2_data = rs2_data_in;

	// Immediate assignment
	// TODO -- needs to be changed
	assign imm_data = inst[31:20];


	// Decode Pipe data assignment logic
	always_ff @(posedge clk or negedge rst_n) begin
		if (~rst_n) begin
			decode_pipe <= 0;
		end else begin
			decode_pipe[`OPCODE_RANGE] <= opcode;
			decode_pipe[`FUNCT3_RANGE] <= funct3;
			decode_pipe[`RD_NUM_RANGE] <= rd_num;
			decode_pipe[`RS1_NUM_RANGE] <= rs1_num;
			decode_pipe[`RS2_NUM_RANGE] <= rs2_num;
			decode_pipe[`RS1_DATA_RANGE] <= rs1_data;
			decode_pipe[`RS2_DATA_RANGE] <= rs2_data;
			decode_pipe[`IMM_DATA_RANGE] <= imm_data;
		end
	end
	

endmodule
