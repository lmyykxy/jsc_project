`timescale  1ns/1ns
`include "../header/fpga_header.vh"

module axi_ddr_top #(
    parameter   DDR_WR_LEN  = 16  , 
    parameter   DDR_RD_LEN  = 16  ,
    parameter   W_NUM_CHNL  = 4'd4,
    parameter   R_NUM_CHNL  = 4'd8
)(
    //50m的时钟与复位信号
    input   wire              ref_clk             ,
    input   wire              sys_rst_n           , //外部复位

    input   wire              pingpang            , //乒乓操作，1使能，0不使能   

    input   wire [31:0]       WportA_wr_b_addr            , 
    input   wire [31:0]       WportA_wr_e_addr            , 
    input   wire              WportA_user_wr_clk          , 
    input   wire              WportA_data_wren            , 
    input   wire [31:0]       WportA_data_wr              , 
    input   wire              WportA_wr_rst               , 

    input   wire [31:0]       WportB_wr_b_addr            , 
    input   wire [31:0]       WportB_wr_e_addr            , 
    input   wire              WportB_user_wr_clk          , 
    input   wire              WportB_data_wren            , 
    input   wire [127:0]      WportB_data_wr              , 
    input   wire              WportB_wr_rst               , 

    input   wire [31:0]       WportC_wr_b_addr            , 
    input   wire [31:0]       WportC_wr_e_addr            , 
    input   wire              WportC_user_wr_clk          , 
    input   wire              WportC_data_wren            , 
    input   wire [31:0]       WportC_data_wr              , 
    input   wire              WportC_wr_rst               , 

    input   wire [31:0]       WportD_wr_b_addr            , 
    input   wire [31:0]       WportD_wr_e_addr            , 
    input   wire              WportD_user_wr_clk          , 
    input   wire              WportD_data_wren            , 
    input   wire [31:0]       WportD_data_wr              , 
    input   wire              WportD_wr_rst               , 

    input   wire [31:0]       RportA_rd_b_addr            ,
    input   wire [31:0]       RportA_rd_e_addr            ,
    input   wire              RportA_user_rd_clk          ,
    input   wire              RportA_data_rden            ,
    output  wire [31:0]       RportA_data_rd              , 
    input   wire              RportA_rd_rst               , 
    input   wire              RportA_read_enable          , 
    output  wire              RportA_data_rd_valid        ,

    input   wire [31:0]       RportB_rd_b_addr            ,
    input   wire [31:0]       RportB_rd_e_addr            ,
    input   wire              RportB_user_rd_clk          ,
    input   wire              RportB_data_rden            ,
    output  wire [127:0]       RportB_data_rd              , 
    input   wire              RportB_rd_rst               , 
    input   wire              RportB_read_enable          , 
    output  wire              RportB_data_rd_valid        ,

    input   wire [31:0]       RportC_rd_b_addr            ,
    input   wire [31:0]       RportC_rd_e_addr            ,
    input   wire              RportC_user_rd_clk          ,
    input   wire              RportC_data_rden            ,
    output  wire [31:0]       RportC_data_rd              , 
    input   wire              RportC_rd_rst               , 
    input   wire              RportC_read_enable          , 
    output  wire              RportC_data_rd_valid        ,

    input   wire [31:0]       RportD_rd_b_addr            ,
    input   wire [31:0]       RportD_rd_e_addr            ,
    input   wire              RportD_user_rd_clk          ,
    input   wire              RportD_data_rden            ,
    output  wire [31:0]       RportD_data_rd              , 
    input   wire              RportD_rd_rst               , 
    input   wire              RportD_read_enable          , 
    output  wire              RportD_data_rd_valid        ,

    // input   wire [31:0]       RportP_rd_b_addr            ,
    // input   wire [31:0]       RportP_rd_e_addr            ,
    // input   wire              RportP_user_rd_clk          ,
    // input   wire              RportP_data_rden            ,
    // output  wire [127:0]      RportP_data_rd              , 
    // input   wire              RportP_rd_rst               , 
    // input   wire              RportP_read_enable          , 
    // output  wire              RportP_data_rd_valid        ,

    input   wire [31:0]       RportP_a_rd_b_addr            ,
    input   wire [31:0]       RportP_a_rd_e_addr            ,
    input   wire              RportP_a_user_rd_clk          ,
    input   wire              RportP_a_data_rden            ,
    output  wire [127:0]      RportP_a_data_rd              , 
    input   wire              RportP_a_rd_rst               , 
    input   wire              RportP_a_read_enable          , 
    output  wire              RportP_a_data_rd_valid        ,

    input   wire [31:0]       RportP_b_rd_b_addr            ,
    input   wire [31:0]       RportP_b_rd_e_addr            ,
    input   wire              RportP_b_user_rd_clk          ,
    input   wire              RportP_b_data_rden            ,
    output  wire [127:0]      RportP_b_data_rd              , 
    input   wire              RportP_b_rd_rst               , 
    input   wire              RportP_b_read_enable          , 
    output  wire              RportP_b_data_rd_valid        ,

    input   wire [31:0]       RportP_c_rd_b_addr            ,
    input   wire [31:0]       RportP_c_rd_e_addr            ,
    input   wire              RportP_c_user_rd_clk          ,
    input   wire              RportP_c_data_rden            ,
    output  wire [127:0]      RportP_c_data_rd              , 
    input   wire              RportP_c_rd_rst               , 
    input   wire              RportP_c_read_enable          , 
    output  wire              RportP_c_data_rd_valid        ,

    input   wire [31:0]       RportP_d_rd_b_addr            ,
    input   wire [31:0]       RportP_d_rd_e_addr            ,
    input   wire              RportP_d_user_rd_clk          ,
    input   wire              RportP_d_data_rden            ,
    output  wire [127:0]      RportP_d_data_rd              , 
    input   wire              RportP_d_rd_rst               , 
    input   wire              RportP_d_read_enable          , 
    output  wire              RportP_d_data_rd_valid        ,


    inout   wire [31:0]       ddr3_dq                     ,
    inout   wire [3:0]        ddr3_dqs_n                  ,
    inout   wire [3:0]        ddr3_dqs_p                  ,
    output  wire [14:0]       ddr3_addr                   ,
    output  wire [2:0]        ddr3_ba                     ,
    output  wire              ddr3_ras_n                  ,
    output  wire              ddr3_cas_n                  ,
    output  wire              ddr3_we_n                   ,
    output  wire              ddr3_reset_n                ,
    output  wire [0:0]        ddr3_ck_p                   ,
    output  wire [0:0]        ddr3_ck_n                   ,
    output  wire [0:0]        ddr3_cke                    ,
    output  wire [0:0]        ddr3_cs_n                   ,
    output  wire [3:0]        ddr3_dm                     ,
    output  wire [0:0]        ddr3_odt                    ,
    inout   wire [3:0]        dly_mon_pad                 ,
    
    output  wire              ui_clk                      , //输出时钟125m
    output  wire              ui_rst                      , //输出复位，高有效
    output  wire              ddr_init_done               ,  //ddr初始化完成
    output  wire              pll_lock                    ,

    // output wire               pcie_almost_empty        
    output wire             pcie_almost_empty_a,
    output wire             pcie_almost_empty_b,
    output wire             pcie_almost_empty_c,
    output wire             pcie_almost_empty_d   
);

