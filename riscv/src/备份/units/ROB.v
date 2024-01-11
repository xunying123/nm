

module ROB(
    input wire clk,
    input wire rst,
    input wire rdy,

    input wire Clear_flag,

    output reg [31:0] b3,
    output reg ROB_to_BHT_needchange2,
    output reg ROB_to_BHT_needchange,

    output reg [31:0] bht_id2,

    output reg ROB_to_RS_needchange,
    output reg [31:0] ROB_to_RS_value_b3,

    output reg ROB_to_SLB_needchange,
    output reg ROB_to_SLB_needchange2,
    output reg [31:0] ROB_to_SLB_value_b3,

    output reg [31:0] commit_rd,
    input wire reg_busy_commit_rd,
    input wire [31:0] reg_reorder_commit_rd,

    output reg ROB_to_Reg_needchange,
    output reg ROB_to_Reg_needchange2,

    output reg [31:0] reg_reg_commit_rd_,
    output reg reg_busy_commit_rd_,

    output reg [31:0] pc_,
    output reg Clear_flag_,

    input wire [31:0] h1,
    input wire [31:0] h2,

    output reg [31:0] ROB_size__,
    output reg [31:0] ROB_R__,
    output reg ROB_s_ready_h1,
    output reg ROB_s_ready_h2,
    output reg [31:0] ROB_s_value_h1,
    output reg [31:0] ROB_s_value_h2,

    input wire insqueue_to_ROB_needchange,
    input wire insqueue_to_ROB_size_addflag,
    input wire [31:0] b1,

    input wire [31:0] ROB_R_,
    input wire [31:0] ROB_s_pc_b1_,
    input wire [31:0] ROB_s_inst_b1_,
    input wire [5:0] ROB_s_ordertype_b1_,
    input wire [31:0] ROB_s_dest_b1_,
    input wire [31:0] ROB_s_jumppc_b1_,
    input wire ROB_s_ready_b1_,
    input wire ROB_s_isjump_b1_,

    input wire RS_to_ROB_needchange,
    input wire RS_to_ROB_needchange2,
    input wire [31:0] b2,

    input wire [31:0] ROB_s_value_b2_,
    input wire ROB_s_ready_b2_,
    input wire [31:0] ROB_s_jumppc_b2_,

    input wire SLB_to_ROB_needchange,
    input wire [31:0] b4,

    input wire [31:0] ROB_s_value_b4_,
    input wire ROB_s_ready_b4_ 
);

reg [5:0] s_order[31:0];
reg [31:0] s_inst[31:0];
reg [31:0] s_pc[31:0];
reg [31:0] s_topc[31:0];
reg [31:0] s_value[31:0];
reg [31:0] s_dest[31:0];
reg s_ready[31:0];
reg s_jump[31:0];
reg [31:0] ll,rr,size;


reg sub_flag;


wire branch;
IsBranch branch1(
    .type(s_order[b3]),
    .is_Branch(branch)
);

wire store;
IsStore store1(
    .type(s_order[b3]),
    .is_Store(store)
);

integer i,j;

