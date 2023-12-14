module riffa_pango_mid(
    input   wire                pclk_div2               ,
    input   wire                core_rst_n              ,

    input   wire    [127:0]     axis_master_tdata       ,
    input   wire                axis_master_tlast       ,
    input   wire    [3:0]       axis_master_tkeep       ,
    input   wire                axis_master_tvalid      ,
    input   wire    [7:0]       axis_master_tuser       ,
    output  reg                 axis_master_tready      ,

    output  wire     [127:0]     axis_slave0_tdata      ,
    output  wire                 axis_slave0_tvalid     ,
    output  wire                 axis_slave0_tlast      ,
    output  wire                 axis_slave0_tuser      ,
    input   wire                axis_slave0_tready      ,

    input   wire    [2:0]       cfg_max_rd_req_size     ,
    input   wire                cfg_bus_master_en       ,
    input   wire    [2:0]       cfg_max_payload_size    ,
    input   wire                cfg_rcb                 ,
    input   wire    [7:0]       cfg_pbus_num            ,
    input   wire    [4:0]       cfg_pbus_dev_num        ,

    input   wire                ven_msi_grant           ,
    input   wire                cfg_msi_en              ,
    output  reg                 ven_msi_req             ,

    input   wire    [7:0]       xadm_cplh_cdts          ,
    input   wire    [11:0]      xadm_cpld_cdts          ,



    output  reg                 user_clk                ,
    output  reg                 reset                   ,

    output  reg     [127:0]     M_AXIS_RX_TDATA         ,
    output  reg     [15:0]      M_AXIS_RX_TKEEP         ,
    output  reg                 M_AXIS_RX_TLAST         ,
    output  reg                 M_AXIS_RX_TVALID        ,
    input   wire                M_AXIS_RX_TREADY        ,
    output  reg     [4:0]       IS_SOF                  ,
    output  reg     [4:0]       IS_EOF                  ,
    output  reg                 RERR_FWD                ,

    input   wire    [127:0]     S_AXIS_TX_TDATA         ,
    input   wire    [15:0]      S_AXIS_TX_TKEEP         ,
    input   wire                S_AXIS_TX_TLAST         ,
    input   wire                S_AXIS_TX_TVALID        ,
    input   wire                S_AXIS_SRC_DSC          ,
    output  wire                S_AXIS_TX_TREADY        ,

    output  reg     [15:0]      COMPLETER_ID            ,
    output  reg                 CFG_BUS_MSTR_ENABLE     ,
    output  reg     [5:0]       CFG_LINK_WIDTH          ,
    output  reg     [1:0]       CFG_LINK_RATE           ,
    output  reg     [2:0]       MAX_READ_REQUEST_SIZE   ,
    output  reg     [2:0]       MAX_PAYLOAD_SIZE        ,

    output  reg                 CFG_INTERRUPT_MSIEN     ,
    output  reg                 CFG_INTERRUPT_RDY       ,
    input   wire                CFG_INTERRUPT           ,

    output  reg                 RCB                     ,
    output  reg     [11:0]      MAX_RC_CPLD             ,
    output  reg     [7:0]       MAX_RC_CPLH              
);


// pcie接收中间层
localparam  RX_STATE_IDLE   = 4'b0000,
            RX_STATE_3DW_H  = 4'b0001,
            RX_STATE_4DW    = 4'b0010,
            RX_STATE_3DW_D  = 4'b0011;

reg     [3:0]   rx_state, rx_state_next;

reg     [127:0] axis_master_tdata_d1; 
reg             axis_master_tlast_d1; 
reg     [3:0]   axis_master_tkeep_d1; 
reg     [7:0]   axis_master_tuser_d1; 
reg             axis_master_tready_d1;
reg             axis_master_tvalid_d1;
reg             M_AXIS_RX_TLAST_d1;
reg             M_AXIS_RX_TVALID_d1;
wire            m_axis_rx_tvalid_posedge;
wire            M_AXIS_RX_TVALID_posedge_af;
wire            restart;
wire    [1:0]   is_eof_offset;

reg     [3:0]   M_AXIS_RX_TKEEP_MID;

