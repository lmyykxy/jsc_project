`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// 实验平台:野火FPGA开发板
// 公司    :http://www.embedfire.com
// 论坛    :http://www.firebbs.cn
// 淘宝    :https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////
module axi_master_read
(
  input           ARESETN,
  input           ACLK,   

  output [3:0]  M_AXI_ARID   , 
  output [31:0] M_AXI_ARADDR , 
  output [7:0]  M_AXI_ARLEN  , 
  output        M_AXI_ARVALID, 
  input         M_AXI_ARREADY, 

  input [3:0]   M_AXI_RID   , 
  input [255:0]  M_AXI_RDATA , 
  input         M_AXI_RLAST , 
  input         M_AXI_RVALID, 
  
  input         RD_START    , 
  input [31:0]  RD_ADRS     , 
  input [9:0]   RD_LEN      ,
  output        RD_READY    , 
  output        RD_FIFO_WE  , 
  output [255:0] RD_FIFO_DATA, 
  output        RD_DONE       
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//

//parameter  define
localparam S_RD_IDLE  = 3'd0; //读空闲
localparam S_RA_WAIT  = 3'd1; //读地址等待
localparam S_RA_START = 3'd2; //读地址
localparam S_RD_WAIT  = 3'd3; //读数据等待
localparam S_RD_PROC  = 3'd4; //读数据循环
localparam S_RD_DONE  = 3'd5; //写结束
//reg define                               
reg [2:0]   rd_state   ; //状态寄存器
reg [31:0]  reg_rd_adrs; //地址寄存器
reg [31:0]  reg_rd_len ; //突发长度寄存器
reg         reg_arvalid; //地址有效寄存器

reg [9:0]   rd_len_reg;
   
//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//

assign RD_DONE = (rd_state == S_RD_DONE) ;
assign M_AXI_ARID         = 4'b0000;//地址id
assign M_AXI_ARADDR[31:0] = reg_rd_adrs[31:0];//地址
assign M_AXI_ARLEN[7:0]   = rd_len_reg;//突发长度
assign M_AXI_ARVALID      = reg_arvalid;

assign RD_READY           = (rd_state == S_RD_IDLE)?1'b1:1'b0;//写空闲
assign RD_FIFO_WE         = M_AXI_RVALID;//读fifo的写使能信号
assign RD_FIFO_DATA[255:0] = M_AXI_RDATA[255:0];//读fifo的写数据信号 

  // 读状态机
  always @(posedge ACLK or negedge ARESETN) begin
    if(!ARESETN) begin
      rd_state          <= S_RD_IDLE;
      reg_rd_adrs[31:0] <= 32'd0;
      reg_rd_len[31:0]  <= 32'd0;
      reg_arvalid       <= 1'b0;
      rd_len_reg <= 10'd0;
    end else begin
      case(rd_state)
        S_RD_IDLE: begin//读空闲
          if(RD_START) begin//突发触发信号
            rd_state          <= S_RA_WAIT;
            reg_rd_adrs[31:0] <= RD_ADRS[31:0];
            reg_rd_len[31:0]  <= RD_LEN[9:0] -32'd1;
            rd_len_reg <= RD_LEN;
          end
          reg_arvalid     <= 1'b0;
        end
        S_RA_WAIT: begin//写地址等待
            rd_state          <= S_RA_START;
        end
        S_RA_START: begin//写地址
          rd_state          <= S_RD_WAIT;
          reg_arvalid       <= 1'b1;//拉高地址有效
        end
        S_RD_WAIT: begin //读取数据等待
          if(M_AXI_ARREADY) begin
            rd_state        <= S_RD_PROC;
            reg_arvalid     <= 1'b0;
          end
        end
        S_RD_PROC: begin //接受循环
          if(M_AXI_RVALID) begin //收到数据有效，握手成功
            if(M_AXI_RLAST) begin //收到最后一个数据
                rd_state<= S_RD_DONE;
            end
          end
        end
    S_RD_DONE:begin //接受接受
      rd_state          <= S_RD_IDLE;
    end
    endcase
    end
  end
   
endmodule