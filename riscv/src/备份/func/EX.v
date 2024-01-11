
module EX(
    input wire [5:0] order,
    input wire [31:0] vj,
    input wire [31:0] vk,
    input wire [31:0] A,
    input wire [31:0] pc,
    output reg [31:0] value,
    output reg [31:0] topc
);

always @(*) begin
    if(order==`LUI) value=A;
    if(order==`AUIPC) value=A+pc;
    if(order==`ADD) value=vj+vk;
    if(order==`SUB) value=vj-vk;
    if(order==`SLL) value=vj<<(vk&5'h1f);
    if(order==`SLT) begin
        if($signed(vj)<$signed(vk)) value=1;
        else value=0;
    end
    if(order==`SLTU) begin
        if(vj<vk) value=1;
        else value=0;
    end
    if(order==`XOR) value=vj^vk;

    if(order==`SRL)value=vj>>(vk&5'h1f);
	if(order==`SRA)value=$signed(vj)>>(vk&5'h1f);
	if(order==`OR)value=vj|vk;
	if(order==`AND)value=vj&vk;

    if(order==`JALR) begin
		topc=(vj+A)&(~1);
		value=pc+4;
	end
    
    if(order==`ADDI)value=vj+A;
	if(order==`SLTI)value=($signed(vj)<$signed(A))?1:0;
	if(order==`SLTIU)value=(vj<A)?1:0;
	if(order==`XORI)value=vj^A;
	if(order==`ORI)value=vj|A;
	if(order==`ANDI)value=vj&A;
	if(order==`SLLI)value=vj<<A;
	if(order==`SRLI)value=vj>>A;
	if(order==`SRAI)value=$signed(vj)>>A;
	

	if(order==`JAL) begin
		value=pc+4;
	end


	if(order==`BEQ) begin
		value=(vj==vk?1:0);
	end
	if(order==`BNE) begin
		value=(vj!=vk?1:0);
	end
	if(order==`BLT) begin
		value=($signed(vj)<$signed(vk)?1:0);
	end
	if(order==`BGE) begin
		value=($signed(vj)>=$signed(vk)?1:0);
	end
	if(order==`BLTU) begin
		value=(vj<vk?1:0);
	end
	if(order==`BGEU) begin
		value=(vj>=vk?1:0);
	end

end





endmodule