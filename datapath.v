/*
* Datapath
* File that instantiates all of the modules that are used the cache coherency
* project
* TESTING GIT
*/

module datapath #(parameter) (clk, rst, we, re, );

	/* Local Params */
	localparam L1_ADDR_WIDTH = 2;
	localparam L2_ADDR_WIDTH = 3;
	localparam DATA_WIDTH = 8;
	localparam NUM_CORES = 4;

	/* Input signals */
	input clk, we, re;
	input [L1_ADDR_WIDTH-1:0] addr;

	/* Additional signals */
	reg [NUM_CORES-1:0] rd_en, wr_en;
	reg l2_rd_en, l2_wr_en; 

	/* Generate variable */
	genvar i;

	/* Instatiation of L1 caches */
	generate
		for(i = 0; NUM_L1; i = i + 1)
			l1cache U_L1 (.clk(clk), .we(wr_en[i]), .re(re_en[i]), .localAddrIn(), .dIn(), .addrIn(), .dOutBus(), dOutCPU(), .statusOut(), .WH(), .WM(), .RH(), .RM());
	endgenerate

	/* Instantiation of L2 Cache */
	cache U_L2 (.clk(clk), .we(we), .re(re), .d(), .addr(), .q());

	cache_fsm U_FSM (.clk(clk), .rst(rst), .rd_hit(), .rd_miss(), .wr_hit(), .wr_miss(), .l1_write_done(), .written_back(), .modified_data(), .shared_data(), .exclusive_data(), .invalid_data(),
		.snoop_hit_rd(), .snoop_hit_wr(), .wr_back(), .invalid_other(), .rd_en_0(red_en[0]), .wr_en_0(wr_en[0]), .rd_en_1(rd_en[1]), wr_en_1(wr_en[1]), 
		.rd_en_2(rd_en[2]), .wr_en_2(wr_en[2]), .rd_en_3(rd_en[3]), .wr_en_3(wr_en[3]), .l2_rd_en(l2_rd_en), .l2_wr_en(l2_wr_en));

endmodule
