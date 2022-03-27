module cache_fsm (clk, rst, rd_hit, rd_miss, wr_hit, wr_miss, 
                L1_write_done, written_back, modified_data, shared_data, exclusive_data, invalid_done, snoop_hit_rd, snoop_hit_wr,
                wr_back, invalid_other rd_en_1, wr_en_1, rd_en_2, wr_en_2, rd_en_3, wr_en_3, l2_rd_en, l2_wr_en);
    input clk;
    input rst;
//need to add miss and hit signals for all L1 caches, this is just for one
    input rd_hit;
    input rd_miss;
    input wr_hit;
    input wr_miss;

    input written_back;  // in case of snoop hit, after data is written to the L1 cache that is requesting data
    input modified_data; // status flag for modified data
    input shared_data;   // status flag for shared data
    input exclusive_data; // status flag for exclusive data
    input invalid_done;   // signal from datapath after other L1 caches have been updated with invalid status
    input L1_write_done;  // (not initialized yet) flag for data written in the L1 cache

    input snoop_hit_rd; // read hit for data present in other L1 caches
    input snoop_hit_wr; // write hit for data present in other L1 caches

    output reg wr_back; // (not initialized yet) signal the L2 to write the modified data back to its L2 address
    output reg invalid_other; //to invalidate the data of the other L1 caches
    
    // read/write enables for L1 and L2 caches
    output reg rd_en_1;
    output reg wr_en_1;

    output reg rd_en_2;
    output reg wr_en_2;

    output reg rd_en_3;
    output reg wr_en_3;

    output reg l2_rd_en;
    output reg l2_wr_en;

reg [2:0] state, next_state;

parameter Invalid = 3'b000,
          Exclusive = 3'b001,
          Modified = 3'b010,
          Shared = 3'b011;
          Write_back = 3'b100; // write modified data back to L2 cache
          L1_write = 3'b101;   // write data in L1
          invalid_check = 3'b110; // check if other caches have invalidated  data

//sequential
always @(posedge clk or posedge rst) begin
    if (rst) begin
        state <= Invalid;
    end
    else begin
         state <= next_state;
    end        
end  
//combinational
//need to add individual cache enable signals
//cross-check states and other signals
//write tb
always @(posedge clk or posedge rst) begin
    next_state = state;
    wr_back = '0;
    invalid_other = '0;

    wr_en_1 = '0;
    rd_en_1 = '0;

    wr_en_2 = '0;
    rd_en_2 = '0;

    wr_en_3 = '0;
    rd_en_3 = '0;

    l2_wr_en = '0;
    l2_rd_en = '0;
    case (state)
    Invalid: begin
        if (rd_miss or wr_miss) begin
            next_state = L1_write;
        end    
        else begin
            next_state = Invalid;
        end    


    end

    Exclusive: begin
        if (snoop_hit_rd) begin
            next_state = Shared;
        end
        else if (snoop_hit_wr) begin
            next_state = Invalid;
        end    
        else_if (wr_hit) begin
            next_state = Modified;
        end
        else if (rd_hit) begin
            next_state = Exclusive;
        end        
    end

    Modified: begin
        if (snoop_hit_wr) begin
            next_state = Invalid;
        end
        else if (snoop_hit_rd) begin
            next_state = Write_back;
        end
        else if (rd_hit or wr_hit) begin
            next_state = Modified;    
        end    
    end

    Shared: begin
        if (snoop_hit_wr) begin
            next_state = Invalid;
        end    
        else if (snoop_hit_rd or rd_hit) begin
            next_state = Shared;
        end
        else if (wr_hit) begin
            invalid_other = 1'b1;
            next_state = invalid_check;
        end        
    end

    Write_back: begin
        if (written_back) begin
            next_state = Shared;
        end    
        else next_state = Write_back;
    end  

    L1_write : begin
        if (modified_data) begin
            next_state = Invalid;
            l2_wr_en = 1'b1;
        end
        else begin
            if (rd_miss) begin
                l2_rd_en = 1'b1;
                if (shared_data) begin
                    next_state = Shared;
                end
                else if (exclusive_data) begin
                    next_state = Exclusive;
                end        
            end
            else if (wr_miss) begin
                l2_rd_en = 1'b1;
                //conditions for individual L1 caches
                invalid_other = 1'b1;
                next_state = invalid_check;
            end    
            else begin
                next_state = L1_write;
            end    
        end            
    end  

    invalid_check: begin
        if (invalid_done) begin
            next_state = Modified;
        end
        else next_state = invalid_check;    
    end        
            
    endcase
end  

endmodule
