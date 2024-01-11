module REG (
    input wire clk,
    input wire rst,
    input wire rdy,

    input wire Clear_flag,

    input wire insqueue_to_Reg_needchange,
    input wire [31:0] order_rs1,
    input wire [31:0] order_rs2,
    output reg reg_busy_order_rs1,
    output reg reg_busy_order_rs2,
    output reg[31:0] reg_reorder_order_rs1,
    output reg[31:0] reg_reorder_order_rs2,
    output reg[31:0] reg_reg_order_rs1,
    output reg[31:0] reg_reg_order_rs2,
    input wire [31:0] order_rd,
    input wire [31:0] reg_reorder_order_rd_,
    input wire reg_busy_order_rd_,

    input wire ROB_to_Reg_needchange,ROB_to_Reg_needchange2,
    input wire [31:0] commit_rd,
    output reg reg_busy_commit_rd,
    output reg [31:0] reg_reorder_commit_rd,
    input wire [31:0] reg_reg_commit_rd_,
    input wire reg_busy_commit_rd_

);

reg [31:0] regs[31:0];
reg [31:0] reg_order[31:0];
reg reg_busy[31:0];

integer i;

always @(*) begin
    reg_busy_order_rs1=reg_busy[order_rs1];
    reg_busy_order_rs2=reg_busy[order_rs2];
    reg_reorder_order_rs1=reg_order[order_rs1];
    reg_reorder_order_rs2=reg_order[order_rs2];
    reg_reg_order_rs1=regs[order_rs1];
    reg_reg_order_rs2=regs[order_rs2];
end

always @(*) begin
    reg_busy_commit_rd=reg_busy[commit_rd];
    reg_reorder_commit_rd=reg_order[commit_rd];
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

    else if(Clear_flag) begin
      for(i=0;i<32;i=i+1) begin
        reg_busy[i]<=0;
      end
    end
    else begin
      if(insqueue_to_Reg_needchange) begin
        if(order_rd!=0) begin
            reg_busy[order_rd]<=reg_busy_order_rd_;
            reg_order[order_rd]<=reg_reorder_order_rd_;
        end
    end

    if(ROB_to_Reg_needchange) begin
      if(commit_rd!=0) begin
        regs[commit_rd]<=reg_reg_commit_rd_;
        if(ROB_to_Reg_needchange2) begin
          if(!insqueue_to_Reg_needchange||commit_rd!=order_rd) begin
            reg_busy[commit_rd]<=reg_busy_commit_rd_;
          end
        end
      end
    end
end
end

endmodule