reg rd_rst,rd_rst_d0;

always @(posedge ui_clk or negedge sys_rst_n) begin
  if(!sys_rst_n) begin
    rd_rst_d0 <= 1'd0;
    rd_rst <= 1'd0;
  end else begin
    rd_rst_d0 <= RportP_a_rd_rst;
    rd_rst <= rd_rst_d0;
  end
end

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//

wire [3:0]    M_AXI_WR_awid                    ;   
wire [31:0]   M_AXI_WR_awaddr                  ; 
wire [7:0]    M_AXI_WR_awlen                   ;     
wire          M_AXI_WR_awvalid                 ;
wire          M_AXI_WR_awready                 ;                 
   
wire [255:0]  M_AXI_WR_wdata                   ;  
wire [31:0]   M_AXI_WR_wstrb                   ;  
wire          M_AXI_WR_wlast                   ;  
wire          M_AXI_WR_wid                     ; 
wire          M_AXI_WR_wready                  ; 
       
wire [3:0]    M_AXI_RD_arid                     ;   
wire [31:0]   M_AXI_RD_araddr                   ; 
wire [7:0]    M_AXI_RD_arlen                    ;    
wire          M_AXI_RD_arvalid                  ;
wire          M_AXI_RD_arready                  ;
  
wire [3:0]    M_AXI_RD_rid                      ;    
wire [255:0]  M_AXI_RD_rdata                    ;  
wire          M_AXI_RD_rlast                    ;  
wire          M_AXI_RD_rvalid                   ; 

wire            wr_burst_req                        ;
wire [31:0]     wr_burst_addr                       ;
wire [9:0]      wr_burst_len                        ; 
wire            wr_ready                            ;
wire            wr_fifo_re                          ;
wire [255:0]    wr_fifo_data                        ;
wire            wr_burst_finish                     ;

wire            rd_burst_req                        ;
wire [31:0]     rd_burst_addr                       ;
wire [9:0]      rd_burst_len                        ; 
wire            rd_ready                            ;
wire            rd_fifo_we                          ;
wire [255:0]    rd_fifo_data                        ;
wire            rd_burst_finish                     ;

wire [W_NUM_CHNL-1:0]           Wport_wr_burst_req      ;
wire [(W_NUM_CHNL*32)-1:0]      Wport_wr_burst_addr     ;
wire [(W_NUM_CHNL*10)-1:0]      Wport_wr_burst_len      ;
wire [W_NUM_CHNL-1:0]           Wport_wr_ready          ;
wire [W_NUM_CHNL-1:0]           Wport_wr_fifo_re        ;
wire [(W_NUM_CHNL*256)-1:0]     Wport_wr_fifo_data      ;
wire [W_NUM_CHNL-1:0]           Wport_wr_burst_finish   ;

wire [R_NUM_CHNL-1:0]           Rport_rd_burst_req      ;
wire [(R_NUM_CHNL*32)-1:0]      Rport_rd_burst_addr     ;
wire [(R_NUM_CHNL*10)-1:0]      Rport_rd_burst_len      ;
wire [R_NUM_CHNL-1:0]           Rport_rd_ready          ;
wire [R_NUM_CHNL-1:0]           Rport_rd_fifo_we        ;
wire [(R_NUM_CHNL*256)-1:0]     Rport_rd_fifo_data      ;
wire [R_NUM_CHNL-1:0]           Rport_rd_burst_finish   ;


