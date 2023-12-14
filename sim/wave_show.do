onerror {resume}
quietly WaveActivateNextPane {} 0

add wave -noupdate -expand -group "system_sig" -color "yellow" /test_fpga_top/u_fpga_top/sys_clk_50m  
add wave -noupdate -expand -group "system_sig" -color "yellow" /test_fpga_top/u_fpga_top/ddr_init_done  
add wave -noupdate -expand -group "system_sig" -color "yellow" /test_fpga_top/u_fpga_top/ddr_rw_inst/dfi_reset_n
add wave -noupdate -expand -group "system_sig" -color "yellow" /test_fpga_top/u_fpga_top/ddr_rw_inst/ui_clk

add wave -noupdate -group "hdmi_input_data" -color "Gold" /test_fpga_top/u_fpga_top/hdmi_clk_in  
add wave -noupdate -group "hdmi_input_data" -color "Gold" /test_fpga_top/u_fpga_top/hdmi_hs_in   
add wave -noupdate -group "hdmi_input_data" -color "Gold" /test_fpga_top/u_fpga_top/hdmi_vs_in   
add wave -noupdate -group "hdmi_input_data" -color "Gold" /test_fpga_top/u_fpga_top/hdmi_de_in   
add wave -noupdate -group "hdmi_input_data" -color "Gold" /test_fpga_top/u_fpga_top/hdmi_data_in 

add wave -noupdate -group "hdmi_input_data" -color "Gold" /test_fpga_top/u_fpga_top/hdmi_clk_in  
add wave -noupdate -group "hdmi_input_data" -color "Gold" /test_fpga_top/u_fpga_top/hdmi_hs_scale_out   
add wave -noupdate -group "hdmi_input_data" -color "Gold" /test_fpga_top/u_fpga_top/hdmi_vs_scale_out   
add wave -noupdate -group "hdmi_input_data" -color "Gold" /test_fpga_top/u_fpga_top/hdmi_de_scale_out   
add wave -noupdate -group "hdmi_input_data" -color "Gold" /test_fpga_top/u_fpga_top/hdmi_data_scale_out 

add wave -noupdate -group "hdmi_dw_output_data" -color "Gold" /test_fpga_top/u_fpga_top/hdmi_wr_en     
add wave -noupdate -group "hdmi_dw_output_data" -color "Gold" /test_fpga_top/u_fpga_top/hdmi_data_dw_out        
add wave -noupdate -group "hdmi_dw_output_data" -color "Gold" /test_fpga_top/u_fpga_top/read_enable    
     
add wave -noupdate -group "hdmi_output_data" -color "Gold" /test_fpga_top/u_fpga_top/data_rd_valid_A        
add wave -noupdate -group "hdmi_output_data" -color "Gold" /test_fpga_top/u_fpga_top/hdmi_data_out        
add wave -noupdate -group "hdmi_output_data" -color "Gold" /test_fpga_top/u_fpga_top/data_rd_valid_B        
add wave -noupdate -group "hdmi_output_data" -color "Gold" /test_fpga_top/u_fpga_top/rd_data_B    

# ---------------------------

add wave -noupdate -group "A" -group "ctrl_in" -color "light blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_A_inst/wr_b_addr    
add wave -noupdate -group "A" -group "ctrl_in" -color "light blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_A_inst/wr_e_addr    
add wave -noupdate -group "A" -group "ctrl_in" -color "light blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_A_inst/user_wr_clk  
add wave -noupdate -group "A" -group "ctrl_in" -color "light blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_A_inst/data_wren    
add wave -noupdate -group "A" -group "ctrl_in" -color "light blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_A_inst/data_wr      
add wave -noupdate -group "A" -group "ctrl_in" -color "light blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_A_inst/wr_rst    

