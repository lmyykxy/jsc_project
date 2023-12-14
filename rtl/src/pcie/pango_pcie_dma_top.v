// Created by IP Generator (Version 2021.1-SP7.3 build 94852)


//////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2019 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//
// THE SOURCE CODE CONTAINED HEREIN IS PROPRIETARY TO PANGO MICROSYSTEMS, INC.
// IT SHALL NOT BE REPRODUCED OR DISCLOSED IN WHOLE OR IN PART OR USED BY
// PARTIES WITHOUT WRITTEN AUTHORIZATION FROM THE OWNER.
//
//////////////////////////////////////////////////////////////////////////////
//
// Library:
// Filename:pango_pcie_dma_top.v
//////////////////////////////////////////////////////////////////////////////
module pango_pcie_dma_top

(
    //clk and rst
    input                           free_clk        ,      // 50 Mhz
    input                           ref_clk_n       ,      //125 Mhz
    input                           ref_clk_p       ,      //125 Mhz
    input                           button_rst_n    ,
    input                           perst_n         ,
    //diff signals
    input           [3:0]           rxn             ,
    input           [3:0]           rxp             ,
    output  wire    [3:0]           txn             ,
    output  wire    [3:0]           txp             ,

    //LED signals
    output  reg                     ref_led         ,
    output  reg                     pclk_led        ,
    output  reg                     pclk_div2_led   ,
    output  wire                    smlh_link_up    /* synthesis PAP_MARK_DEBUG=”true”*/,
    output  wire                    rdlh_link_up    /* synthesis PAP_MARK_DEBUG=”true”*/,

    output  wire                    pclk_div2       /* synthesis PAP_MARK_DEBUG=”true”*/, //gen1:62.5MHz,gen2:125MHz
    output  wire                    core_rst_n      ,
    output  wire                    wr_en           /* synthesis PAP_MARK_DEBUG=”true”*/,
    output  wire    [1:0]           wr_byte_en      /* synthesis PAP_MARK_DEBUG=”true”*/, 
    output  wire    [31:0]          wr_addr         /* synthesis PAP_MARK_DEBUG=”true”*/,
    output  wire    [15:0]          wr_data         /* synthesis PAP_MARK_DEBUG=”true”*/,

    output  wire                    rd_en           /* synthesis PAP_MARK_DEBUG=”true”*/,
    output  wire    [31:0]          rd_addr         /* synthesis syn_keep=1 *//* synthesis PAP_MARK_DEBUG=”true”*/,
    input   wire    [15:0]          rd_data         /* synthesis PAP_MARK_DEBUG=”true”*/
);


localparam  AXIS_SLAVE_NUM = 3      ;  //@IPC enum 1 2 3

//RESET DEBOUNCE and SYNC
wire            sync_button_rst_n       ;
wire            s_pclk_rstn             ;
wire            s_pclk_div2_rstn        ;


//********************** internal signal
//clk and rst
wire            pclk                    ;
wire            ref_clk                 ;
//AXIS master interface
wire            axis_master_tvalid      /* synthesis PAP_MARK_DEBUG=”true”*/;
wire            axis_master_tready      /* synthesis PAP_MARK_DEBUG=”true”*/;
wire    [127:0] axis_master_tdata       /* synthesis PAP_MARK_DEBUG=”true”*/;
wire    [3:0]   axis_master_tkeep       /* synthesis PAP_MARK_DEBUG=”true”*/;
wire            axis_master_tlast       /* synthesis PAP_MARK_DEBUG=”true”*/;
wire    [7:0]   axis_master_tuser       /* synthesis PAP_MARK_DEBUG=”true”*/;

//axis slave 0 interface
wire            axis_slave0_tready      /* synthesis PAP_MARK_DEBUG=”true”*/;
wire            axis_slave0_tvalid      /* synthesis PAP_MARK_DEBUG=”true”*/;
wire    [127:0] axis_slave0_tdata       /* synthesis PAP_MARK_DEBUG=”true”*/;
wire            axis_slave0_tlast       /* synthesis PAP_MARK_DEBUG=”true”*/;
wire            axis_slave0_tuser       /* synthesis PAP_MARK_DEBUG=”true”*/;