axi_ctrl_wr#(
  .DDR_WR_LEN       (16 ),    
  .DDR_RD_LEN       (16 ),    
  .RD_DATA_WIDTH    (256),     
  .RD_DEPTH_WIDTH   (7  ),       
  .WR_DATA_WIDTH    (32 ), //  user int
  .WR_DEPTH_WIDTH   (10 )    
)axi_ctrl_WA(
  .ui_clk                 (ui_clk                 ),
  .ui_rst                 (ui_rst&(!sys_rst_n)    ),
  .pingpang               (pingpang               ),
  .wr_b_addr              (WportA_wr_b_addr       ),
  .wr_e_addr              (WportA_wr_e_addr       ),
  .user_wr_clk            (WportA_user_wr_clk     ),
  .data_wren              (WportA_data_wren       ),
  .data_wr                (WportA_data_wr         ),
  .wr_rst                 (WportA_wr_rst          ),
  .wr_burst_req           (Wport_wr_burst_req   [1    * 0 +: 1  ]),
  .wr_burst_addr          (Wport_wr_burst_addr  [32   * 0 +: 32 ]),
  .wr_burst_len           (Wport_wr_burst_len   [10   * 0 +: 10 ]),
  .wr_ready               (Wport_wr_ready       [1    * 0 +: 1  ]),
  .wr_fifo_re             (Wport_wr_fifo_re     [1    * 0 +: 1  ]),
  .wr_fifo_data           (Wport_wr_fifo_data   [256  * 0 +: 256]),
  .wr_burst_finish        (Wport_wr_burst_finish[1    * 0 +: 1  ]),
  .wr_fifo_almost_full    ()
);

axi_ctrl_wr#(
  .DDR_WR_LEN       (16 ),    
  .DDR_RD_LEN       (16 ),    
  .RD_DATA_WIDTH    (256),     
  .RD_DEPTH_WIDTH   (9  ),       
  .WR_DATA_WIDTH    (128), //  user int
  .WR_DEPTH_WIDTH   (10 )    
)axi_ctrl_WB(
  .ui_clk                 (ui_clk                 ),
  .ui_rst                 (ui_rst&(!sys_rst_n)    ),
  .pingpang               (pingpang               ),
  .wr_b_addr              (WportB_wr_b_addr       ),
  .wr_e_addr              (WportB_wr_e_addr       ),
  .user_wr_clk            (WportB_user_wr_clk     ),
  .data_wren              (WportB_data_wren       ),
  .data_wr                (WportB_data_wr         ),
  .wr_rst                 (WportB_wr_rst          ),
  .wr_burst_req           (Wport_wr_burst_req   [1    * 1 +: 1  ]),
  .wr_burst_addr          (Wport_wr_burst_addr  [32   * 1 +: 32 ]),
  .wr_burst_len           (Wport_wr_burst_len   [10   * 1 +: 10 ]),
  .wr_ready               (Wport_wr_ready       [1    * 1 +: 1  ]),
  .wr_fifo_re             (Wport_wr_fifo_re     [1    * 1 +: 1  ]),
  .wr_fifo_data           (Wport_wr_fifo_data   [256  * 1 +: 256]),
  .wr_burst_finish        (Wport_wr_burst_finish[1    * 1 +: 1  ]),
  .wr_fifo_almost_full    ()
);

axi_ctrl_wr#(
  .DDR_WR_LEN       (16 ),    
  .DDR_RD_LEN       (16 ),    
  .RD_DATA_WIDTH    (256),     
  .RD_DEPTH_WIDTH   (7  ),       
  .WR_DATA_WIDTH    (32 ), //  user int
  .WR_DEPTH_WIDTH   (10 )    
)axi_ctrl_WC(
  .ui_clk                 (ui_clk                 ),
  .ui_rst                 (ui_rst&(!sys_rst_n)    ),
  .pingpang               (pingpang               ),
  .wr_b_addr              (WportC_wr_b_addr       ),
  .wr_e_addr              (WportC_wr_e_addr       ),
  .user_wr_clk            (WportC_user_wr_clk     ),
  .data_wren              (WportC_data_wren       ),
  .data_wr                (WportC_data_wr         ),
  .wr_rst                 (WportC_wr_rst          ),
  .wr_burst_req           (Wport_wr_burst_req   [1    * 2 +: 1  ]),
  .wr_burst_addr          (Wport_wr_burst_addr  [32   * 2 +: 32 ]),
  .wr_burst_len           (Wport_wr_burst_len   [10   * 2 +: 10 ]),
  .wr_ready               (Wport_wr_ready       [1    * 2 +: 1  ]),
  .wr_fifo_re             (Wport_wr_fifo_re     [1    * 2 +: 1  ]),
  .wr_fifo_data           (Wport_wr_fifo_data   [256  * 2 +: 256]),
  .wr_burst_finish        (Wport_wr_burst_finish[1    * 2 +: 1  ]),
  .wr_fifo_almost_full    ()
);

