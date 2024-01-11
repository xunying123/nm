
module Load_Store(
    input wire [5:0] order,
    input wire [31:0] data,
    output reg [31:0] ret
);

always @(*) begin
    ret=data;
    if(order==`LB) begin
        if(data[7]) ret[31:8]=24'hffffff;
        else ret[31:8]=24'h000000;
    end

    if(order==`LH) begin
        if(data[15]) ret[31:16]=16'hffff;
        else ret[31:16]=16'h0000;
    end

    if(order==`LW) ret=data;
    if(order==`LBU) ret[31:8]=24'h000000;
    if(order==`LHU) ret[31:16]=16'h0000;
end

endmodule