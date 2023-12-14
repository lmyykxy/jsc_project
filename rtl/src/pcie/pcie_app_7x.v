`timescale 1ns/1ns

module pcie_app_7x #(
	parameter C_DATA_WIDTH = 128,	// RX/TX interface data width
	parameter C_NUM_CHNL = 4'd1, 			// Number of RIFFA channels (set as needed: 1-12)
	parameter C_MAX_READ_REQ_BYTES = 512,	// Max size of read requests (in bytes). Setting this higher than PCIe Endpoint's MAX READ value just wastes resources
	parameter C_TAG_WIDTH = 5 				// Number of outstanding tag requests
)
(
	input	wire	free_clk		,
	output	wire	pclk_led		,
	output	wire	pclk_div2_led	,

	output	wire	ref_clk_led		,
	input	wire	ref_clk_n		,
	input	wire	ref_clk_p		,

	input	wire	button_rst_n	,
	input	wire	power_up_rst_n	,
	input	wire	perst_n			,

	output	wire	smlh_link_up	,
	output	wire	rdlh_link_up	,

	output  [1:0]    txp			,
  	output  [1:0]    txn			,
  	input   [1:0]    rxp			,
  	input   [1:0]    rxn			,

    output chnl_rx_data,
    output CHNL_RX_DATA_VALID_out,
    output chnl_rx_clk,

    input chnl_tx_data_in,
    output chnl_tx_data_valid_in,
    input chnl_tx_data_almost_empty,
    output rState

);


wire ref_clk;
wire pclk;

`define PCI_EXP_EP_OUI		24'h000A35
`define PCI_EXP_EP_DSN_1	{{8'h1},`PCI_EXP_EP_OUI}
`define PCI_EXP_EP_DSN_2	32'h00000001

//
// RIFFA channel interface
wire	[C_NUM_CHNL-1:0]						chnl_rx_clk;
wire	[C_NUM_CHNL-1:0]						chnl_rx/* synthesis PAP_MARK_DEBUG="1" */;
wire	[C_NUM_CHNL-1:0]						chnl_rx_ack/* synthesis PAP_MARK_DEBUG="1" */;
wire	[C_NUM_CHNL-1:0]						chnl_rx_last/* synthesis PAP_MARK_DEBUG="1" */;
wire	[(C_NUM_CHNL*32)-1:0]					chnl_rx_len/* synthesis PAP_MARK_DEBUG="1" */;
wire	[(C_NUM_CHNL*31)-1:0]					chnl_rx_off/* synthesis PAP_MARK_DEBUG="1" */;
wire	[(C_NUM_CHNL*C_DATA_WIDTH)-1:0]			chnl_rx_data/* synthesis PAP_MARK_DEBUG="1" */;
wire	[C_NUM_CHNL-1:0]						chnl_rx_data_valid/* synthesis PAP_MARK_DEBUG="1" */;
wire	[C_NUM_CHNL-1:0]						chnl_rx_data_ren/* synthesis PAP_MARK_DEBUG="1" */;
	
wire	[C_NUM_CHNL-1:0]						CHNL_RX_DATA_VALID_out/* synthesis PAP_MARK_DEBUG="1" */;

wire	[C_NUM_CHNL-1:0]						chnl_tx_clk;
wire	[C_NUM_CHNL-1:0]						chnl_tx;
wire	[C_NUM_CHNL-1:0]						chnl_tx_ack;
wire	[C_NUM_CHNL-1:0]						chnl_tx_last;
wire	[(C_NUM_CHNL*32)-1:0]					chnl_tx_len;
wire	[(C_NUM_CHNL*31)-1:0]					chnl_tx_off;
wire	[(C_NUM_CHNL*C_DATA_WIDTH)-1:0]			chnl_tx_data;
wire	[C_NUM_CHNL-1:0]						chnl_tx_data_valid;
wire	[C_NUM_CHNL-1:0]						chnl_tx_data_ren;

wire	[(C_NUM_CHNL*C_DATA_WIDTH)-1:0]			chnl_tx_data_in;
wire	[C_NUM_CHNL-1:0]						chnl_tx_data_valid_in;
wire	[C_NUM_CHNL-1:0]						chnl_tx_data_almost_empty;
wire	[(C_NUM_CHNL*2)-1:0]                        rState;
// riffa_pango_mid Inputs
wire   pclk_div2;
wire   core_rst_n;
wire   [127:0]  axis_master_tdata;
wire   axis_master_tlast;
wire   [3:0]  axis_master_tkeep;
wire   axis_master_tvalid;
wire   [7:0]  axis_master_tuser;
wire   axis_slave0_tready;
wire   [2:0]  cfg_max_rd_req_size;
wire   cfg_bus_master_en;
wire   [2:0]  cfg_max_payload_size;
wire   cfg_rcb;
wire   [7:0]  cfg_pbus_num;
wire   [4:0]  cfg_pbus_dev_num;
wire   ven_msi_grant;
wire  cfg_msi_en;
wire   [7:0]  xadm_cplh_cdts;
wire   [11:0]  xadm_cpld_cdts;
wire   M_AXIS_RX_TREADY;
wire   [127:0]  S_AXIS_TX_TDATA;
wire   [15:0]  S_AXIS_TX_TKEEP;
wire   S_AXIS_TX_TLAST;
wire   S_AXIS_TX_TVALID;
wire   S_AXIS_SRC_DSC;
wire   CFG_INTERRUPT;

// riffa_pango_mid Outputs
wire  axis_master_tready;
wire  [127:0]  axis_slave0_tdata/* synthesis PAP_MARK_DEBUG="1" */;
wire  axis_slave0_tvalid;
wire  axis_slave0_tlast;
wire  axis_slave0_tuser;
wire  ven_msi_req;
wire  user_clk;
wire  reset;
wire  [127:0]  M_AXIS_RX_TDATA/* synthesis PAP_MARK_DEBUG="1" */;
wire  [15:0]  M_AXIS_RX_TKEEP/* synthesis PAP_MARK_DEBUG="1" */;
wire  M_AXIS_RX_TLAST/* synthesis PAP_MARK_DEBUG="1" */;
wire  M_AXIS_RX_TVALID/* synthesis PAP_MARK_DEBUG="1" */;
wire  [4:0]  IS_SOF;
wire  [4:0]  IS_EOF;
wire  RERR_FWD;
wire  S_AXIS_TX_TREADY;
wire  [15:0]  COMPLETER_ID;
wire  CFG_BUS_MSTR_ENABLE;
wire  [5:0]  CFG_LINK_WIDTH;
wire  [1:0]  CFG_LINK_RATE;
wire  [2:0]  MAX_READ_REQUEST_SIZE;
wire  [2:0]  MAX_PAYLOAD_SIZE;
wire  CFG_INTERRUPT_MSIEN;
wire  CFG_INTERRUPT_RDY;
wire  RCB;
wire  [11:0]  MAX_RC_CPLD;
wire  [7:0]  MAX_RC_CPLH;

wire riffa_reset;

riffa_pango_mid  u_riffa_pango_mid (
    .pclk_div2               ( pclk_div2               ),
    .core_rst_n              ( core_rst_n              ),
    .axis_master_tdata       ( axis_master_tdata       ),
    .axis_master_tlast       ( axis_master_tlast       ),
    .axis_master_tkeep       ( axis_master_tkeep       ),
    .axis_master_tvalid      ( axis_master_tvalid      ),
    .axis_master_tuser       ( axis_master_tuser       ),
    .axis_slave0_tready      ( axis_slave0_tready      ),
    .cfg_max_rd_req_size     ( cfg_max_rd_req_size     ),
    .cfg_bus_master_en       ( cfg_bus_master_en       ),
    .cfg_max_payload_size    ( cfg_max_payload_size    ),
    .cfg_rcb                 ( cfg_rcb                 ),
    .cfg_pbus_num            ( cfg_pbus_num            ),
    .cfg_pbus_dev_num        ( cfg_pbus_dev_num        ),
    .ven_msi_grant           ( ven_msi_grant           ),
    .cfg_msi_en              ( cfg_msi_en              ),
    .xadm_cplh_cdts          ( xadm_cplh_cdts          ),
    .xadm_cpld_cdts          ( xadm_cpld_cdts          ),
    .M_AXIS_RX_TREADY        ( M_AXIS_RX_TREADY        ),
    .S_AXIS_TX_TDATA         ( S_AXIS_TX_TDATA         ),
    .S_AXIS_TX_TKEEP         ( S_AXIS_TX_TKEEP         ),
    .S_AXIS_TX_TLAST         ( S_AXIS_TX_TLAST         ),
    .S_AXIS_TX_TVALID        ( S_AXIS_TX_TVALID        ),
    .S_AXIS_SRC_DSC          ( S_AXIS_SRC_DSC          ),
    .CFG_INTERRUPT           ( CFG_INTERRUPT           ),

    .axis_master_tready      ( axis_master_tready      ),
    .axis_slave0_tdata       ( axis_slave0_tdata       ),
    .axis_slave0_tvalid      ( axis_slave0_tvalid      ),
    .axis_slave0_tlast       ( axis_slave0_tlast       ),
    .axis_slave0_tuser       ( axis_slave0_tuser       ),
    .ven_msi_req             ( ven_msi_req             ),
    .user_clk                ( user_clk                ),
    .reset                   ( reset                   ),
    .M_AXIS_RX_TDATA         ( M_AXIS_RX_TDATA         ),
    .M_AXIS_RX_TKEEP         ( M_AXIS_RX_TKEEP         ),
    .M_AXIS_RX_TLAST         ( M_AXIS_RX_TLAST         ),
    .M_AXIS_RX_TVALID        ( M_AXIS_RX_TVALID        ),
    .IS_SOF                  ( IS_SOF                  ),
    .IS_EOF                  ( IS_EOF                  ),
    .RERR_FWD                ( RERR_FWD                ),
    .S_AXIS_TX_TREADY        ( S_AXIS_TX_TREADY        ),
    .COMPLETER_ID            ( COMPLETER_ID            ),
    .CFG_BUS_MSTR_ENABLE     ( CFG_BUS_MSTR_ENABLE     ),
    .CFG_LINK_WIDTH          ( CFG_LINK_WIDTH          ),
    .CFG_LINK_RATE           ( CFG_LINK_RATE           ),
    .MAX_READ_REQUEST_SIZE   ( MAX_READ_REQUEST_SIZE   ),
    .MAX_PAYLOAD_SIZE        ( MAX_PAYLOAD_SIZE        ),
    .CFG_INTERRUPT_MSIEN     ( CFG_INTERRUPT_MSIEN     ),
    .CFG_INTERRUPT_RDY       ( CFG_INTERRUPT_RDY       ),
    .RCB                     ( RCB                     ),
    .MAX_RC_CPLD             ( MAX_RC_CPLD             ),
    .MAX_RC_CPLH             ( MAX_RC_CPLH             )
);

PCIE_IP pango_pcie (
  .free_clk						(free_clk),                         // input
  .pclk							(pclk),                             // output
  .pclk_div2					(pclk_div2),                        // output
  .ref_clk						(ref_clk),                          // output
  .ref_clk_n					(ref_clk_n),                        // input
  .ref_clk_p					(ref_clk_p),                        // input
  .button_rst_n					(button_rst_n),                     // input
  .power_up_rst_n				(perst_n),                   // input
  .perst_n						(perst_n),                          // input
  .core_rst_n					(core_rst_n),                       // output
  .smlh_link_up					(smlh_link_up),                     // output
  .rdlh_link_up					(rdlh_link_up),                     // output
  .smlh_ltssm_state				(),                 				// output [4:0]
  
  .p_sel						(0),                            	// input
  .p_strb						('d0),                           	// input [3:0]
  .p_addr						('d0),                           	// input [15:0]
  .p_wdata						('d0),                          	// input [31:0]
  .p_ce							('d0),                             	// input
  .p_we							('d0),                             	// input
  .p_rdy						(),                            		// output
  .p_rdata						(),                          		// output [31:0]

  .rxn							(rxn),                              // input [1:0]
  .rxp							(rxp),                              // input [1:0]
  .txn							(txn),                              // output [1:0]
  .txp							(txp),                              // output [1:0]
  .pcs_nearend_loop				({4{1'b0}}),                 				// input [1:0]
  .pma_nearend_ploop			({4{1'b0}}),                					// input [1:0]
  .pma_nearend_sloop			({4{1'b0}}),                					// input [1:0]
  .axis_master_tvalid			(axis_master_tvalid),               // output
  .axis_master_tready			(axis_master_tready),               // input
  .axis_master_tdata			(axis_master_tdata),                // output [127:0]
  .axis_master_tkeep			(axis_master_tkeep),                // output [3:0]
  .axis_master_tlast			(axis_master_tlast),                // output
  .axis_master_tuser			(axis_master_tuser),                // output [7:0]
  .axis_slave0_tready			(axis_slave0_tready),               // output
  .axis_slave0_tvalid			(axis_slave0_tvalid),               // input
  .axis_slave0_tdata			(axis_slave0_tdata),                // input [127:0]
  .axis_slave0_tlast			(axis_slave0_tlast),                // input
  .axis_slave0_tuser			(axis_slave0_tuser),                // input
  .axis_slave1_tready			(),               					// output
  .axis_slave1_tvalid			('d0),               				// input
  .axis_slave1_tdata			('d0),                				// input [127:0]
  .axis_slave1_tlast			('d0),                				// input
  .axis_slave1_tuser			('d0),                				// input
  .axis_slave2_tready			(),               					// output
  .axis_slave2_tvalid			('d0),               				// input
  .axis_slave2_tdata			('d0),                				// input [127:0]
  .axis_slave2_tlast			('d0),                				// input
  .axis_slave2_tuser			('d0),                				// input

  .pm_xtlh_block_tlp			(),                					// output

  .cfg_send_cor_err_mux			(),             					// output
  .cfg_send_nf_err_mux			(),              					// output
  .cfg_send_f_err_mux			(),               					// output
  .cfg_sys_err_rc				(),                  				// output
  .cfg_aer_rc_err_mux			(),               					// output

  .radm_cpl_timeout				(),                 				// output

  .cfg_max_rd_req_size			(cfg_max_rd_req_size),              // output [2:0]
  .cfg_bus_master_en			(cfg_bus_master_en),                // output
  .cfg_max_payload_size			(cfg_max_payload_size),             // output [2:0]
  .cfg_ext_tag_en				(),                   				// output
  .cfg_rcb						(cfg_rcb),                          // output
  .cfg_mem_space_en				(),                 				// output
  .cfg_pm_no_soft_rst			(),               					// output
  .cfg_crs_sw_vis_en			(),                					// output
  .cfg_no_snoop_en				(),                  				// output
  .cfg_relax_order_en			(),               					// output
  .cfg_tph_req_en				(),                   				// output [1:0]
  .cfg_pf_tph_st_mode			(),               					// output [2:0]
  .cfg_pbus_num					(cfg_pbus_num),                     // output [7:0]
  .cfg_pbus_dev_num				(cfg_pbus_dev_num),                 // output [4:0]
  .rbar_ctrl_update				(),                 				// output
  .cfg_atomic_req_en			(),                					// output

  .ven_msi_grant				(ven_msi_grant),//o
  .cfg_msi_en					(cfg_msi_en),//o
  .ven_msi_req					(ven_msi_req),//i

  .radm_idle					(),                        			// output
  .radm_q_not_empty				(),                 				// output
  .radm_qoverflow				(),                   				// output
  .diag_ctrl_bus				('d0),                    			// input [1:0]
  .dyn_debug_info_sel			('d0),               				// input [3:0]
  .cfg_link_auto_bw_mux			(),             					// output
  .cfg_bw_mgt_mux				(),                   				// output
  .cfg_pme_mux					(),                      			// output
  .debug_info_mux				(),                   				// output [132:0]
  .app_ras_des_sd_hold_ltssm	('d0),    							// input
  .app_ras_des_tba_ctrl			('d0),             					// input [1:0]

  .xadm_cplh_cdts				(xadm_cplh_cdts),                   // output [7:0]
  .xadm_cpld_cdts				(xadm_cpld_cdts)                    // output [11:0]
);

riffa_endpoint #(
	.C_PCI_DATA_WIDTH(C_DATA_WIDTH),
	.C_NUM_CHNL(C_NUM_CHNL),
	.C_MAX_READ_REQ_BYTES(C_MAX_READ_REQ_BYTES),
	.C_TAG_WIDTH(C_TAG_WIDTH),
	.C_ALTERA(0)
) endpoint (
	.CLK(user_clk),
	.RST_IN(reset),
	.RST_OUT(riffa_reset),

	.M_AXIS_RX_TDATA(M_AXIS_RX_TDATA),
	.M_AXIS_RX_TKEEP(M_AXIS_RX_TKEEP),
	.M_AXIS_RX_TLAST(M_AXIS_RX_TLAST),
	.M_AXIS_RX_TVALID(M_AXIS_RX_TVALID),
	.M_AXIS_RX_TREADY(M_AXIS_RX_TREADY),
	.IS_SOF(IS_SOF),
	.IS_EOF(IS_EOF),
	.RERR_FWD(RERR_FWD),
	
	.S_AXIS_TX_TDATA(S_AXIS_TX_TDATA),
	.S_AXIS_TX_TKEEP(S_AXIS_TX_TKEEP),
	.S_AXIS_TX_TLAST(S_AXIS_TX_TLAST),
	.S_AXIS_TX_TVALID(S_AXIS_TX_TVALID),
	.S_AXIS_SRC_DSC(S_AXIS_SRC_DSC),
	.S_AXIS_TX_TREADY(S_AXIS_TX_TREADY),

	.COMPLETER_ID(COMPLETER_ID),
	.CFG_BUS_MSTR_ENABLE(CFG_BUS_MSTR_ENABLE),
	.CFG_LINK_WIDTH(CFG_LINK_WIDTH),
	.CFG_LINK_RATE(CFG_LINK_RATE),
	.MAX_READ_REQUEST_SIZE(MAX_READ_REQUEST_SIZE),
	.MAX_PAYLOAD_SIZE(MAX_PAYLOAD_SIZE), 
	.CFG_INTERRUPT_MSIEN(CFG_INTERRUPT_MSIEN),
	.CFG_INTERRUPT_RDY(CFG_INTERRUPT_RDY),
	.CFG_INTERRUPT(CFG_INTERRUPT),
	.RCB(RCB),
	.MAX_RC_CPLD(MAX_RC_CPLD),
	.MAX_RC_CPLH(MAX_RC_CPLH),

	.RX_ST_DATA(bus_zero),
	.RX_ST_EOP(1'd0),
	.RX_ST_SOP(1'd0),
	.RX_ST_VALID(1'd0),
	.RX_ST_READY(),
	.RX_ST_EMPTY(1'd0),

	.TX_ST_DATA(),
	.TX_ST_VALID(),
	.TX_ST_READY(1'd0),
	.TX_ST_EOP(),
	.TX_ST_SOP(),
	.TX_ST_EMPTY(),
	.TL_CFG_CTL(32'd0),
	.TL_CFG_ADD(4'd0),
	.TL_CFG_STS(53'd0),

	.APP_MSI_ACK(1'd0),
	.APP_MSI_REQ(),
	
	.CHNL_RX_CLK(chnl_rx_clk), 
	.CHNL_RX(chnl_rx), 
	.CHNL_RX_ACK(chnl_rx_ack),
	.CHNL_RX_LAST(chnl_rx_last), 
	.CHNL_RX_LEN(chnl_rx_len), 
	.CHNL_RX_OFF(chnl_rx_off), 
	.CHNL_RX_DATA(chnl_rx_data), 
	.CHNL_RX_DATA_VALID(chnl_rx_data_valid), 
	.CHNL_RX_DATA_REN(chnl_rx_data_ren),
	
	.CHNL_TX_CLK(chnl_tx_clk), 
	.CHNL_TX(chnl_tx), 
	.CHNL_TX_ACK(chnl_tx_ack),
	.CHNL_TX_LAST(chnl_tx_last), 
	.CHNL_TX_LEN(chnl_tx_len), 
	.CHNL_TX_OFF(chnl_tx_off), 
	.CHNL_TX_DATA(chnl_tx_data), 
	.CHNL_TX_DATA_VALID(chnl_tx_data_valid), 
	.CHNL_TX_DATA_REN(chnl_tx_data_ren)
);

genvar i;
generate
	for (i = 0; i < C_NUM_CHNL; i = i + 1) begin : test_channels
		chnl_tester #(C_DATA_WIDTH) module1 (
			.CLK(user_clk),
			.RST(riffa_reset),	// riffa_reset includes riffa_endpoint resets
			// Rx interface
			.CHNL_RX_CLK(chnl_rx_clk[i]), 
			.CHNL_RX(chnl_rx[i]), 
			.CHNL_RX_ACK(chnl_rx_ack[i]), 
			.CHNL_RX_LAST(chnl_rx_last[i]), 
			.CHNL_RX_LEN(chnl_rx_len[32*i +:32]), 
			.CHNL_RX_OFF(chnl_rx_off[31*i +:31]), 
			.CHNL_RX_DATA(chnl_rx_data[C_DATA_WIDTH*i +:C_DATA_WIDTH]), 
			.CHNL_RX_DATA_VALID(chnl_rx_data_valid[i]), 
			.CHNL_RX_DATA_REN(chnl_rx_data_ren[i]),
			// Tx interface
			.CHNL_TX_CLK(chnl_tx_clk[i]), 
			.CHNL_TX(chnl_tx[i]), 
			.CHNL_TX_ACK(chnl_tx_ack[i]), 
			.CHNL_TX_LAST(chnl_tx_last[i]), 
			.CHNL_TX_LEN(chnl_tx_len[32*i +:32]), 
			.CHNL_TX_OFF(chnl_tx_off[31*i +:31]), 
			.CHNL_TX_DATA(chnl_tx_data[C_DATA_WIDTH*i +:C_DATA_WIDTH]), 
			.CHNL_TX_DATA_VALID(chnl_tx_data_valid[i]), 
			.CHNL_TX_DATA_REN(chnl_tx_data_ren[i]),

            .CHNL_RX_DATA_VALID_out(CHNL_RX_DATA_VALID_out[i]),
            
            .CHNL_TX_DATA_in(chnl_tx_data_in[C_DATA_WIDTH*i +:C_DATA_WIDTH]),
            .CHNL_TX_DATA_valid_in(chnl_tx_data_valid_in[i]),
            .CHNL_TX_DATA_almost_empty(chnl_tx_data_almost_empty[i]),
            .rState                     (rState[2*i +:2])
		);	
	end
endgenerate


led_blink  u_ref_clk (
    .blink_clk               ( ref_clk   	),
    .sys_rst_n               ( button_rst_n   ),

    .blink_led               ( ref_clk_led   )
);
led_blink  u_pclk (
    .blink_clk               ( pclk   		),
    .sys_rst_n               ( button_rst_n   ),

    .blink_led               ( pclk_led   	)
);
led_blink  u_pclk_div2 (
    .blink_clk               ( pclk_div2   	),
    .sys_rst_n               ( button_rst_n   ),

    .blink_led               ( pclk_div2_led)
);

endmodule
