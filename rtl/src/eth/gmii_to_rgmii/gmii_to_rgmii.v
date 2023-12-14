`timescale  1ns/1ns

module gmii_to_rgmii(
    input  wire            sys_rst_n        ,
    output wire            gmii_rx_clk      ,
    output wire            gmii_rx_dv       ,
    output wire     [7:0]  gmii_rxd         ,

    input  wire            rgmii_rxc        ,
    input  wire            rgmii_rx_ctl     ,
    input  wire     [3:0]  rgmii_rxd             
);

wire   pll_lock  ;

rgmii_rx u_rgmii_rx(
    .sys_rst_n      (sys_rst_n),
    .rgmii_rxc     (rgmii_rxc   ),
    .rgmii_rx_ctl  (rgmii_rx_ctl),
    .rgmii_rxd     (rgmii_rxd   ),
    
    .gmii_rx_clk   (gmii_rx_clk ),
    .gmii_rx_dv    (gmii_rx_dv  ),
    .gmii_rxd      (gmii_rxd    ),

    .pll_lock      (pll_lock    )
);

endmodule