assign m_axis_rx_tvalid_posedge = axis_master_tvalid & ~axis_master_tvalid_d1;
assign M_AXIS_RX_TVALID_posedge_af = M_AXIS_RX_TVALID & ~M_AXIS_RX_TVALID_d1;
assign restart = ((M_AXIS_RX_TLAST_d1 == 1'd1) && (M_AXIS_RX_TVALID == 1'd1)) ? 1'b1 : 1'b0;

always @(posedge pclk_div2 or negedge core_rst_n) begin
    if(!core_rst_n) begin
        rx_state <= 4'b0000;
    end else begin
        rx_state <= rx_state_next;
    end
end

always @(*) begin
    case (rx_state)
        RX_STATE_IDLE: begin
            if(m_axis_rx_tvalid_posedge && axis_master_tdata[61] == 1'd0) begin
                // 3DW
                rx_state_next = RX_STATE_3DW_H;
            end else if (m_axis_rx_tvalid_posedge && axis_master_tdata[61] == 1'd1) begin
                // 4DW
                rx_state_next = RX_STATE_4DW;
            end else begin
                rx_state_next = RX_STATE_IDLE;
            end
        end 

        RX_STATE_3DW_H: begin
            if (axis_master_tlast_d1 == 1'b1 && axis_master_tvalid == 1'b1 && axis_master_tdata[61] == 1'd0) begin
                rx_state_next = RX_STATE_3DW_H;
            end else if((axis_master_tlast == 1'd1 && axis_master_tkeep == 4'b0001) || axis_master_tlast_d1 == 1'b1) begin
                rx_state_next = RX_STATE_IDLE;
            end else begin
                rx_state_next = RX_STATE_3DW_D;
            end
        end

        RX_STATE_4DW: begin
            if(axis_master_tlast_d1 == 1'b1) begin
                rx_state_next = RX_STATE_IDLE;
            end else begin
                rx_state_next = RX_STATE_4DW;                
            end
        end

        RX_STATE_3DW_D:begin
            if((axis_master_tlast == 1'd1 && axis_master_tkeep == 4'b0001) || (axis_master_tlast_d1 == 1'b1&& axis_master_tvalid == 1'b0)) begin
                rx_state_next = RX_STATE_IDLE;
            end else if(axis_master_tlast_d1 == 1'b1 && axis_master_tvalid == 1'b1 && axis_master_tdata[61] == 1'd0)begin
                rx_state_next = RX_STATE_3DW_H;
            end else begin
                rx_state_next = RX_STATE_3DW_D;
            end            
        end

        default: begin
            rx_state_next = RX_STATE_IDLE;
        end
    endcase
end

always @(posedge pclk_div2 or negedge core_rst_n) begin
    if(!core_rst_n) begin
        M_AXIS_RX_TDATA <= 128'd0;
        M_AXIS_RX_TKEEP_MID <= 4'd0;
        M_AXIS_RX_TVALID <= 1'd0;
        M_AXIS_RX_TLAST <= 1'd0;        
    end else begin
        if(rx_state == RX_STATE_3DW_H) begin
            M_AXIS_RX_TDATA <= {axis_master_tdata[31:0],axis_master_tdata_d1[95:0]};
            if(axis_master_tlast == 1'd1 && axis_master_tkeep == 4'b0001) begin
                M_AXIS_RX_TKEEP_MID <= {1'b1,axis_master_tkeep_d1[3:1]};                
            end else if(axis_master_tlast_d1 == 1'b1) begin
                M_AXIS_RX_TKEEP_MID <= {1'b0,axis_master_tkeep_d1[3:1]};  
            end else begin
                M_AXIS_RX_TKEEP_MID <= {1'b1,axis_master_tkeep_d1[3:1]};  
            end
            M_AXIS_RX_TVALID <= 1'd1;
            if((axis_master_tlast == 1'd1 && axis_master_tkeep == 4'b0001) || axis_master_tlast_d1 == 1'b1) begin
                M_AXIS_RX_TLAST <= 1'd1;
            end else begin
                M_AXIS_RX_TLAST <= 1'd0;
            end
        end else if(rx_state == RX_STATE_3DW_D) begin
            M_AXIS_RX_TDATA <= {axis_master_tdata[31:0],axis_master_tdata_d1[127:32]};
            if(axis_master_tlast == 1'd1 && axis_master_tkeep == 4'b0001) begin
                M_AXIS_RX_TKEEP_MID <= {1'b1,axis_master_tkeep_d1[3:1]};                
            end else if(axis_master_tlast_d1 == 1'b1) begin
                M_AXIS_RX_TKEEP_MID <= {1'b0,axis_master_tkeep_d1[3:1]};  
            end else begin
                M_AXIS_RX_TKEEP_MID <= {1'b1,axis_master_tkeep_d1[3:1]};  
            end

            M_AXIS_RX_TVALID <= 1'd1;
            if((axis_master_tlast == 1'd1 && axis_master_tkeep == 4'b0001) || axis_master_tlast_d1 == 1'b1) begin
                M_AXIS_RX_TLAST <= 1'd1;
            end else begin
                M_AXIS_RX_TLAST <= 1'd0;
            end
        end else if(rx_state == RX_STATE_4DW) begin
            M_AXIS_RX_TDATA <= axis_master_tdata_d1;
            M_AXIS_RX_TKEEP_MID <= axis_master_tkeep_d1;
            M_AXIS_RX_TVALID <= axis_master_tvalid_d1;
            M_AXIS_RX_TLAST <= axis_master_tlast_d1;
        end else begin
            M_AXIS_RX_TDATA <= 128'd0;
            M_AXIS_RX_TKEEP_MID <= 4'd0;
            M_AXIS_RX_TVALID <= 1'd0;
            M_AXIS_RX_TLAST <= 1'd0;
        end
    end 
end

wire [127:0] axis_slave0_tdata_mid;
wire axis_slave0_tvalid_mid,axis_slave0_tlast_mid,axis_slave0_tuser_mid;
reg [127:0] axis_slave0_tdata_mid_i;
reg axis_slave0_tvalid_mid_i,axis_slave0_tlast_mid_i,axis_slave0_tuser_mid_i;
reg [127:0] axis_slave0_tdata_mid_i_d1;
reg axis_slave0_tvalid_mid_i_d1,axis_slave0_tlast_mid_i_d1,axis_slave0_tuser_mid_i_d1;

wire almost_full;

reg [127:0] S_AXIS_TX_TDATA_D1;
reg S_AXIS_TX_TLAST_D1,S_AXIS_TX_TVALID_D1,S_AXIS_SRC_DSC_D1;
reg [15:0] S_AXIS_TX_TKEEP_D1;


always @(posedge pclk_div2 or negedge core_rst_n) begin
    if(!core_rst_n) begin
        S_AXIS_TX_TDATA_D1 <= 'd0;
        S_AXIS_TX_TLAST_D1 <= 'd0;
        S_AXIS_TX_TVALID_D1 <= 'd0;
        S_AXIS_SRC_DSC_D1 <= 'd0;
        S_AXIS_TX_TKEEP_D1 <= 'd0;
    end else begin
        S_AXIS_TX_TDATA_D1  <= S_AXIS_TX_TDATA;
        S_AXIS_TX_TLAST_D1  <= S_AXIS_TX_TLAST;
        S_AXIS_TX_TVALID_D1 <= S_AXIS_TX_TVALID;
        S_AXIS_SRC_DSC_D1   <= S_AXIS_SRC_DSC;
        S_AXIS_TX_TKEEP_D1  <= S_AXIS_TX_TKEEP;
    end
end


//pcie发送中间层
localparam  TX_STATE_IDLE   = 4'b0000,
            TX_STATE_3DW    = 4'b0001,
            TX_STATE_4DW    = 4'b0010;

reg     [3:0]   tx_state;
reg S_AXIS_TX_TREADY_mid;
assign S_AXIS_TX_TREADY = axis_slave0_tready && S_AXIS_TX_TREADY_mid;
assign axis_slave0_tdata = axis_slave0_tdata_mid_i;
assign axis_slave0_tlast = axis_slave0_tlast_mid_i;
assign axis_slave0_tuser = axis_slave0_tuser_mid_i;
assign axis_slave0_tvalid = axis_slave0_tvalid_mid_i;

always @(posedge pclk_div2 or negedge core_rst_n) begin
    if(!core_rst_n) begin
        tx_state <= TX_STATE_IDLE;
    end else begin
        case (tx_state)
            TX_STATE_IDLE: begin
                if(S_AXIS_TX_TVALID && axis_slave0_tready) begin
                    if(S_AXIS_TX_TDATA[29] == 1'b0) begin
                        tx_state <= TX_STATE_3DW;
                    end else begin
                        if(S_AXIS_TX_TLAST) begin
                            tx_state <= TX_STATE_IDLE;
                        end else begin
                            tx_state <= TX_STATE_4DW;
                        end
                    end
                end else begin
                    tx_state <= TX_STATE_IDLE;
                end
            end
            TX_STATE_3DW: begin
                if(axis_slave0_tready) begin
                    if((S_AXIS_TX_TLAST_D1 == 1'd1) || (S_AXIS_TX_TLAST == 1'd1 && S_AXIS_TX_TKEEP[15:12] == 4'b0000)) begin
                        tx_state <= TX_STATE_IDLE;
                    end else begin
                        tx_state <= TX_STATE_3DW;
                    end                    
                end else begin
                    tx_state <= TX_STATE_3DW;
                end

            end

            TX_STATE_4DW: begin
                if(axis_slave0_tready) begin
                    if(S_AXIS_TX_TLAST) begin
                        tx_state <= TX_STATE_IDLE;
                    end else begin
                        tx_state <= TX_STATE_4DW;
                    end                    
                end else begin
                    tx_state <= TX_STATE_4DW;
                end
            end

            default: begin
                tx_state <= TX_STATE_IDLE;
            end
        endcase
    end
end

always @(*) begin
        S_AXIS_TX_TREADY_mid = 1'd1;
        axis_slave0_tdata_mid_i = 'd0;
        axis_slave0_tvalid_mid_i = 'd0;
        axis_slave0_tlast_mid_i = 'd0;
        axis_slave0_tuser_mid_i = 'd0;
        case (tx_state)
            TX_STATE_IDLE: begin
                if(S_AXIS_TX_TVALID && axis_slave0_tready) begin
                    S_AXIS_TX_TREADY_mid = 1'd1;
                    if(S_AXIS_TX_TDATA[29] == 1'b0) begin
                        axis_slave0_tdata_mid_i = S_AXIS_TX_TDATA[95:0];
                        axis_slave0_tvalid_mid_i = S_AXIS_TX_TVALID;
                        axis_slave0_tlast_mid_i = 1'd0;
                        axis_slave0_tuser_mid_i = S_AXIS_SRC_DSC;
                    end else begin
                        axis_slave0_tdata_mid_i = S_AXIS_TX_TDATA;
                        axis_slave0_tvalid_mid_i = S_AXIS_TX_TVALID;
                        axis_slave0_tlast_mid_i = S_AXIS_TX_TLAST;
                        axis_slave0_tuser_mid_i = S_AXIS_SRC_DSC;                        
                    end
                end else begin
                    axis_slave0_tdata_mid_i = 'd0;
                    axis_slave0_tvalid_mid_i = 'd0;
                    axis_slave0_tlast_mid_i = 'd0;
                    axis_slave0_tuser_mid_i = 'd0;
                    // S_AXIS_TX_TREADY_mid = 1'd0;
                end
            end

            TX_STATE_3DW: begin
                if(axis_slave0_tready) begin
                    axis_slave0_tdata_mid_i = {S_AXIS_TX_TDATA[95:0],S_AXIS_TX_TDATA_D1[127:96]};
                    axis_slave0_tvalid_mid_i = 1'd1;
                    axis_slave0_tlast_mid_i = 1'd0;
                    axis_slave0_tuser_mid_i = S_AXIS_SRC_DSC;
                    if((S_AXIS_TX_TLAST_D1 == 1'd1) || (S_AXIS_TX_TLAST == 1'd1 && S_AXIS_TX_TKEEP[15:12] == 4'b0000)) begin
                        axis_slave0_tlast_mid_i = 1'd1;
                    end

                    if(S_AXIS_TX_TLAST == 1'd1 && S_AXIS_TX_TKEEP[15:12] == 4'b1111) begin
                        S_AXIS_TX_TREADY_mid = 1'd0;
                    end else begin
                        S_AXIS_TX_TREADY_mid = 1'd1;
                    end                    
                end else begin
                    S_AXIS_TX_TREADY_mid = 1'd0;
                end

            end

            TX_STATE_4DW: begin
                if(axis_slave0_tready) begin
                    axis_slave0_tdata_mid_i = S_AXIS_TX_TDATA;
                    axis_slave0_tvalid_mid_i = S_AXIS_TX_TVALID;
                    axis_slave0_tlast_mid_i = S_AXIS_TX_TLAST;
                    axis_slave0_tuser_mid_i = S_AXIS_SRC_DSC;     
                    S_AXIS_TX_TREADY_mid = 1'd1;               
                end else begin
                    S_AXIS_TX_TREADY_mid = 1'd0;                    
                end
            end
            default: begin
                // tx_state <= TX_STATE_IDLE;
                S_AXIS_TX_TREADY_mid = 1'd0;
                axis_slave0_tdata_mid_i = 'd0;
                axis_slave0_tvalid_mid_i = 'd0;
                axis_slave0_tlast_mid_i = 'd0;
                axis_slave0_tuser_mid_i = 'd0;
            end
        endcase
    
end




// pcie 其他信号
always @(*) begin
	user_clk = pclk_div2;
	reset = !core_rst_n;

	axis_master_tready = M_AXIS_RX_TREADY;
	

	IS_SOF = {(M_AXIS_RX_TVALID_posedge_af || restart),4'b0000};
	IS_EOF = {M_AXIS_RX_TLAST,is_eof_offset,2'b11};
	RERR_FWD = axis_master_tuser_d1[0] | axis_master_tuser_d1[1] | axis_master_tuser_d1[2];


	COMPLETER_ID = {cfg_pbus_num,cfg_pbus_dev_num,3'b000};
	CFG_BUS_MSTR_ENABLE = cfg_bus_master_en;
	CFG_LINK_WIDTH = 6'b000010;
	CFG_LINK_RATE = 2'b10;
	MAX_PAYLOAD_SIZE = cfg_max_payload_size;
    MAX_READ_REQUEST_SIZE = cfg_max_rd_req_size;

	RCB = cfg_rcb;
	MAX_RC_CPLD = xadm_cpld_cdts;
	MAX_RC_CPLH = xadm_cplh_cdts;

	CFG_INTERRUPT_MSIEN = cfg_msi_en;
	CFG_INTERRUPT_RDY = ven_msi_grant;
	ven_msi_req = CFG_INTERRUPT ;
end

encoder  u_encoder (
    .in_ori_data             ( M_AXIS_RX_TKEEP_MID    ),
    .out_enc_data            ( is_eof_offset   		)
);

always @(*) begin
	M_AXIS_RX_TKEEP[3:0] = M_AXIS_RX_TKEEP_MID[0] == 1'd1 ? 4'b1111 : 4'b0000;
	M_AXIS_RX_TKEEP[7:4] = M_AXIS_RX_TKEEP_MID[1] == 1'd1 ? 4'b1111 : 4'b0000;
	M_AXIS_RX_TKEEP[11:8] = M_AXIS_RX_TKEEP_MID[2] == 1'd1 ? 4'b1111 : 4'b0000;
	M_AXIS_RX_TKEEP[15:12] = M_AXIS_RX_TKEEP_MID[3] == 1'd1 ? 4'b1111 : 4'b0000;
end

// 上升沿检测
always @(posedge pclk_div2 or negedge core_rst_n) begin
	if(!core_rst_n) begin
		axis_master_tvalid_d1 <= 1'd0;
        axis_master_tdata_d1 <= 128'd0;
        axis_master_tkeep_d1 <= 4'd0;
        axis_master_tlast_d1 <= 1'd0;
        axis_master_tuser_d1 <= 8'd0;

        M_AXIS_RX_TVALID_d1 <= 1'd0;
        M_AXIS_RX_TLAST_d1 <= 1'd0;
        
	end else begin
		axis_master_tvalid_d1 <= axis_master_tvalid;
        axis_master_tdata_d1 <= axis_master_tdata;
        axis_master_tkeep_d1 <= axis_master_tkeep;
        axis_master_tlast_d1 <= axis_master_tlast;
        axis_master_tuser_d1 <= axis_master_tuser;

        M_AXIS_RX_TVALID_d1 <= M_AXIS_RX_TVALID;
        M_AXIS_RX_TLAST_d1 <= M_AXIS_RX_TLAST;
	end
end


    
endmodule