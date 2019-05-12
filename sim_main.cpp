#include "Vtop.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include <iostream>

using namespace std;

Vtop* top = new Vtop;
VerilatedVcdC* waves = new VerilatedVcdC;
int clk_count; 

void print_state(string tag) {
	cout << "[" << tag << "] ";
	printf("fetch_pipe: %0x\n",  top->fetch_p);
}

void cycle() {
	clk_count += 1;
	
	top->clk = 0;
	top->eval();
	waves->dump(10*clk_count - 2);
	
	top->clk = 1;
	top->eval();
	waves->dump(10*clk_count);
	
	top->clk = 0;
	top->eval();
	waves->dump(10*clk_count + 5);
	waves->flush();
}

void reset(int cyc = 10) {
	print_state("reset");
	top->rst_n = 1;
	top->eval();
	top->rst_n = 0;
	top->eval();
	for (int i = 0; i < cyc; i++) {
		cycle();
	}
	top->rst_n = 1;
	top->eval();
}

int main (int argc, char  **argv, char **env) {
	Verilated::commandArgs(argc, argv);
	
	// init trace dump
	clk_count = 0;
	Verilated::traceEverOn(true);
	top->trace (waves, 99);
	waves->open ("cpu.vcd");
	
	reset();

	for (int i = 0; i < 20; i++) {
		cycle();
		print_state("cpu_state");
	}

	// while (!Verilated::gotFinish()) { top->eval(); }
	delete top;
	waves->close();

	exit(0);
}
