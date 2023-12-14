`timescale 1ns / 1ps

module axi_ctrl_wr #(
    parameter   DDR_WR_LEN      = 16    ,
    parameter   DDR_RD_LEN      = 16    ,

    parameter   RD_DATA_WIDTH   = 256   ,
    parameter   RD_DEPTH_WIDTH  = 7     ,
    parameter   WR_DATA_WIDTH   = 32    ,
    parameter   WR_DEPTH_WIDTH  = 10    
)(
   input   wire         ui_clk                  , 
   input   wire         ui_rst                  , 
   input   wire         pingpang                , 

   input   wire [31:0]  wr_b_addr               ,   
   input   wire [31:0]  wr_e_addr               ,   
   input   wire         user_wr_clk             ,   
   input   wire         data_wren               ,   
   input   wire [WR_DATA_WIDTH-1:0]  data_wr                 ,   
   input   wire         wr_rst                  ,

   output  wire         wr_burst_req            , 
   output  wire[31:0]   wr_burst_addr           , 
   output  wire[9:0]    wr_burst_len            , 
   input   wire         wr_ready                , 
   input   wire         wr_fifo_re              , 
   output  wire[255:0]  wr_fifo_data            , 
   input   wire         wr_burst_finish         ,

   output  wire         wr_fifo_almost_full
   );
 

reg       wr_burst_req_reg ; //写突发寄存器
reg [31:0]wr_burst_addr_reg ; //写地址寄存器
reg [9:0] wr_burst_len_reg ; //写长度寄存器


//读写地址复位打拍寄存器
reg wr_rst_reg1;
reg wr_rst_reg2;

reg pingpang_reg;//乒乓操作指示寄存器

//wire define
//写fifo信号
wire        wr_fifo_wr_clk        ;
wire        wr_fifo_rd_clk        ;
wire [WR_DATA_WIDTH-1:0] wr_fifo_din           ;
wire        wr_fifo_wr_en         ;
wire        wr_fifo_rd_en         ;
wire [255:0] wr_fifo_dout         ;
wire        wr_fifo_full          ;
wire        wr_fifo_empty         ;
wire        wr_fifo_almost_empty  ;
wire  [7:0] wr_fifo_rd_data_count ;
wire  [11:0] wr_fifo_wr_data_count;


assign wr_burst_req  = wr_burst_req_reg;  //写突发请求
assign wr_burst_addr = wr_burst_addr_reg; //写地址
assign wr_burst_len  = DDR_WR_LEN - 1;        //写长度

//写fifo写时钟位用户端时钟
assign wr_fifo_wr_clk = user_wr_clk;
//写fifo读时钟位axi总时钟
assign wr_fifo_rd_clk = ui_clk;
//写fifo非满为用户输入数据
assign wr_fifo_din    = data_wr;
//写fifo非满为用户输入数据使能
assign wr_fifo_wr_en  = data_wren;
//写fifo非空为axi写主机读取使能
assign wr_fifo_rd_en  = wr_fifo_re;
//写fifo非空为axi写主机读取数据
assign wr_fifo_data   = wr_fifo_dout;


//对写复位信号的跨时钟域打2拍
always@(posedge ui_clk or posedge ui_rst) begin
    if(ui_rst==1'b1)begin
        wr_rst_reg1<=1'b0;
        wr_rst_reg2<=1'b0;
    end
    else begin
        wr_rst_reg1<=wr_rst;
        wr_rst_reg2<=wr_rst_reg1;
    end

end


//写burst请求产生
always@(posedge ui_clk or posedge ui_rst) begin
    if(ui_rst==1'b1)begin
        wr_burst_req_reg<=1'b0;
    end
    //fifo数据长度大于一次突发长度并且axi写空闲
    else if((wr_fifo_rd_data_count+9'd2)>=DDR_WR_LEN && wr_ready==1'b1 && wr_rst == 0) 
    begin 
        wr_burst_req_reg<=1'b1;      
    end
    else begin
        wr_burst_req_reg<=1'b0;
    end

end

//完成一次突发对地址进行相加
//相加地址长度=突发长度x8,64位等于8字节
//128*8=1024
always@(posedge ui_clk or posedge ui_rst) begin
    if(ui_rst==1'b1)begin
        wr_burst_addr_reg<=wr_b_addr;
        pingpang_reg<=1'b0;
        
    end
    //写复位信号上升沿
    else if(wr_rst_reg1&(~wr_rst_reg2)) begin
        wr_burst_addr_reg<=wr_b_addr;
    end 
    else if(wr_burst_finish==1'b1)begin
        wr_burst_addr_reg<=wr_burst_addr_reg+DDR_WR_LEN*256/32;
        //判断是否是乒乓操作
        if(pingpang==1'b1) begin
        //结束地址为2倍的接受地址，有两块区域
            if(wr_burst_addr_reg>=(
            (wr_e_addr-wr_b_addr)*2+wr_b_addr-DDR_WR_LEN*256/32)) 
            begin
                wr_burst_addr_reg<=wr_b_addr;
            end
            //根据地址，pingpang_reg为0或者1
            //用于指示读操作与写操作地址不冲突
            if(wr_burst_addr_reg<wr_e_addr) begin
                pingpang_reg<=1'b0;
            end
            else begin
                pingpang_reg<=1'b1;
            end
        
        end
        //非乒乓操作  最后一个地址写入后开始从头写入
        else begin
            if(wr_burst_addr_reg>=(wr_e_addr-DDR_WR_LEN*256/32)) 
            begin
                wr_burst_addr_reg<=wr_b_addr;
            end
        end
    end
    else begin
        wr_burst_addr_reg<=wr_burst_addr_reg;
    end

end


//------------- wr_fifo_inst -------------
//写fifo
wr_fifo  #(
    .RD_DATA_WIDTH          (RD_DATA_WIDTH              ) ,
    .RD_DEPTH_WIDTH         (RD_DEPTH_WIDTH             ) ,
    .WR_DEPTH_WIDTH         (WR_DEPTH_WIDTH             ) ,
    .WR_DATA_WIDTH          (WR_DATA_WIDTH              )   
)wr_fifo_inst(
  .wr_rst                   ( wr_rst||ui_rst            ) , 
  .rd_rst                   ( wr_rst||ui_rst            ) , 
  .wr_clk                   ( wr_fifo_wr_clk            ) , 
  .rd_clk                   ( wr_fifo_rd_clk            ) , 
  .wr_data                  ( wr_fifo_din[WR_DATA_WIDTH-1:0]         ) , 
  .wr_en                    ( wr_fifo_wr_en             ) , 
  .rd_en                    ( wr_fifo_rd_en             ) , 
  .rd_data                  ( wr_fifo_dout              ) , 
  .wr_full                  ( wr_fifo_full              ) , 
  .almost_full              ( wr_fifo_almost_full       ) , 
  .rd_empty                 ( wr_fifo_empty             ) , 
  .almost_empty             ( wr_fifo_almost_empty      ) ,
  .rd_water_level           ( wr_fifo_rd_data_count     ) , 
  .wr_water_level           ( wr_fifo_wr_data_count     ) 
) ;


endmodule
