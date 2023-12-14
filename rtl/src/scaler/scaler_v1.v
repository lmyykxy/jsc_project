//  COPYRIGHT (c) 2019 PANGO MICROSYSTEMS, INC.
//  ALL RIGHTS RESERVED.
// 
//  THE SOURCE CODE CONTAINED HEREIN IS PROPRIETARY TO PANGO MICROSYSTEMS, INC.
//  IT SHALL NOT BE REPRODUCED OR DISCLOSED IN WHOLE OR IN PART OR USED BY
//  PARTIES WITHOUT WRITTEN AUTHORIZATION FROM THE OWNER.
//
//=============================================================================
//   _____________
//  |  _________  |
//  | |         | |         
//  | |   _     | |____    
//  | |  |  \   |  __  |   Author        : xzliu
//  | |  |  _\ _| |  | |   IDE Version   : 
//  | |__| |  \   |  | |   Device Part   : 
//  |____  |   \ _|  | |   Description   : scaler ,clip pixel 
//       | |         | |                  
//       | |_________| |                  
//       |_____________|
//
//============================================================================= 
//  Revision History:
//  Date          By            Version     Revision Description
//-----------------------------------------------------------------------------
//  2020/3/23      XZLIU       1.0         Initial version
//=============================================================================
module scaler_v1#
(
	
    parameter INPUT_H_TOTAL        = 2200          , // the input h total  
    parameter INPUT_V_TOTAL        = 1125          , // the input v total	
    parameter INPUT_RES_X          = 1920          , // the input resolution  of  X
    parameter INPUT_RES_Y          = 1080          , // the input resolution  of  Y	
											       
	parameter OUTPUT_H_TOTAL       = 1650          , // the output h total  
    parameter OUTPUT_V_TOTAL       = 750           , // the output v total 
    parameter OUTPUT_RES_X         = 1280          , // the output resolution of  X
    parameter OUTPUT_RES_Y         = 720           , // the output resolution  of  Y
    parameter OUTPUT_H_SYNC        = 40            , 
    parameter OUTPUT_H_BP          = 220           , 
    parameter OUTPUT_H_FP          = 110           , 	
    parameter OUTPUT_V_SYNC        = 5             , 
    parameter OUTPUT_V_BP          = 20            , 
    parameter OUTPUT_V_FP          = 5             , 
	

    parameter WR_PRE_PIXEL_NUM     = 2560          , //提前写入fifo的数据个数
    parameter ADJUST_BASE_NUM      = 988           , //调整输出消隐期基数，防止fifo读空；
											       
    parameter DATA_WIDTH           = 8             , // 
    parameter CHANNEL              = 3               
	
)
(
	input	wire                                  rst_n       ,
	input	wire                                  pclk_in     ,
	input	wire                                  pclk_out    ,
		
    input	wire[DATA_WIDTH*CHANNEL-1:0]          pix_data_in ,	
	input	wire                                  vs_in       ,
	input	wire                                  hs_in       ,
	input	wire                                  de_in       ,

	output	wire                                  test0       ,
	output	wire                                  test1       ,
	
	output	wire                                  de_out       ,
	output	wire                                  vs_out       ,
	output	wire                                  hs_out       ,
	output	wire[DATA_WIDTH*CHANNEL-1:0]          pix_data_out 

);
 

//fifo  signal  define 
wire									wr_rst        ;   
wire									wr_en         ; 
wire									almost_full   ;   
wire									wr_full       ;   
wire[DATA_WIDTH*CHANNEL-1:0]		    wr_data       ;   
wire[12-1:0                ]		    rd_water_level;   

wire                                    rd_rst        ;
wire                                    rd_en         ;
wire                                    almost_empty  ;
wire                                    rd_empty      ;
wire[DATA_WIDTH*CHANNEL-1:0]		    rd_data       ; 
  

//hdmi timing
wire                                    de            ;
wire                                    vs            ;
wire                                    hs            ;

reg                                     de_r0,de_r1   ;
reg                                     vs_r0,vs_r1   ;
reg                                     hs_r0,hs_r1   ;
                         

reg                                     clip_rst_n    ;
reg                                     start_to_rd   ;
wire[12-1:0]                            adjust_num    ;


////确保有效数据从第一行开始写
always@(posedge pclk_in	or negedge rst_n)begin
	if(~rst_n)
		clip_rst_n <= 0;
	else if(vs_in)
		clip_rst_n <= 1'b1;
end 		



