module BHT(
    input wire clk,
    input wire rst,
    input wire rdy,

    input wire ROB_to_BHT_needchange2,
    input wire ROB_to_BHT_needchange,
    input wire [31:0] bht_id1,

    input wire [31:0] bht_id2,
    output reg bht_get
    
);

reg bht[1<<12-1:0][1:0];

integer i;

always @(*) begin
    if(bht[bht_id1][0] == 0) begin
        bht_get = 0;
    end
    else begin
        bht_get = 1;
    end
end

always @(posedge clk) begin
    if(rst) begin
        for(i = 0; i < (1<<12); i = i + 1) begin
            bht[i][0] <= 0;
            bht[i][1] <= 0;
        end
    end
    else if(~rdy) begin
    end

        else begin
        if(ROB_to_BHT_needchange2) begin
            if(bht[bht_id2][0]==0 && bht[bht_id2][1]==0) begin
                bht[bht_id2][0] <= 0;
                bht[bht_id2][1] <= 0;
            end
            if(bht[bht_id2][0]==1 && bht[bht_id2][1]==0) begin
                bht[bht_id2][0] <= 0;
                bht[bht_id2][1] <= 0;
            end
            if(bht[bht_id2][0]==0 && bht[bht_id2][1]==1) begin
                bht[bht_id2][0] <= 1;
                bht[bht_id2][1] <= 1;
            end
            if(bht[bht_id2][0]==1 && bht[bht_id2][1]==1) begin
                bht[bht_id2][0] <= 1;
                bht[bht_id2][1] <= 1;
            
            end
        end
        if(ROB_to_BHT_needchange) begin
            if(bht[bht_id2][0]==0 && bht[bht_id2][1]==0) begin
                bht[bht_id2][0] <= 1;
                bht[bht_id2][1] <= 0;
            end
            if(bht[bht_id2][0]==1 && bht[bht_id2][1]==0) begin
                bht[bht_id2][0] <= 0;
                bht[bht_id2][1] <= 1;
            end
            if(bht[bht_id2][0]==0 && bht[bht_id2][1]==1) begin
                bht[bht_id2][0] <= 1;
                bht[bht_id2][1] <= 0;
            end
            if(bht[bht_id2][0]==1 && bht[bht_id2][1]==1) begin
                bht[bht_id2][0] <= 0;
                bht[bht_id2][1] <= 1;
            end
        end
    end
end
endmodule