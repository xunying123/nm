
module Branch (
    input wire [5:0] order,
    output reg is
);

always @(*) begin
    if(order==`BEQ || order==`BNE || order==`BLT || order==`BGE || order==`BLTU || order==`BGEU || order==`JAL || order==`JALR) is=1'b1;
    else is=1'b0;
end



endmodule