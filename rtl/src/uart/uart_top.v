`timescale 1ns / 1ps

`define UD #1

module uart_top(
    //input ports
    input         clk,
    input         uart_rx,
    input         sys_rst_n, 
    input   wire [1:0]   rState, 
    //output ports
    output               pcie_uart_rst,
    output               ov5640_uart_rst,
    output  wire [3:0]   eth_port,
    output  wire [3:0]   camera_port,
    output  wire [3:0]   pcie_port,
    output  wire [3:0]   hdmi_port,        
    output        uart_tx,
    output  [7:0] led,
    output rst_uart,
    output sys_uart_rst
);

   parameter      BPS_NUM = 16'd434;
   //  ���ò�����Ϊ4800ʱ��  bitλ��ʱ�����ڸ���:50MHz set 10417  40MHz set 8333
   //  ���ò�����Ϊ9600ʱ��  bitλ��ʱ�����ڸ���:50MHz set 5208   40MHz set 4167
   //  ���ò�����Ϊ115200ʱ��bitλ��ʱ�����ڸ���:50MHz set 434    40MHz set 347 12M set 104
   
//==========================================================================
//wire and reg in the module
//==========================================================================

    wire           tx_busy;         //transmitter is free.
    wire           rx_finish;       //receiver is free.
    wire    [7:0]  rx_data;         //the data receive from uart_rx.
                                    
    wire    [7:0]  tx_data;         
                                    
    wire           tx_en;           //enable transmit.
    wire           rst_uart;
    wire           sys_uart_rst;   
//==========================================================================
//logic
//==========================================================================
    wire                 rx_en  ;
    reg [3:0]            st_next;
    reg [3:0]            st_cur ;
    reg                  rst_temp;
    parameter            IDLE      = 0 ;
    parameter            PATTERN_u = 10;
    parameter            PATTERN0  = 1 ;
    parameter            PATTERN1  = 2 ;
    parameter            PATTERN2  = 3 ;
    parameter            PATTERN3  = 4 ;
    parameter            PATTERN4  = 5 ; 
    parameter            PATTERN5  = 6 ;  
    parameter            PATTERN6  = 7 ;   
    
    reg         sys_uart_rst_tmp;
