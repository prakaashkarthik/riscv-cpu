module core (
	input clk,
	input rst_n,

	output [31:0] fetch_p
);
	
	logic [5:0] pc, next_pc; // Program Counter
	logic [31:0] inst; // Instruction
	//logic [31:0] fetch_p; // Fetch pipe



	inst_memory imem (
		.addr(pc), 
		.data(inst)
	);
	
	fetch_block fetch (
		.clk(clk), 
		.rst_n(rst_n), 
		.curr_pc_in(pc), 
		.inst_in(inst),

		.next_pc_out(next_pc),
		.fetch_pipe(fetch_p)
	);

	// PC logic
	assign pc = next_pc;


endmodule
