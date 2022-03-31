module L1cache (clk, CPUwe, CPUre, BUSweD, BUSweS, BUSre, dInCPU, dInBus, addrInCPU, dOutBus, dOutCPU, addrInBus, addrOutBus, statusIn, statusOut, WH, WM, RH, RM, d0, a0, s0, d1, a1, s1, d2, a2, s2, d3, a3, s3);
	input clk, CPUwe, CPUre, BUSweD, BUSweS, BUSre;				//Clock and write enable
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
	input [7:0] dInBus;     
	
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
	
	initial begin 
	 	for (i=0; i<4; i=i+1) begin			//Initialize data, addr, and status registers
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
	 
	always @ (posedge clk) begin 
		WHout = 0;
		WMout = 0;
		RHout = 0;
		RMout = 0;
		if (CPUwe) begin		//If write enable
			dataUpdated = 0;		//Data is not updated
			for (i=0; i<4; i=i+1) begin	//Search to see if the address trying to be stored is already stored
				if (addr[i] == addrInCPU) begin 
					//$display("Addr %b already exists in this L1. Updating current value with %b.", addrInCPU, dInCPU);
					data[i] = dInCPU;							//Replace the data
					//theStatus[i] = 2'b00;		//Update the status (might not be required)
					dataUpdated = 1;
					addrOut = addrInCPU;
					WHout = 1;						//Data is updated
				end	
			end 
			//Need to add if localAddr == 4 (cache is full)
			if (dataUpdated == 0) begin             
				//$display("No addr match. Update localAddr: %b", localAddr);
				WMout = 1;
				data[localAddr] = dInCPU;								//Update data at localAddr 
				addr[localAddr] = addrInCPU;							//Update address at localAddr 
				//theStatus[localAddr] = 2'b00;	//Update status at localAddr
				localAddr = localAddr+1;							//Increase localAddr
				dataUpdated = 1;									//Data is updated
				addrOut = addrInCPU;
			end
			addrOut = addrInCPU;  
		end
		if (CPUre) begin  
			for (i=0; i<4; i=i+1) begin	//Search to see if the address trying to be stored is already stored
				if (addr[i] == addrInCPU) begin 
					RHout = 1;  
					outToCPU = data[i];
				end	
			end
			if (RHout == 0) begin
				RMout = 1;
				outToCPU = 'bz;
				addrOut = addrInCPU;
			end 
		end 
		if (BUSre) begin 
			theStatusOut = 2'b11;
			//addrOut = addrInBus;
			//$display("addrInBus: %b", addrInBus);  
			for (i=0; i<4; i=i+1) begin	//Search to see if the address trying to be stored is already stored
				if (addr[i] == addrInBus) begin  
					outToBus = data[i]; 
					localAddrMatch = i; 
					//$display("localAddrMatch %b", i);
					theStatusOut = theStatus[i];
				end	
			end
		end
		if (BUSweS) begin 
			dataUpdated = 0;
			//$display("THE BUS WE");
			//$display("AddrInBus: %b", addrInBus);
			for (i=0; i<4; i=i+1) begin	//Search to see if the address trying to be stored is already stored
				if (addr[i] == addrInBus) begin 
					//$display("addr[i]: %b", addr[i]);   
					localAddrMatch = i;
					theStatus[localAddrMatch] = statusIn;
					//$display("Status In: %b", statusIn);
					if (BUSweD) data[localAddrMatch] = dInBus;
					//$display("Data In: %b", dInBus);
					dataUpdated = 1;
					//$display("BUSwe localAddrMatch");
				end	
			end
			//Need to add if localAddr == 4 (cache is full)
			if (dataUpdated == 0) begin             
				//$display("No addr match. Update localAddr: %b", localAddr);
				if (BUSweD) data[localAddr] = dInBus;								//Update data at localAddr 
				//$display("Data In: %b", dInBus);
				addr[localAddr] = addrInCPU;							//Update address at localAddr 
				theStatus[localAddr] = statusIn;	//Update status at localAddr
				localAddr = localAddr+1;							//Increase localAddr
				dataUpdated = 1;									//Data is updated
				addrOut = addrInCPU;
			end 
		end
	end
	assign dOutBus = outToBus;			//Tristates for inout to bus  
   	assign dOutCPU = 1 ? outToCPU : 'bz;
  //  assign dOutCPU = outToCPU;
	assign addrOutBus = addrOut;
	assign statusOut = theStatusOut;
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
	
	initial begin 
	 	for (i=0; i<8; i=i+1) begin			//Initialize data, addr, and status registers
 			data[i] = 8'b00000000;
  		end    
  	end 
  	
	always @ (posedge clk) begin
		if (we)
			data[addr] <= d;
		if (re) begin
			theOutput = data[addr];
		end 
		else begin
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

