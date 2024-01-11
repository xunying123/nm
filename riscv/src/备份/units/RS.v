

module RS(
    input wire clk,
    input wire rst,
    input wire rdy,

    input wire Clear_flag,

    output reg [31:0] b2,
    output reg RS_to_ROB_needchange,
    output reg RS_to_ROB_needchange2,
    output reg [31:0] ROB_s_value_b2_,
    output reg [31:0] ROB_s_jumppc_b2_,
    output reg ROB_s_ready_b2_,

    input wire [31:0] b3,
    input wire ROB_to_RS_needchange,
    input wire [31:0] ROB_to_RS_value_b3,

    output reg RS_to_SLB_needchange,
    output reg [31:0] RS_to_SLB_value,

    input wire [31:0] b4,
    input wire [31:0] SLB_to_RS_loadvalue,
    input wire SLB_to_RS_needchange,

    output reg [31:0] RS_unbusy_pos,
    input wire insqueue_to_RS_needchange,
    input wire [31:0] r2,

    input wire [31:0] RS_s_vj_r2_,
    input wire [31:0] RS_s_vk_r2_,
    input wire [31:0] RS_s_qj_r2_,
    input wire [31:0] RS_s_qk_r2_,
    input wire [31:0] RS_s_inst_r2_,
    input wire [5:0] RS_s_ordertype_r2_,
    input wire [31:0] RS_s_pc_r2_,
    input wire [31:0] RS_s_jumppc_r2_,
    input wire [31:0] RS_s_A_r2_,
    input wire [31:0] RS_s_reorder_r2_,
    input wire RS_s_busy_r2_

);


reg [5:0] order[31:0];
reg [31:0] pc[31:0];
reg [31:0] topc[31:0];
reg [31:0] A[31:0];
reg [31:0] reorder[31:0];
reg busy[31:0];
reg [31:0] inst[31:0];
reg [31:0] vj[31:0];
reg [31:0] vk[31:0];
reg [31:0] qj[31:0];
reg [31:0] qk[31:0];

integer i,j;

reg [31:0] id;
wire [31:0] value;
wire [31:0] opc;

EX ex(
    .ordertype(order[id]),
    .vj(vj[id]),
    .vk(vk[id]),
    .A(A[id]),
    .pc(pc[id]),
    .value(value),
    .jumppc(opc)
);

always @(*) begin
    RS_to_ROB_needchange=0;
    RS_to_ROB_needchange2=0;
    RS_to_SLB_needchange=0;

    id=-1;
    for(i=31;i>=0;i=i-1) begin
       if(busy[i] && qj[i]==-1 && qk[i]==-1) begin
         id=i;
       end
    end

    if(id!=-1) begin
        b2=reorder[id];
        RS_to_ROB_needchange=1;
        ROB_s_value_b2_=value;
        ROB_s_ready_b2_=1;
        if(order[id]==`JALR) begin
            RS_to_ROB_needchange2=1;
            ROB_s_jumppc_b2_=opc;
        end

        RS_to_SLB_needchange=1;
        RS_to_SLB_value=value;

    end
end

always @(*) begin
    RS_unbusy_pos=-1;
    for(j=31;j>=0;j=j-1) begin
        if(!busy[j]) begin
            RS_unbusy_pos=j;
        end
    end
end

always @(posedge clk) begin
    if(rst) begin
      for(i=0;i<32;i=i+1) begin
        order[i]<=0;
        pc[i]<=0;
        topc[i]<=0;
        A[i]<=0;
        reorder[i]<=0;
        busy[i]<=0;
        inst[i]<=0;
        vj[i]<=0;
        vk[i]<=0;
        qj[i]<=-1;
        qk[i]<=-1;
      end
    end

    else if(~rdy) begin
      
    end

    else if(Clear_flag) begin
      for(i=0;i<32;i=i+1) begin
        busy[i]<=0;
        qj[i]<=-1;
        qk[i]<=-1;
      end
    end

    else begin

      if(id!=-1) begin
        busy[id]<=0;
        for(i=0;i<32;i=i+1) begin
          if(busy[i]) begin
            if(qj[i]==b2) begin
              qj[i]<=-1;
              vj[i]<=value;
            end
            if(qk[i]==b2) begin
              qk[i]<=-1;
              vk[i]<=value;
            end
          end
        end
      end

      if (insqueue_to_RS_needchange) begin
        vj[r2]<=RS_s_vj_r2_;
        vk[r2]<=RS_s_vk_r2_;
        qj[r2]<=RS_s_qj_r2_;
        qk[r2]<=RS_s_qk_r2_;
        inst[r2]<=RS_s_inst_r2_;
        order[r2]<=RS_s_ordertype_r2_;
        pc[r2]<=RS_s_pc_r2_;
        topc[r2]<=RS_s_jumppc_r2_;
        A[r2]<=RS_s_A_r2_;
        reorder[r2]<=RS_s_reorder_r2_;
        busy[r2]<=RS_s_busy_r2_;
      end

      if(ROB_to_RS_needchange) begin
        for(i=0;i<32;i=i+1) begin
          if(busy[i]) begin
            if(qj[i]==b3) begin
              qj[i]<=-1;
              vj[i]<=ROB_to_RS_value_b3;
            end
            if(qk[i]==b3) begin
              qk[i]<=-1;
              vk[i]<=ROB_to_RS_value_b3;
            end
          end
        end
      end

      if(SLB_to_RS_needchange) begin
        for(i=0;i<32;i=i+1) begin
          if(busy[i]) begin
            if(qj[i]==b4) begin
              qj[i]<=-1;
              vj[i]<=SLB_to_RS_loadvalue;
            end
            if(qk[i]==b4) begin
              qk[i]<=-1;
              vk[i]<=SLB_to_RS_loadvalue;
            end
          end
        end
        end
      end
    end

endmodule //RS