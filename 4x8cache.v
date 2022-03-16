module cache (clk, we, d, addr, q);
	input clk, we;
	input [7:0] d;
	input [1:0] addr;
	output [7:0] q;
	
	reg [7:0] temp [3:0];
	always @ (posedge clk)
		if (we)
			temp[addr] <= d;
		assign q = temp[addr];
endmodule

//timescale 1 ns/10 ps

module cache_tb;
	reg clk, we;
	reg [7:0] d;
	reg [1:0] addr;
	wire [7:0] q;
	
	localparam CYCLE = 20;
	integer write_data;
	integer i;
	
	cache testCache1 (.clk(clk), .we(we), .d(d), .addr(addr), .q(q));
	
	initial
	begin
		we = 1;
		d = 8'b10101010;
		addr = 2'b01;
		#CYCLE;
		
		d = 8'b01010101;
		addr = 2'b10;
		#CYCLE;
		
		d = 8'b11111111;
		addr = 2'b11;
		#CYCLE;
		
		write_data = $fopen("testWrite.txt");
		we = 0;
		addr = 0;
		for (i=0; i<4; i=i+1)
		begin
			$fdisplay(write_data, "Data %d: %b", i, q);
			addr=addr+1;
			#CYCLE;
		end
		$fclose(write_data);
		$finish; 		
	end
	initial clk = 0;
	always #(CYCLE/2) clk = ~clk;
endmodule