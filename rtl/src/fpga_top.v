`include "./header/fpga_header.vh"

module fpga_top (
    /* sys_sig */
    input   wire            sys_clk_50m             ,
    input   wire            sys_rst_n               ,
    /* hdmi_iic_sig */
    output  wire            rstn_out                ,
    output  wire            iic_scl                 ,
    inout   wire            iic_sda                 , 
    output  wire            iic_tx_scl              ,
    inout   wire            iic_tx_sda              , 
    /* hdmi_in_sig */
    input   wire            hdmi_clk_in             , 
    input   wire            hdmi_hs_in              ,
    input   wire            hdmi_vs_in              ,
    input   wire            hdmi_de_in              ,
    input   wire [23:0]     hdmi_data_in            , 
    /* hdmi_out_sig */
    output  wire            hdmi_clk_out            ,                            
    output  wire            hdmi_vs_out             , 
    output  wire            hdmi_hs_out             , 
    output  wire            hdmi_de_out             ,
    output  wire [23:0]     hdmi_data_out           ,
    /* ddr_sig */
    output  wire            mem_cs_n                ,
    output  wire            mem_rst_n               ,
    output  wire            mem_ck                  ,
    output  wire            mem_ck_n                ,
    output  wire            mem_cke                 ,
    output  wire            mem_ras_n               ,
    output  wire            mem_cas_n               ,
    output  wire            mem_we_n                ,
    output  wire            mem_odt                 ,
    output  wire [14:0]     mem_a                   ,
    output  wire [2 :0]     mem_ba                  ,
    inout   wire [3 :0]     mem_dqs                 ,
    inout   wire [3 :0]     mem_dqs_n               ,
    inout   wire [31:0]     mem_dq                  ,
    output  wire [3 :0]     mem_dm                  ,
    inout   wire [3 :0]     dly_mon_pad             ,
    /* pcie_sig */
    input   wire            ref_clk_n               ,
    input   wire            ref_clk_p               ,
    input   wire            perst_n                 ,

    input   wire [3:0]      rxn                     ,
    input   wire [3:0]      rxp                     ,
    output  wire [3:0]      txn                     ,
    output  wire [3:0]      txp                     ,
    /* camera_sig */   
    input   wire [7:0]      ov5640_data             ,   //摄像头采集图像数据
    input   wire            ov5640_vsync            ,   //摄像头采集图像场同步信号
    input   wire            ov5640_href             ,   //摄像头采集图像行同步信号
    input   wire            ov5640_pclk             ,   //摄像头像素时钟        
    output  wire            ov5640_rst_n            ,   //
    output  wire            ov5640_pwdn             ,   //
    output  wire            sccb_scl                ,   //SCCB串行时钟
    inout   wire            sccb_sda                ,   //SCCB串行数据
    /* led_sig */
    // LED 1
    output  wire            iic_init_done           ,

    input  wire             rgmii_rxc               ,
    input  wire             rgmii_rx_ctl            ,
    input  wire [3:0]       rgmii_rxd               ,
    
    output wire             eth_rst_n               ,
`ifdef sim
    output  wire            ddr_init_done           ,
    input   wire            hdmi_out
`else
    // LED 2
    output  wire            ddr_init_done           ,           
`endif
    // LED 3
    output  wire            pcie_ref_led            ,
    // LED 4
    output  wire            pcie_pclk_led           ,
    // LED 5
    output  wire            pcie_pclk_div2_led      ,
    // LED 6
    output  wire            pcie_smlh_link_up       ,
    // LED 7
    output  wire            pcie_rdlh_link_up       ,

    input                   uart_rx                 ,
    output                  uart_tx                 ,
    output  [7:0]               led
);

