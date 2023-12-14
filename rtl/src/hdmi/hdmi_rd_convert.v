`timescale  1ns/1ns
`include "../header/fpga_header.vh"
module  hdmi_rd_convert (
    input   wire            sys_rst_n      		,  

    input   wire            hdmi_clk       		,
    input  	wire        	data_rd_valid       ,
    output	wire            hdmi_hs_out        	,
    output	wire            hdmi_vs_out        	,
    output	wire            hdmi_de_out         ,

	output	reg 			dma_rd_A_rden		,
	output	reg 			dma_rd_B_rden		,
	output	reg 			dma_rd_C_rden		,
	output	reg 			dma_rd_D_rden		
);

`ifdef sim
	parameter H_ACTIVE = 16'd1920; 
	parameter H_FP = 16'd2;      
	parameter H_SYNC = 16'd2;   
	parameter H_BP = 16'd2;      
	parameter V_ACTIVE = 16'd4; 
	parameter V_FP  = 16'd2;     
	parameter V_SYNC  = 16'd2;    
	parameter V_BP  = 16'd2;    
	parameter HS_POL = 1'b1;
	parameter VS_POL = 1'b1;
`else
	parameter H_ACTIVE = 16'd1920;
	parameter H_FP = 16'd88;
	parameter H_SYNC = 16'd44;
	parameter H_BP = 16'd148; 
	parameter V_ACTIVE = 16'd1080;
	parameter V_FP  = 16'd4;
	parameter V_SYNC  = 16'd5;
	parameter V_BP  = 16'd36;
	parameter HS_POL = 1'b1;
	parameter VS_POL = 1'b1;
