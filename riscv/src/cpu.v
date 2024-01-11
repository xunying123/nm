// RISCV32I CPU top module
// port modification allowed for debugging purposes

module cpu(
  input  wire   clk_in,			// system clock signal
  input  wire   rst_in,			// reset signal
	input  wire					 rdy_in,			// ready signal, pause cpu when low

  input  wire [ 7:0]   mem_din,		// data input bus
  output wire [ 7:0]   mem_dout,		// data output bus
  output wire [31:0]   mem_a,			// address bus (only 17:0 is used)
  output wire   mem_wr,			// write/read signal (1 for write)
	
	input  wire   io_buffer_full, // 1 if uart buffer is full
	
	output wire [31:0]			dbgreg_dout		// cpu register output (debugging demo)
);

// implementation goes here

// Specifications:
// - Pause cpu(freeze pc, registers, etc.) when rdy_in is low
// - Memory read result will be returned in the next cycle. Write takes 1 cycle(no need to wait)
// - Memory is of size 128KB, with valid address ranging from 0x0 to 0x20000
// - I/O port is mapped to address higher than 0x30000 (mem_a[17:16]==2'data11)
// - 0x30000 read: read a byte from input
// - 0x30000 write: write a byte to output (write 0x00 is ignored)
// - 0x30004 read: read clocks passed since cpu starts (in dword, 4 bytes)
// - 0x30004 write: indicates program stop (will output '\0' through uart tx)

wire clear;

/* Get_ins_to_queue() */  //insqueue
//memctrl
wire memctrl_ins_ready;
wire [31:0] memctrl_ins_;

wire Insq_Mem;

wire [31:0] memctrl_ins_addr;
wire [3:0] memctrl_remain;

//   Search_In_ICache()
//icache
wire [31:0] addr1;
wire hit_icache;
wire [31:0] return_inst;

//   Store_In_ICache()
//icache
wire Inq_Icache;
wire [31:0] addr2;
wire [31:0] store_Inst;

//   BranchJudge()
//BHT
wire [31:0] index_bht;
wire bht_re;


/* do_ins_queue() */  //insqueue
//ROB
wire [31:0] h1;
wire [31:0] h2;

wire [31:0] rob_size;
wire [31:0] rob_r;
wire rob_h1_ready;
wire [31:0] h1_value;
wire rob_h2_ready;
wire [31:0] h2_value;

wire Insq_ROB;
wire ROB_add;
wire [31:0] data1;

wire [31:0] rob_r_;
wire [31:0] rob_pc_;
wire [31:0] rob_inst_;
wire [5:0] rob_order_;
wire [31:0] rob_dest_;
wire [31:0] rob_topc_;
wire rob_jump_;
wire rob_ready_;

//RS
wire [31:0] rs_unbusy;

wire Insq_RS;
wire [31:0] return2;

wire [31:0] rs_vj;
wire [31:0] rs_vk;
wire [31:0] rs_qj;
wire [31:0] rs_qk;
wire [31:0] rs_inst;
wire [5:0] rs_order;
wire [31:0] rs_pc;
wire [31:0] rs_topc;
wire [31:0] rs_A;
wire [31:0] rs_reorder;
wire rs_busy;

//SLB
wire [31:0] slb_size;
wire [31:0] slb_r;

wire Insq_SLB;
wire SLB_add;
wire [31:0] return1;

wire [31:0] slb_r_;
wire [31:0] slb_vj;
wire [31:0] slb_vk;
wire [31:0] slb_qj;
wire [31:0] slb_qk;
wire [31:0] slb_inst;
wire [31:0] slb_order;
wire [31:0] slb_pc;
wire [31:0] slb_A;
wire [31:0] slb_reorder;
wire slb_ready;

//Reg
wire [31:0] rs1_0;
wire [31:0] rs2_0;

wire reg_busy_rs1;
wire reg_busy_rs2;
wire [31:0] reg_rs1_reorder;
wire [31:0] reg_rs2_reorder;
wire [31:0] reg_order_rs1;
wire [31:0] reg_order_rs2;

