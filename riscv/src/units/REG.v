module REG (
    input wire clk,
    input wire rst,
    input wire rdy,

    input wire clear,

    input wire Insq_REG,
    input wire [31:0] rs1_0,
    input wire [31:0] rs2_0,
    output reg reg_busy_rs1,
    output reg reg_busy_rs2,
    output reg[31:0] reg_rs1_reorder,
    output reg[31:0] reg_rs2_reorder,
    output reg[31:0] reg_order_rs1,
    output reg[31:0] reg_order_rs2,
    input wire [31:0] order_rd,
    input wire [31:0] rd_reorder,
    input wire rd_busy,

    input wire ROB_Reg,ROB_Reg2,
    input wire [31:0] rd_commit,
    output reg rd_busy_commit,
    output reg [31:0] rd_reorder_commit,
    input wire [31:0] rd_data_commit,
    input wire rd_busy_commit_

);

reg [31:0] regs[31:0];
reg [31:0] reg_order[31:0];
reg reg_busy[31:0];

integer i;

always @(*) begin
    reg_busy_rs1=reg_busy[rs1_0];
    reg_busy_rs2=reg_busy[rs2_0];
    reg_rs1_reorder=reg_order[rs1_0];
    reg_rs2_reorder=reg_order[rs2_0];
    reg_order_rs1=regs[rs1_0];
    reg_order_rs2=regs[rs2_0];
end

always @(*) begin
    rd_busy_commit=reg_busy[rd_commit];
    rd_reorder_commit=reg_order[rd_commit];
end

always @(posedge clk) begin
    if(rst) begin
      for(i=0;i<32;i=i+1) begin
        regs[i]<=0;
        reg_order[i]<=0;
        reg_busy[i]<=0;
      end
    end

    else if(~rdy) begin
      
    end

    else if(clear) begin
      for(i=0;i<32;i=i+1) begin
        reg_busy[i]<=0;
      end
    end
    else begin
      if(Insq_REG) begin
        if(order_rd!=0) begin
            reg_busy[order_rd]<=rd_busy;
            reg_order[order_rd]<=rd_reorder;
        end
    end

    if(ROB_Reg) begin
      if(rd_commit!=0) begin
        regs[rd_commit]<=rd_data_commit;
        if(ROB_Reg2) begin
          if(!Insq_REG||rd_commit!=order_rd) begin
            reg_busy[rd_commit]<=rd_busy_commit_;
          end
        end
      end
    end
end
end

endmodule