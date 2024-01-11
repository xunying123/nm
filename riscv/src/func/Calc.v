
module Calc(
    input wire [5:0] order,
    output reg is
);

always @(*) begin
    if(order==`LUI || order==`AUIPC || order==`ADD || order==`SUB || order==`SLL || order==`SLT || order==`SLTU || order==`XOR || order==`SRL || order==`SRA || order==`OR || order==`AND || order==`ADDI || order==`SLTI || order==`SLTIU || order==`XORI || order==`ORI || order==`ANDI || order==`SLLI || order==`SRLI || order==`SRAI) begin
        is=1'b1;
    end
    else begin
        is=1'b0;
    end
end

endmodule