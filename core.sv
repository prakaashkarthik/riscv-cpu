module core (
	input clk,
	input rst_n,

	output [31:0] fetch_p
);
	
	logic [5:0] pc, next_pc; // Program Counter
	logic [31:0] inst; // Instruction
	//logic [31:0] fetch_p; // Fetch pipe

	logic [5:0] main_rf_rd_reg_num; 
	logic [31:0] main_rf_read_data;
	logic main_rf_write_en;
	logic [5:0] main_rf_wr_reg_num;
	logic [31:0] main_rf_write_data;	


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

	register_file main_rf(
		.clk(clk), 
		.rst_n(rst_n),
		.rd_reg_num(main_rf_rd_reg_num), 
		.wr_reg_num(main_rf_wr_reg_num), 
		.write_en(main_rf_write_en),
		.write_data(main_rf_write_data),	
		.read_data(main_rf_read_data)
	);



endmodule
