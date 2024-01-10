module BHT(
    input wire clk,
    input wire rst,
    input wire rdy,

    input wire right,
    input wire wrong,
    input wire [7:0] index_bht,

    input wire [7:0] index_bht2,
    output reg bht_re
    
);

reg bht[1<<8-1:0][1:0];

integer i;

reg flag,i1,i2;

always @(*) begin
    if(bht[index_bht][0] == 0) begin
        bht_re = 0;
    end
    else begin
        bht_re = 1;
    end
end


always @(*) begin
    i1=0;
    i2=0;
    flag=0;

    if(wrong) begin
        flag=1;
        if(bht[index_bht2][1]==0) begin
            i1=0;
            i2=1;
        end
        if(bht[index_bht2][1]==1) begin
            i1=1;
            i2=0;
        end
    end

    if(right) begin
        flag=1;
        if(bht[index_bht2][0]==0) begin
            i1=0;
            i2=0;
        end
        if(bht[index_bht2][0]==1) begin
            i1=1;
            i2=1;
        end
    end
end

always @(posedge clk) begin
    if(rst) begin
        for(i = 0; i < 1<<8; i = i + 1) begin
            bht[i][0] <= 0;
            bht[i][1] <= 0;
        end
    end
    else if(~rdy) begin

    end

    else begin
        if(flag) begin
            bht[index_bht2][0]<=i1;
            bht[index_bht2][1]<=i2;
        end
        end
    end
endmodule