module L1cache (clk, we, re, localAddrIn, dIn, addrIn, dOutBus, dOutCPU, addrOut, statusOut, WH, WM, RH, RM);
	input clk, we, re;				//Clock and write enable
	input [1:0] localAddrIn; 	//Location in L1
	input [7:0] dIn;         	//Data In from CPU
	input [2:0] addrIn;			//Address In from CPU
	inout [7:0] dOutBus;          //Data In/Out to bus
	output [7:0] dOutCPU;
	inout [2:0] addrOut;       //Address In/Out to bus
	inout [1:0] statusOut;     //Status Out to bus
	output WH;
	output WM;
	output RH;
	output RM;      
	
	integer i, WHout, WMout, RHout, RMout;
	
	reg [7:0] data [3:0];		//Data register
	reg [2:0] addr [3:0];		//Address register
	reg [1:0] theStatus [3:0];	//Status register
	reg [1:0] localAddr; 		//Address of L1 being accessed
	integer dataUpdated; 		//Boolean to determine if data has been updated 
	integer outToCPU;
	
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
  	end 
	 
	always @ (posedge clk)
	begin 
		WHout = 0;
		WMout = 0;
		RHout = 0;
		RMout = 0;
		if (we)		//If write enable
		begin 
			dataUpdated = 0;		//Data is not updated
			for (i=0; i<4; i=i+1)	//Search to see if the address trying to be stored is already stored
			begin
				if (addr[i] == addrIn)
				begin 
					$display("Addr %b already exists in this L1. Updating current value.", addrIn);
					data[i] = dIn;							//Replace the data
					theStatus[i] = 2'b00;		//Update the status (might not be required)
					dataUpdated = 1;
					WHout = 1;						//Data is updated
				end	
			end 
			//Need to add if localAddr == 4 (cache is full)
			if (dataUpdated == 0)
			begin             
				$display("No addr match. Update localAddr: %b", localAddr);
				WMout = 1;
				data[localAddr] = dIn;								//Update data at localAddr 
				addr[localAddr] = addrIn;							//Update address at localAddr 
				theStatus[localAddr] = 2'b00;	//Update status at localAddr
				localAddr = localAddr+1;							//Increase localAddr
				dataUpdated = 1;									//Data is updated
			end
			/*
			case(theStatus[localAddr])
				2'b00:
				begin
					theStatus[localAddr] <= 2'b01;
				end
				2'b01:
				begin
					theStatus[localAddr] <= 2'b10;
				end
				2'b10:
				begin
					theStatus[localAddr] <= 2'b11;
				end
				2'b11:
				begin
					theStatus[localAddr] <= 2'b00;
				end
			endcase    */
		end
		if (re)
		begin  
			for (i=0; i<4; i=i+1)	//Search to see if the address trying to be stored is already stored
			begin
				if (addr[i] == addrIn)
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
	end
	assign dOutBus = 1 ? data[localAddrIn] : 'bz;			//Tristates for inout to bus  
   	assign dOutCPU = re ? outToCPU : 'bz;
  //  assign dOutCPU = outToCPU;
	assign addrOut = 1 ? addr[localAddrIn] : 'bz;
	assign statusOut = 1? theStatus[localAddrIn] : 'bz;
	assign WH = WHout;   
	assign WM = WMout;  
	assign RH = RHout;  
	assign RM = RMout;   
endmodule

//timescale 1 ns/10 ps