axi_ctrl_wr#(
  .DDR_WR_LEN       (16 ),    
  .DDR_RD_LEN       (16 ),    
  .RD_DATA_WIDTH    (256),     
  .RD_DEPTH_WIDTH   (7  ),       
  .WR_DATA_WIDTH    (32 ), //  user int
  .WR_DEPTH_WIDTH   (10 )    
)axi_ctrl_WD(
  .ui_clk                 (ui_clk                 ),
  .ui_rst                 (ui_rst&(!sys_rst_n)    ),
  .pingpang               (pingpang               ),
  .wr_b_addr              (WportD_wr_b_addr       ),
  .wr_e_addr              (WportD_wr_e_addr       ),
  .user_wr_clk            (WportD_user_wr_clk     ),
  .data_wren              (WportD_data_wren       ),
  .data_wr                (WportD_data_wr         ),
  .wr_rst                 (WportD_wr_rst          ),
  .wr_burst_req           (Wport_wr_burst_req   [1    * 3 +: 1  ]),
  .wr_burst_addr          (Wport_wr_burst_addr  [32   * 3 +: 32 ]),
  .wr_burst_len           (Wport_wr_burst_len   [10   * 3 +: 10 ]),
  .wr_ready               (Wport_wr_ready       [1    * 3 +: 1  ]),
  .wr_fifo_re             (Wport_wr_fifo_re     [1    * 3 +: 1  ]),
  .wr_fifo_data           (Wport_wr_fifo_data   [256  * 3 +: 256]),
  .wr_burst_finish        (Wport_wr_burst_finish[1    * 3 +: 1  ]),
  .wr_fifo_almost_full    ()
);


axi_ctrl_rd#(
  .DDR_WR_LEN       (16 ),    
  .DDR_RD_LEN       (16 ),    
  .RD_DATA_WIDTH    (32 ),  // user int   
  .RD_DEPTH_WIDTH   (10 ),       
  .WR_DATA_WIDTH    (256),
  .WR_DEPTH_WIDTH   (7  )    
)axi_ctrl_rd_RA(
  .ui_clk                 (ui_clk                 ),
  .ui_rst                 (ui_rst&(!sys_rst_n)    ),
  .pingpang               (pingpang               ),
  .rd_b_addr              (RportA_rd_b_addr       ),
  .rd_e_addr              (RportA_rd_e_addr       ),
  .user_rd_clk            (RportA_user_rd_clk     ),
  .data_rden              (RportA_data_rden       ),
  .data_rd                (RportA_data_rd         ),
  .rd_rst                 (RportA_rd_rst          ),
  .read_enable            (RportA_read_enable     ),
  .data_rd_valid          (RportA_data_rd_valid   ),
  
  .rd_burst_req           (Rport_rd_burst_req   [1    * 0 +: 1  ]),
  .rd_burst_addr          (Rport_rd_burst_addr  [32   * 0 +: 32 ]),
  .rd_burst_len           (Rport_rd_burst_len   [10   * 0 +: 10 ]),
  .rd_ready               (Rport_rd_ready       [1    * 0 +: 1  ]),
  .rd_fifo_we             (Rport_rd_fifo_we     [1    * 0 +: 1  ]),
  .rd_fifo_data           (Rport_rd_fifo_data   [256  * 0 +: 256]),
  .rd_burst_finish        (Rport_rd_burst_finish[1    * 0 +: 1  ]),
  .rd_fifo_almost_empty   ()
);

axi_ctrl_rd#(
  .DDR_WR_LEN       (16 ),    
  .DDR_RD_LEN       (16 ),    
  .RD_DATA_WIDTH    (32 ),  // user int   
  .RD_DEPTH_WIDTH   (10 ),       
  .WR_DATA_WIDTH    (256),
  .WR_DEPTH_WIDTH   (7  )    
)axi_ctrl_rd_RB(
  .ui_clk                 (ui_clk                 ),
  .ui_rst                 (ui_rst&(!sys_rst_n)    ),
  .pingpang               (pingpang               ),
  .rd_b_addr              (RportB_rd_b_addr       ),
  .rd_e_addr              (RportB_rd_e_addr       ),
  .user_rd_clk            (RportB_user_rd_clk     ),
  .data_rden              (RportB_data_rden       ),
  .data_rd                (RportB_data_rd         ),
  .rd_rst                 (RportB_rd_rst          ),
  .read_enable            (RportB_read_enable     ),
  .data_rd_valid          (RportB_data_rd_valid   ),
  
  .rd_burst_req           (Rport_rd_burst_req   [1    * 1 +: 1  ]),
  .rd_burst_addr          (Rport_rd_burst_addr  [32   * 1 +: 32 ]),
  .rd_burst_len           (Rport_rd_burst_len   [10   * 1 +: 10 ]),
  .rd_ready               (Rport_rd_ready       [1    * 1 +: 1  ]),
  .rd_fifo_we             (Rport_rd_fifo_we     [1    * 1 +: 1  ]),
  .rd_fifo_data           (Rport_rd_fifo_data   [256  * 1 +: 256]),
  .rd_burst_finish        (Rport_rd_burst_finish[1    * 1 +: 1  ]),
  .rd_fifo_almost_empty   ()
);