`ifdef sim
    localparam PIC_SIZE = 960*2;

    localparam INPUT_H_TOTAL    = 1926 ;
    localparam INPUT_V_TOTAL    = 10   ;
    localparam INPUT_RES_X      = 1920 ;
    localparam INPUT_RES_Y      = 4    ;
    localparam OUTPUT_H_TOTAL   = 963  ;
    localparam OUTPUT_V_TOTAL   = 20   ;
    localparam OUTPUT_RES_X     = 960  ;
    localparam OUTPUT_RES_Y     = 2    ;
    localparam OUTPUT_H_SYNC    = 1    ;
    localparam OUTPUT_H_BP      = 1    ;
    localparam OUTPUT_H_FP      = 1    ;
    localparam OUTPUT_V_SYNC    = 14   ;
    localparam OUTPUT_V_BP      = 2    ;
    localparam OUTPUT_V_FP      = 2    ;

`else
    localparam PIC_SIZE = 960*540;
    
    localparam INPUT_H_TOTAL  = 2200    ;
    localparam INPUT_V_TOTAL  = 1125    ;
    localparam INPUT_RES_X    = 1920    ;
    localparam INPUT_RES_Y    = 1080    ;
    localparam OUTPUT_H_TOTAL = 4400    ;  
    localparam OUTPUT_V_TOTAL = 562     ;
    localparam OUTPUT_RES_X   = 960     ;
    localparam OUTPUT_RES_Y   = 540     ;
    localparam OUTPUT_H_SYNC  = 440     ;
    localparam OUTPUT_H_BP    = 1500    ;
    localparam OUTPUT_H_FP    = 1500    ;
    localparam OUTPUT_V_SYNC  = 7       ;
    localparam OUTPUT_V_BP    = 7       ;
    localparam OUTPUT_V_FP    = 8       ;
`endif

/************** Register && Net declaration **************/
reg  [15:0] rstn_1ms                                ;

reg  [23:0] hdmi_pix                                ;
reg  [23:0] hdmi_pix_d1                             ;
reg         hs_in_reg,vs_in_reg,de_in_reg           ;
reg         hs_in_d1,vs_in_d1,de_in_d1              ;


wire        rst_n                                   ;

wire        ui_clk                                  ;
wire        ui_rst                                  ;

wire        cfg_clk                                 ;
wire        locked                                  ;
wire        init_over                               ;      

wire        wr_en                                   ;
wire [15:0] wr_data                                 ;
wire        rd_en                                   ;
wire [15:0] rd_data_B                               ;
wire        read_enable                             ;
wire        data_rd_valid_A                         ;
wire        data_rd_valid_B                         ;
wire        data_rden_B                             ;

wire        dma_rd_A_rden                           ;
wire        dma_rd_B_rden                           ;
wire        dma_rd_C_rden                           ;
wire        dma_rd_D_rden                           ;

wire        hdmi_wr_en                              ;
wire [31:0] hdmi_data_dw_out                        ;

wire        hdmi_clk_bufg                           ;

wire [23:0] hdmi_data_out_A,hdmi_data_out_B,hdmi_data_out_C,hdmi_data_out_D ;

wire [23:0] hdmi_data_scale_out;
wire        hdmi_de_scale_out,hdmi_hs_scale_out,hdmi_vs_scale_out;

// wire    pcie_almost_empty;

wire    pcie_almost_empty_a;
wire    pcie_almost_empty_b;
wire    pcie_almost_empty_c;
wire    pcie_almost_empty_d;

wire        dma_rd_P_rden_a                           ;
wire        dma_rd_P_rden_b                           ;
wire        dma_rd_P_rden_c                           ;
wire        dma_rd_P_rden_d                           ;

wire [127:0] pcie_data_in_a                           ;
wire [127:0] pcie_data_in_b                           ;
wire [127:0] pcie_data_in_c                           ;
wire [127:0] pcie_data_in_d                           ;

pcie_rd_convert u_pcie_rd_convert (
    .sys_rst_n              ( rst_n &  read_enable & ~rst_uart & sys_uart_rst),
    .pcie_data_in_enable    (pcie_data_in_enable     ),
    .pclk_div2              ( pclk_div2              ),
    .dma_rd_A_rden          ( dma_rd_P_rden_a        ),
    .dma_rd_B_rden          ( dma_rd_P_rden_b        ),
    .dma_rd_C_rden          ( dma_rd_P_rden_c        ),
    .dma_rd_D_rden          ( dma_rd_P_rden_d        )
);
assign pcie_data_in =  (dma_rd_P_rden_a == 1) ? pcie_data_in_a :
                       (dma_rd_P_rden_b == 1) ? pcie_data_in_b :
                       (dma_rd_P_rden_c == 1) ? pcie_data_in_c :
                       (dma_rd_P_rden_d == 1) ? pcie_data_in_d :
                                              128'd0           ;    
/* camera */
wire        cfg_done                                ;
wire [31:0] image_data                              ;
wire        image_data_en                           ;
wire        clk_25M                                 ;

/* pcie */
wire        pclk_div2                               ;
wire        core_rst_n                              ;
// wire        pcie_wr_clk                             ;

wire        wr_en                                   ;
wire [1:0]  wr_byte_en                              ;
wire [31:0] wr_addr                                 ;
wire [15:0] wr_data                                 ;

wire        rd_en                                   ;
wire [31:0] rd_addr                                 ;
wire [15:0] rd_data                                 ;

wire        wr_en_32_out                            ;
wire [127:0] wr_data_32_out                         ;

wire        pcie_data_in_enable                     ;
wire [127:0] pcie_data_in                           ;

 
wire             rec_pkt_done                       ;     
wire             rec_en                             ;      
wire [31:0]      rec_data                           ;     
wire [15:0]      rec_byte_num                       ;      
wire             eth_clk                            ;
wire             eth_rst_n                          ;

/*uart*/
wire            ov5640_uart_rst                         ;
wire            sys_uart_rst                            ;
wire            pcie_uart_rst                           ;
wire [3:0]      eth_port                                ;
wire [3:0]      camera_port                             ;    
wire [3:0]      pcie_port                               ;
wire [3:0]      hdmi_port                               ;  
wire            rst_uart                                ;
wire [1:0]      rState                                  ;
/************** --------------------------- **************/

/************** Combination Part **************/

assign iic_init_done =  init_over; 
assign rstn_out = (rstn_1ms == 16'h2710);
assign sys_init_done = ddr_init_done & cfg_done;
assign ov5640_pwdn = 1'b0;
assign ov5640_rst_n = 1'b1;

`ifdef sim
    assign hdmi_clk_out = hdmi_out;
    assign rst_n = sys_rst_n;
    // assign rst_n = sys_rst_n & ddr_init_done ;
    wire hdmi_de_out_B,hdmi_de_out_C,hdmi_de_out_D;
