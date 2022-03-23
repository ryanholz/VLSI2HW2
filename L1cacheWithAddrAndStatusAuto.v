module L1cache (clk, we, localAddrIn, dIn, addrIn, dOut, addrOut, statusOut);
	input clk, we;				//Clock and write enable
	input [1:0] localAddrIn; 	//Location in L1
	input [7:0] dIn;         	//Data In from CPU
	input [2:0] addrIn;			//Address In from CPU
	inout [7:0] dOut;          //Data In/Out to bus
	inout [2:0] addrOut;       //Address In/Out to bus
	inout [1:0] statusOut;     //Status Out to bus
	integer i;
	
	reg [7:0] data [3:0];		//Data register
	reg [2:0] addr [3:0];		//Address register
	reg [1:0] theStatus [3:0];	//Status register
	reg [1:0] localAddr; 		//Address of L1 being accessed
	integer dataUpdated; 		//Boolean to determine if data has been updated
	
	initial 
 	begin 
	 	for (i=0; i<4; i=i+1)			//Initialize data, addr, and status registers
 		begin
 			data[i] = 8'b00000000;
 			addr[i] = 3'b000;
 			theStatus[i] = 2'b00;
  		end 
  		localAddr = 2'b00;				//Initialize local address to 0
  		dataUpdated = 1;				//Data is up to date   
  	end 
	 
	always @ (posedge clk)
	begin
		if (we)		//If write enable
		begin 
			dataUpdated = 0;		//Data is not updated
			for (i=0; i<4; i=i+1)	//Search to see if the address trying to be stored is already stored
			begin
				if (addr[i] == addrIn)
				begin 
					$display("Addr %b already exists in this L1. Updating current value.", addrIn);
					data[i] = dIn;							//Replace the data
					theStatus[i] = theStatus[i] + 1;		//Update the status (might not be required)
					dataUpdated = 1;						//Data is updated
				end	
			end 
			//Need to add if localAddr == 4 (cache is full)
			if (dataUpdated == 0)
			begin             
				$display("No addr match. Update localAddr: %b", localAddr);
				data[localAddr] = dIn;								//Update data at localAddr 
				addr[localAddr] = addrIn;							//Update address at localAddr 
				theStatus[localAddr] = theStatus[localAddr] + 1;	//Update status at localAddr
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
	end
	assign dOut = 1 ? data[localAddrIn] : 'bz;			//Tristates for inout to bus
	assign addrOut = 1 ? addr[localAddrIn] : 'bz;
	assign statusOut = 1? theStatus[localAddrIn] : 'bz;    
endmodule

//timescale 1 ns/10 ps

module cache_tb;
	reg clk, we;
	reg [1:0] localAddrIn;
	reg [7:0] dIn;
	reg [2:0] addrIn;
	wire [7:0] dOut;
	wire [2:0] addrOut;
	wire [1:0] statusOut;
	
	localparam CYCLE = 20;
	integer write_data;
	integer i;
	
	L1cache testCache1 (.clk(clk), .we(we), .localAddrIn(localAddrIn), .dIn(dIn), .addrIn(addrIn), .dOut(dOut), .addrOut(addrOut), .statusOut(statusOut));
	
	initial
	begin  
		we = 0;
		localAddrIn = 0;
		for (i=0; i<4; i=i+1)
		begin
			$display("Data %d: %b     Addr: %b     Status: %b", i, dOut, addrOut, statusOut);
			localAddrIn=localAddrIn+1;
			#CYCLE;
		end  
		we = 1;
		
		dIn = 8'b10101010;			//Store values at localAddr = 0
		addrIn = 3'b001;
		#CYCLE;
		
		we = 0;
		localAddrIn = 0;
		for (i=0; i<4; i=i+1)
		begin
			$display("Data %d: %b     Addr: %b     Status: %b", i, dOut, addrOut, statusOut);
			localAddrIn=localAddrIn+1;
			#CYCLE;
		end  
		we = 1;
		      
		dIn = 8'b01010101;			//Store values at localAddr = 1
		addrIn = 3'b011;
		#CYCLE; 
		
		we = 0;
		localAddrIn = 0;
		for (i=0; i<4; i=i+1)
		begin
			$display("Data %d: %b     Addr: %b     Status: %b", i, dOut, addrOut, statusOut);
			localAddrIn=localAddrIn+1;
			#CYCLE;
		end  
		we = 1;
		
		dIn = 8'b11111111;			//Because this address already exists in localAddr = 0, the data at that location updates
		addrIn = 3'b001;
		#CYCLE;  
		
		we = 0;
		localAddrIn = 0;
		for (i=0; i<4; i=i+1)
		begin
			$display("Data %d: %b     Addr: %b     Status: %b", i, dOut, addrOut, statusOut);
			localAddrIn=localAddrIn+1;
			#CYCLE;
		end  
		we = 1;
		        
		dIn = 8'b00001111;			//Store values at localAddr = 2
		addrIn = 3'b111;
		#CYCLE;    
		 
		we = 0;
		localAddrIn = 0;
		for (i=0; i<4; i=i+1)
		begin
			$display("Data %d: %b     Addr: %b     Status: %b", i, dOut, addrOut, statusOut);
			localAddrIn=localAddrIn+1;
			#CYCLE;
		end  
		we = 1;
		
		$finish; 		
	end
	initial clk = 0;
	always #(CYCLE/2) clk = ~clk;
endmodule