//axis slave 1 interface
wire            axis_slave1_tready      /* synthesis PAP_MARK_DEBUG=”true”*/;
wire            axis_slave1_tvalid      /* synthesis PAP_MARK_DEBUG=”true”*/;
wire    [127:0] axis_slave1_tdata       /* synthesis PAP_MARK_DEBUG=”true”*/;
wire            axis_slave1_tlast       /* synthesis PAP_MARK_DEBUG=”true”*/;
wire            axis_slave1_tuser       /* synthesis PAP_MARK_DEBUG=”true”*/;

//axis slave 2 interface
wire            axis_slave2_tready      /* synthesis PAP_MARK_DEBUG=”true”*/;
wire            axis_slave2_tvalid      /* synthesis PAP_MARK_DEBUG=”true”*/;
wire    [127:0] axis_slave2_tdata       /* synthesis PAP_MARK_DEBUG=”true”*/;
wire            axis_slave2_tlast       /* synthesis PAP_MARK_DEBUG=”true”*/;
wire            axis_slave2_tuser       /* synthesis PAP_MARK_DEBUG=”true”*/;

wire    [7:0]   cfg_pbus_num            ;
wire    [4:0]   cfg_pbus_dev_num        ;
wire    [2:0]   cfg_max_rd_req_size     ;
wire    [2:0]   cfg_max_payload_size    ;
wire            cfg_rcb                 ;

//system signal
wire    [4:0]   smlh_ltssm_state        /* synthesis PAP_MARK_DEBUG=”true”*/;

// led lights up
reg     [22:0]  ref_led_cnt             ;
reg     [26:0]  pclk_led_cnt            ;
reg     [26:0]  pclk_div2_led_cnt       ;

//uart2apb 32bits
wire            uart_p_sel              ;
wire    [3:0]   uart_p_strb             ;
wire    [15:0]  uart_p_addr             ;
wire    [31:0]  uart_p_wdata            ;
wire            uart_p_ce               ;
wire            uart_p_we               ;
wire            uart_p_rdy              ;
wire    [31:0]  uart_p_rdata            ;

//----------------------------------------------------------rst debounce ----------------------------------------------------------
//ASYNC RST  define IPS2L_PCIE_SPEEDUP_SIM when simulation