`else
    assign rst_n = sys_rst_n & ddr_init_done & init_over ;
    assign hdmi_clk_out = hdmi_clk_bufg;
`endif

assign hdmi_data_out = (dma_rd_A_rden == 1) ? hdmi_data_out_A :
                       (dma_rd_B_rden == 1) ? hdmi_data_out_B :
                       (dma_rd_C_rden == 1) ? hdmi_data_out_C :
                       (dma_rd_D_rden == 1) ? hdmi_data_out_D :
                                              24'd0           ;
/************** ---------------- **************/

/************** Sequencial Part **************/

always @(posedge cfg_clk) begin
      if(!locked)
          rstn_1ms <= 16'd0;
      else
      begin
          if(rstn_1ms == 16'h2710)
              rstn_1ms <= rstn_1ms;
          else
              rstn_1ms <= rstn_1ms + 1'b1;
      end
end

always @(posedge hdmi_clk_bufg or negedge sys_uart_rst) begin
    if(!sys_uart_rst)begin
        hdmi_pix    <= 24'd0    ;
        de_in_reg   <= 1'd0     ;
        hs_in_reg   <= 1'd0     ;
        vs_in_reg   <= 1'd0     ;
        hdmi_pix_d1 <= 24'd0    ;
        de_in_d1    <= 1'd0     ;
        hs_in_d1    <= 1'd0     ;
        vs_in_d1    <= 1'd0     ;
    end else begin
      hdmi_pix_d1   <= hdmi_data_in ;
      de_in_d1      <= hdmi_de_in   ;
      hs_in_d1      <= hdmi_hs_in   ;
      vs_in_d1      <= hdmi_vs_in   ;

      hdmi_pix      <= hdmi_pix_d1  ;
      de_in_reg     <= de_in_d1     ;
      vs_in_reg     <= vs_in_d1     ;
      hs_in_reg     <= hs_in_d1     ;
      end
end

/************** ---------------- **************/

GTP_CLKBUFG hclk (
    .CLKOUT                 ( hdmi_clk_bufg         )   ,
    .CLKIN                  ( hdmi_clk_in           )    
);

pll u_pll (
    .clkin1                 ( sys_clk_50m           )   ,   // input  50MHz
    .clkout1                ( cfg_clk               )   ,   // output 10MHz
    .clkout2                ( clk_25M               )   ,   // output 25MHz camera
    .pll_lock               ( locked                )       // output lock
);

ms72xx_ctl ms72xx_ctl(
    .clk                       (  cfg_clk              )   ,
    .rst_n                     (  rstn_out             )   ,
    .init_over                 (  init_over            )   ,
    .iic_tx_scl                (  iic_tx_scl           )   ,
    .iic_tx_sda                (  iic_tx_sda           )   ,
    .iic_scl                   (  iic_scl              )   ,
    .iic_sda                   (  iic_sda              )    
);

scaler_v1 # (
    .INPUT_H_TOTAL             (  INPUT_H_TOTAL      ),
    .INPUT_V_TOTAL             (  INPUT_V_TOTAL      ),   
    .INPUT_RES_X               (  INPUT_RES_X        ),
    .INPUT_RES_Y               (  INPUT_RES_Y        ),
    .OUTPUT_H_TOTAL            (  OUTPUT_H_TOTAL     ),
    .OUTPUT_V_TOTAL            (  OUTPUT_V_TOTAL     ),
    .OUTPUT_RES_X              (  OUTPUT_RES_X       ),
    .OUTPUT_RES_Y              (  OUTPUT_RES_Y       ),	
    .OUTPUT_H_SYNC             (  OUTPUT_H_SYNC      ),
    .OUTPUT_H_BP               (  OUTPUT_H_BP        ),
    .OUTPUT_H_FP               (  OUTPUT_H_FP        ),
    .OUTPUT_V_SYNC             (  OUTPUT_V_SYNC      ),
    .OUTPUT_V_BP               (  OUTPUT_V_BP        ),
    .OUTPUT_V_FP               (  OUTPUT_V_FP        ),	
	
    .WR_PRE_PIXEL_NUM          (  2560   ),	
    .ADJUST_BASE_NUM           (  988    ),	
	
    .DATA_WIDTH                (  8                 ),
    .CHANNEL                   (  3                 )    
)
scaler_v1_inst
(
    .rst_n                 (   rst_n  & sys_uart_rst                      ),
	.pclk_in               (   hdmi_clk_bufg                ),
	.pclk_out              (   hdmi_clk_bufg                ),

    .pix_data_in           (   hdmi_pix                     ),
    .vs_in                 (   vs_in_reg                    ),
    .hs_in                 (   hs_in_reg                    ),
	.de_in                 (   de_in_reg                    ),

    .test0                 (                                ),
    .test1                 (                                ),
	
    .de_out                (   hdmi_de_scale_out            ),
    .vs_out                (   hdmi_vs_scale_out            ),
    .hs_out                (   hdmi_hs_scale_out            ),
    .pix_data_out          (   hdmi_data_scale_out          )
);


