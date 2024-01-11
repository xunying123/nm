

module I_QUEUE(
    input wire clk,
    input wire rst,
    input wire rdy,

    input wire clear,

    input wire memctrl_ins_ready,
    input wire [31:0] memctrl_ins_,

    output reg Insq_Mem,
    output reg [31:0] memctrl_ins_addr,
    output reg [3:0] memctrl_remain,

    output reg [31:0] addr1,
    input wire hit_icache_,
    input wire [31:0] return_inst,

    output reg Inq_Icache,
    output reg [31:0] addr2,
    output reg [31:0] store_Inst,

    output reg[31:0] index_bht,
    input wire bht_re,

    output reg [31:0] h1,
    output reg [31:0] h2,

    input wire [31:0] rob_size,
    input wire [31:0] rob_r,
    input wire rob_h1_ready,
    input wire rob_h2_ready,
    input wire [31:0] h1_value,
    input wire [31:0] h2_value,

    output reg Insq_ROB,
    output reg ROB_add,
    output reg [31:0] data1,

    output reg [31:0] rob_r_,
    output reg [31:0] rob_pc_,
    output reg [31:0] rob_inst_,
    output reg [5:0] rob_order_,
    output reg [31:0] rob_dest_,
    output reg [31:0] rob_topc_,
    output reg rob_ready_,
    output reg rob_jump_,

    input wire [31:0] rs_unbusy,
    output reg Insq_RS,
    output reg [31:0] return2,

    output reg [31:0] rs_vj,
    output reg [31:0] rs_vk,
    output reg [31:0] rs_qj,
    output reg [31:0] rs_qk,
    output reg [31:0] rs_inst,
    output reg [31:0] rs_pc,
    output reg [31:0] rs_topc,
    output reg [31:0] rs_A,
    output reg [31:0] rs_reorder,
    output reg [5:0] rs_order,
    output reg rs_busy,

    input wire [31:0] slb_size,
    input wire [31:0] slb_r,

    output reg Insq_SLB,
    output reg SLB_add,
    output reg [31:0] return1,

    output reg [31:0] slb_r_,
    output reg [31:0] slb_pc,
    output reg [31:0] slb_inst,
    output reg [31:0] slb_order,
    output reg [31:0] slb_reorder,
    output reg [31:0] slb_vj,
    output reg [31:0] slb_vk,
    output reg [31:0] slb_qj,
    output reg [31:0] slb_qk,
    output reg [31:0] slb_A,
    output reg slb_ready,

    output reg [31:0] rs1_0,
    output reg [31:0] rs2_0,

    input wire reg_busy_rs1,
    input wire reg_busy_rs2,
    input wire [31:0] reg_rs1_reorder,
    input wire [31:0] reg_rs2_reorder,
    input wire [31:0] reg_order_rs1,
    input wire [31:0] reg_order_rs2,

    output reg [31:0] order_rd,
    output reg Insq_REG,

    output reg rd_busy,
    output reg [31:0] rd_reorder,

    input wire [31:0] pc_

);

reg [31:0] pc;

reg [31:0] insq_inst[31:0];
reg [31:0] insq_pc[31:0];
reg [31:0] insq_topc[31:0];
reg insq_jump[31:0];
reg [5:0] insq_order[31:0];
reg [31:0] ll,rr,size;
reg insq_waiting;

reg hit;
reg [31:0] inst;
wire [5:0] order;
wire [31:0] rd;
wire [31:0] rs1;
wire [31:0] rs2;
wire [31:0] imm;

DE de1(
    .inst(inst),
    .order(order),
    .rd(rd),
    .rs1(rs1),
    .rs2(rs2),
    .imm(imm)
);

wire branch;
Branch branch1(
    .order(order),
    .is(branch)
);

wire [5:0] order_;
wire [31:0] rd_;
wire [31:0] rs1_;
wire [31:0] rs2_;
wire [31:0] imm_;

DE de2(
    .inst(insq_inst[ll]),
    .order(order_),
    .rd(rd_),
    .rs1(rs1_),
    .rs2(rs2_),
    .imm(imm_)
);

always @(*) begin
    order_rd=rd_;
    rs1_0=rs1_;
    rs2_0=rs2_;
end

wire load;
Load load1(
    .order(insq_order[ll]),
    .is(load)
);

wire store;
Store store1(
    .order(insq_order[ll]),
    .is(store)
);

reg [31:0] add_flag;

integer i,j;

always @(*) begin
    hit=0;
    add_flag=0;
    Insq_Mem=0;
    Inq_Icache=0;

    if(!insq_waiting && size!=32) begin
      addr1=pc;
      hit=hit_icache_;
      inst=return_inst;

      if(!hit) begin
        Insq_Mem=1;
        memctrl_ins_addr=pc;
        memctrl_remain=4;
      end
    end

    if(memctrl_ins_ready) begin
      inst=memctrl_ins_;
      Inq_Icache=1;
      addr2=pc;
      store_Inst=memctrl_ins_;
    end

    if(memctrl_ins_ready||hit) begin
      j=(rr+1)%32;
      add_flag=1;

      if(branch) begin
        if(order==`JAL);
        else begin
          if(order==`JALR);
          else begin
          index_bht=inst[11:0];
        end
      end
    end
end
end

reg [31:0] sub_flag;