axi_ctrl_rd#(
  .DDR_WR_LEN       (16 ),    
  .DDR_RD_LEN       (16 ),    
  .RD_DATA_WIDTH    (32 ),  // user int   
  .RD_DEPTH_WIDTH   (10 ),       
  .WR_DATA_WIDTH    (256),
  .WR_DEPTH_WIDTH   (7  )    
)axi_ctrl_rd_RC(
  .ui_clk                 (ui_clk                 ),
  .ui_rst                 (ui_rst&(!sys_rst_n)    ),
  .pingpang               (pingpang               ),
  .rd_b_addr              (RportC_rd_b_addr       ),
  .rd_e_addr              (RportC_rd_e_addr       ),
  .user_rd_clk            (RportC_user_rd_clk     ),
  .data_rden              (RportC_data_rden       ),
  .data_rd                (RportC_data_rd         ),
  .rd_rst                 (RportC_rd_rst          ),
  .read_enable            (RportC_read_enable     ),
  .data_rd_valid          (RportC_data_rd_valid   ),
  
  .rd_burst_req           (Rport_rd_burst_req   [1    * 2 +: 1  ]),
  .rd_burst_addr          (Rport_rd_burst_addr  [32   * 2 +: 32 ]),
  .rd_burst_len           (Rport_rd_burst_len   [10   * 2 +: 10 ]),
  .rd_ready               (Rport_rd_ready       [1    * 2 +: 1  ]),
  .rd_fifo_we             (Rport_rd_fifo_we     [1    * 2 +: 1  ]),
  .rd_fifo_data           (Rport_rd_fifo_data   [256  * 2 +: 256]),
  .rd_burst_finish        (Rport_rd_burst_finish[1    * 2 +: 1  ]),
  .rd_fifo_almost_empty   ()
);

axi_ctrl_rd#(
  .DDR_WR_LEN       (16 ),    
  .DDR_RD_LEN       (16 ),    
  .RD_DATA_WIDTH    (32 ),  // user int   
  .RD_DEPTH_WIDTH   (10 ),       
  .WR_DATA_WIDTH    (256),
  .WR_DEPTH_WIDTH   (7  )    
)axi_ctrl_rd_RD(
  .ui_clk                 (ui_clk                 ),
  .ui_rst                 (ui_rst&(!sys_rst_n)    ),
  .pingpang               (pingpang               ),
  .rd_b_addr              (RportD_rd_b_addr       ),
  .rd_e_addr              (RportD_rd_e_addr       ),
  .user_rd_clk            (RportD_user_rd_clk     ),
  .data_rden              (RportD_data_rden       ),
  .data_rd                (RportD_data_rd         ),
  .rd_rst                 (RportD_rd_rst          ),
  .read_enable            (RportD_read_enable     ),
  .data_rd_valid          (RportD_data_rd_valid   ),
  
  .rd_burst_req           (Rport_rd_burst_req   [1    * 3 +: 1  ]),
  .rd_burst_addr          (Rport_rd_burst_addr  [32   * 3 +: 32 ]),
  .rd_burst_len           (Rport_rd_burst_len   [10   * 3 +: 10 ]),
  .rd_ready               (Rport_rd_ready       [1    * 3 +: 1  ]),
  .rd_fifo_we             (Rport_rd_fifo_we     [1    * 3 +: 1  ]),
  .rd_fifo_data           (Rport_rd_fifo_data   [256  * 3 +: 256]),
  .rd_burst_finish        (Rport_rd_burst_finish[1    * 3 +: 1  ]),
  .rd_fifo_almost_empty   ()
);


axi_ctrl_rd#(
  .DDR_WR_LEN       (16   ),    
  .DDR_RD_LEN       (16   ),    
  .RD_DATA_WIDTH    (128  ),  // user int   
  .RD_DEPTH_WIDTH   (9   ),       
  .WR_DATA_WIDTH    (256  ),
  .WR_DEPTH_WIDTH   (8    )    
)axi_ctrl_rd_RP_a(
  .ui_clk                 (ui_clk                 ),
  .ui_rst                 (ui_rst&(!sys_rst_n)    ),
  .pingpang               (pingpang               ),
  .rd_b_addr              (RportP_a_rd_b_addr       ),
  .rd_e_addr              (RportP_a_rd_e_addr       ),
  .user_rd_clk            (RportP_a_user_rd_clk     ),
  .data_rden              (RportP_a_data_rden       ),
  .data_rd                (RportP_a_data_rd         ),
  .rd_rst                 (RportP_a_rd_rst          ),
  .read_enable            (RportP_a_read_enable     ),
  .data_rd_valid          (RportP_a_data_rd_valid   ),
  
  .rd_burst_req           (Rport_rd_burst_req   [1    * 4 +: 1  ]),
  .rd_burst_addr          (Rport_rd_burst_addr  [32   * 4 +: 32 ]),
  .rd_burst_len           (Rport_rd_burst_len   [10   * 4 +: 10 ]),
  .rd_ready               (Rport_rd_ready       [1    * 4 +: 1  ]),
  .rd_fifo_we             (Rport_rd_fifo_we     [1    * 4 +: 1  ]),
  .rd_fifo_data           (Rport_rd_fifo_data   [256  * 4 +: 256]),
  .rd_burst_finish        (Rport_rd_burst_finish[1    * 4 +: 1  ]),

  .rd_fifo_almost_empty   (pcie_almost_empty_a)
);