hdmi_dw_convert u_hdmi_dw_convert (
    .sys_rst_n              ( rst_n  & sys_uart_rst        ),
    .hdmi_clk               ( hdmi_clk_bufg                 ),
    .hdmi_hs_in             ( hdmi_hs_scale_out             ),
    .hdmi_vs_in             ( hdmi_vs_scale_out             ),
    .hdmi_de_in             ( hdmi_de_scale_out             ),
    .hdmi_data_in           ( hdmi_data_scale_out           ),
    .hdmi_wr_en             ( hdmi_wr_en                    ),
    .hdmi_data_dw_out       ( hdmi_data_dw_out              ),
    .read_enable            ( read_enable                   )
);


hdmi_rd_convert u_hdmi_rd_convert (
    .sys_rst_n              ( rst_n &  read_enable & ~rst_uart & sys_uart_rst),
    .hdmi_clk               ( hdmi_clk_out          ),
    .hdmi_hs_out            ( hdmi_hs_out           ),
    .hdmi_vs_out            ( hdmi_vs_out           ),
    .hdmi_de_out            ( hdmi_de_out           ),

    .dma_rd_A_rden          ( dma_rd_A_rden         ),
    .dma_rd_B_rden          ( dma_rd_B_rden         ),
    .dma_rd_C_rden          ( dma_rd_C_rden         ),
    .dma_rd_D_rden          ( dma_rd_D_rden         )
);

eth_top  u_eth_top (
    .sys_rst_n              (sys_rst_n  & sys_uart_rst            ),
    .eth_rst_n              (eth_rst_n              ),
    
    .rgmii_rxc              ( rgmii_rxc             ),
    .rgmii_rx_ctl           ( rgmii_rx_ctl          ),
    .rgmii_rxd              ( rgmii_rxd             ),
    
    .rec_pkt_done           ( rec_pkt_done          ),    
    .rec_en                 ( rec_en                ),
    .rec_data               ( rec_data              ),
    .rec_byte_num           ( rec_byte_num          ),
    .eth_clk                ( eth_clk               ) 
);

