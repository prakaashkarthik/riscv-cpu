`include "struct_defines.svh"

module top (
	input clk, 
	input rst_n,

	output [31:0] fetch_p,
	output [`DECODE_PIPE_MSB : 0] decode_p
);


	core cpu(
		.clk(clk), 
		.rst_n(rst_n),

		.fetch_p(fetch_p),
		.decode_p(decode_p)
	);

endmodule
