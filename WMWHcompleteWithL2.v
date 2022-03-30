module L1cache (clk, CPUwe, CPUre, BUSwe, BUSre, dInCPU, addrInCPU, dOutBus, dOutCPU, addrInBus, addrOutBus, statusIn, statusOut, WH, WM, RH, RM, d0, a0, s0, d1, a1, s1, d2, a2, s2, d3, a3, s3);
	input clk, CPUwe, CPUre, BUSwe, BUSre;				//Clock and write enable
	input [7:0] dInCPU;         	//Data In from CPU
	input [2:0] addrInCPU;			//Address In from CPU
	output [7:0] dOutBus;          //Data In/Out to bus
	output [7:0] dOutCPU;
	input [2:0] addrInBus;
	output [2:0] addrOutBus;       //Address In/Out to bus
	input [1:0] statusIn;
	output [1:0] statusOut;     //Status Out to bus
	output WH;
	output WM;
	output RH;
	output RM;
	output [7:0] d0, d1, d2, d3;
	output [2:0] a0, a1, a2, a3;
	output [1:0] s0, s1, s2, s3;      
	
	integer i, WHout, WMout, RHout, RMout;
	
	reg [7:0] data [3:0];		//Data register
	reg [2:0] addr [3:0];		//Address register
	reg [1:0] theStatus [3:0];	//Status register
	reg [1:0] localAddr; 		//Address of L1 being accessed
	integer dataUpdated; 		//Boolean to determine if data has been updated 
	integer outToCPU;
	integer outToBus;
	integer localAddrMatch;
	integer theStatusOut;
	integer addrOut;
	
	initial 
 	begin 
	 	for (i=0; i<4; i=i+1)			//Initialize data, addr, and status registers
 		begin
 			data[i] = 8'bzzzzzzzz;
 			addr[i] = 3'bzzz;
 			theStatus[i] = 2'b11;
  		end 
  		localAddr = 2'b00;				//Initialize local address to 0
  		dataUpdated = 1;				//Data is up to date
  		localAddrMatch = 2'bzz;
  		theStatusOut = 2'b11;
  		addrOut = 0; 
  	end 
	 
	always @ (posedge clk)
	begin 
		WHout = 0;
		WMout = 0;
		RHout = 0;
		RMout = 0;
		if (CPUwe)		//If write enable
		begin 
			dataUpdated = 0;		//Data is not updated
			for (i=0; i<4; i=i+1)	//Search to see if the address trying to be stored is already stored
			begin
				if (addr[i] == addrInCPU)
				begin 
					$display("Addr %b already exists in this L1. Updating current value.", addrInCPU);
					data[i] = dInCPU;							//Replace the data
					//theStatus[i] = 2'b00;		//Update the status (might not be required)
					dataUpdated = 1;
					addrOut = addrInCPU;
					WHout = 1;						//Data is updated
				end	
			end 
			//Need to add if localAddr == 4 (cache is full)
			if (dataUpdated == 0)
			begin             
				$display("No addr match. Update localAddr: %b", localAddr);
				WMout = 1;
				data[localAddr] = dInCPU;								//Update data at localAddr 
				addr[localAddr] = addrInCPU;							//Update address at localAddr 
				//theStatus[localAddr] = 2'b00;	//Update status at localAddr
				localAddr = localAddr+1;							//Increase localAddr
				dataUpdated = 1;									//Data is updated
				addrOut = addrInCPU;
			end  
		end
		if (CPUre)
		begin  
			for (i=0; i<4; i=i+1)	//Search to see if the address trying to be stored is already stored
			begin
				if (addr[i] == addrInCPU)
				begin 
					RHout = 1;  
					outToCPU = data[i];
				end	
			end
			if (RHout == 0)
			begin
				RMout = 1;
				outToCPU = 'bz;
			end 
		end 
		if (BUSre)
		begin 
			theStatusOut = 2'b11;
			$display("addrInBus: %b", addrInBus);  
			for (i=0; i<4; i=i+1)	//Search to see if the address trying to be stored is already stored
			begin    
				if (addr[i] == addrInBus)
				begin  
					outToBus = data[i]; 
					localAddrMatch = i; 
					$display("localAddrMatch %b", i);
					theStatusOut = theStatus[i];
					$display("BUSre localAddrMatch");
				end	
			end
		end
		if (BUSwe)
		begin 
			$display("THE BUS WE");
			$display("AddrInBus: %b", addrInBus);
			for (i=0; i<4; i=i+1)	//Search to see if the address trying to be stored is already stored
			begin
				if (addr[i] == addrInBus)
				begin    
					localAddrMatch = i;
					theStatus[localAddrMatch] = statusIn;
					$display("BUSwe localAddrMatch");
				end	
			end
		end
	end
	assign dOutBus = outToBus;			//Tristates for inout to bus  
   	assign dOutCPU = CPUre ? outToCPU : 'bz;
  //  assign dOutCPU = outToCPU;
	assign addrOutBus = addrOut;
	assign statusOut = BUSre ? theStatusOut : 'bz;
	assign WH = WHout;   
	assign WM = WMout;  
	assign RH = RHout;  
	assign RM = RMout;   
	assign d0 = data[0];
	assign d1 = data[1];
	assign d2 = data[2];
	assign d3 = data[3];
	assign a0 = addr[0];
	assign a1 = addr[1];
	assign a2 = addr[2];
	assign a3 = addr[3];
	assign s0 = theStatus[0];
	assign s1 = theStatus[1];
	assign s2 = theStatus[2];
	assign s3 = theStatus[3];
