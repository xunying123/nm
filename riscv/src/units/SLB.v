

module SLB (
    input wire clk,
    input wire rst,
    input wire rdy,

    input wire clear,

    output reg [31:0] data4,

    input wire memctrl_data_ready,
    input wire [31:0] memctrl_data_ret,

    output reg slb_load,
    output reg slb_store,

    output reg [5:0] slb_mem_order,
    output reg [31:0] slb_mem_vj,
    output reg [31:0] slb_mem_vk,
    output reg [31:0] slb_mem_A,

    output reg SLB_ROB,
    output reg [31:0] data4_value,
    output reg data4_ready,

    output reg SLB_RS,
    output reg [31:0] load_value,

    output reg [31:0] slb_size,
    output reg [31:0] slb_r,

    input wire Insq_SLB,
    input wire SLB_add,
    input wire [31:0] return1,

    input wire [31:0] slb_r_,
    input wire [31:0] slb_vj,
    input wire [31:0] slb_vk,
    input wire [31:0] slb_A,
    input wire [31:0] slb_reorder,
    input wire [31:0] slb_qj,
    input wire [31:0] slb_qk,
    input wire [31:0] slb_pc,
    input wire [31:0] slb_inst,
    input wire [31:0] slb_order,
    input wire slb_ready,


    input wire RS_SLB,
    input wire [31:0] data2,

    input wire [31:0] slb_value,

    input wire [31:0] data3,
    input wire ROB_SLB,
    input wire ROB_SLB2,
    input wire [31:0] data3_SLB


);


reg [5:0] order[31:0];
reg [31:0] inst[31:0];
reg [31:0] vj[31:0];
reg [31:0] vk[31:0];
reg [31:0] qj[31:0];
reg [31:0] qk[31:0];
reg [31:0] pc[31:0];
reg [31:0] topc[31:0];
reg [31:0] A[31:0];
reg [31:0] reorder[31:0];
reg [31:0] ready[31:0];
reg [31:0] ll,rr,size;
reg waiting;

wire [31:0] loaded;

reg [31:0] return3;

Load_Store ls(
    .order(order[return3]),
    .data(memctrl_data_ret),
    .ret(loaded)
);

wire isload;
Load l(
    .order(order[return3]),
    .is(isload)
);

integer i;

reg sub_size;

always @(*) begin
    sub_size=0;
    slb_load=0;
    slb_store=0;

    SLB_ROB=0;
    SLB_RS=0;

    if(memctrl_data_ready) begin
      return3=ll;
      if(isload) begin
        data4=reorder[return3];
        SLB_ROB=1;
        data4_value=loaded;
        data4_ready=1;

        SLB_RS=1;
        load_value=loaded;

        sub_size=1;
      end

      else begin
        data4=reorder[return3];
        SLB_ROB=1;
        data4_ready=1;

        sub_size=1;
      end
    end

    if(!waiting&&size) begin
      return3=ll;
      if(isload) begin
        if(qj[return3]==-1) begin
          slb_load=1;
          slb_mem_order=order[return3];
            slb_mem_vj=vj[return3];
            slb_mem_A=A[return3];
        end
      end

      else begin
        if(qj[return3]==-1 && qk[return3]==-1&&ready[return3]) begin
          slb_store=1;
          slb_mem_order=order[return3];
            slb_mem_vj=vj[return3];
            slb_mem_A=A[return3];
            slb_mem_vk=vk[return3];
        end
      end
    end
end


always @(*) begin
    slb_size=size;
    slb_r=rr;
end

always @(posedge clk) begin
    if(rst) begin
      for(i=0;i<=32;i=i+1) begin
        order[i]<=0;
        pc[i]<=0;
        inst[i]<=0;
        vj[i]<=0;
        qj[i]<=-1;
        qk[i]<=-1;
        vk[i]<=0;
        A[i]<=0;
        reorder[i]<=0;
        ready[i]<=0;
        inst[i]<=0;
      end
      ll<=1;
      rr<=0;
      size<=0;
      waiting<=0;
    end

    else if(~rdy) begin
      
    end

    else if(clear) begin
      ll<=1;
      rr<=0;
      size<=0;
      waiting<=0;
      for(i=0;i<32;i=i+1) begin
        qj[i]<=-1;
        qk[i]<=-1;
      end
    end

    else begin
      size<=size+SLB_add-sub_size;

      if(memctrl_data_ready) begin
        waiting<=0;
        if(isload) begin
          ll<=(ll+1)%32;
          qj[ll]<=-1;
          qk[ll]<=-1;
        for(i=0;i<32;i=i+1) begin
            if(qj[i]==data4) begin
              qj[i]<=-1;
              vj[i]<=loaded;
                end

            if(qk[i]==data4) begin
              qk[i]<=-1;
              vk[i]<=loaded;
                end
            end 
        end

        else begin
          ll<=(ll+1)%32;
          qj[ll]<=-1;
          qk[ll]<=-1;
        end
      end

      if(!waiting&&size) begin
        if(isload) begin
          if(qj[return3]==-1) begin
            waiting<=1;
          end
        end

        else begin
          if(qj[return3]==-1 && qk[return3]==-1 && ready[return3]) begin
            waiting<=1;
          end
        end
      end

      if(Insq_SLB) begin
        vj[return1]<=slb_vj;
        vk[return1]<=slb_vk;
        qj[return1]<=slb_qj;
        qk[return1]<=slb_qk;
        pc[return1]<=slb_pc;
        A[return1]<=slb_A;
        reorder[return1]<=slb_reorder;
        ready[return1]<=slb_ready;
        order[return1]<=slb_order;
        inst[return1]<=slb_inst;
        rr<=slb_r_;
      end

      if(RS_SLB) begin
        for(i=0;i<32;i=i+1) begin
            if(qj[i]==data2) begin
              qj[i]<=-1;
              vj[i]<=slb_value;
            end
    
            if(qk[i]==data2) begin
              qk[i]<=-1;
              vk[i]<=slb_value;
            end
        end
      end

      if(ROB_SLB) begin
        for(i=0;i<32;i=i+1) begin
            if(qj[i]==data3) begin
              qj[i]<=-1;
              vj[i]<=data3_SLB;
            end
    
            if(qk[i]==data3) begin
              qk[i]<=-1;
              vk[i]<=data3_SLB;
            end
        end
      end

        if(ROB_SLB2) begin
            for(i=0;i<32;i=i+1) begin
                if(reorder[i]==data3) begin
                  ready[i]<=1;
                end
            end
        end
    end
end

endmodule