add wave -noupdate -group "A" -group "ctrl_wr_fifo" -color "Salmon" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_A_inst/wr_fifo_inst/wr_rst            
add wave -noupdate -group "A" -group "ctrl_wr_fifo" -color "Salmon" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_A_inst/wr_fifo_inst/rd_rst            
add wave -noupdate -group "A" -group "ctrl_wr_fifo" -color "Salmon" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_A_inst/wr_fifo_inst/wr_clk            
add wave -noupdate -group "A" -group "ctrl_wr_fifo" -color "Salmon" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_A_inst/wr_fifo_inst/rd_clk            
add wave -noupdate -group "A" -group "ctrl_wr_fifo" -color "Salmon" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_A_inst/wr_fifo_inst/wr_data           
add wave -noupdate -group "A" -group "ctrl_wr_fifo" -color "Salmon" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_A_inst/wr_fifo_inst/wr_en             
add wave -noupdate -group "A" -group "ctrl_wr_fifo" -color "Salmon" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_A_inst/wr_fifo_inst/rd_en             
add wave -noupdate -group "A" -group "ctrl_wr_fifo" -color "Salmon" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_A_inst/wr_fifo_inst/rd_data           
add wave -noupdate -group "A" -group "ctrl_wr_fifo" -color "Salmon" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_A_inst/wr_fifo_inst/wr_full           
add wave -noupdate -group "A" -group "ctrl_wr_fifo" -color "Salmon" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_A_inst/wr_fifo_inst/almost_full       
add wave -noupdate -group "A" -group "ctrl_wr_fifo" -color "Salmon" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_A_inst/wr_fifo_inst/rd_empty          
add wave -noupdate -group "A" -group "ctrl_wr_fifo" -color "Salmon" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_A_inst/wr_fifo_inst/almost_empty      
add wave -noupdate -group "A" -group "ctrl_wr_fifo" -color "Salmon" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_A_inst/wr_fifo_inst/rd_water_level    
add wave -noupdate -group "A" -group "ctrl_wr_fifo" -color "Salmon" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_A_inst/wr_fifo_inst/wr_water_level    


add wave -noupdate -group "A" -group "ctrl_out" -color "pink" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_A_inst/wr_fifo_rd_data_count        
add wave -noupdate -group "A" -group "ctrl_out" -color "pink" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_A_inst/wr_burst_req        
add wave -noupdate -group "A" -group "ctrl_out" -color "pink" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_A_inst/wr_burst_addr       
add wave -noupdate -group "A" -group "ctrl_out" -color "pink" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_A_inst/wr_burst_len        
add wave -noupdate -group "A" -group "ctrl_out" -color "pink" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_A_inst/wr_ready            
add wave -noupdate -group "A" -group "ctrl_out" -color "pink" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_A_inst/wr_fifo_re          
add wave -noupdate -group "A" -group "ctrl_out" -color "pink" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_A_inst/wr_fifo_data        
add wave -noupdate -group "A" -group "ctrl_out" -color "pink" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_A_inst/wr_burst_finish 

add wave -noupdate -group "A" -group "ctrl_rd_in" -color "pink" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_A_inst/rd_burst_req   
add wave -noupdate -group "A" -group "ctrl_rd_in" -color "pink" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_A_inst/rd_burst_addr  
add wave -noupdate -group "A" -group "ctrl_rd_in" -color "pink" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_A_inst/rd_burst_len   
add wave -noupdate -group "A" -group "ctrl_rd_in" -color "pink" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_A_inst/rd_ready       
add wave -noupdate -group "A" -group "ctrl_rd_in" -color "pink" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_A_inst/rd_fifo_we     
add wave -noupdate -group "A" -group "ctrl_rd_in" -color "pink" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_A_inst/rd_fifo_data   
add wave -noupdate -group "A" -group "ctrl_rd_in" -color "pink" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_A_inst/rd_burst_finish

add wave -noupdate -group "A" -group "ctrl_rd_fifo" -color "Cadet Blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_A_inst/rd_fifo_inst/wr_rst            
add wave -noupdate -group "A" -group "ctrl_rd_fifo" -color "Cadet Blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_A_inst/rd_fifo_inst/rd_rst            
add wave -noupdate -group "A" -group "ctrl_rd_fifo" -color "Cadet Blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_A_inst/rd_fifo_inst/wr_clk            
add wave -noupdate -group "A" -group "ctrl_rd_fifo" -color "Cadet Blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_A_inst/rd_fifo_inst/rd_clk            
add wave -noupdate -group "A" -group "ctrl_rd_fifo" -color "Cadet Blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_A_inst/rd_fifo_inst/wr_data           
add wave -noupdate -group "A" -group "ctrl_rd_fifo" -color "Cadet Blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_A_inst/rd_fifo_inst/wr_en             
add wave -noupdate -group "A" -group "ctrl_rd_fifo" -color "Cadet Blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_A_inst/rd_fifo_inst/rd_en             
add wave -noupdate -group "A" -group "ctrl_rd_fifo" -color "Cadet Blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_A_inst/rd_fifo_inst/rd_data           
add wave -noupdate -group "A" -group "ctrl_rd_fifo" -color "Cadet Blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_A_inst/rd_fifo_inst/wr_full           
add wave -noupdate -group "A" -group "ctrl_rd_fifo" -color "Cadet Blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_A_inst/rd_fifo_inst/almost_full       
add wave -noupdate -group "A" -group "ctrl_rd_fifo" -color "Cadet Blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_A_inst/rd_fifo_inst/rd_empty          
add wave -noupdate -group "A" -group "ctrl_rd_fifo" -color "Cadet Blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_A_inst/rd_fifo_inst/almost_empty      
add wave -noupdate -group "A" -group "ctrl_rd_fifo" -color "Cadet Blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_A_inst/rd_fifo_inst/rd_water_level    
add wave -noupdate -group "A" -group "ctrl_rd_fifo" -color "Cadet Blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_A_inst/rd_fifo_inst/wr_water_level    
    
