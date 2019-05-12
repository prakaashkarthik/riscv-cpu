module fetch_block (
	input clk, 
	input rst_n, 
	input [31:0] inst_in,
	input [5:0]  curr_pc_in,

	output [5:0] next_pc_out,
	output [31:0] fetch_pipe
);

	logic [31:0] inst;
	logic [5:0]  curr_pc;
	logic [5:0]  next_pc;

	assign inst = inst_in;
	assign curr_pc = curr_pc_in;
	assign next_pc = curr_pc + 1;

	// Next PC logic
	always_ff @(posedge clk or negedge rst_n) begin 
		if (~rst_n) begin
			next_pc_out <= 0;
		end else begin
			next_pc_out <= next_pc;
		end
	end
	
	// Fetch pipe logic
	always_ff @(posedge clk or negedge rst_n) begin 
		if (~rst_n) begin
			fetch_pipe <= 0;
		end else begin
			fetch_pipe <= inst;
		end
	end

endmodule

