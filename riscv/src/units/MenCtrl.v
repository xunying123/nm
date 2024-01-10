
module MemCtrl(
    input wire clk,
    input wire rst,
    input wire rdy,
    input wire io_buffer_full,
    output reg w_r,
    output reg [31:0] addr_input,
    input wire [7:0] data_output,
    output reg [7:0] data_input,

    input wire clear,

    output reg memctrl_ins_ready,
    output reg [31:0] memctrl_ins_,

    input wire Insq_Mem,
    input wire [31:0] memctrl_ins_addr,
    input wire [3:0] memctrl_remain,

    output reg memctrl_data_ready,
    output reg [31:0] memctrl_data_ret,

    input wire slb_load,
    input wire slb_store,

    input wire [5:0] slb_mem_order,
    input wire [31:0] slb_mem_vj,
    input wire [31:0] slb_mem_vk,
    input wire [31:0] slb_mem_A 

    );

reg io_buffer_full_pre;
    
reg [31:0] ins_addr;
reg [3:0] ins_remain;
reg [3:0] ins_current;
reg [31:0] ins_ret;
reg ins_ready;


reg [31:0] data_addr;
reg [3:0] data_remain;
reg [3:0] data_current; 
reg [31:0] data_out_m;
reg [31:0] data_in_m;
reg data_ready;
reg data_l_s; 

reg [31:0] pos;
reg flag;
reg [7:0] data_in,data_out;
reg [7:0] ins_out;

integer i;

always @(*) begin
  data_input=0;
  ins_out=0;
  data_out=0;
  data_in=0;

    flag=!((1<=ins_remain && ins_remain<=3) || (ins_remain==5))&&data_remain;
    if(flag) begin
      if(data_l_s==0) begin
        if(1<=data_remain&& data_remain<=4) begin
          w_r=0;
          addr_input=data_addr[31:0];
        end

        else begin
          w_r=0;
          addr_input=0;
        end

        if(1<=data_current && data_current<=4) begin
          data_out=data_output;
        end
      end

      else begin

        if(!((io_buffer_full_pre || io_buffer_full) && (data_addr==32'h30000 || data_addr==32'h30004))) begin
        if(data_current==0) begin
          data_in=data_in_m[7:0];
        end
        if(data_current==1) begin
          data_in=data_in_m[15:8];
        end
        if(data_current==2) begin
          data_in=data_in_m[23:16];
        end
        if(data_current==3) begin
          data_in=data_in_m[31:24];
        end

        if(1<=data_remain && data_remain<=4) begin
          w_r=1;
          addr_input=data_addr[31:0];
          data_input=data_in;
        end

        else begin
          w_r=0;
          addr_input=0;
        end
      end

      else begin
        w_r=0;
        addr_input=0;
      end
    end
  end


    else if(ins_remain) begin
      if(1<=ins_remain && ins_remain<=4) begin
        w_r=0;
        addr_input=ins_addr[31:0];
        ins_out=data_output;
      end

      else begin
        w_r=0;
        addr_input=0;
      end

      if(1<=ins_current && ins_current<=4) begin
        ins_out=data_output;
      end
    end 
    else begin
      w_r=0;
      addr_input=0;
    end
end


always @(*) begin
    memctrl_ins_ready=ins_ready;
    memctrl_ins_=ins_ret;
end

always @(*) begin
  memctrl_data_ready=data_ready;
    memctrl_data_ret=data_out_m;
end

always @(*) begin
    pos=slb_mem_vj+slb_mem_A;
end

