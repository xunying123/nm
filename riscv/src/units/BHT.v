module BHT(
    input wire clk,
    input wire rst,
    input wire rdy,

    input wire right,
    input wire wrong,
    input wire [31:0] index_bht,

    input wire [31:0] index_bht2,
    output reg bht_re
    
);

reg bht[1<<12-1:0][1:0];

integer i;

always @(*) begin
    if(bht[index_bht2[11:0]][1] == 0) begin
        bht_re = 0;
    end
    else begin
        bht_re = 1;
    end
end

always @(posedge clk) begin
    if(rst) begin
        for(i = 0; i < 1<<12; i = i + 1) begin
            bht[i][0] <= 0;
            bht[i][1] <= 0;
        end
    end
    else if(rdy) begin
        if(right) begin
            if(bht[index_bht[11:0]][0]==0 && bht[index_bht[11:0]][1]==0) begin
                bht[index_bht[11:0]][0] <= 0;
                bht[index_bht[11:0]][1] <= 0;
            end
            else if(bht[index_bht[11:0]][0]==1 && bht[index_bht[11:0]][1]==0) begin
                bht[index_bht[11:0]][0] <= 0;
                bht[index_bht[11:0]][1] <= 0;
            end
            else if(bht[index_bht[11:0]][0]==0 && bht[index_bht[11:0]][1]==1) begin
                bht[index_bht[11:0]][0] <= 1;
                bht[index_bht[11:0]][1] <= 1;
            end
            else if(bht[index_bht[11:0]][0]==1 && bht[index_bht[11:0]][1]==1) begin
                bht[index_bht[11:0]][0] <= 1;
                bht[index_bht[11:0]][1] <= 1;
            
            end
        end
        if(wrong) begin
            if(bht[index_bht[11:0]][0]==0 && bht[index_bht[11:0]][1]==0) begin
                bht[index_bht[11:0]][0] <= 1;
                bht[index_bht[11:0]][1] <= 0;
            end
            else if(bht[index_bht[11:0]][0]==1 && bht[index_bht[11:0]][1]==0) begin
                bht[index_bht[11:0]][0] <= 0;
                bht[index_bht[11:0]][1] <= 1;
            end
            else if(bht[index_bht[11:0]][0]==0 && bht[index_bht[11:0]][1]==1) begin
                bht[index_bht[11:0]][0] <= 1;
                bht[index_bht[11:0]][1] <= 0;
            end
            else if(bht[index_bht[11:0]][0]==1 && bht[index_bht[11:0]][1]==1) begin
                bht[index_bht[11:0]][0] <= 0;
                bht[index_bht[11:0]][1] <= 1;
            end
        end
    end
end
endmodule