`timescale  1ns/1ns

module  hdmi_dw_convert (
    input   wire            sys_rst_n           ,  

    input   wire            hdmi_clk            ,
    input   wire            hdmi_hs_in          ,
    input   wire            hdmi_vs_in          ,
    input   wire            hdmi_de_in          ,
    input   wire [23:0]     hdmi_data_in        ,

    output  wire            hdmi_wr_en          ,
    output  wire [31:0]     hdmi_data_dw_out    ,

    output  reg             read_enable     
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//

//parameter define
parameter   PIC_WAIT    =   4'd10; 

//wire  define
wire            pic_flag            ;   

//reg   define
reg             vs_inync_dly1       ;   
reg             vs_inync_dly2       ;
reg     [3:0]   cnt_pic             ;  
reg     [3:0]   frame_cnt           ; 
reg             pic_valid           ;   
reg     [23:0]  pic_data_reg        ;   
reg     [31:0]  data_out_reg        ;   
reg             data_flag           ;   
reg             data_flag_dly1      ;   

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//

always@(posedge hdmi_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0) begin
        vs_inync_dly1    <=  1'b0;
        vs_inync_dly2    <=  1'b0;
        end
    else
        begin
        vs_inync_dly1    <=  hdmi_vs_in;
        vs_inync_dly2    <=  vs_inync_dly1;
        end

assign  pic_flag = ((vs_inync_dly1 == 1'b0)
                    && (hdmi_vs_in == 1'b1)) ? 1'b1 : 1'b0;

always@(posedge hdmi_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_pic <=  4'd0;
    else    if(cnt_pic < PIC_WAIT)
        cnt_pic <=  cnt_pic + 1'b1;
    else
        cnt_pic <=  cnt_pic;

always@(posedge hdmi_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        frame_cnt <=  4'd0;
    else    if(frame_cnt < 3 && (pic_flag == 1'b1))
        frame_cnt <=  frame_cnt + 1'b1;
    else
        frame_cnt <=  frame_cnt;

always@(posedge hdmi_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        read_enable <=  1'd0;
    else    if(frame_cnt > 1 )
        read_enable <= 1'b1;
    else
        read_enable <=  read_enable;

always@(posedge hdmi_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        pic_valid   <=  1'b0;
    else    if((cnt_pic == PIC_WAIT) && (pic_flag == 1'b1))
        pic_valid   <=  1'b1;
    else
        pic_valid   <=  pic_valid;


always@(posedge hdmi_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            data_out_reg    <=  16'd0;
            pic_data_reg    <=  8'd0;
            data_flag       <=  1'b0;
        end
    else    if(hdmi_de_in == 1'b1)
        begin
            data_flag       <=  1'b1;
            pic_data_reg    <=  {8'b0, hdmi_data_in};
            data_out_reg    <=  pic_data_reg;
        end
    else
        begin
            data_flag       <=  1'b0;
            pic_data_reg    <=  8'd0;
            data_out_reg    <=  data_out_reg;
        end

always@(posedge hdmi_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data_flag_dly1  <=  1'b0;
    else
        data_flag_dly1  <=  data_flag;


assign  hdmi_data_dw_out = (pic_valid == 1'b1) ? data_out_reg : 16'b0;

assign  hdmi_wr_en = (pic_valid == 1'b1) ? data_flag_dly1 : 1'b0;

endmodule