# ---------------------------

add wave -noupdate -group "B" -group "ctrl_in" -color "light blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_B_inst/wr_b_addr    
add wave -noupdate -group "B" -group "ctrl_in" -color "light blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_B_inst/wr_e_addr    
add wave -noupdate -group "B" -group "ctrl_in" -color "light blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_B_inst/user_wr_clk  
add wave -noupdate -group "B" -group "ctrl_in" -color "light blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_B_inst/data_wren    
add wave -noupdate -group "B" -group "ctrl_in" -color "light blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_B_inst/data_wr      
add wave -noupdate -group "B" -group "ctrl_in" -color "light blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_B_inst/wr_rst    

add wave -noupdate -group "B" -group "ctrl_wr_fifo" -color "Salmon" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_B_inst/wr_fifo_inst/wr_rst            
add wave -noupdate -group "B" -group "ctrl_wr_fifo" -color "Salmon" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_B_inst/wr_fifo_inst/rd_rst            
add wave -noupdate -group "B" -group "ctrl_wr_fifo" -color "Salmon" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_B_inst/wr_fifo_inst/wr_clk            
add wave -noupdate -group "B" -group "ctrl_wr_fifo" -color "Salmon" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_B_inst/wr_fifo_inst/rd_clk            
add wave -noupdate -group "B" -group "ctrl_wr_fifo" -color "Salmon" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_B_inst/wr_fifo_inst/wr_data           
add wave -noupdate -group "B" -group "ctrl_wr_fifo" -color "Salmon" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_B_inst/wr_fifo_inst/wr_en             
add wave -noupdate -group "B" -group "ctrl_wr_fifo" -color "Salmon" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_B_inst/wr_fifo_inst/rd_en             
add wave -noupdate -group "B" -group "ctrl_wr_fifo" -color "Salmon" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_B_inst/wr_fifo_inst/rd_data           
add wave -noupdate -group "B" -group "ctrl_wr_fifo" -color "Salmon" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_B_inst/wr_fifo_inst/wr_full           
add wave -noupdate -group "B" -group "ctrl_wr_fifo" -color "Salmon" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_B_inst/wr_fifo_inst/almost_full       
add wave -noupdate -group "B" -group "ctrl_wr_fifo" -color "Salmon" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_B_inst/wr_fifo_inst/rd_empty          
add wave -noupdate -group "B" -group "ctrl_wr_fifo" -color "Salmon" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_B_inst/wr_fifo_inst/almost_empty      
add wave -noupdate -group "B" -group "ctrl_wr_fifo" -color "Salmon" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_B_inst/wr_fifo_inst/rd_water_level    
add wave -noupdate -group "B" -group "ctrl_wr_fifo" -color "Salmon" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_B_inst/wr_fifo_inst/wr_water_level    


add wave -noupdate -group "B" -group "ctrl_out" -color "pink" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_B_inst/wr_fifo_rd_data_count        
add wave -noupdate -group "B" -group "ctrl_out" -color "pink" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_B_inst/wr_burst_req        
add wave -noupdate -group "B" -group "ctrl_out" -color "pink" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_B_inst/wr_burst_addr       
add wave -noupdate -group "B" -group "ctrl_out" -color "pink" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_B_inst/wr_burst_len        
add wave -noupdate -group "B" -group "ctrl_out" -color "pink" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_B_inst/wr_ready            
add wave -noupdate -group "B" -group "ctrl_out" -color "pink" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_B_inst/wr_fifo_re          
add wave -noupdate -group "B" -group "ctrl_out" -color "pink" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_B_inst/wr_fifo_data        
add wave -noupdate -group "B" -group "ctrl_out" -color "pink" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_B_inst/wr_burst_finish 

