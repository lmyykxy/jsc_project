`timescale  1ns/1ns
module  pcie_rd_convert (
    input   wire            sys_rst_n      		,  
    input   wire            pclk_div2       	,
	input 	wire			pcie_data_in_enable ,

	output	reg 			dma_rd_A_rden		,
	output	reg 			dma_rd_B_rden		,
	output	reg 			dma_rd_C_rden		,
	output	reg 			dma_rd_D_rden		
);


reg[11:0] h_cnt;                 //horizontal counter
reg[11:0] v_cnt;                 //vertical counter


reg h_active;                    //horizontal video active
reg v_active;                    //vertical video active
wire video_active;               //video active(horizontal active and vertical active)

// assign video_active = h_active & v_active;
assign video_active = 1;

always @(*) begin
	dma_rd_A_rden = 1'b0;
	dma_rd_B_rden = 1'b0;
	dma_rd_C_rden = 1'b0;
	dma_rd_D_rden = 1'b0;
	
	if(v_cnt <= 540 -1) begin
		if(h_cnt <= 960 -1)begin
			dma_rd_A_rden = video_active;
		end else begin
			dma_rd_B_rden = video_active;
		end
	end 
	else begin
		if(h_cnt <= 960 -1)begin
			dma_rd_C_rden = video_active;
		end else begin
			dma_rd_D_rden = video_active;
		end
	end
end

always@(posedge pclk_div2 or negedge pcie_data_in_enable)
begin
	if(pcie_data_in_enable == 1'b0)
		h_cnt <= 12'd0;
	else if(h_cnt == 1920 - 1)//horizontal counter maximum value
		h_cnt <= 12'd0;
	else
		h_cnt <= h_cnt + 12'd1;
end



always@(posedge pclk_div2 or negedge pcie_data_in_enable)
begin
	if(pcie_data_in_enable == 1'b0)
		v_cnt <= 12'd0;
	else if(h_cnt == 0)//horizontal sync time
		if(v_cnt == 1080 - 1)//vertical counter maximum value
			v_cnt <= 12'd0;
		else
			v_cnt <= v_cnt + 12'd1;
	else
		v_cnt <= v_cnt;
end



// always@(posedge pclk_div2 or negedge sys_rst_n)
// begin
// 	if(sys_rst_n == 1'b0)
// 		h_active <= 1'b0;
// 	else if(h_cnt == 0)//horizontal active begin
// 		h_active <= 1'b1;
// 	else if(h_cnt == 1920 - 1)//horizontal active end
// 		h_active <= 1'b0;
// 	else
// 		h_active <= h_active;
// end


// always@(posedge pclk_div2 or negedge sys_rst_n)
// begin
// 	if(sys_rst_n == 1'b0)
// 		v_active <= 1'd0;
// 	else if((v_cnt == 0) && (h_cnt == 0 ))//vertical active begin
// 		v_active <= 1'b1;
// 	else if((v_cnt == 1080 - 1) && (h_cnt == 0)) //vertical active end
// 		v_active <= 1'b0;   
// 	else
// 		v_active <= v_active;
// 	end

endmodule