pixel_clip # (    
    .INPUT_RES_X           (  INPUT_RES_X      ),
    .INPUT_RES_Y           (  INPUT_RES_Y      ),
    .OUTPUT_RES_X          (  OUTPUT_RES_X     ),
    .OUTPUT_RES_Y          (  OUTPUT_RES_Y     )    
)
u_pixel_clip
(
    .rst_n                 (  clip_rst_n       ), 
    .pclk_in               (  pclk_in          ),
	.de_in                 (  de_in            ),
    .vs_in                 (  vs_in            ),
	
    .pixel_valid           (  wr_en            )
	
    );




 //fifo 
assign wr_rst  =  ~rst_n ;
assign wr_data =  pix_data_in      ;

assign rd_en   =  de               ;
assign rd_rst  =  ~rst_n;


fifo_line_buffer  u_fifo_line_buffer (
  .wr_clk                (  pclk_in      ),    
  .wr_rst                (  wr_rst       ),
  .wr_en                 (  wr_en        ),    
  .wr_data               (  wr_data      ),    
  .wr_full               (  wr_full      ),    
  .almost_full           (  almost_full  ),    
									    
  .rd_clk                (  pclk_out     ),   
  .rd_rst                (  rd_rst       ),   
  .rd_en                 (  rd_en        ),   
  .rd_data               (  rd_data      ),   
  .rd_empty              (  rd_empty     ),
  .rd_water_level        (rd_water_level ),    // output [12:0]  
  .almost_empty          (  almost_empty )  
);




always@(posedge pclk_out  or negedge rst_n)begin
	if(~rst_n)
		start_to_rd <= 0;
	else if(rd_water_level >= WR_PRE_PIXEL_NUM)	 //已经写了足够的数据后，开始读取
	    start_to_rd <= 1'b1;
	else if	( vs_out )
		start_to_rd <= 1'b0;
end 		


blank_adjust # (
    .OUTPUT_H_TOTAL            (  OUTPUT_H_TOTAL    ),
    .OUTPUT_RES_X              (  OUTPUT_RES_X      ),
    .ADJUST_BASE_NUM           (  ADJUST_BASE_NUM   )
    
)
blank_adjust
(
    .rst_n                 (   rst_n         ),
    .start_to_rd           (   start_to_rd   ),
	.pclk_out              (   pclk_out      ),
    .de                    (   de            ),
    .vs                    (   vs            ),  
    .adjust_num            (   adjust_num    )  
    );


hdmi_timing # (
    .OUTPUT_H_TOTAL            (  OUTPUT_H_TOTAL    ),
    .OUTPUT_V_TOTAL            (  OUTPUT_V_TOTAL    ),
    .OUTPUT_RES_X              (  OUTPUT_RES_X       ),
    .OUTPUT_RES_Y              (  OUTPUT_RES_Y       ),	
    .OUTPUT_H_SYNC             (  OUTPUT_H_SYNC      ),
    .OUTPUT_H_BP               (  OUTPUT_H_BP        ),
    .OUTPUT_H_FP               (  OUTPUT_H_FP        ),
    .OUTPUT_V_SYNC             (  OUTPUT_V_SYNC      ),
    .OUTPUT_V_BP               (  OUTPUT_V_BP        ),
    .OUTPUT_V_FP               (  OUTPUT_V_FP        )    
)
u_hdmi_timing
(
    .rst_n                 (   rst_n         ),
    .pclk_out              (   pclk_out      ),
    .start_to_rd           (   start_to_rd   ),
    .adjust_num            (   adjust_num    ),
    .de                    (   de            ),
    .vs                    (   vs            ),
    .hs                    (   hs            )
    );



always@(posedge pclk_out or negedge rst_n)begin
	if(~rst_n)begin
		de_r0 <= 0;
		de_r1 <= 0;
		
		hs_r0 <= 0;
		hs_r1 <= 0;	
		
		vs_r0 <= 0;
		vs_r1 <= 0;
	end 
    else begin
	    de_r0 <= de;
		de_r1 <= de_r0;
		
		hs_r0 <= hs;
		hs_r1 <= hs_r0;	
		
		vs_r0 <= vs;
		vs_r1 <= vs_r0;
	end 
end 	

assign   de_out        = de_r1  ;
assign   vs_out        = vs_r1  ;
assign   hs_out        = hs_r1 ;
assign   pix_data_out  = rd_data;

		
assign test0 = 	wr_en ;	
assign test1 = 	start_to_rd;	


 

   
endmodule