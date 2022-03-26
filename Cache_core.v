module CPU_Cache (clk, rst, wr_en, rd_en, addr, data, out_data);
    input clk, rst;
    input wr_en, rd_en;
    input [1:0] addr;
    input [7:0] data;
    output [7:0] out_data;

    reg [7:0] mem [3:0];
    always @(posedge clk or posedge rst) begin
        if (rst)
            out_data <= '0;
        else
           if (wr_en)
            mem [addr] <= data;
            if (rd_en)
            out_data <= mem [addr];
    end 
 end
