module top (
	input clk, 
	input rst_n,

	output [31:0] fetch_p
);


	core cpu(
		.clk(clk), 
		.rst_n(rst_n),

		.fetch_p(fetch_p)
	);

endmodule