hsst_rst_cross_sync_v1_0 #(
    `ifdef IPS2L_PCIE_SPEEDUP_SIM
    .RST_CNTR_VALUE     (16'h10             )
    `else
    .RST_CNTR_VALUE     (16'hC000           )
    `endif
)
u_refclk_buttonrstn_debounce(
    .clk                (ref_clk            ),
    .rstn_in            (button_rst_n       ),
    .rstn_out           (sync_button_rst_n  )
);

hsst_rst_cross_sync_v1_0 #(
    `ifdef IPS2L_PCIE_SPEEDUP_SIM
    .RST_CNTR_VALUE     (16'h10             )
    `else
    .RST_CNTR_VALUE     (16'hC000           )
    `endif
)
u_refclk_perstn_debounce(
    .clk                (ref_clk            ),
    .rstn_in            (perst_n            ),
    .rstn_out           (sync_perst_n       )
);

ipsl_pcie_sync_v1_0  u_ref_core_rstn_sync    (
    .clk                (ref_clk            ),
    .rst_n              (core_rst_n         ),
    .sig_async          (1'b1               ),
    .sig_synced         (ref_core_rst_n     )
);

ipsl_pcie_sync_v1_0  u_pclk_core_rstn_sync   (
    .clk                (pclk               ),
    .rst_n              (core_rst_n         ),
    .sig_async          (1'b1               ),
    .sig_synced         (s_pclk_rstn        )
);

ipsl_pcie_sync_v1_0  u_pclk_div2_core_rstn_sync   (
    .clk                (pclk_div2          ),
    .rst_n              (core_rst_n         ),
    .sig_async          (1'b1               ),
    .sig_synced         (s_pclk_div2_rstn   )
);

//----------------------------------------------------------clk led ----------------------------------------------------------
always @(posedge ref_clk or negedge sync_perst_n)
begin
    if (!sync_perst_n)
        ref_led_cnt    <= 23'd0;
    else
        ref_led_cnt    <= ref_led_cnt + 23'd1;
end

always @(posedge ref_clk or negedge sync_perst_n)
begin
    if (!sync_perst_n)
        ref_led        <= 1'b1;
    else if(&ref_led_cnt)
        ref_led        <= ~ref_led;
end

always @(posedge pclk or negedge s_pclk_rstn)
begin
    if (!s_pclk_rstn)
        pclk_led_cnt    <= 27'd0;
    else
        pclk_led_cnt    <= pclk_led_cnt + 27'd1;
end

always @(posedge pclk or negedge s_pclk_rstn)
begin
    if (!s_pclk_rstn)
        pclk_led        <= 1'b1;
    else if(&pclk_led_cnt)
        pclk_led        <= ~pclk_led;
end

always @(posedge pclk_div2 or negedge s_pclk_div2_rstn)
begin
    if (!s_pclk_div2_rstn)
        pclk_div2_led_cnt    <= 27'd0;
    else
        pclk_div2_led_cnt    <= pclk_div2_led_cnt + 27'd1;
end

always @(posedge pclk_div2 or negedge s_pclk_div2_rstn)
begin
    if (!s_pclk_div2_rstn)
        pclk_div2_led        <= 1'b1;
    else if(&pclk_div2_led_cnt)
        pclk_div2_led        <= ~pclk_div2_led;
end

//----------------------------------------------------------   dma  ----------------------------------------------------------
     
wire                        ven_msi_req        ;  
wire                        cfg_msi_en         ;     
wire                        ven_msi_grant      ; 
wire    [2:0]               ven_msi_tc         ; 
wire    [4:0]               ven_msi_vector     ; 
wire    [31:0]              cfg_msi_pending    ; 


	
	
// DMA CTRL      BASE ADDR = 0x8000
rt_pcie_dma #(
    .AXIS_SLAVE_NUM         (AXIS_SLAVE_NUM         )
)
u_rt_pcie_dma
(
    .clk                    (pclk_div2              ),  //gen1:62.5MHz,gen2:125MHz
    .rst_n                  (core_rst_n             ),
    //num
    .i_cfg_pbus_num         (cfg_pbus_num           ),  //input [7:0]
    .i_cfg_pbus_dev_num     (cfg_pbus_dev_num       ),  //input [4:0]
    .i_cfg_max_rd_req_size  (cfg_max_rd_req_size    ),  //input [2:0]
    .i_cfg_max_payload_size (cfg_max_payload_size   ),  //input [2:0]
    //**********************************************************************
    //axis master interface
    .i_axis_master_tvld     (axis_master_tvalid     ),
    .o_axis_master_trdy     (axis_master_tready     ),
    .i_axis_master_tdata    (axis_master_tdata      ),
    .i_axis_master_tkeep    (axis_master_tkeep      ),
    .i_axis_master_tlast    (axis_master_tlast      ),
    .i_axis_master_tuser    (axis_master_tuser      ),

    //**********************************************************************
    //axis_slave0 interface
    .i_axis_slave0_trdy     (axis_slave0_tready     ),
    .o_axis_slave0_tvld     (axis_slave0_tvalid     ),
    .o_axis_slave0_tdata    (axis_slave0_tdata      ),
    .o_axis_slave0_tlast    (axis_slave0_tlast      ),
    .o_axis_slave0_tuser    (axis_slave0_tuser      ),
    //axis_slave1 interface
    .i_axis_slave1_trdy     (axis_slave1_tready     ),
    .o_axis_slave1_tvld     (axis_slave1_tvalid     ),
    .o_axis_slave1_tdata    (axis_slave1_tdata      ),
    .o_axis_slave1_tlast    (axis_slave1_tlast      ),
    .o_axis_slave1_tuser    (axis_slave1_tuser      ),
    //axis_slave2 interface
    .i_axis_slave2_trdy     (axis_slave2_tready     ),
    .o_axis_slave2_tvld     (axis_slave2_tvalid     ),
    .o_axis_slave2_tdata    (axis_slave2_tdata      ),
    .o_axis_slave2_tlast    (axis_slave2_tlast      ),
    .o_axis_slave2_tuser    (axis_slave2_tuser      ),
    //**********************************************************************
	//msi interface 
    .cfg_msi_en             (cfg_msi_en             ),
    .ven_msi_grant	        (ven_msi_grant          ),
    .ven_msi_req            (ven_msi_req            ),
	.ven_msi_tc             (ven_msi_tc             ),
    .ven_msi_vector         (ven_msi_vector         ),
    .cfg_msi_pending        (cfg_msi_pending        ),
    //**********************************************************************	
	.o_wr_en                (wr_en                  ),
    .o_wr_byte_en           (wr_byte_en             ),
    .o_wr_addr              (wr_addr                ),
    .o_wr_data              (wr_data                ),
	                        
	.o_rd_en                (rd_en                ),
    .o_rd_addr              (rd_addr              ),
    .i_rd_data              (rd_data              )
);



//----------------------------------------------------------   pcie wrap  ----------------------------------------------------------
//pcie wrap : HSSTLP : 0x0000~6000 PCIe BASE ADDR : 0x7000

PCIE_IP
u_ipsl_pcie_wrap
(
    .button_rst_n               (sync_button_rst_n      ),
    .power_up_rst_n             (sync_perst_n           ),
    .perst_n                    (sync_perst_n           ),
    //clk and rst
    .pclk                       (pclk                   ),      //output
    .pclk_div2                  (pclk_div2              ),      //output
    .free_clk                   (free_clk               ),
    .ref_clk                    (ref_clk                ),      //output
    .ref_clk_n                  (ref_clk_n              ),      //input
    .ref_clk_p                  (ref_clk_p              ),      //input
    .core_rst_n                 (core_rst_n             ),      //output
    
    //APB interface to  DBI cfg
    //.p_clk                      (ref_clk                ),      //input
    .p_sel                      ('d0                    ),      //input
    .p_strb                     ('d0                    ),      //input  [ 3:0]
    .p_addr                     ('d0                    ),      //input  [15:0]
    .p_wdata                    ('d0                    ),      //input  [31:0]
    .p_ce                       ('d0                    ),      //input
    .p_we                       ('d0                    ),      //input
    .p_rdy                      (                       ),      //output
    .p_rdata                    (                       ),      //output [31:0]
   
    //PHY diff signals
    .rxn                        (rxn                    ),      //input   [3:0]
    .rxp                        (rxp                    ),      //input   [3:0]
    .txn                        (txn                    ),      //output  [3:0]
    .txp                        (txp                    ),      //output  [3:0]
    .pcs_nearend_loop           ({4{1'b0}}              ),      //input
    .pma_nearend_ploop          ({4{1'b0}}              ),      //input
    .pma_nearend_sloop          ({4{1'b0}}              ),      //input
    //AXIS master interface
    .axis_master_tvalid         (axis_master_tvalid     ),      //output
    .axis_master_tready         (axis_master_tready     ),      //input
    .axis_master_tdata          (axis_master_tdata      ),      //output [127:0]
    .axis_master_tkeep          (axis_master_tkeep      ),      //output [3:0]
    .axis_master_tlast          (axis_master_tlast      ),      //output
    .axis_master_tuser          (axis_master_tuser      ),      //output [7:0]
    
    //axis slave 0 interface
    .axis_slave0_tready         (axis_slave0_tready     ),      //output
    .axis_slave0_tvalid         (axis_slave0_tvalid     ),      //input
    .axis_slave0_tdata          (axis_slave0_tdata      ),      //input  [127:0]
    .axis_slave0_tlast          (axis_slave0_tlast      ),      //input
    .axis_slave0_tuser          (axis_slave0_tuser      ),      //input
    
    //axis slave 1 interface
    .axis_slave1_tready         (axis_slave1_tready     ),      //output
    .axis_slave1_tvalid         (axis_slave1_tvalid     ),      //input
    .axis_slave1_tdata          (axis_slave1_tdata      ),      //input  [127:0]
    .axis_slave1_tlast          (axis_slave1_tlast      ),      //input
    .axis_slave1_tuser          (axis_slave1_tuser      ),      //input
    //axis slave 2 interface
    .axis_slave2_tready         (axis_slave2_tready     ),      //output
    .axis_slave2_tvalid         (axis_slave2_tvalid     ),      //input
    .axis_slave2_tdata          (axis_slave2_tdata      ),      //input  [127:0]
    .axis_slave2_tlast          (axis_slave2_tlast      ),      //input
    .axis_slave2_tuser          (axis_slave2_tuser      ),      //input
     
    .pm_xtlh_block_tlp          (                       ),      //output


    .cfg_send_cor_err_mux       (                       ),      //output
    .cfg_send_nf_err_mux        (                       ),      //output
    .cfg_send_f_err_mux         (                       ),      //output
    .cfg_sys_err_rc             (                       ),      //output
    .cfg_aer_rc_err_mux         (                       ),      //output
    //radm timeout
    .radm_cpl_timeout           (                       ),      //output
    
    //configuration signals
    .cfg_max_rd_req_size        (cfg_max_rd_req_size    ),      //output [2:0]
    .cfg_bus_master_en          (                       ),      //output
    .cfg_max_payload_size       (cfg_max_payload_size   ),      //output [2:0]
    .cfg_ext_tag_en             (                       ),      //output
    .cfg_rcb                    (cfg_rcb                ),      //output
    .cfg_mem_space_en           (                       ),      //output
    .cfg_pm_no_soft_rst         (                       ),      //output
    .cfg_crs_sw_vis_en          (                       ),      //output
    .cfg_no_snoop_en            (                       ),      //output
    .cfg_relax_order_en         (                       ),      //output
    .cfg_tph_req_en             (                       ),      //output [2-1:0]
    .cfg_pf_tph_st_mode         (                       ),      //output [3-1:0]
    .rbar_ctrl_update           (                       ),      //output
    .cfg_atomic_req_en          (                       ),      //output
    
    .cfg_pbus_num               (cfg_pbus_num           ),      //output [7:0]
    .cfg_pbus_dev_num           (cfg_pbus_dev_num       ),      //output [4:0]
    
    //debug signals
    .radm_idle                  (                       ),      //output
    .radm_q_not_empty           (                       ),      //output
    .radm_qoverflow             (                       ),      //output
    .diag_ctrl_bus              (2'b0                   ),      //input   [1:0]
    .cfg_link_auto_bw_mux       (                       ),      //output              merge cfg_link_auto_bw_msi and cfg_link_auto_bw_int
    .cfg_bw_mgt_mux             (                       ),      //output              merge cfg_bw_mgt_int and cfg_bw_mgt_msi
    .cfg_pme_mux                (                       ),      //output              merge cfg_pme_int and cfg_pme_msi
    .app_ras_des_sd_hold_ltssm  (1'b0                   ),      //input
    .app_ras_des_tba_ctrl       (2'b0                   ),      //input   [1:0]
    
    .dyn_debug_info_sel         (4'b0                   ),      //input   [3:0]
    .debug_info_mux             (                       ),      //output  [132:0]
    
    //system signal
    .smlh_link_up               (smlh_link_up           ),      //output
    .rdlh_link_up               (rdlh_link_up           ),      //output
    .smlh_ltssm_state           (smlh_ltssm_state       )       //output  [4:0]
);
endmodule