//==========================================================================
//instance
//==========================================================================
    assign rst_uart = rst_temp;
    assign sys_uart_rst = sys_uart_rst_tmp;
    always @(posedge clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            st_cur      <= 'b0 ;
        end
        else begin
            st_cur      <= st_next ;
        end
    end
    always @(*) begin
        //st_next = st_cur ;//�������ѡ��ǲ�ȫ�����Ը���ֵ����latch
        case(st_cur)
            IDLE:begin
                if(rx_data==0)
                    st_next = PATTERN0;
                else     
                    st_next = IDLE;
            end
            PATTERN0:begin
                if(rx_data==0)
                    st_next = PATTERN0;
                else     
                    st_next = PATTERN_u;
            end
            PATTERN_u:begin
                if(rState==0)begin
                    case (rx_data)
                        8'h01:     st_next = PATTERN1 ;
                        8'h02:     st_next = PATTERN2 ;
                        8'h03:     st_next = PATTERN3 ;
                        8'h04:     st_next = PATTERN4 ;
                        8'h05:     st_next = PATTERN5 ;
                        8'h06:     st_next = PATTERN6 ;
                        default:   st_next = PATTERN_u;
                    endcase
                end
                else 
                    st_next = PATTERN_u;
            end
            PATTERN1:
                st_next = IDLE;
            PATTERN2:
                st_next = IDLE;
            PATTERN3:
                st_next = IDLE;
            PATTERN4:
                st_next = IDLE;
            PATTERN5:
                st_next = IDLE; 
            PATTERN6:
                st_next = IDLE;    
            default:   st_next = IDLE;                                                 
        endcase      
    end

    reg ov5640_uart_rst_tmp;
    reg pcie_uart_rst_tmp;
    reg [3:0]   eth_port_tmp;
    reg [3:0]   camera_port_tmp;
    reg [3:0]   pcie_port_tmp;
    reg [3:0]   hdmi_port_tmp;
    reg [7:0]   led_reg;

    assign led = led_reg; 

    always @(posedge clk or negedge sys_rst_n) begin
         if(!sys_rst_n) begin
            rst_temp            <=0        ;
            sys_uart_rst_tmp    <=0        ;
            pcie_uart_rst_tmp   <=0        ;
            ov5640_uart_rst_tmp <=0        ;
            eth_port_tmp        <=0        ;
            camera_port_tmp     <=1        ;
            pcie_port_tmp       <=2        ;
            hdmi_port_tmp       <=3        ; 
            led_reg             <=8'h55    ;            
        end
        else if (st_cur == IDLE) begin
            rst_temp            <=0        ;
            sys_uart_rst_tmp    <=1        ;
            pcie_uart_rst_tmp   <=pcie_uart_rst_tmp    ;
            ov5640_uart_rst_tmp <=ov5640_uart_rst_tmp  ;
            eth_port_tmp        <=eth_port_tmp      ;
            camera_port_tmp     <=camera_port_tmp   ;
            pcie_port_tmp       <=pcie_port_tmp     ;
            hdmi_port_tmp       <=hdmi_port_tmp     ;
            led_reg             <=led_reg    ;  
        end
        else if (st_cur == PATTERN0) begin
            rst_temp            <=0        ;
            sys_uart_rst_tmp    <=1        ;
            pcie_uart_rst_tmp   <=pcie_uart_rst_tmp   ;
            ov5640_uart_rst_tmp <=ov5640_uart_rst_tmp ;
            eth_port_tmp        <=eth_port_tmp      ;
            camera_port_tmp     <=camera_port_tmp   ;
            pcie_port_tmp       <=pcie_port_tmp     ;
            hdmi_port_tmp       <=hdmi_port_tmp     ; 
            led_reg             <=led_reg    ;  
        end
        else if (st_cur == PATTERN_u) begin
             rst_temp           <=0        ;
             sys_uart_rst_tmp   <=1        ;
            pcie_uart_rst_tmp   <=pcie_uart_rst_tmp ; 
            ov5640_uart_rst_tmp <=ov5640_uart_rst_tmp;
            eth_port_tmp        <=eth_port_tmp      ;
            camera_port_tmp     <=camera_port_tmp   ;
            pcie_port_tmp       <=pcie_port_tmp     ;
            hdmi_port_tmp       <=hdmi_port_tmp     ; 
            led_reg             <=8'h55    ;  
        end                     
        else if (st_cur == PATTERN1) begin
            rst_temp            <=1        ;
            sys_uart_rst_tmp    <=1        ;
            pcie_uart_rst_tmp   <=0        ;
            ov5640_uart_rst_tmp <=ov5640_uart_rst_tmp        ;
            eth_port_tmp        <=0        ;
            camera_port_tmp     <=1        ;
            pcie_port_tmp       <=2        ;
            hdmi_port_tmp       <=3        ; 
            led_reg             <=8'h01    ;
        end
        else if (st_cur == PATTERN2) begin
            rst_temp            <=1        ;
            sys_uart_rst_tmp    <=1        ;
            pcie_uart_rst_tmp   <=pcie_uart_rst_tmp;
            ov5640_uart_rst_tmp <=ov5640_uart_rst_tmp        ;
            eth_port_tmp        <=1        ;
            camera_port_tmp     <=2        ;
            pcie_port_tmp       <=3        ;
            hdmi_port_tmp       <=0        ;
            led_reg             <=8'h02    ; 
        end
        else if (st_cur == PATTERN3) begin
            rst_temp            <=1        ;
            sys_uart_rst_tmp    <=1        ;
            pcie_uart_rst_tmp   <=pcie_uart_rst_tmp        ;
            ov5640_uart_rst_tmp <=ov5640_uart_rst_tmp        ;
            eth_port_tmp        <=2        ;
            camera_port_tmp     <=3        ;
            pcie_port_tmp       <=0        ;
            hdmi_port_tmp       <=1        ;
            led_reg             <=8'h03    ; 
        end
        else if (st_cur == PATTERN4) begin
            rst_temp            <=1        ;
            sys_uart_rst_tmp    <=1        ;
            pcie_uart_rst_tmp   <=pcie_uart_rst_tmp        ;
            ov5640_uart_rst_tmp <=ov5640_uart_rst_tmp        ;
            eth_port_tmp        <=3        ;
            camera_port_tmp     <=0        ;
            pcie_port_tmp       <=1        ;
            hdmi_port_tmp       <=2        ;
            led_reg             <=8'h04    ; 
        end
        else if (st_cur == PATTERN5) begin
            rst_temp            <=1        ;
            sys_uart_rst_tmp    <=1        ;
            pcie_uart_rst_tmp   <=pcie_uart_rst_tmp;
            ov5640_uart_rst_tmp <=~ov5640_uart_rst_tmp;
            eth_port_tmp        <=3        ;
            camera_port_tmp     <=0        ;
            pcie_port_tmp       <=1        ;
            hdmi_port_tmp       <=2        ;
            led_reg             <=8'h05    ;
        end
        else if (st_cur == PATTERN6) begin
            rst_temp            <=0        ;
            ov5640_uart_rst_tmp <=ov5640_uart_rst_tmp;
            sys_uart_rst_tmp    <=0        ;
            pcie_uart_rst_tmp   <=pcie_uart_rst_tmp;
            eth_port_tmp        <=2        ;
            camera_port_tmp     <=3        ;
            pcie_port_tmp       <=0        ;
            hdmi_port_tmp       <=1        ;
            led_reg             <=8'h06    ;
        end
        else begin
            rst_temp            <=rst_temp          ;
            sys_uart_rst_tmp    <=sys_uart_rst_tmp        ;
            ov5640_uart_rst_tmp <=ov5640_uart_rst_tmp;
            pcie_uart_rst_tmp   <=pcie_uart_rst_tmp ;
            eth_port_tmp        <=eth_port_tmp      ;
            camera_port_tmp     <=camera_port_tmp   ;
            pcie_port_tmp       <=pcie_port_tmp     ;
            hdmi_port_tmp       <=hdmi_port_tmp     ;
            led_reg             <=8'h00             ; 
        end
    end

    assign tx_data         =   rx_data              ;
    assign ov5640_uart_rst =   ov5640_uart_rst_tmp  ;
    assign pcie_uart_rst   =   pcie_uart_rst_tmp    ;
    assign eth_port        =   eth_port_tmp         ;   
    assign camera_port     =   camera_port_tmp      ;
    assign pcie_port       =   pcie_port_tmp        ;  
    assign hdmi_port       =   hdmi_port_tmp        ;  
    //uart transmit data module.
    uart_tx #(
         .BPS_NUM            (  BPS_NUM       ) //parameter         BPS_NUM  =    16'd434
     )
     u_uart_tx(
        .clk                 (  clk           ),// input            clk,               
        .tx_data             (  tx_data       ),// input [7:0]      tx_data,           
        .tx_pluse            (  tx_en         ),// input            tx_pluse,          
        .uart_tx             (  uart_tx       ),// output reg       uart_tx,                                  
        .tx_busy             (  tx_busy       ) // output           tx_busy            
    );                                             
                                               
    //Uart receive data module.                
    uart_rx #(
         .BPS_NUM            (  BPS_NUM       ) //parameter          BPS_NUM  =    16'd434
     )
     u_uart_rx (                        
        .clk                 (  clk           ),// input             clk,                              
        .uart_rx             (  uart_rx       ),// input             uart_rx,            
        .rx_data             (  rx_data       ),// output reg [7:0]  rx_data,                                   
        .rx_en               (  rx_en         ),// output reg        rx_en,                          
        .rx_finish           (  rx_finish     ) // output            rx_finish           
    );                                            
    
endmodule