module theBus (clk, weD0, weS0, re0, d0In, a0In, s0In, d0Out, a0Out, s0Out, WH0, WM0, RH0, RM0, weD1, weS1, re1, d1In, a1In, s1In, d1Out, a1Out, s1Out, WH1, WM1, RH1, RM1, weD2, weS2, re2, d2In, a2In, s2In, d2Out, a2Out, s2Out, WH2, WM2, RH2, RM2, weD3, weS3, re3, d3In, a3In, s3In, d3Out, a3Out, s3Out, WH3, WM3, RH3, RM3, weL2, reL2, dataToL2, addrToL2, dataFromL2);
	input clk;
	output weD0, weS0, weD1, weS1, weD2, weS2, weD3, weS3;
	output re0, re1, re2, re3;
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
	integer theweD [3:0];
	integer theweS [3:0];
	integer there [3:0];
	integer theAddr, theData;
	integer thedOutL2;
	integer theCore;
	integer theSIn [3:0];
	integer theWEL2, theREL2;
	integer i;
	
	initial begin            //idk if we need these
    	state = 0;
    	thedOut [0] = 0;
    	theaOut [0] = 0;
    	thesOut [0] = 0;
    	thedOut [1] = 0;
    	theaOut [1] = 0;
    	thesOut [1] = 0;
    	theweD [0] = 0;		//Bus write enable for data
    	theweS [0] = 0;		//Bus write enable for status
    	there [0] = 0;
       //	thewe [1]= 0;
    	//there [1] = 0;
    	theAddr = 3'bzzz;
    	theData = 8'bzzzzzzzz;
    	theCore = 0;
    	theSIn[0] = 0;
    	theSIn[1] = 0;
    	theWEL2 = 0;
    	theREL2 = 0;
    end
    
    always @ (posedge clk) begin
    	if (state == 0) begin
    	//$display("Waiting state");
    		//Write Miss
    		if (WM0 == 1) begin
      			//$display("Outputting addr and re to L11");
    			theAddr = a0In;
    			//$display("theAddr: %b", theAddr);
    			theCore = 0;
    		end 
    		if (WM1 == 1) begin
      			//$display("Outputting addr and re to L100000000000");
    			theAddr = a1In;
    			//$display("theAddr: %b", theAddr);
    			theCore = 1;
    		end 
    		if (WM2 == 1) begin
      			//$display("Outputting addr and re to L11");
    			theAddr = a2In;
    			//$display("theAddr: %b", theAddr);
    			theCore = 2;
    		end 
    		if (WM3 == 1) begin
      			//$display("Outputting addr and re to L10");
    			theAddr = a3In;
    			//$display("theAddr: %b", theAddr);
    			theCore = 3;
    		end
    		if (WM0 == 1 || WM1 == 1 || WM2 == 1 || WM3 == 1) begin 
    			//$display("I SENSE A WRITE MISS");
    			//$display("The core is %b", theCore);
    			state = 1;
    		   	for (i=0; i<4; i=i+1) begin 
    				theaOut [i] = theAddr;
    				there [i] = 1;
    			end             
    			theaOut[0] = theAddr;
    			theaOut[1] = theAddr;
    			theaOut[2] = theAddr;
    			theaOut[3] = theAddr;
    			there[0] = 1;
    			there[1] = 1;
    			there[2] = 1;
    			there[3] = 1;
    			//$display("The real address is: %b", theAddr); 
    		end 
    		
    		//Write Hit
    		if (WH0 == 1) begin
      			//$display("Outputting addr and re to L11");
    			theAddr = a0In;
    		   //	$display("theAddr: %b", theAddr);
    			theCore = 0;
    		end 
    		if (WH1 == 1) begin
      			//$display("Outputting addr and re to L10");
    			theAddr = a1In;
    			//$display("theAddr: %b", theAddr);
    			theCore = 1;
    		end 
    		if (WH2 == 1) begin
      			//$display("Outputting addr and re to L11");
    			theAddr = a2In;
    			//$display("theAddr: %b", theAddr);
    			theCore = 2;
    		end 
    		if (WH3 == 1) begin
      			//$display("Outputting addr and re to L10");
    			theAddr = a3In;
    			//$display("theAddr: %b", theAddr);
    			theCore = 3;
    		end
    		if (WH0 == 1 || WH1 == 1 || WH2 == 1 || WH3 == 1) begin
    			//$display("I SENSE A WRITE HIT");
    			//$display("The core is %b", theCore);
    			state = 11;
    			theaOut[0] = theAddr;
    			theaOut[1] = theAddr;
    			theaOut[2] = theAddr;
    			theaOut[3] = theAddr;
    			there[0] = 1;
    			there[1] = 1;
    			there[2] = 1;
    			there[3] = 1;
    			//if (WH0) theData = d0In;
    			//if (WH1) theData = d1In;
    			//if (WH2) theData = d2In;
    			//if (WH3) theData = d3In;
    			/*for (i=0; i<4; i=i+1)
    			begin
    				if (i != theCore)
    				begin
    					there[i] = 1;
    				end 
    			end         */
    		end 
    		
    		//Read Miss
    		if (RM0 == 1) begin
      			//$display("Outputting addr and re to L101");
    			theAddr = a0In;
    			//$display("theAddr: %b", theAddr);
    			theCore = 0;
    		end 
    		if (RM1 == 1) begin
      			//$display("Outputting addr and re to L11");
    			theAddr = a1In;
    		   //	$display("the ADDRESS: %b", theAddr);
    		   //	$display("theAddr: %b", theAddr);
    			theCore = 1;
    		end 
    		if (RM2 == 1) begin
      			//$display("Outputting addr and re to L12");
    			theAddr = a2In;
    			//$display("theAddr: %b", theAddr);
    			theCore = 2;
    		end 
    		if (RM3 == 1) begin
      			//$display("Outputting addr and re to L13");
    			theAddr = a3In;
    			//$display("theAddr: %b", theAddr);
    			theCore = 3;
    		end
    		if (RM0 == 1 || RM1 == 1 || RM2 == 1 || RM3 == 1) begin 
    			//$display("I SENSE A READ MISS");
    			//$display("The core is %b", theCore);
    			state = 21;
    			theaOut[0] = theAddr;
    			theaOut[1] = theAddr;
    			theaOut[2] = theAddr;
    			theaOut[3] = theAddr;
    			there[0] = 1;
    			there[1] = 1;
    			there[2] = 1;
    			there[3] = 1;
    		end
    		
    		//Read Hit
    		if (RH0 == 1) begin
      			//$display("Outputting addr and re to L10000000");
    			theAddr = a0In;
    			//$display("theAddr: %b", theAddr);
    			theCore = 0;
    		end 
    		if (RH1 == 1) begin
      			//$display("Outputting addr and re to L11111111");
    			theAddr = a1In;
    			//$display("the ADDRESS: %b", theAddr);
    		   //	$display("theAddr: %b", theAddr);
    			theCore = 1;
    		end 
    		if (RH2 == 1) begin
      			//$display("Outputting addr and re to L12222222222");
    			theAddr = a2In;
    			//$display("theAddr: %b", theAddr);
    			theCore = 2;
    		end 
    		if (RH3 == 1) begin
      			//$display("Outputting addr and re to L1333333333");
    			theAddr = a3In;
    			//$display("theAddr: %b", theAddr);
    			theCore = 3;
    		end
    		if (RH0 == 1 || RH1 == 1 || RH2 == 1 || RH3 == 1) begin 
    			//$display("I SENSE A READ HIT");
    			//$display("The core is %b", theCore);
    			state = 31;
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
    	else if (state == 1) begin
    		//$display("Waiting for response");
    		state = 2;
    	end 
    	else if (state == 2) begin
    		theSIn[0] = s0In;
    		theSIn[1] = s1In;
    		theSIn[2] = s2In;
    		theSIn[3] = s3In;  
    		//$display("In state 2");
    		
    		case (theCore)
    		0: theData = d0In;
    		1: theData = d1In;
    		2: theData = d2In;
    		3: theData = d3In;
    		endcase
    		thedOut[theCore] = theData;
    		//$display("The data: %b", thedOut[theCore]);
    		
    		
    		theweS [theCore] = 1;
    		theweD [theCore] = 1;
    		//$display("S0In is %b", s0In);
    		//$display("S1In is %b", s1In);
    		//$display("S2In is %b", s2In);
    		//$display("S3In is %b", s3In);
    		thesOut [theCore] = 2'b00;
    		for (i=0; i<4; i=i+1) begin
    			if (i != theCore) begin
    	   			if (theSIn[i] == 2'b11) begin
    		   			//$display("L11 didn't have addr. So L10 is Modified");
    		   			//thewe[i] = 1;
    	  			end
    	  			if (theSIn[i] == 2'b00) begin 
    					//$display("L11 did have addr. So L10 is Shared");
    	   				thesOut [theCore] = 2'b01;
    	   				thesOut [i] = 2'b11;
    	   				theweS[i] = 1;
    	   				theweD[i] = 0;
    	   				theWEL2 = 1;
    	 			end 
    	 			if (theSIn[i] == 2'b01) begin 
    					//$display("L11 did have addr. So L10 is Shared");
    	   				thesOut [theCore] = 2'b01;
    	   				thesOut [i] = 2'b11;
    	   				theweS[i] = 1;
    	   				theweD[i] = 0;
    	   				//theWEL2 = 1;
    	 			end 
    	 		end 
    	 	end    
    		theaOut [theCore] = theAddr;
    		//$display("theAddr: %b", theAddr);
    		//$display("S0Out: %b   S1Out: %b   S2Out: %b   S3Out: %b", thesOut[0], thesOut[1], thesOut[2], thesOut[3]);
    		for (i=0; i<4; i=i+1) begin
    			if (i != theCore) begin
    				there [i] = 0;
    			end 
    		end 
    		state = 3;
    	end 
    	else if (state == 3) begin  
	    	//$display("In state 3");
    		theweS[0] = 0;
    		theweS[1] = 0;
    		theweS[2] = 0;
    		theweS[3] = 0;
    		theweD[0] = 0;
    		theweD[1] = 0;
    		theweD[2] = 0;
    		theweD[3] = 0;
    		thesOut [theCore] = 0;
    		theWEL2 = 0;
    		state = 0;
    	end
    	else if (state == 11) begin
    		//$display("Waiting for response");
    		state = 12;
    	end 
    	else if (state == 12) begin
    		theSIn[0] = s0In;
    		theSIn[1] = s1In;
    		theSIn[2] = s2In;
    		theSIn[3] = s3In;
    		//$display("S0In is %b", s0In);
    		//$display("S1In is %b", s1In);
    		//$display("S2In is %b", s2In);
    		//$display("S3In is %b", s3In);
    		state = 0;
    		theweS[theCore] = 1;
    		//theweD[theCore] = 1;
    		//thedOut[theCore] = theData;
    	/*	if (WH0 == 1) begin	
	    	thedOut[theCore] = d0In;
	    	$display("ITS WH0 with d0In %b", d0In); end 
    		if (WH1 == 1) begin	
	    	thedOut[theCore] = d1In;
	    	$display("ITS WH1 with d0In %b", d0In); end 
	    	if (WH2 == 1) begin	
	    	thedOut[theCore] = d2In;
	    	$display("ITS WH2 with d0In %b", d0In); end 
	    	if (WH3 == 1) begin	
	    	thedOut[theCore] = d3In;
	    	$display("ITS WH3 with d0In %b", d0In); end           */
    		
    		 
    		if (theSIn[theCore] == 2'b00) begin
    			thesOut[theCore] = 2'b00;
    		end
    		else if (theSIn[theCore] == 2'b01) begin
    			//$display("rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrWrite hit on exclusive value");
    			thesOut[theCore] = 2'b00;
    		end
    		else if (theSIn[theCore] == 2'b10) begin
    			thesOut[theCore] = 2'b01;
    			for (i=0; i<4; i=i+1) begin
    				if (i != theCore) begin
    					thesOut[i] = 2'b11;
    					theweS[i] = 1;
    				end 
    			end
    			theWEL2 = 1;
    			case (theCore)
    						0: theData = d0In;
    						1: theData = d1In;
    						2: theData = d2In;
    						3: theData = d3In;
    					endcase
    					//$display("theWEL2 = 1. theData = %b", theData);
    		end 
    		else if (theSIn[theCore] == 2'b11) begin
    			thesOut[theCore] = 2'b01;
    			for (i=0; i<4; i=i+1) begin
    				if (i != theCore) begin
    					thesOut[i] = 2'b11;
    					theweS[i] = 1;
    				end 
    			end 
    		end  
    		state = 13; 
    	end 
    	else if (state == 13) begin
    		theweS[0] = 0;
    		theweS[1] = 0;
    		theweS[2] = 0;
    		theweS[3] = 0;
    		theweD[0] = 0;
    		theweD[1] = 0;
    		theweD[2] = 0;
    		theweD[3] = 0;
    		thesOut [theCore] = 0;
    		state = 0;		
    	end 
    	else if (state == 21) begin
    		//$display("Waiting for response");
    		state = 22;
    	end 
    	else if (state == 22) begin
    		theSIn[0] = s0In;
    		theSIn[1] = s1In;
    		theSIn[2] = s2In;
    		theSIn[3] = s3In;  
    		//$display("In state 22");
    		//$display("S0In is %b", s0In);
    		//$display("S1In is %b", s1In);
    		//$display("S2In is %b", s2In);
    		//$display("S3In is %b", s3In);
    		
    	  /*	case (theCore)
    		0: theData = d0In;
    		1: theData = d1In;
    		2: theData = d2In;
    		3: theData = d3In;
    		endcase             */
    		if (theSIn[0] == 2'b11 && theSIn[1] == 2'b11 && theSIn[2] == 2'b11 && theSIn[3] == 2'b11) begin
    			//$display("theREL2 = 1");
    			theREL2 = 1;
    			state = 23;
 			end 
 		 	else begin
 				state = 25;
	    		for (i=0; i<4; i=i+1) begin 
   	 				if (theSIn[i] == 2'b01) begin 
    					case (i)
    						0: thedOut[theCore] = d0In;
    						1: thedOut[theCore] = d1In;
    						2: thedOut[theCore] = d2In;
    						3: thedOut[theCore] = d3In;
    					endcase 
    					//$display("aaaaaaaaaaaaaaaaaaaaa heres data: %b", thedOut[theCore]);
    					theweS[i] = 1;
    					theweS[theCore] = 1;
    					thesOut[theCore] = 2'b10;
    					theweD[theCore] = 1;  
    					thesOut [i] = 2'b10;
    					//$display("Found THE exclusive case");
    				end
    				if (theSIn[i] == 2'b10) begin
    					case (i)
    						0: thedOut[theCore] = d0In;
    						1: thedOut[theCore] = d1In;
    						2: thedOut[theCore] = d2In;
    						3: thedOut[theCore] = d3In;
    					endcase 
    					theweS[i] = 1;
    					theweS[theCore] = 1;
    					thesOut[theCore] = 2'b10;
    					theweD[theCore] = 1;  
    					thesOut [i] = 2'b10;
    					//$display("Found shared case");
    				end 	
    				if (theSIn[i] == 2'b00) begin
    					case (i)
    						0: theData = d0In;
    						1: theData = d1In;
    						2: theData = d2In;
    						3: theData = d3In;
    					endcase
    					thedOut[theCore] = theData; 
    					theweS[i] = 1;
    					theweS[theCore] = 1;
    					thesOut[theCore] = 2'b10;
    					theweD[theCore] = 1;  
    					thesOut [i] = 2'b10;
    					theWEL2 = 1;
    					//$display("Found modified case");
    				end
    				if (theSIn[i] == 2'b00) begin
    					case (theCore)
    						0: theData = d0In;
    						1: theData = d1In;
    						2: theData = d2In;
    						3: theData = d3In;
    					endcase
    					thedOut[theCore] = theData; 
    					theweS[i] = 1;
    					theweS[theCore] = 1;
    					thesOut[theCore] = 2'b11;
    					theweD[theCore] = 1;  
    					thesOut [i] = 2'b01;
    					theWEL2 = 1;
    					//$display("Found shared case");
    				end
    			end 
    		 end 
    	end
    	else if (state == 23) begin
    		state = 24;
    	end 
    	else if (state == 24) begin
    		theData = dataFromL2;
    		theREL2 = 0;
    		theweS[theCore] = 1;
    		theweD[theCore] = 1;
    		thesOut[theCore] = 2'b01;
    		thedOut[theCore] = theData;
    		state = 25;
    	end 
    	else if (state == 25) begin
    		theweS[0] = 0;
    		theweS[1] = 0;
    		theweS[2] = 0;
    		theweS[3] = 0;
    		theweD[0] = 0;
    		theweD[1] = 0;
    		theweD[2] = 0;
    		theweD[3] = 0;
    		theWEL2 = 0;
    		state = 0;
    	end 
    	else if (state == 31) begin
    		//$display("Waiting for response");
    		state = 32;
    	end 
    	else if (state == 32) begin
    		theSIn[0] = s0In;
    		theSIn[1] = s1In;
    		theSIn[2] = s2In;
    		theSIn[3] = s3In;  
    		//$display("In state 32");
    		
    		if (theSIn[theCore] == 2'b00) begin	
    			for (i=0; i<4; i=i+1) begin
   			 		if (i != theCore) begin
   		 				if (theSIn[i] == 2'b00 || theSIn[i] == 2'b10) begin
    						case (i)
    							0: thedOut[theCore] = d0In;
    							1: thedOut[theCore] = d1In;
    							2: thedOut[theCore] = d2In;
    							3: thedOut[theCore] = d3In;
    						endcase                        
    						theweS[i] = 1;
    						theweD[i] = 1;
    						//$display("Found modified/shared case");
    					end
    				end 
    			end 
    			for (i=0; i<4; i=i+1) begin
    				if (theSIn[i] == 2'b01) begin
    					case (i)
    						0: thedOut[theCore] = d0In;
    						1: thedOut[theCore] = d1In;
    						2: thedOut[theCore] = d2In;
    						3: thedOut[theCore] = d3In;
    					endcase                        
    					theweS[i] = 1;
    					theweD[i] = 1;
    					//$display("Found exclusive case");
    				end
    			end 
    		end
    		
    		if (theSIn[theCore] == 2'b00) begin
    			thesOut[theCore] = 2'b00;
    		end
    		else if (theSIn[theCore] == 2'b01) begin
    			thesOut[theCore] = 2'b01;
    		end
    		else if (theSIn[theCore] == 2'b10) begin
    			thesOut[theCore] = 2'b10;
    		end 
    		theweS[theCore] = 1;
    		theweD[theCore] = 1;
    		//$display("The data: %b", thedOut[theCore]);
    		//$display("S0In is %b", s0In);
    		//$display("S1In is %b", s1In);
    		//$display("S2In is %b", s2In);
    		//$display("S3In is %b", s3In);
    		//thesOut [theCore] = 2'b10;
    		//$display("thesOut[theCore] = 2'b01");
    		
    		state = 33;
    	end
    	else if (state == 33) begin
    		theweS[0] = 0;
    		theweS[1] = 0;
    		theweS[2] = 0;
    		theweS[3] = 0;
    		theweD[0] = 0;
    		theweD[1] = 0;
    		theweD[2] = 0;
    		theweD[3] = 0;
    		theWEL2 = 0;
    		state = 0;
    	end  		  
    end
    
    assign d0Out = thedOut[0];
    assign a0Out = theaOut[0];
    assign s0Out = thesOut[0];
    assign d1Out = thedOut[1];
    assign a1Out = theaOut[1];
    assign s1Out = thesOut[1];
    assign weS0 = theweS[0];
    assign weD0 = theweD[0];
    assign re0 = there[0];
    assign weS1 = theweS[1];
    assign weD1 = theweD[1];
    assign re1 = there[1];
    assign d2Out = thedOut[2];
    assign a2Out = theaOut[2];
    assign s2Out = thesOut[2];
    assign d3Out = thedOut[3];
    assign a3Out = theaOut[3];
    assign s3Out = thesOut[3];
    assign weS2 = theweS[2];
    assign weD2 = theweD[2];
    assign re2 = there[2];
    assign weS3 = theweS[3];
    assign weD3 = theweD[3];
    assign re3 = there[3];
    assign weL2 = theWEL2;
    assign reL2 = theREL2;
    assign dataToL2 = theData;
    assign addrToL2 = theAddr;
endmodule

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
		/*for (i=0; i<8; i=i+1)
		begin
			$display("L2 %b Data: %b", i, L2data[i]);
		end 
		for (j=0; j<4; j=j+1)
		begin
			$display("L1 cache %b", j);
			$display("WH: %b  , WM: %b  , RH: %b  , RM: %b", WH[j], WM[j], RH[j], RM[j]);
			$display("Bus Lines  -  Data: %b   Addr: %b  Status: %b", dOutBus[j], addrOutBus[j], statusOut[j]);
		end      */
		
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
		
		//WM on Invalid / Other exclusive
		core = 1; 
		CPUwe[core] = 1;
		dInCPU[core] = 8'b10011001;		
		addrInCPU[core] = 3'b101;
		#CYCLE;
		CPUwe[core] = 0;
		#CYCLE;
		#CYCLE;
		#CYCLE;
		#CYCLE;
		$display("Write %b to addr %b on core %b", dInCPU[core], addrInCPU[core], core);
		$display("WM other copy Exclusive");
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
		
		//RM with Exclusive
		core = 3;
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
	   	$display("RM with Exclusive copy");
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
		
		//WH on Exclusive
		core = 0;  
		CPUwe[core] = 1;
		dInCPU[core] = 8'b00001111;			
		addrInCPU[core] = 3'b001;
		#CYCLE;
		CPUwe[core] = 0;
		#CYCLE;
		#CYCLE;
		#CYCLE;
		#CYCLE;
		$display("Write %b to addr %b on core %b", dInCPU[core], addrInCPU[core], core);
		$display("WH on Exclusive");
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
		
		//WH on Modified 
		core = 0; 
		CPUwe[core] = 1;
		dInCPU[core] = 8'b01111110;			
		addrInCPU[core] = 3'b001;
		#CYCLE;
		CPUwe[core] = 0;
		#CYCLE;
		#CYCLE;
		#CYCLE;
		#CYCLE;
		$display("Write %b to addr %b on core %b", dInCPU[core], addrInCPU[core], core);
		$display("WH on Modified");
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
		
		//RM with others Shared 
		core = 0;
		CPUre[core] = 1;
		addrInCPU[core] = 3'b101;
		#CYCLE;
		#CYCLE;
		#CYCLE;
		#CYCLE;
		CPUre[core] = 0;
	   	#CYCLE; 
	   	$display("Read addr %b from core %b", addrInCPU[core], core);
	   	$display("RM other copies Shared");
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
		
		//RM with other modified
		core = 3;
		CPUre[core] = 1;
		addrInCPU[core] = 3'b001;
		#CYCLE;
		#CYCLE;
		#CYCLE;
		#CYCLE;
		CPUre[core] = 0;
	   	#CYCLE;    
	   	$display("Read addr %b from core %b", addrInCPU[core], core);
	   	$display("RM other copy Modified");
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
		
		//WH on Shared  
		core = 1;
		CPUwe[core] = 1;
		dInCPU[core] = 8'b10000001;		
		addrInCPU[core] = 3'b101;
		#CYCLE;
		CPUwe[core] = 0;
		#CYCLE;
		#CYCLE;
		#CYCLE;
		#CYCLE;
		$display("Write %b to addr %b on core %b", dInCPU[core], addrInCPU[core], core);
		$display("WH on Shared");
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
		
		//WM other copies Shared  
		core = 1;
		CPUwe[core] = 1;
		dInCPU[core] = 8'b11100111;		
		addrInCPU[core] = 3'b001;
		#CYCLE;
		CPUwe[core] = 0;
		#CYCLE;
		#CYCLE;
		#CYCLE;
		#CYCLE;
		$display("Write %b to addr %b on core %b", dInCPU[core], addrInCPU[core], core);
		$display("WM other copies Shared");
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
		
		$finish; 		
	end
	initial clk = 0;
	always #(CYCLE/2) clk = ~clk;
endmodule