`endif

parameter H_TOTAL = H_ACTIVE + H_FP + H_SYNC + H_BP;//horizontal total time (pixels)
parameter V_TOTAL = V_ACTIVE + V_FP + V_SYNC + V_BP;//vertical total time (lines)

reg hs_reg;                      //horizontal sync register
reg vs_reg;                      //vertical sync register
reg hs_reg_d0;                   //delay 1 clock of 'hs_reg'
reg vs_reg_d0;                   //delay 1 clock of 'vs_reg'
reg[11:0] h_cnt;                 //horizontal counter
reg[11:0] v_cnt;                 //vertical counter
reg[11:0] active_x;              //video x position 
reg[11:0] active_y;              //video y position 

reg h_active;                    //horizontal video active
reg v_active;                    //vertical video active
wire video_active;               //video active(horizontal active and vertical active)
reg video_active_d0;             //delay 1 clock of video_active
assign hdmi_hs_out = hs_reg_d0;
assign hdmi_vs_out = vs_reg_d0;
assign video_active = h_active & v_active;
assign hdmi_de_out = video_active_d0;

reg dma_rd_A_rden_d0;
reg dma_rd_B_rden_d0;
reg dma_rd_C_rden_d0;
reg dma_rd_D_rden_d0;

always @(*) begin
	dma_rd_A_rden_d0 = 1'b0;
	dma_rd_B_rden_d0 = 1'b0;
	dma_rd_C_rden_d0 = 1'b0;
	dma_rd_D_rden_d0 = 1'b0;
	
	if(v_cnt <= V_FP + V_SYNC + V_BP + (V_ACTIVE / 2) -1) begin
		if(h_cnt <= H_FP + H_SYNC + H_BP + (H_ACTIVE/2) -1)begin
			dma_rd_A_rden_d0 = video_active;
		end else begin
			dma_rd_B_rden_d0 = video_active;
		end
	end else begin
		if(h_cnt <= H_FP + H_SYNC + H_BP + (H_ACTIVE/2) -1)begin
			dma_rd_C_rden_d0 = video_active;
		end else begin
			dma_rd_D_rden_d0 = video_active;
		end
	end
end


always@(posedge hdmi_clk or negedge sys_rst_n)
begin
	if(sys_rst_n == 1'b0)
		begin
			dma_rd_A_rden <= 1'b0;
			dma_rd_B_rden <= 1'b0;
			dma_rd_C_rden <= 1'b0;
			dma_rd_D_rden <= 1'b0;
		end
	else
		begin
			dma_rd_A_rden <= dma_rd_A_rden_d0;
			dma_rd_B_rden <= dma_rd_B_rden_d0;
			dma_rd_C_rden <= dma_rd_C_rden_d0;
			dma_rd_D_rden <= dma_rd_D_rden_d0;
		end
end

always@(posedge hdmi_clk or negedge sys_rst_n)
begin
	if(sys_rst_n == 1'b0)
		begin
			hs_reg_d0 <= 1'b0;
			vs_reg_d0 <= 1'b0;
			video_active_d0 <= 1'b0;
		end
	else
		begin
			hs_reg_d0 <= hs_reg;
			vs_reg_d0 <= vs_reg;
			video_active_d0 <= video_active;
		end
end

always@(posedge hdmi_clk or negedge sys_rst_n)
begin
	if(sys_rst_n == 1'b0)
		h_cnt <= 12'd0;
	else if(h_cnt == H_TOTAL - 1)//horizontal counter maximum value
		h_cnt <= 12'd0;
	else
		h_cnt <= h_cnt + 12'd1;
end

always@(posedge hdmi_clk or negedge sys_rst_n)
begin
	if(sys_rst_n == 1'b0)
		active_x <= 12'd0;
	else if(h_cnt >= H_FP + H_SYNC + H_BP - 1)//horizontal video active
		active_x <= h_cnt - (H_FP[11:0] + H_SYNC[11:0] + H_BP[11:0] - 12'd1);
	else
		active_x <= active_x;
end

always@(posedge hdmi_clk or negedge sys_rst_n)
begin
	if(sys_rst_n == 1'b0)
		v_cnt <= 12'd0;
	else if(h_cnt == H_FP  - 1)//horizontal sync time
		if(v_cnt == V_TOTAL - 1)//vertical counter maximum value
			v_cnt <= 12'd0;
		else
			v_cnt <= v_cnt + 12'd1;
	else
		v_cnt <= v_cnt;
end

always@(posedge hdmi_clk or negedge sys_rst_n)
begin
	if(sys_rst_n == 1'b0)
		hs_reg <= 1'b0;
	else if(h_cnt == H_FP - 1)//horizontal sync begin
		hs_reg <= HS_POL;
	else if(h_cnt == H_FP + H_SYNC - 1)//horizontal sync end
		hs_reg <= ~hs_reg;
	else
		hs_reg <= hs_reg;
end

always@(posedge hdmi_clk or negedge sys_rst_n)
begin
	if(sys_rst_n == 1'b0)
		h_active <= 1'b0;
	else if(h_cnt == H_FP + H_SYNC + H_BP - 1)//horizontal active begin
		h_active <= 1'b1;
	else if(h_cnt == H_TOTAL - 1)//horizontal active end
		h_active <= 1'b0;
	else
		h_active <= h_active;
end

always@(posedge hdmi_clk or negedge sys_rst_n)
begin
	if(sys_rst_n == 1'b0)
		vs_reg <= 1'd0;
	else if((v_cnt == V_FP - 1) && (h_cnt == H_FP - 1))//vertical sync begin
		vs_reg <= HS_POL;
	else if((v_cnt == V_FP + V_SYNC - 1) && (h_cnt == H_FP - 1))//vertical sync end
		vs_reg <= ~vs_reg;  
	else
		vs_reg <= vs_reg;
end

always@(posedge hdmi_clk or negedge sys_rst_n)
begin
	if(sys_rst_n == 1'b0)
		v_active <= 1'd0;
	else if((v_cnt == V_FP + V_SYNC + V_BP - 1) && (h_cnt == H_FP - 1))//vertical active begin
		v_active <= 1'b1;
	else if((v_cnt == V_TOTAL - 1) && (h_cnt == H_FP - 1)) //vertical active end
		v_active <= 1'b0;   
	else
		v_active <= v_active;
	end

endmodule
