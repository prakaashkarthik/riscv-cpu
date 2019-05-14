module register_file # (parameter REG_FILE_SIZE = 32, parameter REG_WIDTH = 32) (
	input clk, 
	input rst_n, 
	input [4:0] rd_reg_num0, 
	input [4:0] rd_reg_num1, 
	input [4:0] wr_reg_num, 
	input write_en,
	input [REG_WIDTH - 1 : 0] write_data,	
	
	output [REG_WIDTH - 1 : 0] read_data0, 
	output [REG_WIDTH - 1 : 0] read_data1
);


	logic [31:0] reg_file [REG_FILE_SIZE];
	logic final_write_en; 

	// Reset and write logic
	
	// According to RV32I spec, register 0 is the zero register and cannot
	// be written to
	assign final_write_en = (wr_reg_num == 0) ? 0 : write_en;
	genvar i; 
	generate 
		for (i = 0; i < REG_FILE_SIZE; i++) begin
			always_ff @(posedge clk or negedge rst_n) begin
				if (~rst_n) begin
					reg_file[i] <= 0;
				end else if (final_write_en) begin
					reg_file[wr_reg_num] <= write_data;
				end
			end
		end
	endgenerate

	// Read logic
	assign read_data0 = reg_file[rd_reg_num0];
	assign read_data1 = reg_file[rd_reg_num1];


endmodule
