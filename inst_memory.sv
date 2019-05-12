module inst_memory (
	input  [5:0]  addr,
	output [31:0] data
);

	logic [31:0] mem [63:0]; 

	initial begin
		$readmemh("memfile.dat", mem);
	end

	assign data = mem[addr];
	
	// always begin
	//	$display("Input addr: 0x%x; Output instruction: 0x%x", addr, data);
	// end
endmodule 
