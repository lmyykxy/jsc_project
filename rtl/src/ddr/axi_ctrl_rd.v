`timescale 1ns / 1ps

module axi_ctrl_rd #(
    parameter   DDR_WR_LEN      = 16    ,
    parameter   DDR_RD_LEN      = 16    ,

    parameter   RD_DATA_WIDTH   = 32    ,
    parameter   RD_DEPTH_WIDTH  = 10    ,
    parameter   WR_DEPTH_WIDTH  = 7     ,
    parameter   WR_DATA_WIDTH   = 256   
)(
   input   wire        ui_clk                   , 
   input   wire        ui_rst                   , 
   input   wire        pingpang                 , 

   input   wire [31:0] rd_b_addr                ,
   input   wire [31:0] rd_e_addr                ,   
   input   wire        user_rd_clk              ,   
   input   wire        data_rden                ,   
   output  wire [RD_DATA_WIDTH-1:0] data_rd                  ,   
   input   wire        rd_rst                   ,
   input   wire        read_enable              ,
   output  wire        data_rd_valid            ,
          
   output  wire        rd_burst_req             , 
   output  wire[31:0]  rd_burst_addr            , 
   output  wire[9:0]   rd_burst_len             , 
   input   wire        rd_ready                 , 
   input   wire        rd_fifo_we               , 
   input   wire[255:0] rd_fifo_data             , 
   input   wire        rd_burst_finish          ,

   output  wire        rd_fifo_almost_empty
);
 


reg       rd_burst_req_reg ; //读突发寄存器
reg [31:0]rd_burst_addr_reg; //读地址寄存器
reg [9:0] rd_burst_len_reg ; //读长度寄存器
//读写地址复位打拍寄存器
reg wr_rst_reg1;
reg wr_rst_reg2;
reg rd_rst_reg1;
reg rd_rst_reg2;

reg pingpang_reg;//乒乓操作指示寄存器



//读fifo信号
wire        rd_fifo_wr_clk        ;
wire        rd_fifo_rd_clk        ;
wire [255:0] rd_fifo_din           ;
wire        rd_fifo_wr_en         ;
wire        rd_fifo_rd_en         ;
wire [RD_DATA_WIDTH-1:0] rd_fifo_dout          ;
wire        rd_fifo_full          ;
wire        rd_fifo_almost_full   ;
wire        rd_fifo_empty         ;
wire  [11:0]rd_fifo_rd_data_count ;
wire  [11:0] rd_fifo_wr_data_count ;


assign rd_burst_req  = rd_burst_req_reg;  //读突发请求
assign rd_burst_addr = rd_burst_addr_reg; //读地址
assign rd_burst_len  = DDR_RD_LEN - 1;        //读长度


//读fifo写时钟位axi读主机时钟
assign rd_fifo_wr_clk=ui_clk;
//读fifo读时钟位用户时钟
assign rd_fifo_rd_clk=user_rd_clk;
//读fifo读使能为用户使能
assign rd_fifo_rd_en =data_rden;
//读fifo读数据为用户使能
assign data_rd       =rd_fifo_dout;
//读fifo写使能为axi读主机写使能
assign rd_fifo_wr_en =rd_fifo_we;
//读fifo写使能为axi读主机写数据
assign rd_fifo_din   =rd_fifo_data;

assign data_rd_valid=~rd_fifo_empty;


//对读复位信号的跨时钟域打2拍
always@(posedge ui_clk or posedge ui_rst) begin
    if(ui_rst==1'b1)begin
        rd_rst_reg1<=1'b0;
        rd_rst_reg2<=1'b0;
    end
    else begin
        rd_rst_reg1<=rd_rst;
        rd_rst_reg2<=rd_rst_reg1;
    end

end



//读burst请求产生
always@(posedge ui_clk or posedge ui_rst) begin
    if(ui_rst==1'b1)begin
        rd_burst_req_reg<=1'b0;
    end
    //fifo可写长度大于一次突发长度并且axi读空闲，fifo总深度WR_DEPTH_WIDTH
    else if((rd_fifo_wr_data_count <= ((1<<WR_DEPTH_WIDTH) - (2*DDR_RD_LEN))) 
            && rd_ready==1'b1 &&read_enable==1'b1 && rd_rst == 0) 
    begin
        rd_burst_req_reg<=1'b1;
    end
    else begin
        rd_burst_req_reg<=1'b0;
    end

end

//完成一次突发对地址进行相加
//相加地址长度=突发长度x8,64位等于8字节
//128*8=1024
always@(posedge ui_clk or posedge ui_rst) begin
    if(ui_rst==1'b1)begin
        rd_burst_addr_reg<=rd_b_addr;
        // if(pingpang==1'b1) rd_burst_addr_reg<=rd_e_addr;
        // else rd_burst_addr_reg<=rd_b_addr;
    end
    else if(rd_rst_reg1&(~rd_rst_reg2)) begin
        rd_burst_addr_reg<=rd_b_addr;
    end 
    else  if(rd_burst_finish==1'b1)begin
          rd_burst_addr_reg<=rd_burst_addr_reg+DDR_WR_LEN*256/32;//地址累加
        //乒乓操作
         if(pingpang==1'b1) begin
           //到达结束地址 
           if((rd_burst_addr_reg==(rd_e_addr-DDR_WR_LEN*256/32))||
    (rd_burst_addr_reg==((rd_e_addr-rd_b_addr)*2+rd_b_addr-DDR_WR_LEN*256/32))) 
           begin
                //根据写指示地址信号，对读信号进行复位
               if(pingpang_reg==1'b1) rd_burst_addr_reg<=rd_b_addr;
               else rd_burst_addr_reg<=rd_e_addr;
           end
                    
        end
        else begin  //非乒乓操作
            if(rd_burst_addr_reg>=(rd_e_addr-DDR_WR_LEN*256/32)) 
            begin
            rd_burst_addr_reg<=rd_b_addr;
            end
        end
    end
    else begin
        rd_burst_addr_reg<=rd_burst_addr_reg;
    end

end



//------------- rd_fifo_inst -------------
//读fifo
rd_fifo  #(
    .RD_DATA_WIDTH          (RD_DATA_WIDTH              ),
    .RD_DEPTH_WIDTH         (RD_DEPTH_WIDTH             ),
    .WR_DEPTH_WIDTH         (WR_DEPTH_WIDTH             ),
    .WR_DATA_WIDTH          (WR_DATA_WIDTH              )  
)rd_fifo_inst
(
  .wr_rst                   ( rd_rst||ui_rst         ) , 
  .rd_rst                   ( rd_rst||ui_rst         ) , 
  .wr_clk                   ( rd_fifo_wr_clk         ) , 
  .rd_clk                   ( rd_fifo_rd_clk         ) , 
  .wr_data                  ( rd_fifo_din            ) , 
  .wr_en                    ( rd_fifo_wr_en          ) , 
  .rd_en                    ( rd_fifo_rd_en          ) , 
  .rd_data                  ( rd_fifo_dout[RD_DATA_WIDTH-1:0]     ) , 
  .wr_full                  ( rd_fifo_full           ) , 
  .almost_full              ( rd_fifo_almost_full    ) ,
  .rd_empty                 ( rd_fifo_empty          ) , 
  .almost_empty             ( rd_fifo_almost_empty   ) ,
  .rd_water_level           ( rd_fifo_rd_data_count  ) ,
  .wr_water_level           ( rd_fifo_wr_data_count  ) 
) ;

endmodule