always @(*) begin
    sub_flag=0;
    Insq_RS=0;
    Insq_SLB=0;
    SLB_add=0;
    Insq_ROB=0;
    ROB_add=0;
    Insq_REG=0;

    if(size==0);
    else if(rob_size==32);
    else begin
      if(load || store) begin
        if(slb_size==32) ;
        else begin
          Insq_SLB=1;
          Insq_ROB=1;
          return1=(slb_r+1)%32;
          slb_r_=return1;
          SLB_add=1;

          data1=(rob_r+1)%32;
          rob_r_=data1;
          ROB_add=1;

          sub_flag=1;

          rob_pc_=insq_pc[ll];
          rob_inst_=insq_inst[ll];
          rob_order_=insq_order[ll];
          rob_dest_=order_rd;
          rob_ready_=0;
          

          if(reg_busy_rs1) begin
            h1=reg_rs1_reorder;
            if(rob_h1_ready) begin
              slb_vj=h1_value;
              slb_qj=-1;
            end
            else slb_qj=h1;
          end

          else begin
            slb_vj=reg_order_rs1;
            slb_qj=-1;
          end

          if(store) begin
            if(reg_busy_rs2) begin
              h2=reg_rs2_reorder;
              if(rob_h2_ready) begin
                slb_vk=h2_value;
                slb_qk=-1;
              end
              else slb_qk=h2;
            end

            else begin
              slb_vk=reg_order_rs2;
              slb_qk=-1;
            end
          end

          else slb_qk=-1;


          slb_inst=insq_inst[ll];
            slb_order=insq_order[ll];
            slb_reorder=data1;
            slb_pc=insq_pc[ll];
            slb_A=imm_;

            if(store) begin
              slb_ready=0;
            end


            if(!store) begin
              Insq_REG=1;
              rd_reorder=data1;
              rd_busy=1;
            end
        end
      end

      else begin
        return2=rs_unbusy;
        if(return2==-1);
        else begin
          data1=(rob_r+1)%32;
          sub_flag=1;
          Insq_ROB=1;
          rob_r_=data1;
          ROB_add=1;
          rob_inst_=insq_inst[ll];
          rob_pc_=insq_pc[ll];
          rob_order_=insq_order[ll];
          rob_topc_=insq_topc[ll];
          rob_jump_=insq_jump[ll];
            rob_dest_=order_rd;
            rob_ready_=0;

            Insq_RS=1;

            if(insq_inst[ll][6:0]!=7'h37 && insq_inst[ll][6:0]!=7'h17 && insq_inst[ll][6:0]!=7'h6f) begin
              if(reg_busy_rs1) begin
                h1=reg_rs1_reorder;
                if(rob_h1_ready) begin
                  rs_vj=h1_value;
                  rs_qj=-1;
                end
                else rs_qj=h1;
              end

              else begin
                rs_vj=reg_order_rs1;
                rs_qj=-1;
              end
            end

            else rs_qj=-1;


            if(insq_inst[ll][6:0]==7'h33 || insq_inst[ll][6:0]==7'h63) begin
              if(reg_busy_rs2) begin
                h2=reg_rs2_reorder;
                if(rob_h2_ready) begin
                  rs_vk=h2_value;
                  rs_qk=-1;
                end
                else rs_qk=h2;
              end

              else begin
                rs_vk=reg_order_rs2;
                rs_qk=-1;
              end
            end

            else rs_qk=-1;

            rs_inst=insq_inst[ll];
            rs_pc=insq_pc[ll];
            rs_topc=insq_topc[ll];
            rs_A=imm_;
            rs_reorder=data1;
            rs_order=insq_order[ll];
            rs_busy=1;

            if(insq_inst[ll][6:0]!=7'h63) begin
              Insq_REG=1;
              rd_reorder=data1;
              rd_busy=1;
            end
        end
      end
    end
end

always @(posedge clk) begin
    if(rst) begin
      pc<=0;

      for(i=0;i<32;i=i+1) begin
        insq_inst[i]<=0;
        insq_pc[i]<=0;
        insq_topc[i]<=0;
        insq_order[i]<=0;
        insq_jump[i]<=0;
      end
      ll<=1;
        rr<=0;
        size<=0;
        insq_waiting<=0;
    end

    else if(~rdy) begin
      
    end

    else if(clear) begin
      ll<=1;
      rr<=0;
      size<=0;
      insq_waiting<=0;
      pc<=pc_;
    end


    else begin
      size<=size+add_flag-sub_flag;
      if(!insq_waiting && size!=32) begin
        if(!hit) begin
          insq_waiting<=1;
        end
      end

      if(memctrl_ins_ready) begin
        insq_waiting<=0;
      end

      if(memctrl_ins_ready || hit) begin
        rr<=j;
        insq_inst[j]<=inst;
        insq_pc[j]<=pc;
        insq_order[j]<=order;

        if(branch) begin
          if(order==`JAL) begin
            pc<=pc+imm;
          end 

          else begin
            
          if(order==`JALR) begin
            pc<=pc+4;
          end

          else begin
            insq_topc[j]<=pc+imm;

            if(bht_re) begin
              pc<=pc+imm;
              insq_jump[j]<=1;
            end

            else begin
                pc<=pc+4;
                insq_jump[j]<=0;
            end
          end
        end
      end

      else begin
        pc<=pc+4;
      end
    end

    if(size==0);

    else if(rob_size==32);
    else begin
      if(store || load) begin
        if(slb_size==32);
        else begin
          ll<=(ll+1)%32;
        end
      end

      else begin
        if(return2==-1);
        else begin
          ll<=(ll+1)%32;
        end
      end
    end
end
end

endmodule