wire Insq_REG;
wire [31:0] order_rd;

wire rd_busy;
wire [31:0] rd_reorder;


/* do_ROB() */  //ROB
//RS and SLB
wire [31:0] data3;

//BHT
wire wrong; // predict wrong
wire right; // predict correct
wire [31:0] index_bht2;

//RS
wire ROB_RS;
wire [31:0] data3_RS;

//SLB
wire ROB_SLB;
wire ROB_SLB2;
wire [31:0] data3_SLB;


//Reg
wire [31:0] rd_commit;

wire rd_busy_commit;
wire [31:0] rd_reorder_commit;

wire ROB_Reg;
wire ROB_Reg2;

wire [31:0] rd_data_commit;
wire rd_busy_commit_;

//insqueue
wire [31:0] pc_;

/* do_RS() */  //RS
//ROB and SLB
wire [31:0] data2;

//ROB
wire RS_ROB;
wire RS_ROB2;

wire [31:0] data2_value;
wire data2_ready;
wire [31:0] data2_topc;

//SLB
wire RS_SLB;

wire [31:0] slb_value;


/* do_SLB() */
//RS and ROB
wire [31:0] data4;

//memctrl
wire memctrl_data_ready;
wire [31:0] memctrl_data_ret;

wire slb_load;//load
wire slb_store;//store

wire [5:0] slb_mem_order;
wire [31:0] slb_mem_vj;
wire [31:0] slb_mem_vk;
wire [31:0] slb_mem_A;

//ROB
wire SLB_ROB;
wire [31:0] data4_value;
wire data4_ready;

//RS
wire SLB_RS;
wire [31:0] load_value;