module cache_tb;
	reg clk, we, re;
	reg [1:0] localAddrIn;
	reg [7:0] dIn;
	reg [2:0] addrIn;
	wire [7:0] dOut;
	wire [2:0] addrOut;
	wire [1:0] statusOut;
	wire [7:0] dOutCPU;
	wire WH;
	wire WM;
	wire RH;
	wire RM;
	
	localparam CYCLE = 20;
	integer write_data;
	integer i;
	
	L1cache testCache1 (.clk(clk), .we(we), .re(re), .localAddrIn(localAddrIn), .dIn(dIn), .addrIn(addrIn), .dOutBus(dOut), .dOutCPU(dOutCPU), .addrOut(addrOut), .statusOut(statusOut), .WH(WH), .WM(WM), .RH(RH), .RM(RM));
	
	initial
	begin 
		//Print initial state of cache 
		we = 0;
		re = 0;
		localAddrIn = 0;
		for (i=0; i<4; i=i+1)
		begin
			$display("Data %d: %b     Addr: %b     Status: %b  ", i, dOut, addrOut, statusOut);
			localAddrIn=localAddrIn+1;
			#CYCLE;
		end
	    $display("WH: %b  , WM: %b  , RH: %b  , RM: %b", WH, WM, RH, RM);
		
		//Test writing  
		we = 1;
		dIn = 8'b10101010;			//Store values at localAddr = 0
		addrIn = 3'b001;
		#CYCLE;
		$display("Write %b to addr %b", dIn, addrIn);
		$display("WH: %b  , WM: %b  , RH: %b  , RM: %b", WH, WM, RH, RM);
		we = 0;
		localAddrIn = 0;
		for (i=0; i<4; i=i+1)
		begin
			$display("Data %d: %b     Addr: %b     Status: %b  ", i, dOut, addrOut, statusOut);
			localAddrIn=localAddrIn+1;
			#CYCLE;
		end   
		
		we = 1;
		dIn = 8'b01010101;			//Store values at localAddr = 1
		addrIn = 3'b011;
		#CYCLE;
		$display("Write %b to addr %b", dIn, addrIn); 
		$display("WH: %b  , WM: %b  , RH: %b  , RM: %b", WH, WM, RH, RM);
		we = 0;
		localAddrIn = 0;
		for (i=0; i<4; i=i+1)
		begin
			$display("Data %d: %b     Addr: %b     Status: %b  ", i, dOut, addrOut, statusOut);
			localAddrIn=localAddrIn+1;
			#CYCLE;
		end   
		
		we = 1;
		dIn = 8'b11111111;			//Because this address already exists in localAddr = 0, the data at that location updates
		addrIn = 3'b001;
		#CYCLE;
		$display("Write %b to addr %b", dIn, addrIn);  
		$display("WH: %b  , WM: %b  , RH: %b  , RM: %b", WH, WM, RH, RM);
		we = 0;
		localAddrIn = 0;
		for (i=0; i<4; i=i+1)
		begin
			$display("Data %d: %b     Addr: %b     Status: %b  ", i, dOut, addrOut, statusOut);
			localAddrIn=localAddrIn+1;
			#CYCLE;
		end   
		
		we = 1;
		dIn = 8'b00001111;			//Store values at localAddr = 2
		addrIn = 3'b111;
		#CYCLE;
		$display("Write %b to addr %b", dIn, addrIn);    
		$display("WH: %b  , WM: %b  , RH: %b  , RM: %b", WH, WM, RH, RM); 
		we = 0;
		localAddrIn = 0;
		for (i=0; i<4; i=i+1)
		begin
		   $display("Data %d: %b     Addr: %b     Status: %b  ", i, dOut, addrOut, statusOut);
			localAddrIn=localAddrIn+1;
			#CYCLE;
		end 
		
		  
		re = 1;
		
		addrIn = 3'b111;
		#CYCLE
		$display("Read from addr %b", addrIn);
		$display("The data for addr %b is %b", addrIn, dOutCPU);     
		$display("WH: %b  , WM: %b  , RH: %b  , RM: %b", WH, WM, RH, RM); 
		
		addrIn = 3'b101;
		#CYCLE
		$display("Read from addr %b", addrIn);
		$display("The data for addr %b is %b", addrIn, dOutCPU);     
		$display("WH: %b  , WM: %b  , RH: %b  , RM: %b", WH, WM, RH, RM);
		
		re = 0;
		addrIn = 3'b111;
		#CYCLE  
		$display("Read from addr %b", addrIn);
		$display("The data for addr %b is %b", addrIn, dOutCPU);
		$display("WH: %b  , WM: %b  , RH: %b  , RM: %b", WH, WM, RH, RM);
		
		$finish; 		
	end
	initial clk = 0;
	always #(CYCLE/2) clk = ~clk;
endmodule