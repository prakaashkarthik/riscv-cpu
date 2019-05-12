`include "register_file_defines.svh"
`include "struct_defines.svh"

module core (
	input clk,
	input rst_n,

	output [31:0] fetch_p,
	output [`DECODE_PIPE_MSB : 0] decode_p
);
	
	logic [5:0] pc, next_pc; // Program Counter
	logic [31:0] inst; // Instruction

	logic [4:0] main_rf_read_reg_num0, main_rf_read_reg_num1; 
	logic [31:0] main_rf_read_data0, main_rf_read_data1;
	
	/* verilator lint_off UNDRIVEN */
	logic main_rf_write_en;
	logic [4:0] main_rf_wr_reg_num;
	logic [31:0] main_rf_write_data;	
	/* verilator lint_on UNDRIVEN */


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
		.rd_reg_num0(main_rf_read_reg_num0), 
		.rd_reg_num1(main_rf_read_reg_num1), 
		.wr_reg_num(main_rf_wr_reg_num), 
		.write_en(main_rf_write_en),
		.write_data(main_rf_write_data),

		.read_data0(main_rf_read_data0),
		.read_data1(main_rf_read_data1)
	);


	rv32i_decode_block decode(
		.clk(clk),
		.rst_n(rst_n),
		
		.inst(fetch_p),
		
		.rs1_data_in(main_rf_read_data0),
		.rs2_data_in(main_rf_read_data1),
		
		.rs1_num_o(main_rf_read_reg_num0),
		.rs2_num_o(main_rf_read_reg_num1),
		
		.decode_pipe(decode_p)
	);


endmodule
