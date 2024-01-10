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

reg [31:0] cache [127:0];
reg [26:0] tag [127:0];
reg valid[127:0];

integer i;

reg [6:0] temp1,temp2;


always @(*) begin

    return_inst=0;
    
    temp1=addr1[6:0];
    if(valid[temp1]&& tag[temp1]==addr1[31:7]) begin
        hit_icache=1;
        return_inst=cache[temp1];
    end
    else begin
        hit_icache=0;
    end
end

always @(*) begin
    temp2=addr2[6:0];
end

always @(posedge clk) begin
    if(rst) begin
      for(i=0;i<128;i=i+1) begin
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
            tag[temp2]<=addr2[31:7];
            valid[temp2]<=1;
        end
    end
end


endmodule