axi_ctrl_rd#(
  .DDR_WR_LEN       (16   ),    
  .DDR_RD_LEN       (16   ),    
  .RD_DATA_WIDTH    (128  ),  // user int   
  .RD_DEPTH_WIDTH   (9   ),       
  .WR_DATA_WIDTH    (256  ),
  .WR_DEPTH_WIDTH   (8    )    
)axi_ctrl_rd_RP_b(
  .ui_clk                 (ui_clk                 ),
  .ui_rst                 (ui_rst&(!sys_rst_n)    ),
  .pingpang               (pingpang               ),
  .rd_b_addr              (RportP_b_rd_b_addr       ),
  .rd_e_addr              (RportP_b_rd_e_addr       ),
  .user_rd_clk            (RportP_b_user_rd_clk     ),
  .data_rden              (RportP_b_data_rden       ),
  .data_rd                (RportP_b_data_rd         ),
  .rd_rst                 (RportP_b_rd_rst          ),
  .read_enable            (RportP_b_read_enable     ),
  .data_rd_valid          (RportP_b_data_rd_valid   ),
  
  .rd_burst_req           (Rport_rd_burst_req   [1    * 5+: 1  ]),
  .rd_burst_addr          (Rport_rd_burst_addr  [32   * 5+: 32 ]),
  .rd_burst_len           (Rport_rd_burst_len   [10   * 5+: 10 ]),
  .rd_ready               (Rport_rd_ready       [1    * 5+: 1  ]),
  .rd_fifo_we             (Rport_rd_fifo_we     [1    * 5+: 1  ]),
  .rd_fifo_data           (Rport_rd_fifo_data   [256  * 5+: 256]),
  .rd_burst_finish        (Rport_rd_burst_finish[1    * 5+: 1  ]),

  .rd_fifo_almost_empty   (pcie_almost_empty_b)
);

axi_ctrl_rd#(
  .DDR_WR_LEN       (16   ),    
  .DDR_RD_LEN       (16   ),    
  .RD_DATA_WIDTH    (128  ),  // user int   
  .RD_DEPTH_WIDTH   (9   ),       
  .WR_DATA_WIDTH    (256  ),
  .WR_DEPTH_WIDTH   (8    )    
)axi_ctrl_rd_RP_c(
  .ui_clk                 (ui_clk                 ),
  .ui_rst                 (ui_rst&(!sys_rst_n)    ),
  .pingpang               (pingpang               ),
  .rd_b_addr              (RportP_c_rd_b_addr       ),
  .rd_e_addr              (RportP_c_rd_e_addr       ),
  .user_rd_clk            (RportP_c_user_rd_clk     ),
  .data_rden              (RportP_c_data_rden       ),
  .data_rd                (RportP_c_data_rd         ),
  .rd_rst                 (RportP_c_rd_rst          ),
  .read_enable            (RportP_c_read_enable     ),
  .data_rd_valid          (RportP_c_data_rd_valid   ),
  
  .rd_burst_req           (Rport_rd_burst_req   [1    * 6 +: 1  ]),
  .rd_burst_addr          (Rport_rd_burst_addr  [32   * 6 +: 32 ]),
  .rd_burst_len           (Rport_rd_burst_len   [10   * 6 +: 10 ]),
  .rd_ready               (Rport_rd_ready       [1    * 6 +: 1  ]),
  .rd_fifo_we             (Rport_rd_fifo_we     [1    * 6 +: 1  ]),
  .rd_fifo_data           (Rport_rd_fifo_data   [256  * 6 +: 256]),
  .rd_burst_finish        (Rport_rd_burst_finish[1    * 6 +: 1  ]),

  .rd_fifo_almost_empty   (pcie_almost_empty_c)
);

axi_ctrl_rd#(
  .DDR_WR_LEN       (16   ),    
  .DDR_RD_LEN       (16   ),    
  .RD_DATA_WIDTH    (128  ),  // user int   
  .RD_DEPTH_WIDTH   (9   ),       
  .WR_DATA_WIDTH    (256  ),
  .WR_DEPTH_WIDTH   (8    )    
)axi_ctrl_rd_RP_d(
  .ui_clk                 (ui_clk                 ),
  .ui_rst                 (ui_rst&(!sys_rst_n)    ),
  .pingpang               (pingpang               ),
  .rd_b_addr              (RportP_d_rd_b_addr       ),
  .rd_e_addr              (RportP_d_rd_e_addr       ),
  .user_rd_clk            (RportP_d_user_rd_clk     ),
  .data_rden              (RportP_d_data_rden       ),
  .data_rd                (RportP_d_data_rd         ),
  .rd_rst                 (RportP_d_rd_rst          ),
  .read_enable            (RportP_d_read_enable     ),
  .data_rd_valid          (RportP_d_data_rd_valid   ),
  
  .rd_burst_req           (Rport_rd_burst_req   [1    * 7 +: 1  ]),
  .rd_burst_addr          (Rport_rd_burst_addr  [32   * 7 +: 32 ]),
  .rd_burst_len           (Rport_rd_burst_len   [10   * 7 +: 10 ]),
  .rd_ready               (Rport_rd_ready       [1    * 7 +: 1  ]),
  .rd_fifo_we             (Rport_rd_fifo_we     [1    * 7 +: 1  ]),
  .rd_fifo_data           (Rport_rd_fifo_data   [256  * 7 +: 256]),
  .rd_burst_finish        (Rport_rd_burst_finish[1    * 7 +: 1  ]),

  .rd_fifo_almost_empty   (pcie_almost_empty_d)
);


