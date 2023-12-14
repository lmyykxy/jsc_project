module eth_top #(
    parameter BOARD_MAC   = 48'h11_22_33_44_55_66       ,
    parameter BOARD_IP    = {8'd192,8'd168,8'd10,8'd2}  
)(
    input  wire             sys_rst_n                                       ,
    output wire             eth_rst_n                                       ,

    input  wire             rgmii_rxc                                       ,
    input  wire             rgmii_rx_ctl                                    ,
    input  wire [3:0]       rgmii_rxd                                       ,

    output wire             rec_pkt_done                                    ,
    output wire             rec_en                                          ,
    output wire [31:0]      rec_data                                        ,
    output wire [15:0]      rec_byte_num                                    ,
    output wire             eth_clk                                       
);



wire            gmii_rx_clk      ;
wire            gmii_rx_dv       ;
wire     [7:0]  gmii_rxd         ;

assign eth_rst_n = 1'b1;
assign eth_clk = gmii_rx_clk;

gmii_to_rgmii u_gmii_to_rgmii(
    .sys_rst_n(sys_rst_n),
    .gmii_rx_clk   ( gmii_rx_clk        ) ,
    .gmii_rx_dv    ( gmii_rx_dv         ) ,
    .gmii_rxd      ( gmii_rxd           ) ,

    .rgmii_rxc     ( rgmii_rxc          ) ,
    .rgmii_rx_ctl  ( rgmii_rx_ctl       ) ,
    .rgmii_rxd     ( rgmii_rxd          ) 
);
     
udp_dma #(
    .BOARD_MAC       ( BOARD_MAC     ),
    .BOARD_IP        ( BOARD_IP      )
) u_udp_rx (
    .rst_n           ( sys_rst_n     ),

    .clk             ( gmii_rx_clk   ),        
    .gmii_rx_dv      ( gmii_rx_dv    ),                                 
    .gmii_rxd        ( gmii_rxd      ),  
         
    .rec_pkt_done    ( rec_pkt_done  ),      
    .rec_en          ( rec_en        ),            
    .rec_data        ( rec_data      ),          
    .rec_byte_num    ( rec_byte_num  )       
); 

endmodule