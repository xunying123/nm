
module MemCtrl(
    input wire clk,
    input wire rst,
    input wire rdy,
    
    output reg r_or_w,
    output reg [31:0] a_in,
    input wire [7:0] d_out,
    output reg [7:0] d_in,

    input wire Clear_flag,

    output reg memctrl_ins_ok__,
    output reg [31:0] memctrl_ins_ans__,

    input wire insqueue_to_memctrl_needchange,
    input wire [31:0] memctrl_ins_addr_,
    input wire [3:0] memctrl_ins_remain_cycle_,

    output reg memctrl_data_ok__,
    output reg [31:0] memctrl_data_ans__,

    input wire SLB_to_memctrl_needchange,
    input wire SLB_to_memctrl_needchange2,

    input wire [5:0] SLB_to_memctrl_ordertype,
    input wire [31:0] SLB_to_memctrl_vj,
    input wire [31:0] SLB_to_memctrl_vk,
    input wire [31:0] SLB_to_memctrl_A 

    );
    
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
    flag=!((1<=ins_remain && ins_remain<=3) || (ins_remain==5))&&data_remain;
    if(flag) begin
      if(data_l_s==0) begin
        if(1<=data_remain&& data_remain<=4) begin
          r_or_w=0;
          a_in=data_addr[31:0];
        end

        else begin
          r_or_w=0;
          a_in=0;
        end

        if(1<=data_current && data_current<=4) begin
          data_out=d_out;
        end
      end

      else begin
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
          r_or_w=1;
          a_in=data_addr[31:0];
          d_in=data_in;
        end

        else begin
          r_or_w=0;
          a_in=0;
        end
      end
    end

    else if(ins_remain) begin
      if(1<=ins_remain && ins_remain<=4) begin
        r_or_w=0;
        a_in=ins_addr[31:0];
        ins_out=d_out;
      end

      else begin
        r_or_w=0;
        a_in=0;
      end

      if(1<=ins_current && ins_current<=4) begin
        ins_out=d_out;
      end
    end 
    else begin
      r_or_w=0;
      a_in=0;
    end
end


always @(*) begin
    memctrl_ins_ok__=ins_ready;
    memctrl_ins_ans__=ins_ret;
end

always @(*) begin
  memctrl_data_ok__=data_ready;
    memctrl_data_ans__=data_out_m;
end

always @(*) begin
    pos=SLB_to_memctrl_vj+SLB_to_memctrl_A;
end

always @(posedge clk) begin
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
    
        pos<=0;
        flag<=0;
        data_in<=0;
        data_out<=0;
        ins_out<=0;
     end
    
    else if(~rdy) begin
       
    end
    
    else if(Clear_flag) begin
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
          if(data_remain==5) begin
            data_remain<=0;
            data_current<=0;
            data_ready<=1;
          end

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

      else if(ins_remain) begin
        if(ins_remain==5) begin
          ins_remain<=0;
          ins_current<=0;
          ins_ready<=1;
        end

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

      if (insqueue_to_memctrl_needchange) begin
        ins_addr<=memctrl_ins_addr_;
        ins_remain<=memctrl_ins_remain_cycle_;
      end

      if(SLB_to_memctrl_needchange) begin
        data_l_s=0;
        if(SLB_to_memctrl_ordertype==`LB) begin
            data_addr<=pos;
            data_remain<=1;
        end

        if(SLB_to_memctrl_ordertype==`LH) begin
            data_addr<=pos;
            data_remain<=2;
        end

        if(SLB_to_memctrl_ordertype==`LW) begin
            data_addr<=pos;
            data_remain<=4;
        end

        if(SLB_to_memctrl_ordertype==`LBU) begin
            data_addr<=pos;
            data_remain<=1;
        end

        if(SLB_to_memctrl_ordertype==`LHU) begin
            data_addr<=pos;
            data_remain<=2;
        end
      end

        if(SLB_to_memctrl_needchange2) begin
            data_l_s=1;
            data_in_m=SLB_to_memctrl_vk;
            if(SLB_to_memctrl_ordertype==`SB) begin
                data_addr<=pos;
                data_remain<=1;
            end
    
            if(SLB_to_memctrl_ordertype==`SH) begin
                data_addr<=pos;
                data_remain<=2;
            end
    
            if(SLB_to_memctrl_ordertype==`SW) begin
                data_addr<=pos;
                data_remain<=4;
            end
        end
    end
end
endmodule