endmodule

module L2cache (clk, we, re, d, addr, q, q0, q1, q2, q3, q4, q5, q6, q7);
	input clk, we, re;
	input [7:0] d;
	input [2:0] addr;
	output [7:0] q;
	output [7:0] q0;
	output [7:0] q1;
	output [7:0] q2;
	output [7:0] q3;
	output [7:0] q4;
	output [7:0] q5;
	output [7:0] q6;
	output [7:0] q7;
	
	integer i;
	integer theOutput;
	
	reg [7:0] data [7:0];
	
	initial 
 	begin 
	 	for (i=0; i<8; i=i+1)			//Initialize data, addr, and status registers
 		begin
 			data[i] = 8'b00000000;
  		end    
  	end 
  	
	always @ (posedge clk)
	begin
		if (we)
			data[addr] <= d;
		if (re)          
		begin
			theOutput = data[addr];
		end 
		else
		begin
			theOutput = 8'bzzzzzzzz;
		end 	
	end 
	assign q = theOutput;
	assign q0 = data[0];
	assign q1 = data[1];
	assign q2 = data[2];
	assign q3 = data[3];
	assign q4 = data[4];
	assign q5 = data[5];
	assign q6 = data[6];
	assign q7 = data[7];
endmodule

module theBus (clk, we0, re0, d0In, a0In, s0In, d0Out, a0Out, s0Out, WH0, WM0, RH0, RM0, we1, re1, d1In, a1In, s1In, d1Out, a1Out, s1Out, WH1, WM1, RH1, RM1, we2, re2, d2In, a2In, s2In, d2Out, a2Out, s2Out, WH2, WM2, RH2, RM2, we3, re3, d3In, a3In, s3In, d3Out, a3Out, s3Out, WH3, WM3, RH3, RM3, weL2, reL2, dataToL2, addrToL2, dataFromL2);
	input clk;
	output we0, re0, we1, re1, we2, re2, we3, re3;
	input [7:0] d0In;
	input [2:0] a0In;
	input [1:0] s0In;
	output [7:0] d0Out;
	output [2:0] a0Out;
	output [1:0] s0Out;
	input WH0, WM0, RH0, RM0;
	input [7:0] d1In;
	input [2:0] a1In;
	input [1:0] s1In;
	output [7:0] d1Out;
	output [2:0] a1Out;
	output [1:0] s1Out;
	input WH1, WM1, RH1, RM1;
	input [7:0] d2In;
	input [2:0] a2In;
	input [1:0] s2In;
	output [7:0] d2Out;
	output [2:0] a2Out;
	output [1:0] s2Out;
	input WH2, WM2, RH2, RM2;
	input [7:0] d3In;
	input [2:0] a3In;
	input [1:0] s3In;
	output [7:0] d3Out;
	output [2:0] a3Out;
	output [1:0] s3Out;
	input WH3, WM3, RH3, RM3;
	output weL2, reL2;
	output [7:0] dataToL2;
	output [2:0] addrToL2;
	input [7:0] dataFromL2;
	
	integer state;
	integer thedOut [3:0];
	integer theaOut [3:0];
	integer thesOut [3:0];
	integer thewe [3:0];
	integer there [3:0];
	integer theAddr, theData;
	integer thedOutL2;
	integer theCore;
	integer theSIn [3:0];
	integer theWEL2, theREL2;
	integer i;
	
	initial 
    begin
    	state = 0;
    	thedOut [0] = 0;
    	theaOut [0] = 0;
    	thesOut [0] = 0;
    	thedOut [1] = 0;
    	theaOut [1] = 0;
    	thesOut [1] = 0;
    	thewe [0] = 0;
    	there [0] = 0;
    	thewe [1]= 0;
    	there [1] = 0;
    	theAddr = 3'bzzz;
    	theData = 8'bzzzzzzzz;
    	theCore = 0;
    	theSIn[0] = 0;
    	theSIn[1] = 0;
    	theWEL2 = 0;
    	theREL2 = 0;
    end
    
    always @ (posedge clk)
    begin
    	if (state == 0)
    	begin
    	$display("Waiting state");
    		//Write Miss
    		if (WM0 == 1)
      		begin
      			$display("Outputting addr and re to L11");
    			theAddr = a0In;
    			$display("theAddr: %b", theAddr);
    			theCore = 0;
    		end 
    		if (WM1 == 1)
      		begin
      			$display("Outputting addr and re to L10");
    			theAddr = a1In;
    			$display("theAddr: %b", theAddr);
    			theCore = 1;
    		end 
    		if (WM2 == 1)
      		begin
      			$display("Outputting addr and re to L11");
    			theAddr = a2In;
    			$display("theAddr: %b", theAddr);
    			theCore = 2;
    		end 
    		if (WM3 == 1)
      		begin
      			$display("Outputting addr and re to L10");
    			theAddr = a3In;
    			$display("theAddr: %b", theAddr);
    			theCore = 3;
    		end
    		if (WM0 == 1 || WM1 == 1 || WM2 == 1 || WM3 == 1)
    		begin
    			$display("The core is %b", theCore);
    			$display("WRITE MISS addr: %b    data: %b", theAddr, theData);
    			state = 1;
    			for (i=0; i<4; i=i+1)
    			begin 
    				theaOut [i] = theAddr;
    				there [i] = 1;
    			end 
    		end 
    		
    		//Write Hit
    		if (WH0 == 1)
      		begin
      			$display("Outputting addr and re to L11");
    			theAddr = a0In;
    			$display("theAddr: %b", theAddr);
    			theCore = 0;
    		end 
    		if (WH1 == 1)
      		begin
      			$display("Outputting addr and re to L10");
    			theAddr = a1In;
    			$display("theAddr: %b", theAddr);
    			theCore = 1;
    		end 
    		if (WH2 == 1)
      		begin
      			$display("Outputting addr and re to L11");
    			theAddr = a2In;
    			$display("theAddr: %b", theAddr);
    			theCore = 2;
    		end 
    		if (WH3 == 1)
      		begin
      			$display("Outputting addr and re to L10");
    			theAddr = a3In;
    			$display("theAddr: %b", theAddr);
    			theCore = 3;
    		end
    		if (WH0 == 1 || WH1 == 1 || WH2 == 1 || WH3 == 1)
    		begin
    			$display("The core is %b", theCore);
    			state = 11;
    			theaOut[0] = theAddr;
    			theaOut[1] = theAddr;
    			theaOut[2] = theAddr;
    			theaOut[3] = theAddr;
    			there[0] = 1;
    			there[1] = 1;
    			there[2] = 1;
    			there[3] = 1;
    		end 
    	end 
    	else if (state == 1)
    	begin
    		$display("Waiting for response");
    		state = 2;
    	end 
    	else if (state == 2)
    	begin
    		theSIn[0] = s0In;
    		theSIn[1] = s1In;
    		theSIn[2] = s2In;
    		theSIn[3] = s3In;  
    		$display("In state 2");
    		
    		case (theCore)
    		0: theData = d0In;
    		1: theData = d1In;
    		2: theData = d2In;
    		3: theData = d3In;
    		endcase
    		
    		thewe [theCore] = 1;
    		$display("S0In is %b", s0In);
    		$display("S1In is %b", s1In);
    		$display("S2In is %b", s2In);
    		$display("S3In is %b", s3In);
    		thesOut [theCore] = 2'b00;
    		for (i=0; i<4; i=i+1)
    		begin
    			if (i != theCore)
    			begin
    	   			if (theSIn[i] == 2'b11)
    	   			begin
    		   			$display("L11 didn't have addr. So L10 is Modified");
    		   			//thewe[i] = 1;
    	  			end
    	  			if (theSIn[i] == 2'b00)
    	  			begin 
    					$display("L11 did have addr. So L10 is Shared");
    	   				thesOut [theCore] = 2'b01;
    	   				thesOut [i] = 2'b11;
    	   				thewe[i] = 1;
    	   				theWEL2 = 1;
    	 			end 
    	 		end 
    	 	end    
    		theaOut [theCore] = theAddr;
    		$display("theAddr: %b", theAddr);
    		$display("S0Out: %b   S1Out: %b   S2Out: %b   S3Out: %b", thesOut[0], thesOut[1], thesOut[2], thesOut[3]);
    		for (i=0; i<4; i=i+1)
    		begin
    			if (i != theCore)
    			begin
    				there [i] = 0;
    			end 
    		end 
    		state = 3;
    	end 
    	else if (state == 3)
    	begin  
	    	$display("In state 3");
    		thewe [0] = 0;
    		thewe[1] = 0;
    		thewe[2] = 0;
    		thewe[3] = 0;
    		thesOut [theCore] = 0;
    		theWEL2 = 0;
    		state = 0;
    	end
    	else if (state == 11)
    	begin
    		$display("Waiting for response");
    		state = 12;
    	end 
    	else if (state == 12)
    	begin
    		theSIn[0] = s0In;
    		theSIn[1] = s1In;
    		theSIn[2] = s2In;
    		theSIn[3] = s3In;
    		$display("S0In is %b", s0In);
    		$display("S1In is %b", s1In);
    		$display("S2In is %b", s2In);
    		$display("S3In is %b", s3In);
    		state = 0;
    		thewe[theCore] = 1;
    		if (theSIn[theCore] == 2'b00)
    		begin
    			thesOut[theCore] = 2'b00;
    		end
    		else if (theSIn[theCore] == 2'b01)
    		begin
    			thesOut[theCore] = 2'b00;
    		end
    		else if (theSIn[theCore] == 2'b11)
    		begin
    			theWEL2 = 1;
    			case (theCore)
    				0: theData = d0In;
    				1: theData = d1In;
    				2: theData = d2In;
    				3: theData = d3In;
    			endcase
    			thesOut[theCore] = 2'b01;
    			for (i=0; i<4; i=i+1)
    			begin
    				if (i != theCore)
    				begin
    					thesOut[i] = 2'b11;
    					thewe[i] = 1;
    				end 
    			end 
    		end  
    		state = 13; 
    	end 
    	else if (state == 13)
    	begin
    		thewe [0] = 0;
    		thewe[1] = 0;
    		thewe[2] = 0;
    		thewe[3] = 0;
    		thesOut [theCore] = 0;
    		state = 0;
    		theWEL2 = 0;		
    	end 		  
    end
    
    assign d0Out = thedOut [0];
    assign a0Out = theaOut [0];
    assign s0Out = thesOut [0];
    assign d1Out = thedOut [1];
    assign a1Out = theaOut [1];
    assign s1Out = thesOut [1];
    assign we0 = thewe [0];
    assign re0 = there [0];
    assign we1 = thewe [1];
    assign re1 = there [1];
    assign d2Out = thedOut [2];
    assign a2Out = theaOut [2];
    assign s2Out = thesOut [2];
    assign d3Out = thedOut [3];
    assign a3Out = theaOut [3];
    assign s3Out = thesOut [3];
    assign we2 = thewe [2];
    assign re2 = there [2];
    assign we3 = thewe [3];
    assign re3 = there [3];
    assign weL2 = theWEL2;
    assign reL2 = theREL2;
    assign dataToL2 = theData;
    assign addrToL2 = theAddr;
endmodule

module cache_tb;
	reg clk;
	reg CPUwe [3:0];
	reg CPUre [3:0];
	wire BUSwe [3:0];
	wire BUSre [3:0];
	reg [7:0] dInCPU [3:0];
	reg [2:0] addrInCPU [3:0];
	wire [7:0] dOutBus [3:0];
	wire [2:0] addrInBus [3:0];
	wire [2:0] addrOutBus [3:0];
	wire [1:0] statusOut [3:0];
	wire [1:0] statusIn [3:0];
	wire [7:0] dOutCPU [3:0];
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
	integer i, j;
	
	L1cache testCache0 (.clk(clk), .CPUwe(CPUwe[0]), .CPUre(CPUre[0]), .BUSwe(BUSwe[0]), .BUSre(BUSre[0]), .dInCPU(dInCPU[0]), .addrInCPU(addrInCPU[0]), .dOutBus(dOutBus[0]), .dOutCPU(dOutCPU[0]), .addrInBus(addrInBus[0]), .addrOutBus(addrOutBus[0]), .statusIn(statusIn[0]), .statusOut(statusOut[0]), .WH(WH[0]), .WM(WM[0]), .RH(RH[0]), .RM(RM[0]), .d0(d0[0]), .d1(d0[1]), .d2(d0[2]), .d3(d0[3]), .a0(a0[0]), .a1(a0[1]), .a2(a0[2]), .a3(a0[3]), .s0(s0[0]), .s1(s0[1]), .s2(s0[2]), .s3(s0[3]));
	L1cache testCache1 (.clk(clk), .CPUwe(CPUwe[1]), .CPUre(CPUre[1]), .BUSwe(BUSwe[1]), .BUSre(BUSre[1]), .dInCPU(dInCPU[1]), .addrInCPU(addrInCPU[1]), .dOutBus(dOutBus[1]), .dOutCPU(dOutCPU[1]), .addrInBus(addrInBus[1]), .addrOutBus(addrOutBus[1]), .statusIn(statusIn[1]), .statusOut(statusOut[1]), .WH(WH[1]), .WM(WM[1]), .RH(RH[1]), .RM(RM[1]), .d0(d1[0]), .d1(d1[1]), .d2(d1[2]), .d3(d1[3]), .a0(a1[0]), .a1(a1[1]), .a2(a1[2]), .a3(a1[3]), .s0(s1[0]), .s1(s1[1]), .s2(s1[2]), .s3(s1[3]));
	L1cache testCache2 (.clk(clk), .CPUwe(CPUwe[2]), .CPUre(CPUre[2]), .BUSwe(BUSwe[2]), .BUSre(BUSre[2]), .dInCPU(dInCPU[2]), .addrInCPU(addrInCPU[2]), .dOutBus(dOutBus[2]), .dOutCPU(dOutCPU[2]), .addrInBus(addrInBus[2]), .addrOutBus(addrOutBus[2]), .statusIn(statusIn[2]), .statusOut(statusOut[2]), .WH(WH[2]), .WM(WM[2]), .RH(RH[2]), .RM(RM[2]), .d0(d2[0]), .d1(d2[1]), .d2(d2[2]), .d3(d2[3]), .a0(a2[0]), .a1(a2[1]), .a2(a2[2]), .a3(a2[3]), .s0(s2[0]), .s1(s2[1]), .s2(s2[2]), .s3(s2[3]));
	L1cache testCache3 (.clk(clk), .CPUwe(CPUwe[3]), .CPUre(CPUre[3]), .BUSwe(BUSwe[3]), .BUSre(BUSre[3]), .dInCPU(dInCPU[3]), .addrInCPU(addrInCPU[3]), .dOutBus(dOutBus[3]), .dOutCPU(dOutCPU[3]), .addrInBus(addrInBus[3]), .addrOutBus(addrOutBus[3]), .statusIn(statusIn[3]), .statusOut(statusOut[3]), .WH(WH[3]), .WM(WM[3]), .RH(RH[3]), .RM(RM[3]), .d0(d3[0]), .d1(d3[1]), .d2(d3[2]), .d3(d3[3]), .a0(a3[0]), .a1(a3[1]), .a2(a3[2]), .a3(a3[3]), .s0(s3[0]), .s1(s3[1]), .s2(s3[2]), .s3(s3[3]));
	theBus testBus (.clk(clk), .we0(BUSwe[0]), .re0(BUSre[0]), .d0In(dOutBus[0]), .a0In(addrOutBus[0]), .s0In(statusOut[0]), .a0Out(addrInBus[0]), .s0Out(statusIn[0]), .WH0(WH[0]), .WM0(WM[0]), .RH0(RH[0]), .RM0(RM[0]), .we1(BUSwe[1]), .re1(BUSre[1]), .d1In(dOutBus[1]), .a1In(addrOutBus[1]), .s1In(statusOut[1]), .a1Out(addrInBus[1]), .s1Out(statusIn[1]), .WH1(WH[1]), .WM1(WM[1]), .RH1(RH[1]), .RM1(RM[1]), .we2(BUSwe[2]), .re2(BUSre[2]), .d2In(dOutBus[2]), .a2In(addrOutBus[2]), .s2In(statusOut[2]), .a2Out(addrInBus[2]), .s2Out(statusIn[2]), .WH2(WH[2]), .WM2(WM[2]), .RH2(RH[2]), .RM2(RM[2]), .we3(BUSwe[3]), .re3(BUSre[3]), .d3In(dOutBus[3]), .a3In(addrOutBus[3]), .s3In(statusOut[3]), .a3Out(addrInBus[3]), .s3Out(statusIn[3]), .WH3(WH[3]), .WM3(WM[3]), .RH3(RH[3]), .RM3(RM[3]), .weL2(weL2), .reL2(reL2), .dataToL2(dataInL2), .addrToL2(addrInL2), .dataFromL2(dataOutL2));
	L2cache testCache4 (.clk(clk), .we(weL2), .re(reL2), .d(dataInL2), .addr(addrInL2), .q(dataOutL2), .q0(L2data[0]), .q1(L2data[1]), .q2(L2data[2]), .q3(L2data[3]), .q4(L2data[4]), .q5(L2data[5]), .q6(L2data[6]), .q7(L2data[7]));
	
	initial
	begin 
		//Print initial state of cache 
		CPUwe[0] = 0;
		CPUre[0] = 0;
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
		for (i=0; i<8; i=i+1)
		begin
			$display("L2 %b Data: %b", i, L2data[i]);
		end 
		for (j=0; j<4; j=j+1)
		begin
			$display("L1 cache %b", j);
			$display("WH: %b  , WM: %b  , RH: %b  , RM: %b", WH[j], WM[j], RH[j], RM[j]);
			$display("Bus Lines  -  Data: %b   Addr: %b  Status: %b", dOutBus[j], addrOutBus[j], statusOut[j]);
		end
		
		//WM on Invalid  
		CPUwe[2] = 1;
		dInCPU[2] = 8'b10101010;			//Store values at localAddr = 0
		addrInCPU[2] = 3'b001;
		#CYCLE;
		CPUwe[2] = 0;
		#CYCLE;
		#CYCLE;
		#CYCLE;
		#CYCLE;
		$display("Write %b to addr %b", dInCPU[0], addrInCPU[0]);
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
		for (i=0; i<8; i=i+1)
		begin
			$display("L2 %b Data: %b", i, L2data[i]);
		end
		
		//WM on Invalid 
		CPUwe[0] = 1;
		dInCPU[0] = 8'b11110000;			//Store values at localAddr = 0
		addrInCPU[0] = 3'b011;
		#CYCLE;
		CPUwe[0] = 0;
		#CYCLE;
		#CYCLE;
		#CYCLE;
		#CYCLE;
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
		for (i=0; i<8; i=i+1)
		begin
			$display("L2 %b Data: %b", i, L2data[i]);
		end
		
		//WM on Invalid with addr in other cache 
		CPUwe[1] = 1;
		dInCPU[1] = 8'b00001111;			//Store values at localAddr = 0
		addrInCPU[1] = 3'b011;
		#CYCLE;
		CPUwe[1] = 0;
		#CYCLE;
		#CYCLE;
		#CYCLE
		#CYCLE;		
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
		for (i=0; i<8; i=i+1)
		begin
			$display("L2 %b Data: %b", i, L2data[i]);
		end
		
		//WH on M
		CPUwe[2] = 1;
		dInCPU[2] = 8'b11111111;			//Store values at localAddr = 0
		addrInCPU[2] = 3'b001;
		#CYCLE;
		CPUwe[2] = 0;
		#CYCLE;
		#CYCLE;
		#CYCLE
		#CYCLE;		
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
		for (i=0; i<8; i=i+1)
		begin
			$display("L2 %b Data: %b", i, L2data[i]);
		end
		
		//WH on E
		CPUwe[1] = 1;
		dInCPU[1] = 8'b11001100;			//Store values at localAddr = 0
		addrInCPU[1] = 3'b011;
		#CYCLE;
		CPUwe[1] = 0;
		#CYCLE;
		#CYCLE;
		#CYCLE
		#CYCLE;		
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
		for (i=0; i<8; i=i+1)
		begin
			$display("L2 %b Data: %b", i, L2data[i]);
		end
		
		//WH on I
		CPUwe[0] = 1;
		dInCPU[0] = 8'b00110011;			//Store values at localAddr = 0
		addrInCPU[0] = 3'b011;
		#CYCLE;
		CPUwe[0] = 0;
		#CYCLE;
		#CYCLE;
		#CYCLE
		#CYCLE;		
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
		for (i=0; i<8; i=i+1)
		begin
			$display("L2 %b Data: %b", i, L2data[i]);
		end
		
		$finish; 		
	end
	initial clk = 0;
	always #(CYCLE/2) clk = ~clk;
endmodule