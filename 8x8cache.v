module cache (clk, we, re, d, addr, q);
	input clk, we, re;
	input [7:0] d;
	input [2:0] addr;
	output [7:0] q;
	
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
endmodule

//timescale 1 ns/10 ps

module cache_tb;
	reg clk, we, re;
	reg [7:0] d;
	reg [2:0] addr;
	wire [7:0] q;
	
	localparam CYCLE = 20;
	integer write_data;
	integer i;
	
	cache testCache1 (.clk(clk), .we(we), .re(re), .d(d), .addr(addr), .q(q));
	
	initial
	begin
		we = 1;
		re = 0;
		d = 8'b10101010;
		addr = 3'b001;
		#CYCLE;
		
		d = 8'b01010101;
		addr = 3'b010;
		#CYCLE;
		
		d = 8'b11111111;
		addr = 3'b111;
		#CYCLE;
		
		we = 0;
		$display("The output with re = 0: %b", q);
		re = 1;
		addr = 0;
		for (i=0; i<8; i=i+1)
		begin 
			#CYCLE;
			$display("Data %d: %b", i, q);
			addr=addr+1;
		end                 
		
		$finish; 		
	end
	initial clk = 0;
	always #(CYCLE/2) clk = ~clk;
endmodule