WRport_arbitor_v2 #(
    .W_NUM_CHNL ( W_NUM_CHNL ),
    .R_NUM_CHNL ( R_NUM_CHNL ))
u_WRport_arbitor (
    .ui_clk                     (ui_clk),                      
    .ui_rst                     (ui_rst),                      
    .rd_rst                     (rd_rst),

    .Wport_wr_burst_req         (Wport_wr_burst_req   ),                      
    .Wport_wr_burst_addr        (Wport_wr_burst_addr  ),                         
    .Wport_wr_burst_len         (Wport_wr_burst_len   ),                      
    .Wport_wr_ready             (Wport_wr_ready       ),                      
    .Wport_wr_fifo_re           (Wport_wr_fifo_re     ),                        
    .Wport_wr_fifo_data         (Wport_wr_fifo_data   ),                      
    .Wport_wr_burst_finish      (Wport_wr_burst_finish),

    .Rport_rd_burst_req         (Rport_rd_burst_req   ),                      
    .Rport_rd_burst_addr        (Rport_rd_burst_addr  ),                         
    .Rport_rd_burst_len         (Rport_rd_burst_len   ),                      
    .Rport_rd_ready             (Rport_rd_ready       ),                      
    .Rport_rd_fifo_we           (Rport_rd_fifo_we     ),                        
    .Rport_rd_fifo_data         (Rport_rd_fifo_data   ),                      
    .Rport_rd_burst_finish      (Rport_rd_burst_finish),

    .wr_burst_req               (wr_burst_req         ),                        
    .wr_burst_addr              (wr_burst_addr        ),                       
    .wr_burst_len               (wr_burst_len         ),                        
    .wr_ready                   (wr_ready             ),                        
    .wr_fifo_re                 (wr_fifo_re           ),                      
    .wr_fifo_data               (wr_fifo_data         ),                        
    .wr_burst_finish            (wr_burst_finish      ),

    .rd_burst_req               (rd_burst_req         ),                        
    .rd_burst_addr              (rd_burst_addr        ),                       
    .rd_burst_len               (rd_burst_len         ),                        
    .rd_ready                   (rd_ready             ),                        
    .rd_fifo_we                 (rd_fifo_we           ),                      
    .rd_fifo_data               (rd_fifo_data         ),                        
    .rd_burst_finish            (rd_burst_finish      )                   
);


//------------- axi_master_write_inst -------------
axi_master_write axi_master_write_inst
(
  .ARESETN      ( ~ui_rst        ), 
  .ACLK         ( ui_clk         ), 
  .M_AXI_AWID   (M_AXI_WR_awid   ), 
  .M_AXI_AWADDR (M_AXI_WR_awaddr ), 
  .M_AXI_AWLEN  (M_AXI_WR_awlen  ), 
  .M_AXI_AWVALID(M_AXI_WR_awvalid), 
  .M_AXI_AWREADY(M_AXI_WR_awready), 
 
  .M_AXI_WDATA (M_AXI_WR_wdata   ), 
  .M_AXI_WSTRB (M_AXI_WR_wstrb   ), 
  .M_AXI_WLAST (M_AXI_WR_wlast   ), 
  .M_AXI_WREADY(M_AXI_WR_wready  ),                  
  
  .WR_START    (wr_burst_req     ), 
  .WR_ADRS     (wr_burst_addr    ), 
  .WR_LEN      (wr_burst_len     ), 
  .WR_READY    (wr_ready         ), 
  .WR_FIFO_RE  (wr_fifo_re       ), 
  .WR_FIFO_DATA(wr_fifo_data     ), 
  .WR_DONE     (wr_burst_finish  )      
);
 
//------------- axi_master_read_inst -------------    
axi_master_read axi_master_read_inst
(
  . ARESETN      (~ui_rst||~rd_rst),
  . ACLK         (ui_clk),
  . M_AXI_ARID   (M_AXI_RD_arid   ), 
  . M_AXI_ARADDR (M_AXI_RD_araddr ), 
  . M_AXI_ARLEN  (M_AXI_RD_arlen  ), 
  . M_AXI_ARVALID(M_AXI_RD_arvalid), 
  . M_AXI_ARREADY(M_AXI_RD_arready), 
  
  . M_AXI_RID   (M_AXI_RD_rid   ), 
  . M_AXI_RDATA (M_AXI_RD_rdata ), 
  . M_AXI_RLAST (M_AXI_RD_rlast ), 
  . M_AXI_RVALID(M_AXI_RD_rvalid), 

  . RD_START    (rd_burst_req   ), 
  . RD_ADRS     (rd_burst_addr  ), 
  . RD_LEN      (rd_burst_len   ), 
  . RD_READY    (rd_ready       ), 
  . RD_FIFO_WE  (rd_fifo_we     ), 
  . RD_FIFO_DATA(rd_fifo_data   ), 
  . RD_DONE     (rd_burst_finish)  
);

/************** DDR IP **************/

wire ref_clk_bypass       ;
reg	 free_run_clk         ;
wire dfi_reset_n          ;
wire rst_n                ;

