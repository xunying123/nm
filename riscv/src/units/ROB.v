

module ROB(
    input wire clk,
    input wire rst,
    input wire rdy,

    input wire clear,

    output reg [31:0] data3,
    output reg right,
    output reg wrong,

    output reg [31:0] index_bht2,

    output reg ROB_RS,
    output reg [31:0] data3_RS,

    output reg ROB_SLB,
    output reg ROB_SLB2,
    output reg [31:0] data3_SLB,

    output reg [31:0] rd_commit,
    input wire rd_busy_commit,
    input wire [31:0] rd_reorder_commit,

    output reg ROB_Reg,
    output reg ROB_Reg2,

    output reg [31:0] rd_data_commit,
    output reg rd_busy_commit_,

    output reg [31:0] pc_,
    output reg clear_o,

    input wire [31:0] h1,
    input wire [31:0] h2,

    output reg [31:0] rob_size,
    output reg [31:0] rob_r,
    output reg rob_h1_ready,
    output reg rob_h2_ready,
    output reg [31:0] h1_value,
    output reg [31:0] h2_value,

    input wire Insq_ROB,
    input wire ROB_add,
    input wire [31:0] data1,

    input wire [31:0] rob_r_,
    input wire [31:0] rob_pc_,
    input wire [31:0] rob_inst_,
    input wire [5:0] rob_order_,
    input wire [31:0] rob_dest_,
    input wire [31:0] rob_topc_,
    input wire rob_ready_,
    input wire rob_jump_,

    input wire RS_ROB,
    input wire RS_ROB2,
    input wire [31:0] data2,

    input wire [31:0] data2_value,
    input wire data2_ready,
    input wire [31:0] data2_topc,

    input wire SLB_ROB,
    input wire [31:0] data4,

    input wire [31:0] data4_value,
    input wire data4_ready 
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
Branch branch1(
    .order(s_order[data3]),
    .is(branch)
);

wire store;
Store store1(
    .order(s_order[data3]),
    .is(store)
);

integer i,j;

always @(*) begin
    sub_flag=0;
    ROB_Reg=0;
    ROB_Reg2=0;
    ROB_RS=0;
    ROB_SLB=0;
    ROB_SLB2=0;
    right=0;
    wrong=0;
    clear_o=0;

    if(!size);
    else begin
      data3=ll;
      if(branch) begin
        if(!s_ready[data3]);
        else begin
          sub_flag=1;

          if(s_order[data3]==`JAL) begin
            ROB_Reg=1;
            rd_commit=s_dest[data3];
            rd_data_commit=s_value[data3];
            if(rd_busy_commit&& rd_reorder_commit==data3) begin
              ROB_Reg2=1;
              rd_busy_commit_=0;
            end

            ROB_RS=1;
            data3_RS=s_value[data3];

            ROB_SLB=1;
            data3_SLB=s_value[data3];

          end
          else begin
            if((s_value[data3]^s_jump[data3])==1 || s_order[data3]==`JALR) begin
              wrong=1;
              index_bht2=s_inst[data3][11:0];
              if(s_value[data3]) pc_=s_topc[data3];
              else pc_=s_pc[data3]+4;
              clear_o=1;

              if(s_order[data3]==`JALR) begin
                ROB_Reg=1;
                rd_commit=s_dest[data3];
                rd_data_commit=s_value[data3];
                if(rd_busy_commit && rd_reorder_commit==data3) begin
                  ROB_Reg2=1;
                  rd_busy_commit_=0;
                end
              end
            end
            else begin
              right=1;
              index_bht2=s_inst[data3][11:0];
            end
          end
        end
      end

      else if(store) begin
        if(!s_ready[data3]) begin
          ROB_SLB2=1;
        end

        else begin
          sub_flag=1;
        end
      end

      else begin
        if(!s_ready[data3]);
        else begin
          sub_flag=1;
          ROB_Reg=1;
          rd_commit=s_dest[data3];
          rd_data_commit=s_value[data3];
          if(rd_busy_commit && rd_reorder_commit==data3) begin
            ROB_Reg2=1;
            rd_busy_commit_=0;
          end

            ROB_RS=1;
            data3_RS=s_value[data3];

            ROB_SLB=1;
            data3_SLB=s_value[data3];


        end
      end
    end
end

always @(*) begin
    rob_size=size;
    rob_r=rr;
    rob_h1_ready=s_ready[h1];
    rob_h2_ready=s_ready[h2];
    h1_value=s_value[h1];
    h2_value=s_value[h2];
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

    else if(clear) begin
      ll<=1;
      rr<=0;
      size<=0;
      for(i=0;i<32;i=i+1) begin
        s_ready[i]<=0;
      end
    end

    else begin
      size<=size+ROB_add-sub_flag;

      if(!size);

      else begin
        if(branch) begin
          if(!s_ready[data3]);
          else begin
            ll<=(ll+1)%32;
          end
        end

        else if(store) begin
          if(!s_ready[data3]);
          else begin
            ll<=(ll+1)%32;
          end
        end

        else begin
          if(!s_ready[data3]);
          else begin
            ll<=(ll+1)%32;
          end
        end
      end


      if(Insq_ROB) begin
        rr<=rob_r_;
        s_pc[data1]<=rob_pc_;
        s_inst[data1]<=rob_inst_;
        s_order[data1]<=rob_order_;
        s_dest[data1]<=rob_dest_;
        s_topc[data1]<=rob_topc_;
        s_ready[data1]<=rob_ready_;
        s_jump[data1]<=rob_jump_;
      end

      if(RS_ROB) begin
        s_value[data2]<=data2_value;
        s_ready[data2]<=data2_ready;

        if(RS_ROB2) begin
          s_topc[data2]<=data2_topc;
        end

      end

      if(SLB_ROB) begin
        s_value[data4]<=data4_value;
        s_ready[data4]<=data4_ready;
      end
      
    end
end




endmodule