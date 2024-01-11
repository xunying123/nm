

module SLB (
    input wire clk,
    input wire rst,
    input wire rdy,

    input wire Clear_flag,

    output reg [31:0] b4,

    input wire memctrl_data_ok,
    input wire [31:0] memctrl_data_ans,

    output reg SLB_to_memctrl_needchange,
    output reg SLB_to_memctrl_needchange2,

    output reg [5:0] SLB_to_memctrl_ordertype,
    output reg [31:0] SLB_to_memctrl_vj,
    output reg [31:0] SLB_to_memctrl_vk,
    output reg [31:0] SLB_to_memctrl_A,

    output reg SLB_to_ROB_needchange,
    output reg [31:0] ROB_s_value_b4_,
    output reg ROB_s_ready_b4_,

    output reg SLB_to_RS_needchange,
    output reg [31:0] SLB_to_RS_loadvalue,

    output reg [31:0] SLB_size__,
    output reg [31:0] SLB_R__,

    input wire insqueue_to_SLB_needchange,
    input wire insqueue_to_SLB_size_addflag,
    input wire [31:0] r1,

    input wire [31:0] SLB_R_,
    input wire [31:0] SLB_s_vj_r1_,
    input wire [31:0] SLB_s_vk_r1_,
    input wire [31:0] SLB_s_A_r1_,
    input wire [31:0] SLB_s_reorder_r1_,
    input wire [31:0] SLB_s_qj_r1_,
    input wire [31:0] SLB_s_qk_r1_,
    input wire [31:0] SLB_s_pc_r1_,
    input wire [31:0] SLB_s_inst_r1_,
    input wire [31:0] SLB_s_ordertype_r1_,
    input wire SLB_s_ready_r1_,


    input wire RS_to_SLB_needchange,
    input wire [31:0] b2,

    input wire [31:0] RS_to_SLB_value,

    input wire [31:0] b3,
    input wire ROB_to_SLB_needchange,
    input wire ROB_to_SLB_needchange2,
    input wire [31:0] ROB_to_SLB_value_b3


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

Extend_LoadData ls(
    .tmp_ordertype(order[return3]),
    .data(memctrl_data_ans),
    .ans(loaded)
);

wire isload;
IsLoad l(
    .type(order[return3]),
    .is_Load(isload)
);

integer i;

reg sub_size;

always @(*) begin
    sub_size=0;
    SLB_to_memctrl_needchange=0;
    SLB_to_memctrl_needchange2=0;

    SLB_to_ROB_needchange=0;
    SLB_to_RS_needchange=0;

    if(memctrl_data_ok) begin
      return3=ll;
      if(isload) begin
        b4=reorder[return3];
        SLB_to_ROB_needchange=1;
        ROB_s_value_b4_=loaded;
        ROB_s_ready_b4_=1;

        SLB_to_RS_needchange=1;
        SLB_to_RS_loadvalue=loaded;

        sub_size=1;
      end

      else begin
        b4=reorder[return3];
        SLB_to_ROB_needchange=1;
        ROB_s_ready_b4_=1;

        sub_size=1;
      end
    end

    if(!waiting&&size) begin
      return3=ll;
      if(isload) begin
        if(qj[return3]==-1) begin
          SLB_to_memctrl_needchange=1;
          SLB_to_memctrl_ordertype=order[return3];
            SLB_to_memctrl_vj=vj[return3];
            SLB_to_memctrl_A=A[return3];
        end
      end

      else begin
        if(qj[return3]==-1 && qk[return3]==-1&&ready[return3]) begin
          SLB_to_memctrl_needchange2=1;
          SLB_to_memctrl_ordertype=order[return3];
            SLB_to_memctrl_vj=vj[return3];
            SLB_to_memctrl_A=A[return3];
            SLB_to_memctrl_vk=vk[return3];
        end
      end
    end
end


always @(*) begin
    SLB_size__=size;
    SLB_R__=rr;
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

    else if(Clear_flag) begin
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
      size<=size+insqueue_to_SLB_size_addflag-sub_size;

      if(memctrl_data_ok) begin
        waiting<=0;
        if(isload) begin
          ll<=(ll+1)%32;
          qj[ll]<=-1;
          qk[ll]<=-1;
        for(i=0;i<32;i=i+1) begin
            if(qj[i]==b4) begin
              qj[i]<=-1;
              vj[i]<=loaded;
                end

            if(qk[i]==b4) begin
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

      if(insqueue_to_SLB_needchange) begin
        vj[r1]<=SLB_s_vj_r1_;
        vk[r1]<=SLB_s_vk_r1_;
        qj[r1]<=SLB_s_qj_r1_;
        qk[r1]<=SLB_s_qk_r1_;
        pc[r1]<=SLB_s_pc_r1_;
        A[r1]<=SLB_s_A_r1_;
        reorder[r1]<=SLB_s_reorder_r1_;
        ready[r1]<=SLB_s_ready_r1_;
        order[r1]<=SLB_s_ordertype_r1_;
        inst[r1]<=SLB_s_inst_r1_;
        rr<=SLB_R_;
      end

      if(RS_to_SLB_needchange) begin
        for(i=0;i<32;i=i+1) begin
            if(qj[i]==b2) begin
              qj[i]<=-1;
              vj[i]<=RS_to_SLB_value;
            end
    
            if(qk[i]==b2) begin
              qk[i]<=-1;
              vk[i]<=RS_to_SLB_value;
            end
        end
      end

      if(ROB_to_SLB_needchange) begin
        for(i=0;i<32;i=i+1) begin
            if(qj[i]==b3) begin
              qj[i]<=-1;
              vj[i]<=ROB_to_SLB_value_b3;
            end
    
            if(qk[i]==b3) begin
              qk[i]<=-1;
              vk[i]<=ROB_to_SLB_value_b3;
            end
        end
      end

        if(ROB_to_SLB_needchange2) begin
            for(i=0;i<32;i=i+1) begin
                if(reorder[i]==b3) begin
                  ready[i]<=1;
                end
            end
        end
    end
end

endmodule