add wave -noupdate -group "B" -group "ctrl_rd_in" -color "pink" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_B_inst/rd_burst_req   
add wave -noupdate -group "B" -group "ctrl_rd_in" -color "pink" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_B_inst/rd_burst_addr  
add wave -noupdate -group "B" -group "ctrl_rd_in" -color "pink" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_B_inst/rd_burst_len   
add wave -noupdate -group "B" -group "ctrl_rd_in" -color "pink" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_B_inst/rd_ready       
add wave -noupdate -group "B" -group "ctrl_rd_in" -color "pink" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_B_inst/rd_fifo_we     
add wave -noupdate -group "B" -group "ctrl_rd_in" -color "pink" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_B_inst/rd_fifo_data   
add wave -noupdate -group "B" -group "ctrl_rd_in" -color "pink" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_B_inst/rd_burst_finish

add wave -noupdate -group "B" -group "ctrl_rd_fifo" -color "Cadet Blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_B_inst/rd_fifo_inst/wr_rst            
add wave -noupdate -group "B" -group "ctrl_rd_fifo" -color "Cadet Blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_B_inst/rd_fifo_inst/rd_rst            
add wave -noupdate -group "B" -group "ctrl_rd_fifo" -color "Cadet Blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_B_inst/rd_fifo_inst/wr_clk            
add wave -noupdate -group "B" -group "ctrl_rd_fifo" -color "Cadet Blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_B_inst/rd_fifo_inst/rd_clk            
add wave -noupdate -group "B" -group "ctrl_rd_fifo" -color "Cadet Blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_B_inst/rd_fifo_inst/wr_data           
add wave -noupdate -group "B" -group "ctrl_rd_fifo" -color "Cadet Blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_B_inst/rd_fifo_inst/wr_en             
add wave -noupdate -group "B" -group "ctrl_rd_fifo" -color "Cadet Blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_B_inst/rd_fifo_inst/rd_en             
add wave -noupdate -group "B" -group "ctrl_rd_fifo" -color "Cadet Blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_B_inst/rd_fifo_inst/rd_data           
add wave -noupdate -group "B" -group "ctrl_rd_fifo" -color "Cadet Blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_B_inst/rd_fifo_inst/wr_full           
add wave -noupdate -group "B" -group "ctrl_rd_fifo" -color "Cadet Blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_B_inst/rd_fifo_inst/almost_full       
add wave -noupdate -group "B" -group "ctrl_rd_fifo" -color "Cadet Blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_B_inst/rd_fifo_inst/rd_empty          
add wave -noupdate -group "B" -group "ctrl_rd_fifo" -color "Cadet Blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_B_inst/rd_fifo_inst/almost_empty      
add wave -noupdate -group "B" -group "ctrl_rd_fifo" -color "Cadet Blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_B_inst/rd_fifo_inst/rd_water_level    
add wave -noupdate -group "B" -group "ctrl_rd_fifo" -color "Cadet Blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_ctrl_B_inst/rd_fifo_inst/wr_water_level    
    
# ---------------------------

add wave -noupdate -group "axi_wr" -color "Medium Slate Blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_master_write_inst/ACLK    
add wave -noupdate -group "axi_wr" -color "Medium Slate Blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_master_write_inst/wr_state    
add wave -noupdate -group "axi_wr" -color "Medium Slate Blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_master_write_inst/M_AXI_AWID    
add wave -noupdate -group "axi_wr" -color "Medium Slate Blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_master_write_inst/M_AXI_AWADDR  
add wave -noupdate -group "axi_wr" -color "Medium Slate Blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_master_write_inst/M_AXI_AWLEN   
add wave -noupdate -group "axi_wr" -color "Medium Slate Blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_master_write_inst/M_AXI_AWVALID 
add wave -noupdate -group "axi_wr" -color "Medium Slate Blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_master_write_inst/M_AXI_AWREADY
add wave -noupdate -group "axi_wr" -color "pink" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_master_write_inst/m_axi_ready_d2  
add wave -noupdate -group "axi_wr" -color "pink" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_master_write_inst/m_axi_last_d2   
add wave -noupdate -group "axi_wr" -color "pink" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_master_write_inst/M_AXI_WDATA   
add wave -noupdate -group "axi_wr" -color "Medium Slate Blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_master_write_inst/M_AXI_WSTRB   
add wave -noupdate -group "axi_wr" -color "Medium Slate Blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_master_write_inst/M_AXI_WLAST   
add wave -noupdate -group "axi_wr" -color "Medium Slate Blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_master_write_inst/M_AXI_WREADY  
add wave -noupdate -group "axi_wr" -color "Medium Slate Blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_master_write_inst/reg_w_len  

