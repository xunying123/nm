
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

	if(order==`JALR)topc=(vj+A)&(~1);
    else topc=0;//for_latch
    
	if(order==`LUI)value=A;
	else if(order==`AUIPC)value=pc+A;

	else if(order==`ADD)value=vj+vk;
	else if(order==`SUB)value=vj-vk;
	else if(order==`SLL)value=vj<<(vk&5'h1f);
	else if(order==`SLT)value=($signed(vj)<$signed(vk))?1:0;
	else if(order==`SLTU)value=(vj<vk)?1:0;
	else if(order==`XOR)value=vj^vk;
	else if(order==`SRL)value=vj>>(vk&5'h1f);
	else if(order==`SRA)value=$signed(vj)>>(vk&5'h1f);
	else if(order==`OR)value=vj|vk;
	else if(order==`AND)value=vj&vk;

	else if(order==`JALR) begin
		value=pc+4;
	end


	else if(order==`ADDI)value=vj+A;
	else if(order==`SLTI)value=($signed(vj)<$signed(A))?1:0;
	else if(order==`SLTIU)value=(vj<A)?1:0;
	else if(order==`XORI)value=vj^A;
	else if(order==`ORI)value=vj|A;
	else if(order==`ANDI)value=vj&A;
	else if(order==`SLLI)value=vj<<A;
	else if(order==`SRLI)value=vj>>A;
	else if(order==`SRAI)value=$signed(vj)>>A;
	

	else if(order==`JAL) begin
		value=pc+4;
	end


	else if(order==`BEQ) begin
		value=(vj==vk?1:0);
	end
	else if(order==`BNE) begin
		value=(vj!=vk?1:0);
	end
	else if(order==`BLT) begin
		value=($signed(vj)<$signed(vk)?1:0);
	end
	else if(order==`BGE) begin
		value=($signed(vj)>=$signed(vk)?1:0);
	end
	else if(order==`BLTU) begin
		value=(vj<vk?1:0);
	end
	else if(order==`BGEU) begin
		value=(vj>=vk?1:0);
	end
	else value=0;//for_latch

end





endmodule