axi_ddr_top #(
    .DDR_WR_LEN             ( 16                    ) ,
    .DDR_RD_LEN             ( 16                    )  
) ddr_rw_inst ( 
    .ref_clk                ( sys_clk_50m           ) ,
    .sys_rst_n              ( sys_rst_n   & sys_uart_rst          ) ,
    .pingpang               ( 0                     ) ,

    .WportA_user_wr_clk     ( eth_clk               ) ,//eth wr
    .WportA_data_wren       ( rec_en                ) ,  
    .WportA_data_wr         ( rec_data              ) ,  
    .WportA_wr_b_addr       ( 32'd0                 ) ,  
    .WportA_wr_e_addr       ( PIC_SIZE*32/32        ) ,  
    .WportA_wr_rst          ( 1'b0                  ) ,  

    .WportB_user_wr_clk     ( pclk_div2             ) ,//pcie er
    .WportB_data_wren       ( wr_en_32_out          ) ,
    .WportB_data_wr         ( wr_data_32_out        ) ,
    .WportB_wr_b_addr       ( PIC_SIZE*32/32*2      ) ,
    .WportB_wr_e_addr       ( PIC_SIZE*32/32*3      ) ,
    .WportB_wr_rst          ( 1'd0         ) ,

    .WportC_user_wr_clk     ( ov5640_pclk           ) ,//camera wr
    .WportC_data_wren       ( image_data_en         ) ,
    .WportC_data_wr         ( image_data            ) ,
    .WportC_wr_b_addr       ( PIC_SIZE*32/32*1      ) ,
    .WportC_wr_e_addr       ( PIC_SIZE*32/32*2      ) ,
    .WportC_wr_rst          ( ov5640_uart_rst       ) ,

    .WportD_user_wr_clk     ( hdmi_clk_bufg         ) ,//hdmi wr
    .WportD_data_wren       ( hdmi_wr_en            ) ,
    .WportD_data_wr         ( hdmi_data_dw_out      ) ,
    .WportD_wr_b_addr       ( PIC_SIZE*32/32*3      ) ,
    .WportD_wr_e_addr       ( PIC_SIZE*32/32*4      ) ,
    .WportD_wr_rst          ( 1'b0                  ) ,

    .RportA_user_rd_clk     ( hdmi_clk_out          ) ,//eth rd
    .RportA_data_rden       ( dma_rd_A_rden         ) ,
    .RportA_data_rd         ( hdmi_data_out_A       ) ,
    .RportA_rd_b_addr       ( PIC_SIZE*32/32*eth_port      ) ,
    .RportA_rd_e_addr       ( PIC_SIZE*32/32*(eth_port+1)      ) ,
    .RportA_rd_rst          ( rst_uart                 ) ,
    .RportA_read_enable     ( read_enable           ) ,
    .RportA_data_rd_valid   ( data_rd_valid_A       ) ,

    .RportB_user_rd_clk     ( hdmi_clk_out          ) ,//camera rd
    .RportB_data_rden       ( dma_rd_B_rden         ) ,
    .RportB_data_rd         ( hdmi_data_out_B       ) ,
    .RportB_rd_b_addr       ( PIC_SIZE*camera_port      ) ,
    .RportB_rd_e_addr       ( PIC_SIZE*(camera_port+1'd1)      ) ,
    .RportB_rd_rst          ( rst_uart                 ) ,
    .RportB_read_enable     ( read_enable           ) ,
    .RportB_data_rd_valid   ( data_rd_valid_B       ) ,

    .RportC_user_rd_clk     ( hdmi_clk_out          ) ,//pcie rd
    .RportC_data_rden       ( dma_rd_C_rden         ) ,
    .RportC_data_rd         ( hdmi_data_out_C       ) ,
    .RportC_rd_b_addr       ( PIC_SIZE*pcie_port      ) ,
    .RportC_rd_e_addr       ( PIC_SIZE*(pcie_port+1)      ) ,
    .RportC_rd_rst          ( rst_uart                  ) ,
    .RportC_read_enable     ( read_enable           ) ,
    .RportC_data_rd_valid   ( data_rd_valid_C       ) ,

    .RportD_user_rd_clk     ( hdmi_clk_out          ) ,//hdmi rd
    .RportD_data_rden       ( dma_rd_D_rden         ) ,
    .RportD_data_rd         ( hdmi_data_out_D       ) ,
    .RportD_rd_b_addr       ( PIC_SIZE*hdmi_port      ) ,
    .RportD_rd_e_addr       ( PIC_SIZE*(hdmi_port+1'd1)      ) ,
    .RportD_rd_rst          ( rst_uart                 ) ,
    .RportD_read_enable     ( read_enable           ) ,
    .RportD_data_rd_valid   ( data_rd_valid_D       ) ,

    .RportP_a_user_rd_clk     ( pclk_div2             ) ,//pcie input
    .RportP_a_data_rden       ( pcie_data_in_enable && dma_rd_P_rden_a) ,//input
    .RportP_a_data_rd         ( pcie_data_in_a          ) ,//output
    .RportP_a_rd_b_addr       ( PIC_SIZE*0            ) ,//input
    .RportP_a_rd_e_addr       ( PIC_SIZE*1            ) ,//input
    .RportP_a_rd_rst          ( rst_uart              ) ,//inpit
    .RportP_a_read_enable     ( read_enable           ) ,//input
    .RportP_a_data_rd_valid   ( data_rd_valid_A       ) ,//output none
    .pcie_almost_empty_a      (pcie_almost_empty_a      ) ,//output

    .RportP_b_user_rd_clk     ( pclk_div2             ) ,//pcie input
    .RportP_b_data_rden       ( pcie_data_in_enable && dma_rd_P_rden_b  ) ,//input
    .RportP_b_data_rd         ( pcie_data_in_b          ) ,//output
    .RportP_b_rd_b_addr       ( PIC_SIZE*1            ) ,//input
    .RportP_b_rd_e_addr       ( PIC_SIZE*2            ) ,//input
    .RportP_b_rd_rst          ( rst_uart              ) ,//inpit
    .RportP_b_read_enable     ( read_enable           ) ,//input
    .RportP_b_data_rd_valid   ( data_rd_valid_B       ) ,//output none
    .pcie_almost_empty_b      (pcie_almost_empty_b      ) ,//output
    
    .RportP_c_user_rd_clk     ( pclk_div2             ) ,//pcie input
    .RportP_c_data_rden       ( pcie_data_in_enable && dma_rd_P_rden_c  ) ,//input
    .RportP_c_data_rd         ( pcie_data_in_c          ) ,//output
    .RportP_c_rd_b_addr       ( PIC_SIZE*2            ) ,//input
    .RportP_c_rd_e_addr       ( PIC_SIZE*3            ) ,//input
    .RportP_c_rd_rst          ( rst_uart              ) ,//inpit
    .RportP_c_read_enable     ( read_enable           ) ,//input
    .RportP_c_data_rd_valid   ( data_rd_valid_C       ) ,//output none
    .pcie_almost_empty_c      (pcie_almost_empty_c      ) ,//output
    
    .RportP_d_user_rd_clk     ( pclk_div2             ) ,//pcie input
    .RportP_d_data_rden       ( pcie_data_in_enable && dma_rd_P_rden_d  ) ,//input
    .RportP_d_data_rd         ( pcie_data_in_d          ) ,//output
    .RportP_d_rd_b_addr       ( PIC_SIZE*3            ) ,//input
    .RportP_d_rd_e_addr       ( PIC_SIZE*4            ) ,//input
    .RportP_d_rd_rst          ( rst_uart              ) ,//inpit
    .RportP_d_read_enable     ( read_enable           ) ,//input
    .RportP_d_data_rd_valid   ( data_rd_valid_D       ) ,//output none
    .pcie_almost_empty_d      (pcie_almost_empty_d      ) ,//output

    // .RportP_user_rd_clk     ( pclk_div2             ) ,//pcie 
    // .RportP_data_rden       ( pcie_data_in_enable   ) ,
    // .RportP_data_rd         ( pcie_data_in          ) ,
    // .RportP_rd_b_addr       ( PIC_SIZE*hdmi_port      ) ,
    // .RportP_rd_e_addr       ( PIC_SIZE*(hdmi_port+1'd1)      ) ,
    // .RportP_rd_rst          ( rst_uart                  ) ,
    // .RportP_read_enable     ( read_enable           ) ,
    // .RportP_data_rd_valid   ( data_rd_valid_D       ) ,
    // .pcie_almost_empty      (pcie_almost_empty      ) ,
   
    .ui_rst                 ( ui_rst                ) ,
    .ui_clk                 ( ui_clk                ) ,
    .ddr_init_done          ( ddr_init_done         ) ,
    .pll_lock               ( pll_lock              ) ,

    .ddr3_dq                ( mem_dq                ) ,
    .ddr3_dqs_n             ( mem_dqs_n             ) ,
    .ddr3_dqs_p             ( mem_dqs               ) ,
    .ddr3_addr              ( mem_a                 ) ,
    .ddr3_ba                ( mem_ba                ) ,
    .ddr3_ras_n             ( mem_ras_n             ) ,
    .ddr3_cas_n             ( mem_cas_n             ) ,
    .ddr3_we_n              ( mem_we_n              ) ,
    .ddr3_reset_n           ( mem_rst_n             ) ,
    .ddr3_ck_p              ( mem_ck                ) ,
    .ddr3_ck_n              ( mem_ck_n              ) ,
    .ddr3_cke               ( mem_cke               ) ,
    .ddr3_cs_n              ( mem_cs_n              ) ,
    .ddr3_dm                ( mem_dm                ) ,
    .ddr3_odt               ( mem_odt               )  
);

pcie_app_7x u_pcie_app (
    .free_clk	            ( sys_clk_50m           ) , 
    .pclk_led	            ( pcie_pclk_led         ) , 
    .pclk_div2_led          ( pcie_pclk_div2_led    ) ,
    
    .ref_clk_led	        ( pcie_ref_led          ) ,
    .ref_clk_n	            ( ref_clk_n             ) ,
    .ref_clk_p	            ( ref_clk_p             ) ,
    
    .button_rst_n	        ( sys_rst_n    & sys_uart_rst          ) ,
    .power_up_rst_n	        ( perst_n               ) ,
    .perst_n			    ( perst_n               ) ,
    
    .smlh_link_up           ( pcie_smlh_link_up     ) ,
    .rdlh_link_up           ( pcie_rdlh_link_up     ) ,
    
    .txp                    ( rxn                   ) ,
    .txn                    ( rxp                   ) ,
    .rxp                    ( txn                   ) ,
    .rxn                    ( txp                   ) ,

    .chnl_rx_clk            ( pclk_div2             ) ,
    .CHNL_RX_DATA_VALID_out ( wr_en_32_out          ) ,
    .chnl_rx_data           ( wr_data_32_out        ) ,

    .chnl_tx_data_in        (pcie_data_in           ),
    .chnl_tx_data_valid_in  (pcie_data_in_enable    ),
    .chnl_tx_data_almost_empty(pcie_almost_empty_a && pcie_almost_empty_b && pcie_almost_empty_c && pcie_almost_empty_d    ),
    .rState                 (rState                 )

);

ov5640_top  u_ov5640_top (
    .sys_clk                (clk_25M                ),   //系统时钟
    .sys_rst_n              (rst_n & locked && ~ov5640_uart_rst      ),   //复位信号
    .sys_init_done          (sys_init_done          ),   //系统初始化完成(SDRAM + 摄像头)

    .ov5640_pclk            (ov5640_pclk            ),   //摄像头像素时钟
    .ov5640_href            (ov5640_href            ),   //摄像头行同步信号
    .ov5640_vsync           (ov5640_vsync           ),   //摄像头场同步信号
    .ov5640_data            (ov5640_data            ),   //摄像头图像数据

    .cfg_done               (cfg_done               ),   //寄存器配置完成
    .sccb_scl               (sccb_scl               ),   //SCL
    .sccb_sda               (sccb_sda               ),   //SDA
    .ov5640_wr_en           (image_data_en          ),   //图像数据有效使能信号
    .ov5640_data_out        (image_data             )    //图像数据
);       

uart_top u_uart_top( 
    .clk                    (sys_clk_50m            ),
    .sys_rst_n              (sys_rst_n              ),
    .uart_rx                (uart_rx                ),
    .eth_port               (eth_port               ),
    .camera_port            (camera_port            ),
    .pcie_port              (pcie_port              ),
    .hdmi_port              (hdmi_port              ),
    .uart_tx                (uart_tx                ),
    .led                    (led                    ),
    .rst_uart               (rst_uart               ),
    .rState                 (rState                 ),
    .ov5640_uart_rst        (ov5640_uart_rst        ),
    .pcie_uart_rst          (pcie_uart_rst          ),
    .sys_uart_rst           (sys_uart_rst           )

);

endmodule