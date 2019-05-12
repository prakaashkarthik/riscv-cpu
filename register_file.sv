module register_file # (parameter REG_FILE_SIZE = 32) (
	input clk, 
	input rst_n, 
	input [5:0] rd_reg_num, 
	input [5:0] wr_reg_num, 
	input write_en,
	input [31:0] write_data,	
	
	output [31:0] read_data
);


	logic [31:0] reg_file [REG_FILE_SIZE];

	// Reset logic
	genvar i; 
	generate 
		for (i = 0; i < REG_FILE_SIZE; i++) begin
			always_ff @(negedge rst_n) begin
				if (~rst_n) begin
					reg_file[i] <= 0;
				end
			end
		end
	endgenerate

	// Read logic
	assign read_data = reg_file[rd_reg_num];

	// Write logic
	always_ff @(posedge clk) begin
		if (write_en) begin
			reg_file[wr_reg_num] <= write_data;
		end 
	       // Do I need an else here for synthesizability?	
	end
endmodule