add wave -noupdate -group "axi_rd" -color "Medium Slate Blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_master_read_inst/M_AXI_ARID  
add wave -noupdate -group "axi_rd" -color "Medium Slate Blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_master_read_inst/M_AXI_ARADDR
add wave -noupdate -group "axi_rd" -color "Medium Slate Blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_master_read_inst/M_AXI_ARLEN 
add wave -noupdate -group "axi_rd" -color "Medium Slate Blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_master_read_inst/M_AXI_ARVALID
add wave -noupdate -group "axi_rd" -color "Medium Slate Blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_master_read_inst/M_AXI_ARREADY
add wave -noupdate -group "axi_rd" -color "Medium Slate Blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_master_read_inst/M_AXI_RID   
add wave -noupdate -group "axi_rd" -color "Medium Slate Blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_master_read_inst/M_AXI_RDATA 
add wave -noupdate -group "axi_rd" -color "Medium Slate Blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_master_read_inst/M_AXI_RLAST 
add wave -noupdate -group "axi_rd" -color "Medium Slate Blue" /test_fpga_top/u_fpga_top/ddr_rw_inst/axi_master_read_inst/M_AXI_RVALID

add wave -noupdate -group "pcie_write" /test_fpga_top/u_fpga_top/u_pcie_writer/sys_clk
add wave -noupdate -group "pcie_write" /test_fpga_top/u_fpga_top/u_pcie_writer/wr_en   
add wave -noupdate -group "pcie_write" /test_fpga_top/u_fpga_top/u_pcie_writer/wr_data 
add wave -noupdate -group "pcie_write" /test_fpga_top/u_fpga_top/u_pcie_writer/rd_en   
add wave -noupdate -group "pcie_write" /test_fpga_top/u_fpga_top/u_pcie_writer/rd_addr 
add wave -noupdate -group "pcie_write" /test_fpga_top/u_fpga_top/u_pcie_writer/rd_data 
add wave -noupdate -group "pcie_write"  -color "pink" /test_fpga_top/u_fpga_top/u_pcie_writer/wr_state
add wave -noupdate -group "pcie_write"  -color "pink" /test_fpga_top/u_fpga_top/u_pcie_writer/line_count

add wave -noupdate -group "hdmi_top_out"  -color "Blue Violet" /test_fpga_top/u_fpga_top/hdmi_clk_out 
add wave -noupdate -group "hdmi_top_out"  -color "Blue Violet" /test_fpga_top/u_fpga_top/hdmi_vs_out  
add wave -noupdate -group "hdmi_top_out"  -color "Blue Violet" /test_fpga_top/u_fpga_top/hdmi_hs_out  
add wave -noupdate -group "hdmi_top_out"  -color "Blue Violet" /test_fpga_top/u_fpga_top/hdmi_de_out  
add wave -noupdate -group "hdmi_top_out"  -color "Blue Violet" /test_fpga_top/u_fpga_top/hdmi_data_out
add wave -noupdate -group "hdmi_top_out_size_up"  -color "pink" /test_fpga_top/u_fpga_top/dma_rd_A_rden
add wave -noupdate -group "hdmi_top_out_size_up"  -color "pink" /test_fpga_top/u_fpga_top/hdmi_data_out_A
add wave -noupdate -group "hdmi_top_out_size_up"  -color "pink" /test_fpga_top/u_fpga_top/dma_rd_B_rden
add wave -noupdate -group "hdmi_top_out_size_up"  -color "pink" /test_fpga_top/u_fpga_top/hdmi_data_out_B
add wave -noupdate -group "hdmi_top_out_size_up"  -color "pink" /test_fpga_top/u_fpga_top/dma_rd_C_rden
add wave -noupdate -group "hdmi_top_out_size_up"  -color "pink" /test_fpga_top/u_fpga_top/hdmi_data_out_C
add wave -noupdate -group "hdmi_top_out_size_up"  -color "pink" /test_fpga_top/u_fpga_top/dma_rd_D_rden
add wave -noupdate -group "hdmi_top_out_size_up"  -color "pink" /test_fpga_top/u_fpga_top/hdmi_data_out_D


TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {432200 ns} 0}
configure wave -namecolwidth 155
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
configure wave -signalnamewidth 1

update
WaveRestoreZoom {432200ns} {432600ns}
