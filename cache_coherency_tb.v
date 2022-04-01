module cache_tb;
	reg clk;
	reg CPUwe [3:0];
	reg CPUre [3:0];
	wire BUSweS [3:0];
	wire BUSweD [3:0];
	wire BUSre [3:0];
	reg [7:0] dInCPU [3:0];
	reg [2:0] addrInCPU [3:0];
	wire [7:0] dOutBus [3:0];
	wire [2:0] addrInBus [3:0];
	wire [2:0] addrOutBus [3:0];
	wire [1:0] statusOut [3:0];
	wire [1:0] statusIn [3:0];
	wire [7:0] dOutCPU [3:0];
	wire [7:0] dInBus [3:0];
	wire WH [3:0];
	wire WM [3:0];
	wire RH [3:0];
	wire RM [3:0];
	wire [7:0] d0 [3:0];
	wire [2:0] a0 [3:0];
	wire [1:0] s0 [3:0];
	wire [7:0] d1 [3:0];
	wire [2:0] a1 [3:0];
	wire [1:0] s1 [3:0];
	wire [7:0] d2 [3:0];
	wire [2:0] a2 [3:0];
	wire [1:0] s2 [3:0];
	wire [7:0] d3 [3:0];
	wire [2:0] a3 [3:0];
	wire [1:0] s3 [3:0];
	wire weL2, reL2;
	wire [7:0] dataInL2;
	wire [2:0] addrInL2;
	wire [7:0] dataOutL2;
	wire [7:0] L2data [7:0];
	
	localparam CYCLE = 20;
	integer write_data;
	integer i, j, core;
	
	L1cache testCache0 (.clk(clk), .CPUwe(CPUwe[0]), .CPUre(CPUre[0]), .BUSweD(BUSweD[0]), .BUSweS(BUSweS[0]), .BUSre(BUSre[0]), .dInCPU(dInCPU[0]), .dInBus(dInBus[0]), .addrInCPU(addrInCPU[0]), .dOutBus(dOutBus[0]), .dOutCPU(dOutCPU[0]), .addrInBus(addrInBus[0]), .addrOutBus(addrOutBus[0]), .statusIn(statusIn[0]), .statusOut(statusOut[0]), .WH(WH[0]), .WM(WM[0]), .RH(RH[0]), .RM(RM[0]), .d0(d0[0]), .d1(d0[1]), .d2(d0[2]), .d3(d0[3]), .a0(a0[0]), .a1(a0[1]), .a2(a0[2]), .a3(a0[3]), .s0(s0[0]), .s1(s0[1]), .s2(s0[2]), .s3(s0[3]));
	L1cache testCache1 (.clk(clk), .CPUwe(CPUwe[1]), .CPUre(CPUre[1]), .BUSweD(BUSweD[1]), .BUSweS(BUSweS[1]), .BUSre(BUSre[1]), .dInCPU(dInCPU[1]), .dInBus(dInBus[1]), .addrInCPU(addrInCPU[1]), .dOutBus(dOutBus[1]), .dOutCPU(dOutCPU[1]), .addrInBus(addrInBus[1]), .addrOutBus(addrOutBus[1]), .statusIn(statusIn[1]), .statusOut(statusOut[1]), .WH(WH[1]), .WM(WM[1]), .RH(RH[1]), .RM(RM[1]), .d0(d1[0]), .d1(d1[1]), .d2(d1[2]), .d3(d1[3]), .a0(a1[0]), .a1(a1[1]), .a2(a1[2]), .a3(a1[3]), .s0(s1[0]), .s1(s1[1]), .s2(s1[2]), .s3(s1[3]));
	L1cache testCache2 (.clk(clk), .CPUwe(CPUwe[2]), .CPUre(CPUre[2]), .BUSweD(BUSweD[2]), .BUSweS(BUSweS[2]), .BUSre(BUSre[2]), .dInCPU(dInCPU[2]), .dInBus(dInBus[2]), .addrInCPU(addrInCPU[2]), .dOutBus(dOutBus[2]), .dOutCPU(dOutCPU[2]), .addrInBus(addrInBus[2]), .addrOutBus(addrOutBus[2]), .statusIn(statusIn[2]), .statusOut(statusOut[2]), .WH(WH[2]), .WM(WM[2]), .RH(RH[2]), .RM(RM[2]), .d0(d2[0]), .d1(d2[1]), .d2(d2[2]), .d3(d2[3]), .a0(a2[0]), .a1(a2[1]), .a2(a2[2]), .a3(a2[3]), .s0(s2[0]), .s1(s2[1]), .s2(s2[2]), .s3(s2[3]));
	L1cache testCache3 (.clk(clk), .CPUwe(CPUwe[3]), .CPUre(CPUre[3]), .BUSweD(BUSweD[3]), .BUSweS(BUSweS[3]), .BUSre(BUSre[3]), .dInCPU(dInCPU[3]), .dInBus(dInBus[3]), .addrInCPU(addrInCPU[3]), .dOutBus(dOutBus[3]), .dOutCPU(dOutCPU[3]), .addrInBus(addrInBus[3]), .addrOutBus(addrOutBus[3]), .statusIn(statusIn[3]), .statusOut(statusOut[3]), .WH(WH[3]), .WM(WM[3]), .RH(RH[3]), .RM(RM[3]), .d0(d3[0]), .d1(d3[1]), .d2(d3[2]), .d3(d3[3]), .a0(a3[0]), .a1(a3[1]), .a2(a3[2]), .a3(a3[3]), .s0(s3[0]), .s1(s3[1]), .s2(s3[2]), .s3(s3[3]));
	theBus testBus (.clk(clk), .weD0(BUSweD[0]), .weS0(BUSweS[0]), .re0(BUSre[0]), .d0In(dOutBus[0]), .a0In(addrOutBus[0]), .s0In(statusOut[0]), .d0Out(dInBus[0]), .a0Out(addrInBus[0]), .s0Out(statusIn[0]), .WH0(WH[0]), .WM0(WM[0]), .RH0(RH[0]), .RM0(RM[0]), .weD1(BUSweD[1]), .weS1(BUSweS[1]), .re1(BUSre[1]), .d1In(dOutBus[1]), .a1In(addrOutBus[1]), .s1In(statusOut[1]), .d1Out(dInBus[1]), .a1Out(addrInBus[1]), .s1Out(statusIn[1]), .WH1(WH[1]), .WM1(WM[1]), .RH1(RH[1]), .RM1(RM[1]), .weD2(BUSweD[2]), .weS2(BUSweS[2]), .re2(BUSre[2]), .d2In(dOutBus[2]), .a2In(addrOutBus[2]), .s2In(statusOut[2]), .d2Out(dInBus[2]), .a2Out(addrInBus[2]), .s2Out(statusIn[2]), .WH2(WH[2]), .WM2(WM[2]), .RH2(RH[2]), .RM2(RM[2]), .weD3(BUSweD[3]), .weS3(BUSweS[3]), .re3(BUSre[3]), .d3In(dOutBus[3]), .a3In(addrOutBus[3]), .s3In(statusOut[3]), .d3Out(dInBus[3]), .a3Out(addrInBus[3]), .s3Out(statusIn[3]), .WH3(WH[3]), .WM3(WM[3]), .RH3(RH[3]), .RM3(RM[3]), .weL2(weL2), .reL2(reL2), .dataToL2(dataInL2), .addrToL2(addrInL2), .dataFromL2(dataOutL2));
	L2cache testCache4 (.clk(clk), .we(weL2), .re(reL2), .d(dataInL2), .addr(addrInL2), .q(dataOutL2), .q0(L2data[0]), .q1(L2data[1]), .q2(L2data[2]), .q3(L2data[3]), .q4(L2data[4]), .q5(L2data[5]), .q6(L2data[6]), .q7(L2data[7]));
	
	initial begin 
		// Dumpfile used for waveform 
		$dumpfile("hw2.vcd");
		$dumpvars();

		//Print initial state of cache 
		$display("Initial");
		$display("L1 0  d0: %b  d1: %b  d2:  %b  d3:  %b", d0[0], d0[1], d0[2], d0[3]);
		$display("L1 0  a0: %b       a1: %b       a2:  %b       a3:  %b", a0[0], a0[1], a0[2], a0[3]);
		$display("L1 0  s0: %b        s1: %b        s2:  %b        s3:  %b", s0[0], s0[1], s0[2], s0[3]);
		$display("L1 1  d0: %b  d1: %b  d2:  %b  d3:  %b", d1[0], d1[1], d1[2], d1[3]);
		$display("L1 1  a0: %b       a1: %b       a2:  %b       a3:  %b", a1[0], a1[1], a1[2], a1[3]);
		$display("L1 1  s0: %b        s1: %b        s2:  %b        s3:  %b", s1[0], s1[1], s1[2], s1[3]);
		$display("L1 2  d0: %b  d1: %b  d2:  %b  d3:  %b", d2[0], d2[1], d2[2], d2[3]);
		$display("L1 2  a0: %b       a1: %b       a2:  %b       a3:  %b", a2[0], a2[1], a2[2], a2[3]);
		$display("L1 2  s0: %b        s1: %b        s2:  %b        s3:  %b", s2[0], s2[1], s2[2], s2[3]);
		$display("L1 3  d0: %b  d1: %b  d2:  %b  d3:  %b", d3[0], d3[1], d3[2], d3[3]);
		$display("L1 3  a0: %b       a1: %b       a2:  %b       a3:  %b", a3[0], a3[1], a3[2], a3[3]);
		$display("L1 3  s0: %b        s1: %b        s2:  %b        s3:  %b", s3[0], s3[1], s3[2], s3[3]);
		
		//WM on Invalid
		core = 2;  
		CPUwe[core] = 1;
		dInCPU[core] = 8'b10101010;			
		addrInCPU[core] = 3'b001;
		#CYCLE;
		CPUwe[core] = 0;
		#CYCLE;
		#CYCLE;
		#CYCLE;
		#CYCLE;
		$display("Write %b to addr %b on core %b", dInCPU[core], addrInCPU[core], core);
		$display("WM no other copies");
		$display("L1 0  d0: %b  d1: %b  d2:  %b  d3:  %b", d0[0], d0[1], d0[2], d0[3]);
		$display("L1 0  a0: %b       a1: %b       a2:  %b       a3:  %b", a0[0], a0[1], a0[2], a0[3]);
		$display("L1 0  s0: %b        s1: %b        s2:  %b        s3:  %b", s0[0], s0[1], s0[2], s0[3]);
		$display("L1 1  d0: %b  d1: %b  d2:  %b  d3:  %b", d1[0], d1[1], d1[2], d1[3]);
		$display("L1 1  a0: %b       a1: %b       a2:  %b       a3:  %b", a1[0], a1[1], a1[2], a1[3]);
		$display("L1 1  s0: %b        s1: %b        s2:  %b        s3:  %b", s1[0], s1[1], s1[2], s1[3]);
		$display("L1 2  d0: %b  d1: %b  d2:  %b  d3:  %b", d2[0], d2[1], d2[2], d2[3]);
		$display("L1 2  a0: %b       a1: %b       a2:  %b       a3:  %b", a2[0], a2[1], a2[2], a2[3]);
		$display("L1 2  s0: %b        s1: %b        s2:  %b        s3:  %b", s2[0], s2[1], s2[2], s2[3]);
		$display("L1 3  d0: %b  d1: %b  d2:  %b  d3:  %b", d3[0], d3[1], d3[2], d3[3]);
		$display("L1 3  a0: %b       a1: %b       a2:  %b       a3:  %b", a3[0], a3[1], a3[2], a3[3]);
		$display("L1 3  s0: %b        s1: %b        s2:  %b        s3:  %b", s3[0], s3[1], s3[2], s3[3]);
		for (i=0; i<8; i=i+1) begin
			$display("L2 %b Data: %b", i, L2data[i]);
		end
		
		//RM all Invalid
		core = core;
		CPUre[core] = 1;		
		addrInCPU[core] = 3'b101;
		#CYCLE;
		#CYCLE;
		#CYCLE;
		#CYCLE;
		CPUre[core] = 0;
	   	#CYCLE;
	   	#CYCLE; 
	   	#CYCLE;
	   	$display("Read addr %b from core %b", addrInCPU[core], core);
	   	$display("RM no valid copies");
		$display("L1 0  d0: %b  d1: %b  d2:  %b  d3:  %b", d0[0], d0[1], d0[2], d0[3]);
		$display("L1 0  a0: %b       a1: %b       a2:  %b       a3:  %b", a0[0], a0[1], a0[2], a0[3]);
		$display("L1 0  s0: %b        s1: %b        s2:  %b        s3:  %b", s0[0], s0[1], s0[2], s0[3]);
		$display("L1 1  d0: %b  d1: %b  d2:  %b  d3:  %b", d1[0], d1[1], d1[2], d1[3]);
		$display("L1 1  a0: %b       a1: %b       a2:  %b       a3:  %b", a1[0], a1[1], a1[2], a1[3]);
		$display("L1 1  s0: %b        s1: %b        s2:  %b        s3:  %b", s1[0], s1[1], s1[2], s1[3]);
		$display("L1 2  d0: %b  d1: %b  d2:  %b  d3:  %b", d2[0], d2[1], d2[2], d2[3]);
		$display("L1 2  a0: %b       a1: %b       a2:  %b       a3:  %b", a2[0], a2[1], a2[2], a2[3]);
		$display("L1 2  s0: %b        s1: %b        s2:  %b        s3:  %b", s2[0], s2[1], s2[2], s2[3]);
		$display("L1 3  d0: %b  d1: %b  d2:  %b  d3:  %b", d3[0], d3[1], d3[2], d3[3]);
		$display("L1 3  a0: %b       a1: %b       a2:  %b       a3:  %b", a3[0], a3[1], a3[2], a3[3]);
		$display("L1 3  s0: %b        s1: %b        s2:  %b        s3:  %b", s3[0], s3[1], s3[2], s3[3]);
		for (i=0; i<8; i=i+1) begin
			$display("L2 %b Data: %b", i, L2data[i]);
		end 
		
		//WM on Invalid / Other modified 
		core = 0;
		CPUwe[core] = 1;
		dInCPU[core] = 8'b11110000;		
		addrInCPU[core] = 3'b001;
		#CYCLE;
		CPUwe[core] = 0;
		#CYCLE;
		#CYCLE;
		#CYCLE;
		#CYCLE;
		$display("Write %b to addr %b on core %b", dInCPU[core], addrInCPU[core], core);
		$display("WM other copy Modified");
		$display("L1 0  d0: %b  d1: %b  d2:  %b  d3:  %b", d0[0], d0[1], d0[2], d0[3]);
		$display("L1 0  a0: %b       a1: %b       a2:  %b       a3:  %b", a0[0], a0[1], a0[2], a0[3]);
		$display("L1 0  s0: %b        s1: %b        s2:  %b        s3:  %b", s0[0], s0[1], s0[2], s0[3]);

