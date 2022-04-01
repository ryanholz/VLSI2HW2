# VLSI2HW2

Cache coherency design using the MESI protocol

- A testbench file is included but our testing was conducted exclusively with the testbench module found inside the cache_coherency_RTL.v file.

- Below is a brief description of all of the CPU side signals needed to interface with the design (also found in the report):
	- CPUwe[i]: CPU write enable
	- CPUre[i]: CPU read enable
	- dInCPU[i]: data input from CPU
	- addrInCPU[i]: address input from CPU
	- dOutCPU[i]: data output to CPU

