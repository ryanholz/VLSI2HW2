/*
* Datapath
* File that instantiates all of the modules that are used the cache coherency project.
* Note: L1 and L2 cache modules are from WMWHcompleteWithL2.v file. 
*/

module datapath #(parameter) (clk, rst, CPUwe, CPUre, CPUaddr, CPUdata, );

	/* Local Params */
	localparam L1_ADDR_WIDTH = 2;
	localparam L2_ADDR_WIDTH = 3;
	localparam MESI_WIDTH = 2;
	localparam DATA_WIDTH = 8;
	localparam NUM_CORES = 4;
	localparam NUM_L1_BLOCKS = 4;

	/* Input signals */
	/*
	* Signal Descriptions
	* clk - self explanatory
	* CPUwe/CPUre - read enable and write enable from CPU for each L1 cache
	* CPUaddr/CPUdata - address and data lines from the CPU for L1 cache
	* TODO - Add additional signals for remaining L1 signals and FSM
	*/
	input clk, we, re;
	input [L1_ADDR_WIDTH-1:0] CPUaddr;
	input [NUM_CORES-1:0] CPUre, CPUwe;
	input [DATA_WIDTH-1:0] CPUdata;

	/* Output signals */
	/*
	* Signal descriptions
	* TODO - Discuss output signals for the overall design
	*/

	/* Additional signals */
	/*
	* Signal description
	* l2_re/l2_we - read and write enable for the l2 cache
	* WM/WH/RM/RH - read/write hit/miss signals that go to the fsm
	* dx - data output from each block in L1, with x being the cache number
	* ax - address lines coming out of each block in L1, with x being cache number
	* sx - status lines for each block in L1, with x being cache number
	* l2_block_out - output signal for each block of l2 cache
	* TODO - Unsure if l2 signals are coming from controller or CPU (my guess is controller)
	*/
	reg l2_re, l2_we;
	reg WM, WH, RM, RH;
	reg [DATA_WIDTH-1:0] l1_data [NUM_CORES-1:0][NUM_L1_BLOCKS-1:0];
	reg [L2_ADDR_WIDTH-1:0] l1_addr [NUM_CORES-1:0][NUM_L1_BLOCKS-1:0];
	reg [MESI_WIDTH-1:0] l1_status [NUM_CORES-1:0][NUM_L1_BLOCKS-1:0];
	reg [DATA_WIDTH-1:0] l2_block_out [NUM_L2_BLOCKS-1:0];

	/* Generate variable */
	genvar i;
	
	/* Instatiation of L1 caches */
       generate
	       for(i = 0; i < NUM_CORES; i = i + 1)
			l1cache U_L1 (.clk(clk), .CPUwe(CPUwe[i]), .CPUre(CPUre[i]), .BUSwe(), .BUSre(), .dInCPU(CPUdata), .addrInCPU(CPUaddr), .dOutBus(), dOutCPU(), .addrInBus(), 
				.addrOutBus(), .statusIn(), .statusOut(), .WH(WH), .WM(WM), .RH(RH), .RM(RM), .d0(l1_data[i][0]), .a0(l1_addr[i][1]), .s0(l1_status[i][0]), 
				.d1(l1_data[i][1]), .a1(l1_addr[i][1]), .s1(l1_status[i][1]), .d2(l1_data[i][2]), .a2(l1_addr[i][2]), .s2(l1_status[i][2]), 
				.d3(l1_data[i][3]), .a3(l1_addr[i][3]), .s3(l1_status[i][3]));
	endgenerate

	/* Instantiation of L2 Cache */
	l2cache U_L2 (.clk(clk), .we(l2_we), .re(l2_re), .d(), .addr(), .q0(l2_block_out[0]), .q1(l2_block_out[1]), .q2(l2_block_out[2]), .q3(l2_block_out[3]), 
		.q4(l2_block_out[4]), .q5(l2_block_out[5]), .q6(l2_block_out[6]), .q7(l2_block_out[7]));

	cache_fsm U_FSM (.clk(clk), .rst(rst), .rd_hit(), .rd_miss(), .wr_hit(), .wr_miss(), .l1_write_done(), .written_back(), .modified_data(), .shared_data(), .exclusive_data(), .invalid_data(),
		.snoop_hit_rd(), .snoop_hit_wr(), .wr_back(), .invalid_other(), .rd_en_0(red_en[0]), .wr_en_0(wr_en[0]), .rd_en_1(rd_en[1]), wr_en_1(wr_en[1]), 
		.rd_en_2(rd_en[2]), .wr_en_2(wr_en[2]), .rd_en_3(rd_en[3]), .wr_en_3(wr_en[3]), .l2_rd_en(l2_rd_en), .l2_wr_en(l2_wr_en));

endmodule