always @(posedge clk) begin
  io_buffer_full_pre<=io_buffer_full;
    if(rst) begin
        ins_addr<=0;
        ins_remain<=0;
        ins_current<=0;
        ins_ret<=0;
        ins_ready<=0;
    
        data_addr<=0;
        data_remain<=0;
        data_current<=0;
        data_out_m<=0;
        data_in_m<=0;
        data_ready<=0;
        data_l_s<=0;

     end
    
    else if(~rdy) begin
       
    end
    
    else if(clear) begin
        ins_remain<=0;
        ins_current<=0;
        ins_ready<=0;
        data_remain<=0;
        data_current<=0;
        data_ready<=0;
    end

    else begin
      if(!(flag&&data_l_s==0&&data_remain==5)&&!(flag&&data_l_s==1&&data_remain==1)) begin
        data_ready<=0;
      end
      if(!(!flag&&ins_remain&&ins_remain==5)) begin
        ins_ready<=0;
      end

      if(flag) begin
        if(data_l_s==0) begin
          if(data_remain==4) begin
            data_remain<=3;
            data_current<=data_current+1;
            data_addr<=data_addr+1;
          end

          if(data_remain==3) begin
            data_remain<=2;
            data_current<=data_current+1;
            data_addr<=data_addr+1;
          end

          if(data_remain==2) begin
            data_remain<=1;
            data_current<=data_current+1;
            data_addr<=data_addr+1;
          end

          if(data_remain==1) begin
            data_remain<=5;
            data_current<=data_current+1;
            data_addr<=data_addr+1;
          end

          if(data_remain==5) begin
            data_remain<=0;
            data_current<=0;
            data_ready<=1;
          end


          if(data_current==1) begin
            data_out_m[7:0]<=data_out;
          end

          if(data_current==2) begin
            data_out_m[15:8]<=data_out;
          end

            if(data_current==3) begin
              data_out_m[23:16]<=data_out;
            end

            if(data_current==4) begin
              data_out_m[31:24]<=data_out;
            end
        end

        else begin

          if(!((io_buffer_full_pre || io_buffer_full) && (data_addr==32'h30000 || data_addr==32'h30004))) begin
          if(data_remain==4) begin
            data_remain<=3;
            data_current<=data_current+1;
            data_addr<=data_addr+1;
          end

          if(data_remain==3) begin
            data_remain<=2;
            data_current<=data_current+1;
            data_addr<=data_addr+1;
          end

          if(data_remain==2) begin
            data_remain<=1;
            data_current<=data_current+1;
            data_addr<=data_addr+1;
          end

          if(data_remain==1) begin
            data_remain<=0;
            data_current<=0;
            data_ready<=1;
          end
        end
      end
    end

      else if(ins_remain) begin

        if(ins_remain==4) begin
          ins_remain<=3;
          ins_current<=ins_current+1;
          ins_addr<=ins_addr+1;
        end

        if(ins_remain==3) begin
          ins_remain<=2;
          ins_current<=ins_current+1;
          ins_addr<=ins_addr+1;
        end

        if(ins_remain==2) begin
          ins_remain<=1;
          ins_current<=ins_current+1;
          ins_addr<=ins_addr+1;
        end

        if(ins_remain==1) begin
          ins_remain<=5;
          ins_current<=ins_current+1;
          ins_addr<=ins_addr+1;
        end

        if(ins_remain==5) begin
          ins_remain<=0;
          ins_current<=0;
          ins_ready<=1;
        end


        if(ins_current==1) begin
          ins_ret[7:0]<=ins_out;
        end

        if(ins_current==2) begin
          ins_ret[15:8]<=ins_out;
        end

        if(ins_current==3) begin
          ins_ret[23:16]<=ins_out;
        end

        if(ins_current==4) begin
          ins_ret[31:24]<=ins_out;
        end
      end

      if (Insq_Mem) begin
        ins_addr<=memctrl_ins_addr;
        ins_remain<=memctrl_remain;
      end

      if(slb_load) begin
        data_l_s=0;
        if(slb_mem_order==`LB) begin
            data_addr<=pos;
            data_remain<=1;
        end

        if(slb_mem_order==`LH) begin
            data_addr<=pos;
            data_remain<=2;
        end

        if(slb_mem_order==`LW) begin
            data_addr<=pos;
            data_remain<=4;
        end

        if(slb_mem_order==`LBU) begin
            data_addr<=pos;
            data_remain<=1;
        end

        if(slb_mem_order==`LHU) begin
            data_addr<=pos;
            data_remain<=2;
        end
      end

        if(slb_store) begin
            data_l_s=1;
            data_in_m=slb_mem_vk;
            if(slb_mem_order==`SB) begin
                data_addr<=pos;
                data_remain<=1;
            end
    
            if(slb_mem_order==`SH) begin
                data_addr<=pos;
                data_remain<=2;
            end
    
            if(slb_mem_order==`SW) begin
                data_addr<=pos;
                data_remain<=4;
            end
        end
    end
end
endmodule