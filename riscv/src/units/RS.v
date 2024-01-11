

module RS(
    input wire clk,
    input wire rst,
    input wire rdy,

    input wire clear,

    output reg [31:0] data2,
    output reg RS_ROB,
    output reg RS_ROB2,
    output reg [31:0] data2_value,
    output reg [31:0] data2_topc,
    output reg data2_ready,

    input wire [31:0] data3,
    input wire ROB_RS,
    input wire [31:0] data3_RS,

    output reg RS_SLB,
    output reg [31:0] slb_value,

    input wire [31:0] data4,
    input wire [31:0] load_value,
    input wire SLB_RS,

    output reg [31:0] rs_unbusy,
    input wire Insq_RS,
    input wire [31:0] return2,

    input wire [31:0] rs_vj,
    input wire [31:0] rs_vk,
    input wire [31:0] rs_qj,
    input wire [31:0] rs_qk,
    input wire [31:0] rs_inst,
    input wire [5:0] rs_order,
    input wire [31:0] rs_pc,
    input wire [31:0] rs_topc,
    input wire [31:0] rs_A,
    input wire [31:0] rs_reorder,
    input wire rs_busy

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
    .order(order[id]),
    .vj(vj[id]),
    .vk(vk[id]),
    .A(A[id]),
    .pc(pc[id]),
    .value(value),
    .topc(opc)
);

always @(*) begin
    RS_ROB=0;
    RS_ROB2=0;
    RS_SLB=0;

    id=-1;
    for(i=31;i>=0;i=i-1) begin
       if(busy[i] && qj[i]==-1 && qk[i]==-1) begin
         id=i;
       end
    end

    if(id!=-1) begin
        data2=reorder[id];
        RS_ROB=1;
        data2_value=value;
        data2_ready=1;
        if(order[id]==`JALR) begin
            RS_ROB2=1;
            data2_topc=opc;
        end

        RS_SLB=1;
        slb_value=value;

    end
end

always @(*) begin
    rs_unbusy=-1;
    for(j=31;j>=0;j=j-1) begin
        if(!busy[j]) begin
            rs_unbusy=j;
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

    else if(clear) begin
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
            if(qj[i]==data2) begin
              qj[i]<=-1;
              vj[i]<=value;
            end
            if(qk[i]==data2) begin
              qk[i]<=-1;
              vk[i]<=value;
            end
          end
        end
      end

      if (Insq_RS) begin
        vj[return2]<=rs_vj;
        vk[return2]<=rs_vk;
        qj[return2]<=rs_qj;
        qk[return2]<=rs_qk;
        inst[return2]<=rs_inst;
        order[return2]<=rs_order;
        pc[return2]<=rs_pc;
        topc[return2]<=rs_topc;
        A[return2]<=rs_A;
        reorder[return2]<=rs_reorder;
        busy[return2]<=rs_busy;
      end

      if(ROB_RS) begin
        for(i=0;i<32;i=i+1) begin
          if(busy[i]) begin
            if(qj[i]==data3) begin
              qj[i]<=-1;
              vj[i]<=data3_RS;
            end
            if(qk[i]==data3) begin
              qk[i]<=-1;
              vk[i]<=data3_RS;
            end
          end
        end
      end

      if(SLB_RS) begin
        for(i=0;i<32;i=i+1) begin
          if(busy[i]) begin
            if(qj[i]==data4) begin
              qj[i]<=-1;
              vj[i]<=load_value;
            end
            if(qk[i]==data4) begin
              qk[i]<=-1;
              vk[i]<=load_value;
            end
          end
        end
        end
      end
    end

endmodule //RS