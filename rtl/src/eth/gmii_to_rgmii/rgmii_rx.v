`timescale  1ns/1ns

module rgmii_rx(
    input  wire            sys_rst_n        ,
    input  wire            rgmii_rxc        ,
    input  wire            rgmii_rx_ctl     ,
    input  wire     [3:0]  rgmii_rxd        ,

    output wire            gmii_rx_clk      ,
    output reg             gmii_rx_dv       ,
    output reg     [7:0]   gmii_rxd         ,

    output wire            pll_lock
    );


wire            gmii_rx_dv_s;
wire  [ 7:0]    gmii_rxd_s;

//pll_sft U_pll_phase_shift(   
//    .clkout0   (gmii_rx_clk    ),   //125MHz
//    .clkin1    (rgmii_rxc      ),
//    .clkfb     (gmii_rx_clk    ),
//    .pll_rst   (1'b0           ),
//    .pll_lock  (pll_lock       )
//    );

GTP_CLKBUFG GTP_CLKBUFG_RXSHFT(
    .CLKIN     (!rgmii_rxc),
    .CLKOUT    (gmii_rx_clk)
);


always @(posedge gmii_rx_clk or negedge sys_rst_n)
begin
    if(!sys_rst_n) begin
        gmii_rxd <= 'd0;
        gmii_rx_dv <= 'd0;
    end else begin
    gmii_rxd   <= gmii_rxd_s;
    gmii_rx_dv <= gmii_rx_dv_s;    
    end

end

// GTP_IDDR_E2#(
//     .GRS_EN ("TRUE")
// )GTP_IDDR_E2_1(
//     .D      (rgmii_rxd[0]),
//     .RS     (0),
//     .CLK    (gmii_rx_clk),
//     .Q0     (gmii_rxd_s[0]),
//     .Q1     (gmii_rxd_s[4])
// );
wire [5:0] nc1;
GTP_ISERDES #(
    .ISERDES_MODE    ("IDDR"),  //"IDDR","IMDDR","IGDES4","IMDES4","IGDES7","IGDES8","IMDES8"
    .GRS_EN          ("TRUE"),  //"TRUE"; "FALSE"
    .LRS_EN          ("TRUE")   //"TRUE"; "FALSE"
) igddr1(         
    .DI              (rgmii_rxd[0]),
    .ICLK            (1'd0        ),
    .DESCLK          (gmii_rx_clk ),
    .RCLK            (gmii_rx_clk ),
    .WADDR           (3'd0        ),
    .RADDR           (3'd0        ),
    .RST             (1'b0        ),
    .DO              ({gmii_rxd_s[4],gmii_rxd_s[0],nc1})
);
// GTP_IDDR_E2#(
//     .GRS_EN ("TRUE")
// )GTP_IDDR_E2_2(
//     .D      (rgmii_rxd[1]),
//     .RS     (0),
//     .CLK    (gmii_rx_clk),
//     .Q0     (gmii_rxd_s[1]),
//     .Q1     (gmii_rxd_s[5])
// );
wire [5:0] nc2;
GTP_ISERDES #(
    .ISERDES_MODE    ("IDDR"),  //"IDDR","IMDDR","IGDES4","IMDES4","IGDES7","IGDES8","IMDES8"
    .GRS_EN          ("TRUE"),  //"TRUE"; "FALSE"
    .LRS_EN          ("TRUE")   //"TRUE"; "FALSE"
) igddr2(
    .DI              (rgmii_rxd[1]),
    .ICLK            (1'd0        ),
    .DESCLK          (gmii_rx_clk ),
    .RCLK            (gmii_rx_clk ),
    .WADDR           (3'd0        ),
    .RADDR           (3'd0        ),
    .RST             (1'b0        ),
    .DO              ({gmii_rxd_s[5],gmii_rxd_s[1],nc2})
);
// GTP_IDDR_E2#(
//     .GRS_EN ("TRUE")
// )GTP_IDDR_E2_3(
//     .D      (rgmii_rxd[2]),
//     .RS     (0),
//     .CLK    (gmii_rx_clk),
//     .Q0     (gmii_rxd_s[2]),
//     .Q1     (gmii_rxd_s[6])
// );
wire [5:0] nc3;
GTP_ISERDES #(
    .ISERDES_MODE    ("IDDR"),  //"IDDR","IMDDR","IGDES4","IMDES4","IGDES7","IGDES8","IMDES8"
    .GRS_EN          ("TRUE"),  //"TRUE"; "FALSE"
    .LRS_EN          ("TRUE")   //"TRUE"; "FALSE"
) igddr3(
    .DI              (rgmii_rxd[2]),
    .ICLK            (1'd0        ),
    .DESCLK          (gmii_rx_clk ),
    .RCLK            (gmii_rx_clk ),
    .WADDR           (3'd0        ),
    .RADDR           (3'd0        ),
    .RST             (1'b0        ),
    .DO              ({gmii_rxd_s[6],gmii_rxd_s[2],nc3})
);
// GTP_IDDR_E2#(
//     .GRS_EN ("TRUE")
// )GTP_IDDR_E2_4(
//     .D      (rgmii_rxd[3]),
//     .RS     (0),
//     .CLK    (gmii_rx_clk),
//     .Q0     (gmii_rxd_s[3]),
//     .Q1     (gmii_rxd_s[7])
// );
wire [5:0] nc4;
GTP_ISERDES #(
    .ISERDES_MODE    ("IDDR"),  //"IDDR","IMDDR","IGDES4","IMDES4","IGDES7","IGDES8","IMDES8"
    .GRS_EN          ("TRUE"),  //"TRUE"; "FALSE"
    .LRS_EN          ("TRUE")   //"TRUE"; "FALSE"
) igddr4(
    .DI              (rgmii_rxd[3]),
    .ICLK            (1'd0        ),
    .DESCLK          (gmii_rx_clk ),
    .RCLK            (gmii_rx_clk ),
    .WADDR           (3'd0        ),
    .RADDR           (3'd0        ),
    .RST             (1'b0        ),
    .DO              ({gmii_rxd_s[7],gmii_rxd_s[3],nc4})
);
// GTP_IDDR_E2#(
//     .GRS_EN ("TRUE")
// )GTP_IDDR_E2_5(
//     .D      (rgmii_rx_ctl),
//     .RS     (0),
//     .CLK    (gmii_rx_clk),
//     .Q0     (gmii_rx_dv_s),
//     .Q1     (rgmii_rx_ctl_s)
// );
wire [5:0] nc5;
GTP_ISERDES #(
    .ISERDES_MODE    ("IDDR"),  //"IDDR","IMDDR","IGDES4","IMDES4","IGDES7","IGDES8","IMDES8"
    .GRS_EN          ("TRUE"),  //"TRUE"; "FALSE"
    .LRS_EN          ("TRUE")   //"TRUE"; "FALSE"
) igddr5(
    .DI              (rgmii_rx_ctl),
    .ICLK            (1'd0        ),
    .DESCLK          (gmii_rx_clk ),
    .RCLK            (gmii_rx_clk ),
    .WADDR           (3'd0        ),
    .RADDR           (3'd0        ),
    .RST             (1'b0        ),
    .DO              ({rgmii_rx_ctl_s,gmii_rx_dv_s,nc5})
);

endmodule