assign rst_n = sys_rst_n & pll_lock ;
assign ui_rst = !sys_rst_n        ;

always @(posedge ref_clk_bypass or negedge rst_n)
begin
	if(~rst_n)
		free_run_clk <= 1'b0;
	else
	  free_run_clk <= ~free_run_clk;  
end

`ifdef sim
  DDR3 I_DDR3 (
`else
  ddr3_test I_DDR3 (
`endif 
  .ref_clk                  ( ref_clk                 ) ,   
  .resetn                   ( sys_rst_n               ) ,   // input
  .ddr_init_done            ( ddr_init_done           ) ,   // output
  .ddrphy_clkin             ( ui_clk                  ) ,   // output
  .pll_lock                 ( pll_lock                ) ,   // output

  .axi_awaddr               ( M_AXI_WR_awaddr[27:0]   ) ,   // input [27:0]
  .axi_awuser_ap            ( 1'b0                    ) ,   // input
  .axi_awuser_id            ( M_AXI_WR_awid           ) ,   // input [3:0]
  .axi_awlen                ( M_AXI_WR_awlen[3:0]     ) ,   // input [3:0]
  .axi_awready              ( M_AXI_WR_awready        ) ,   // output
  .axi_awvalid              ( M_AXI_WR_awvalid        ) ,   // input

  .axi_wdata                ( M_AXI_WR_wdata          ) ,   
  .axi_wstrb                ( M_AXI_WR_wstrb          ) ,   
  .axi_wready               ( M_AXI_WR_wready         ) ,   
  .axi_wusero_id            (                         ) ,   
  .axi_wusero_last          ( M_AXI_WR_wlast          ) ,   

  .axi_araddr               ( M_AXI_RD_araddr[27:0]   ) ,   // input [27:0]
  .axi_aruser_ap            ( 1'b0                    ) ,   // input
  .axi_aruser_id            ( M_AXI_RD_arid           ) ,   // input [3:0]
  .axi_arlen                ( M_AXI_RD_arlen[3:0]     ) ,   // input [3:0]
  .axi_arready              ( M_AXI_RD_arready        ) ,   // output
  .axi_arvalid              ( M_AXI_RD_arvalid        ) ,   // input

  .axi_rdata                ( M_AXI_RD_rdata          ) ,   // output [255:0]
  .axi_rid                  ( M_AXI_RD_rid            ) ,   // output [3:0]
  .axi_rlast                ( M_AXI_RD_rlast          ) ,   // output
  .axi_rvalid               ( M_AXI_RD_rvalid         ) ,   // output

  .apb_clk                  ( 1'b0                    ) ,   // input
  .apb_rst_n                ( 1'b0                    ) ,   // input
  .apb_sel                  ( 1'b0                    ) ,   // input
  .apb_enable               ( 1'b0                    ) ,   // input
  .apb_addr                 ( 8'd0                    ) ,   // input [7:0]
  .apb_write                ( 1'b0                    ) ,   // input
  .apb_ready                (                         ) ,   // output
  .apb_wdata                ( 16'd0                   ) ,   // input [15:0]
  .apb_rdata                (                         ) ,   // output [15:0]
  .apb_int                  (                         ) ,   // output

  .mem_rst_n                ( ddr3_reset_n            ) ,  // output
  .mem_dq                   ( ddr3_dq                 ),   // output
  .mem_dqs                  ( ddr3_dqs_p              ),   // output
  .mem_dqs_n                ( ddr3_dqs_n              ),   // output
  .mem_a                    ( ddr3_addr               ),   // output
  .mem_ba                   ( ddr3_ba                 ),   // output
  .mem_ck                   ( ddr3_ck_p               ),   // output
  .mem_ck_n                 ( ddr3_ck_n               ),   // output
  .mem_cke                  ( ddr3_cke                ),   // output
  .mem_dm                   ( ddr3_dm                 ),   // output [14:0]
  .mem_odt                  ( ddr3_odt                ),   // output [2:0]
  .mem_cs_n                 ( ddr3_cs_n               ),   // inout [3:0]
  .mem_ras_n                ( ddr3_ras_n              ),   // inout [3:0]
  .mem_cas_n                ( ddr3_cas_n              ),   // inout [31:0]
  .mem_we_n                 ( ddr3_we_n               ),   // output [3:0]

  .debug_data               (                         ) ,   // output [135:0]
  .debug_slice_state        (                         ) ,   // output [51:0]
  .debug_calib_ctrl         (                         ) ,   // output [21:0]
  .ck_dly_set_bin           (                         ) ,   // output [7:0]
  .force_ck_dly_en          ( 0                       ) ,   // input
  .force_ck_dly_set_bin     ( 0                       ) ,   // input [7:0]
  .dll_step                 (                         ) ,   // output [7:0]
  .dll_lock                 (                         ) ,   // output
  .init_read_clk_ctrl       ( 0                       ) ,   // input [1:0]
  .init_slip_step           ( 0                       ) ,   // input [3:0]
  .force_read_clk_ctrl      ( 0                       ) ,   // input
  .ddrphy_gate_update_en    ( 0                       ) ,   // input
  .update_com_val_err_flag  (                         ) ,   // output [3:0]
  .rd_fake_stop             ( 0                       )     // input
) ;


endmodule
