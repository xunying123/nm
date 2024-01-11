module ICache(
    input wire clk,
    input wire rst,
    input wire rdy,

    input wire [31:0] addr1,
    output reg hit_icache,
    output reg [31:0] return_inst,
    
    input wire Inq_Icache,
    input wire [31:0] addr2,
    input wire [31:0] store_Inst
    
);

reg [31:0] cache [255:0];
reg [26:0] tag [255:0];
reg valid[255:0];

integer i;

reg [7:0] temp1,temp2;


always @(*) begin
    temp1=addr1[7:0];
    if(valid[temp1]==1 && tag[temp1]==addr1[31:8]) begin
        hit_icache=1;
        return_inst=cache[temp1];
    end
    else begin
        hit_icache=0;
    end
end

always @(*) begin
    temp2=addr2[7:0];
end

always @(posedge clk) begin
    if(rst) begin
      for(i=0;i<256;i=i+1) begin
        cache[i]<=0;
        tag[i]<=0;
        valid[i]<=0;
      end
    end

    else if(~rdy) begin
      
    end

    else begin
        if(Inq_Icache) begin
            cache[temp2]<=store_Inst;
            tag[temp2]<=addr2[31:8];
            valid[temp2]<=1;
        end
    end
end


endmodule