always @(*) begin
    sub_flag=0;
    ROB_to_Reg_needchange=0;
    ROB_to_Reg_needchange2=0;
    ROB_to_RS_needchange=0;
    ROB_to_SLB_needchange=0;
    ROB_to_SLB_needchange2=0;
    ROB_to_BHT_needchange2=0;
    ROB_to_BHT_needchange=0;
    Clear_flag_=0;

    if(!size);
    else begin
      b3=ll;
      if(branch) begin
        if(!s_ready[b3]);
        else begin
          sub_flag=1;

          if(s_order[b3]==`JAL) begin
            ROB_to_Reg_needchange=1;
            commit_rd=s_dest[b3];
            reg_reg_commit_rd_=s_value[b3];
            if(reg_busy_commit_rd&& reg_reorder_commit_rd==b3) begin
              ROB_to_Reg_needchange2=1;
              reg_busy_commit_rd_=0;
            end

            ROB_to_RS_needchange=1;
            ROB_to_RS_value_b3=s_value[b3];

            ROB_to_SLB_needchange=1;
            ROB_to_SLB_value_b3=s_value[b3];

          end
          else begin
            if((s_value[b3]^s_jump[b3])==1 || s_order[b3]==`JALR) begin
              ROB_to_BHT_needchange=1;
              bht_id2=s_inst[b3][11:0];
              if(s_value[b3]) pc_=s_topc[b3];
              else pc_=s_pc[b3]+4;
              Clear_flag_=1;

              if(s_order[b3]==`JALR) begin
                ROB_to_Reg_needchange=1;
                commit_rd=s_dest[b3];
                reg_reg_commit_rd_=s_value[b3];
                if(reg_busy_commit_rd && reg_reorder_commit_rd==b3) begin
                  ROB_to_Reg_needchange2=1;
                  reg_busy_commit_rd_=0;
                end
              end
            end
            else begin
              ROB_to_BHT_needchange2=1;
              bht_id2=s_inst[b3][11:0];
            end
          end
        end
      end

      else if(store) begin
        if(!s_ready[b3]) begin
          ROB_to_SLB_needchange2=1;
        end

        else begin
          sub_flag=1;
        end
      end

      else begin
        if(!s_ready[b3]);
        else begin
          sub_flag=1;
          ROB_to_Reg_needchange=1;
          commit_rd=s_dest[b3];
          reg_reg_commit_rd_=s_value[b3];
          if(reg_busy_commit_rd && reg_reorder_commit_rd==b3) begin
            ROB_to_Reg_needchange2=1;
            reg_busy_commit_rd_=0;
          end

            ROB_to_RS_needchange=1;
            ROB_to_RS_value_b3=s_value[b3];

            ROB_to_SLB_needchange=1;
            ROB_to_SLB_value_b3=s_value[b3];


        end
      end
    end
end

always @(*) begin
    ROB_size__=size;
    ROB_R__=rr;
    ROB_s_ready_h1=s_ready[h1];
    ROB_s_ready_h2=s_ready[h2];
    ROB_s_value_h1=s_value[h1];
    ROB_s_value_h2=s_value[h2];
end

always @(posedge clk) begin
    if(rst) begin
      for(i=0;i<32;i=i+1) begin
        s_order[i]<=0;
        s_inst[i]<=0;
        s_pc[i]<=0;
        s_topc[i]<=0;
        s_value[i]<=0;
        s_dest[i]<=0;
        s_ready[i]<=0;
        s_jump[i]<=0;
      end

      ll<=1;
      rr<=0;
      size<=0;
    end

    else if(~rdy) begin
      
    end

    else if(Clear_flag) begin
      ll<=1;
      rr<=0;
      size<=0;
      for(i=0;i<32;i=i+1) begin
        s_ready[i]<=0;
      end
    end

    else begin
      size<=size+insqueue_to_ROB_size_addflag-sub_flag;

      if(!size);

      else begin
        if(branch) begin
          if(!s_ready[b3]);
          else begin
            ll<=(ll+1)%32;
          end
        end

        else if(store) begin
          if(!s_ready[b3]);
          else begin
            ll<=(ll+1)%32;
          end
        end

        else begin
          if(!s_ready[b3]);
          else begin
            ll<=(ll+1)%32;
          end
        end
      end


      if(insqueue_to_ROB_needchange) begin
        rr<=ROB_R_;
        s_pc[b1]<=ROB_s_pc_b1_;
        s_inst[b1]<=ROB_s_inst_b1_;
        s_order[b1]<=ROB_s_ordertype_b1_;
        s_dest[b1]<=ROB_s_dest_b1_;
        s_topc[b1]<=ROB_s_jumppc_b1_;
        s_ready[b1]<=ROB_s_ready_b1_;
        s_jump[b1]<=ROB_s_isjump_b1_;
      end

      if(RS_to_ROB_needchange) begin
        s_value[b2]<=ROB_s_value_b2_;
        s_ready[b2]<=ROB_s_ready_b2_;

        if(RS_to_ROB_needchange2) begin
          s_topc[b2]<=ROB_s_jumppc_b2_;
        end

      end

      if(SLB_to_ROB_needchange) begin
        s_value[b4]<=ROB_s_value_b4_;
        s_ready[b4]<=ROB_s_ready_b4_;
      end
      
    end
end




endmodule