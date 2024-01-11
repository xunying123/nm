
module DE(
    input wire [31:0] inst,
    output reg [5:0] order,
    output reg [31:0] rd,
    output reg [31:0] rs1,
    output reg [31:0] rs2,
    output reg [31:0] imm
);

wire [6:0] num1;
wire [2:0] num2;
wire [6:0] num3;
assign num1=inst[6:0];
assign num2=inst[14:12];
assign num3=inst[31:25];

always @(*) begin
    rd=inst[11:7];
    rs1=inst[19:15];
    rs2=inst[24:20];
    
    if(num1==7'h37 || num1==7'h17) begin
      if(num1==7'h37) begin
        order=`LUI;
      end
      if(num1==7'h17) begin
        order=`AUIPC;
      end
      imm={inst[31:12],12'h000};
    end

    if(num1==7'h33) begin
        if(num2==3'h0) begin
          if(num3==7'h00) begin
            order=`ADD;
          end
          if(num3==7'h20) begin
            order=`SUB;
          end
        end
        if(num2==3'h1) begin
          order=`SLL;
        end
        if(num2==3'h2) begin
          order=`SLT;
        end
        if(num2==3'h3) begin
          order=`SLTU;
        end
        if(num2==3'h4) begin
          order=`XOR;
        end
        if(num2==3'h5) begin
          if(num3==7'h00) begin
            order=`SRL;
          end
          else if(num3==7'h20) begin
            order=`SRA;
          end
        end
        if(num2==3'h6) begin
          order=`OR;
        end
        if(num2==3'h7) begin
          order=`AND;
        end
    end

    if(num1==7'h67) begin
        order=`JALR;
        imm={20'b0,inst[31:20]};
    end

    if(num1==7'h03) begin
        if(num2==3'h0) begin
            order=`LB;
        end
        if(num2==3'h1) begin
            order=`LH;
        end
        if(num2==3'h2) begin
            order=`LW;
        end
        if(num2==3'h4) begin
            order=`LBU;
        end
        if(num2==3'h5) begin
            order=`LHU;
        end
        imm={20'b0,inst[31:20]};
    end

    if(num1==7'h13) begin
        if(num2==3'h0) begin
            order=`ADDI;
        end
        if(num2==3'h2) begin
            order=`SLTI;
        end
        if(num2==3'h3) begin
            order=`SLTIU;
        end
        if(num2==3'h4) begin
            order=`XORI;
        end
        if(num2==3'h6) begin
            order=`ORI;
        end
        if(num2==3'h7) begin
            order=`ANDI;
        end
        if(num2==3'h1) begin
            order=`SLLI;
        end
        if(num2==3'h5) begin
            if(num3==7'h00) begin
            order=`SRLI;
            end
            if(num3==7'h20) begin
            order=`SRAI;
            imm[10]=0;
            end
        end
        imm={20'b0,inst[31:20]};
    end

    if(num1==7'h23) begin
        if(num2==3'h0) begin
            order=`SB;
        end
        if(num2==3'h1) begin
            order=`SH;
        end
        if(num2==3'h2) begin
            order=`SW;
        end
        imm={20'b0,inst[31:25],inst[11:7]};
    end

    if(num1==7'h6f) begin
        order=`JAL;
        imm={11'b0,inst[31],inst[19:12],inst[20],inst[30:21],1'b0};
    end

    if(num1==7'h63) begin
        if(num2==3'h0) begin
            order=`BEQ;
        end
        if(num2==3'h1) begin
            order=`BNE;
        end
        if(num2==3'h4) begin
            order=`BLT;
        end
        if(num2==3'h5) begin
            order=`BGE;
        end
        if(num2==3'h6) begin
            order=`BLTU;
        end
        if(num2==3'h7) begin
            order=`BGEU;
        end
        imm={19'b0,inst[31],inst[7],inst[30:25],inst[11:8],1'b0};
    end 

    if(order==`JALR || order==`LB || order==`LH || order==`LW || order==`LBU || order==`LHU) begin
        if(imm>>11)imm=imm|32'hfffff000;
    end

    if(order==`SB || order==`SH || order==`SW) begin
        if(imm>>11)imm=imm|32'hfffff000;
    end

    if(order==`BEQ || order==`BNE || order==`BLT || order==`BGE || order==`BLTU || order==`BGEU) begin
        if(imm>>12)imm=imm|32'hffffe000;
    end

    if(order==`ADDI || order==`SLTI || order==`SLTIU || order==`XORI || order==`ORI || order==`ANDI) begin
        if(imm>>11)imm=imm|32'hfffff000;
    end

    if(order==`JAL) begin
        if(imm>>20)imm=imm|32'hfff00000;
    end
   

end

endmodule