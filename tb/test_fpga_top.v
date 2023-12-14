`timescale  1ns / 100ps

module test_fpga_top;

GTP_GRS GRS_INST(
	.GRS_N (1'b1)
);

// fpga_top Parameters
real PERIOD  = 20;
parameter HDMI_PERIOD_40 = 25;
parameter HDMI_PERIOD_150 = 6.667;

// fpga_top Inputs
reg     sys_clk_50m                          = 0 ;
reg     hdmi_clk_in_40                       = 0 ;
reg     hdmi_clk_in_150                      = 0 ;
reg     sys_rst_n                            = 0 ;
reg     hdmi_rst_n                           = 0 ;

wire            mem_cs_n                                ;
wire            mem_rst_n                               ;
wire            mem_ck                                  ;
wire            mem_ck_n                                ;
wire            mem_cke                                 ;
wire            mem_ras_n                               ;
wire            mem_cas_n                               ;
wire            mem_we_n                                ;
wire            mem_odt                                 ;
wire [14:0]     mem_a                                   ;
wire [2 :0]     mem_ba                                  ;
wire [3 :0]     mem_dqs                                 ;
wire [3 :0]     mem_dqs_n                               ;
wire [31:0]     mem_dq                                  ;
wire [3 :0]     mem_dm                                  ;

wire            hdmi_hs_in                              ;
wire            hdmi_vs_in                              ;
wire            hdmi_de_in                              ;
wire [7:0]      rgb_r                                   ;
wire [7:0]      rgb_g                                   ;
wire [7:0]      rgb_b                                   ;

wire [23:0]     hdmi_rgb_data                           ;


initial
begin
    forever #(PERIOD/2)  sys_clk_50m=~sys_clk_50m;
end

initial
begin
    forever #(HDMI_PERIOD_40/2)  hdmi_clk_in_40=~hdmi_clk_in_40;
end

initial
begin
    forever #(HDMI_PERIOD_150/2)  hdmi_clk_in_150=~hdmi_clk_in_150;
end


initial
begin
    #(PERIOD*2) sys_rst_n  =  1;
end

initial
begin
    #130000 hdmi_rst_n  =  1;
end

assign hdmi_rgb_data = {rgb_r,rgb_g,rgb_b};

fpga_top  u_fpga_top (
    .sys_clk_50m             ( sys_clk_50m          ),
    .sys_rst_n               ( sys_rst_n            ),

    .hdmi_clk_in             ( hdmi_clk_in_150       ),
    
    .hdmi_data_in            ( hdmi_rgb_data        ),
    .hdmi_hs_in              ( hdmi_hs_in           ),
    .hdmi_vs_in              ( hdmi_vs_in           ),
    .hdmi_de_in              ( hdmi_de_in           ),

    .mem_cs_n                ( mem_cs_n             ),
    .mem_rst_n               ( mem_rst_n            ),
    .mem_ck                  ( mem_ck               ),
    .mem_ck_n                ( mem_ck_n             ),
    .mem_cke                 ( mem_cke              ),
    .mem_ras_n               ( mem_ras_n            ),
    .mem_cas_n               ( mem_cas_n            ),
    .mem_we_n                ( mem_we_n             ),
    .mem_odt                 ( mem_odt              ),
    .mem_a                   ( mem_a                ),
    .mem_ba                  ( mem_ba               ),
    .mem_dm                  ( mem_dm               ),
    .mem_dqs                 ( mem_dqs              ),
    .mem_dqs_n               ( mem_dqs_n            ),
    .mem_dq                  ( mem_dq               ),
    .dly_mon_pad             ( dly_mon_pad          ),

    .hdmi_out                ( hdmi_clk_in_150      )
);



tb_ddr3_top #(
    .MEM_A_WIDTH            ( 15                    ),
    .MEM_DM_WIDTH           ( 2                     ),
    .TOTAL_DQ_WIDTH         ( 32                    ),
    .MEM_DQ_WIDTH           ( 16                    ),
    .MEM_DQS_WIDTH          ( 2                     ),
    .DELAY_PCB              ( 0.1                   )
)
 u_tb_ddr3_top (
    .mem_a                   ( mem_a                ),
    .mem_ba                  ( mem_ba               ),
    .mem_dm                  ( mem_dm               ),
    .mem_ck                  ( mem_ck               ),
    .mem_ck_n                ( mem_ck_n             ),
    .mem_cke                 ( mem_cke              ),
    .mem_cs_n                ( mem_cs_n             ),
    .mem_ras_n               ( mem_ras_n            ),
    .mem_cas_n               ( mem_cas_n            ),
    .mem_we_n                ( mem_we_n             ),
    .mem_odt                 ( mem_odt              ),
    .mem_reset_n             ( mem_rst_n            ),

    .mem_dq                  ( mem_dq               ),
    .mem_dqs                 ( mem_dqs              ),
    .mem_dqs_n               ( mem_dqs_n            )
);

hdmi_gen u_hdmi_gen(
    .clk                     ( hdmi_clk_in_150       ),
    .rst                     ( !hdmi_rst_n           ),

    .hs                      ( hdmi_hs_in           ),
    .vs                      ( hdmi_vs_in           ),
    .de                      ( hdmi_de_in           ),
    .rgb_r                   ( rgb_r                ),
    .rgb_g                   ( rgb_g                ),
    .rgb_b                   ( rgb_b                )
);


endmodule