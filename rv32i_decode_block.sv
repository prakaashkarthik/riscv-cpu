module rv32i_decode_block # (parameter INSTRUCTION_WIDTH = 32) (
	input clk, 
	input rst_n, 
	input [INSTRUCTION_WIDTH - 1 : 0] inst, 

	input [REGISTER_WIDTH - 1 : 0] rs1_data_in,
	input [REGISTER_WIDTH - 1 : 0] rs2_data_in,

	output [4:0] rs1_num_o,
	output [4:0] rs2_num_o, 

	output [`DECODE_PIPE_MSB : 0] decode_pipe
);

	logic [4:0] rd_num, rs1_num, rs2_num;
	logic [6:0] opcode;
	logic [2:0] funct3;
	logic [6:0] funct7;
	logic [4:0] shamt;
	logic [31:0] imm_data;

	logic [REGISTER_WIDTH - 1 : 0] rs1_data, rs2_data;
	logic [REGISTER_WIDTH - 1 : 0] operand1, operand2, operand3;


	// Instruction field assignments
	assign opcode = inst[6:0];
	assign funct3 = inst[14:12];

	// Funct7 assignment
	assign funct7 = (opcode == 'h33) ? inst[31:25] : 'h0;

	// Shift Amount assignment
	// It is never in another position, and can be ignored for other 
	// opcodes -- so no ifs needed
	assign shamt = inst[24:20]; 
	
	
	
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
	/* verilator lint_off WIDTH */
	always_comb begin
		imm_data = 0;
		case (opcode) 
			'h37: imm_data = inst[31:12]; // LUI
			'h17: imm_data = inst[31:12]; // AUIPC
			'h6f: begin // JALR
				imm_data[20] = inst[31];
				imm_data[19:12] = inst[19:12];
				imm_data[11] = inst[20];
				imm_data[10:1] = inst[30:21];
			end
			'h63: begin // Branch instructions
				imm_data[12] = inst[31];
				imm_data[11] = inst[7];
				imm_data[10:5] = inst[30:25];
				imm_data[4:1] = inst[11:8];
			end
			'h3: imm_data = inst[31:20]; // Load instructions
			'h23: begin // Store instructions
				imm_data[11:5] = inst[31:25];
				imm_data[4:0] = inst[11:7];
			end
			'h13: imm_data = inst[31:20]; // Imm ALU instructions
			default: imm_data = 0;
		endcase
	end
	/* verilator lint_on WIDTH */






	// Operand deciding	
	// This is the bulk of the decode section -- where we look into which
	// opcode we're processing and we send just the necessary operands to
	// the execute block
	
	// Logic for operand1
	always_comb begin
		case (opcode)
			'h3:  operand1 = rs1_data; // Imm Load instructions
			'h13: operand1 = rs1_data; // Imm ALU instructions
			'h23: operand1 = rs1_data; // Store instructions
			'h33: operand1 = rs1_data; // Register ALU instructions
			'h63: operand1 = rs1_data; // branch instructions
			'h73: if (funct3 == 'h1 || funct3 == 'h2 || funct3 == 'h3) operand1 = rs1_data; // Subset of CSR instructions
			'h37: operand1 = imm_data; // LUI
			'h17: operand1 = imm_data; // AUIPC
			'h6f: operand1 = imm_data; // JAL
			'h67: operand1 = rs1_data; // JALR
	
			default: operand1 = 0;
		endcase
	end

	// Logic for operand2
	always_comb begin
		operand2 = 0;
		case (opcode)
			'h3:  operand2 = imm_data; // Imm Load instructions
			'h13: begin 
				if (funct3 == 'h1 || funct3 == 'h5) operand2[4:0] = shamt; // Imm ALU instructions
				else operand2 = imm_data;
			end
			'h23: operand2 = rs2_data; // Store instructions
			'h33: operand2 = rs2_data; // Register ALU instructions
			'h63: operand2 = rs2_data; // branch instructions
			// 'h73: To be figured out; // Subset of CSR instructions
			'h67: operand2 = imm_data; // JALR
	
			default: operand2 = 0;
		endcase
	end

	// Logic for operand3
	always_comb begin
		case (opcode)
			'h63: operand3 = imm_data; // Branch instructions
			'h23: operand3 = imm_data; // Store instructions
			default: operand3 = 0; 
		endcase
	end


	// Decode Pipe data assignment logic
	// macro defines are in struct_defines.svh
	always_ff @(posedge clk or negedge rst_n) begin
		if (~rst_n) begin
			decode_pipe <= 0;
		end else begin
			decode_pipe[`OPCODE_RANGE] <= opcode;
			decode_pipe[`FUNCT3_RANGE] <= funct3;
			decode_pipe[`FUNCT7_RANGE] <= funct7;
			decode_pipe[`RD_NUM_RANGE] <= rd_num;
			decode_pipe[`OPERAND1_RANGE] <= operand1;
			decode_pipe[`OPERAND2_RANGE] <= operand2;
			decode_pipe[`OPERAND3_RANGE] <= operand3;
		end
	end
	

endmodule