I_QUEUE  I_QUEUE_inst (
    .clk(clk_in),
    .rst(rst_in),
    .rdy(rdy_in),
    .clear(clear),
    .memctrl_ins_ready(memctrl_ins_ready),
    .memctrl_ins_(memctrl_ins_),
    .Insq_Mem(Insq_Mem),
    .memctrl_ins_addr(memctrl_ins_addr),
    .memctrl_remain(memctrl_remain),
    .addr1(addr1),
    .hit_icache_(hit_icache),
    .return_inst(return_inst),
    .Inq_Icache(Inq_Icache),
    .addr2(addr2),
    .store_Inst(store_Inst),
    .index_bht(index_bht),
    .bht_re(bht_re),
    .h1(h1),
    .h2(h2),
    .rob_size(rob_size),
    .rob_r(rob_r),
    .rob_h1_ready(rob_h1_ready),
    .rob_h2_ready(rob_h2_ready),
    .h1_value(h1_value),
    .h2_value(h2_value),
    .Insq_ROB(Insq_ROB),
    .ROB_add(ROB_add),
    .data1(data1),
    .rob_r_(rob_r_),
    .rob_pc_(rob_pc_),
    .rob_inst_(rob_inst_),
    .rob_order_(rob_order_),
    .rob_dest_(rob_dest_),
    .rob_topc_(rob_topc_),
    .rob_ready_(rob_ready_),
    .rob_jump_(rob_jump_),
    .rs_unbusy(rs_unbusy),
    .Insq_RS(Insq_RS),
    .return2(return2),
    .rs_vj(rs_vj),
    .rs_vk(rs_vk),
    .rs_qj(rs_qj),
    .rs_qk(rs_qk),
    .rs_inst(rs_inst),
    .rs_pc(rs_pc),
    .rs_topc(rs_topc),
    .rs_A(rs_A),
    .rs_reorder(rs_reorder),
    .rs_order(rs_order),
    .rs_busy(rs_busy),
    .slb_size(slb_size),
    .slb_r(slb_r),
    .Insq_SLB(Insq_SLB),
    .SLB_add(SLB_add),
    .return1(return1),
    .slb_r_(slb_r_),
    .slb_pc(slb_pc),
    .slb_inst(slb_inst),
    .slb_order(slb_order),
    .slb_reorder(slb_reorder),
    .slb_vj(slb_vj),
    .slb_vk(slb_vk),
    .slb_qj(slb_qj),
    .slb_qk(slb_qk),
    .slb_A(slb_A),
    .slb_ready(slb_ready),
    .rs1_0(rs1_0),
    .rs2_0(rs2_0),
    .reg_busy_rs1(reg_busy_rs1),
    .reg_busy_rs2(reg_busy_rs2),
    .reg_rs1_reorder(reg_rs1_reorder),
    .reg_rs2_reorder(reg_rs2_reorder),
    .reg_order_rs1(reg_order_rs1),
    .reg_order_rs2(reg_order_rs2),
    .order_rd(order_rd),
    .Insq_REG(Insq_REG),
    .rd_busy(rd_busy),
    .rd_reorder(rd_reorder),
    .pc_(pc_)
  );

  ICache  ICache_inst (
    .clk(clk_in),
    .rst(rst_in),
    .rdy(rdy_in),
    .addr1(addr1),
    .hit_icache(hit_icache),
    .return_inst(return_inst),
    .Inq_Icache(Inq_Icache),
    .addr2(addr2),
    .store_Inst(store_Inst)
  );


  MemCtrl  MemCtrl_inst (
    .clk(clk_in),
    .rst(rst_in),
    .rdy(rdy_in),
    .w_r(mem_wr),
    .addr_input(mem_a),
    .data_output(mem_din),
    .data_input(mem_dout),
    .clear(clear),
    .memctrl_ins_ready(memctrl_ins_ready),
    .memctrl_ins_(memctrl_ins_),
    .Insq_Mem(Insq_Mem),
    .memctrl_ins_addr(memctrl_ins_addr),
    .memctrl_remain(memctrl_remain),
    .memctrl_data_ready(memctrl_data_ready),
    .memctrl_data_ret(memctrl_data_ret),
    .slb_load(slb_load),
    .slb_store(slb_store),
    .slb_mem_order(slb_mem_order),
    .slb_mem_vj(slb_mem_vj),
    .slb_mem_vk(slb_mem_vk),
    .slb_mem_A(slb_mem_A)
  );

  REG  REG_inst (
    .clk(clk_in),
    .rst(rst_in),
    .rdy(rdy_in),
    .clear(clear),
    .Insq_REG(Insq_REG),
    .rs1_0(rs1_0),
    .rs2_0(rs2_0),
    .reg_busy_rs1(reg_busy_rs1),
    .reg_busy_rs2(reg_busy_rs2),
    .reg_rs1_reorder(reg_rs1_reorder),
    .reg_rs2_reorder(reg_rs2_reorder),
    .reg_order_rs1(reg_order_rs1),
    .reg_order_rs2(reg_order_rs2),
    .order_rd(order_rd),
    .rd_reorder(rd_reorder),
    .rd_busy(rd_busy),
    .ROB_Reg(ROB_Reg),
    .ROB_Reg2(ROB_Reg2),
    .rd_commit(rd_commit),
    .rd_busy_commit(rd_busy_commit),
    .rd_reorder_commit(rd_reorder_commit),
    .rd_data_commit(rd_data_commit),
    .rd_busy_commit_(rd_busy_commit_)
  );


  ROB  ROB_inst (
    .clk(clk_in),
    .rst(rst_in),
    .rdy(rdy_in),
    .clear(clear),
    .data3(data3),
    .right(right),
    .wrong(wrong),
    .index_bht2(index_bht2),
    .ROB_RS(ROB_RS),
    .data3_RS(data3_RS),
    .ROB_SLB(ROB_SLB),
    .ROB_SLB2(ROB_SLB2),
    .data3_SLB(data3_SLB),
    .rd_commit(rd_commit),
    .rd_busy_commit(rd_busy_commit),
    .rd_reorder_commit(rd_reorder_commit),
    .ROB_Reg(ROB_Reg),
    .ROB_Reg2(ROB_Reg2),
    .rd_data_commit(rd_data_commit),
    .rd_busy_commit_(rd_busy_commit_),
    .pc_(pc_),
    .clear_o(clear),
    .h1(h1),
    .h2(h2),
    .rob_size(rob_size),
    .rob_r(rob_r),
    .rob_h1_ready(rob_h1_ready),
    .rob_h2_ready(rob_h2_ready),
    .h1_value(h1_value),
    .h2_value(h2_value),
    .Insq_ROB(Insq_ROB),
    .ROB_add(ROB_add),
    .data1(data1),
    .rob_r_(rob_r_),
    .rob_pc_(rob_pc_),
    .rob_inst_(rob_inst_),
    .rob_order_(rob_order_),
    .rob_dest_(rob_dest_),
    .rob_topc_(rob_topc_),
    .rob_ready_(rob_ready_),
    .rob_jump_(rob_jump_),
    .RS_ROB(RS_ROB),
    .RS_ROB2(RS_ROB2),
    .data2(data2),
    .data2_value(data2_value),
    .data2_ready(data2_ready),
    .data2_topc(data2_topc),
    .SLB_ROB(SLB_ROB),
    .data4(data4),
    .data4_value(data4_value),
    .data4_ready(data4_ready)
  );

  RS  RS_inst (
    .clk(clk_in),
    .rst(rst_in),
    .rdy(rdy_in),
    .clear(clear),
    .data2(data2),
    .RS_ROB(RS_ROB),
    .RS_ROB2(RS_ROB2),
    .data2_value(data2_value),
    .data2_topc(data2_topc),
    .data2_ready(data2_ready),
    .data3(data3),
    .ROB_RS(ROB_RS),
    .data3_RS(data3_RS),
    .RS_SLB(RS_SLB),
    .slb_value(slb_value),
    .data4(data4),
    .load_value(load_value),
    .SLB_RS(SLB_RS),
    .rs_unbusy(rs_unbusy),
    .Insq_RS(Insq_RS),
    .return2(return2),
    .rs_vj(rs_vj),
    .rs_vk(rs_vk),
    .rs_qj(rs_qj),
    .rs_qk(rs_qk),
    .rs_inst(rs_inst),
    .rs_order(rs_order),
    .rs_pc(rs_pc),
    .rs_topc(rs_topc),
    .rs_A(rs_A),
    .rs_reorder(rs_reorder),
    .rs_busy(rs_busy)
  );

  SLB  SLB_inst (
    .clk(clk_in),
    .rst(rst_in),
    .rdy(rdy_in),
    .clear(clear),
    .data4(data4),
    .memctrl_data_ready(memctrl_data_ready),
    .memctrl_data_ret(memctrl_data_ret),
    .slb_load(slb_load),
    .slb_store(slb_store),
    .slb_mem_order(slb_mem_order),
    .slb_mem_vj(slb_mem_vj),
    .slb_mem_vk(slb_mem_vk),
    .slb_mem_A(slb_mem_A),
    .SLB_ROB(SLB_ROB),
    .data4_value(data4_value),
    .data4_ready(data4_ready),
    .SLB_RS(SLB_RS),
    .load_value(load_value),
    .slb_size(slb_size),
    .slb_r(slb_r),
    .Insq_SLB(Insq_SLB),
    .SLB_add(SLB_add),
    .return1(return1),
    .slb_r_(slb_r_),
    .slb_vj(slb_vj),
    .slb_vk(slb_vk),
    .slb_A(slb_A),
    .slb_reorder(slb_reorder),
    .slb_qj(slb_qj),
    .slb_qk(slb_qk),
    .slb_pc(slb_pc),
    .slb_inst(slb_inst),
    .slb_order(slb_order),
    .slb_ready(slb_ready),
    .RS_SLB(RS_SLB),
    .data2(data2),
    .slb_value(slb_value),
    .data3(data3),
    .ROB_SLB(ROB_SLB),
    .ROB_SLB2(ROB_SLB2),
    .data3_SLB(data3_SLB)
  );

  BHT  BHT_inst (
    .clk(clk_in),
    .rst(rst_in),
    .rdy(rdy_in),
    .right(right),
    .wrong(wrong),
    .index_bht(index_bht),
    .index_bht2(index_bht2),
    .bht_re(bht_re)
  );









endmodule