`timescale  1ns/1ns

module axi_master_write
(
  input           ARESETN    , 
  input           ACLK       , 

  output [3:0]  M_AXI_AWID   , 
  output [31:0] M_AXI_AWADDR , 
  output [7:0]  M_AXI_AWLEN  , 
  output        M_AXI_AWVALID, 
  input         M_AXI_AWREADY, 

  output [255:0] M_AXI_WDATA  , 
  output [31:0]  M_AXI_WSTRB  , 
  input         M_AXI_WLAST  , 
  input         M_AXI_WREADY , 

  input         WR_START     , 
  input [31:0]  WR_ADRS      , 
  input [9:0]   WR_LEN       , 
  output        WR_READY     , 
  output        WR_FIFO_RE   , 
  input [255:0]  WR_FIFO_DATA , 
  output        WR_DONE        
);

localparam S_WR_IDLE  = 3'd0;
localparam S_WA_WAIT  = 3'd1;
localparam S_WA_START = 3'd2;
localparam S_WD_WAIT  = 3'd3;
localparam S_WD_PROC  = 3'd4;
localparam S_WR_WAIT  = 3'd5;
localparam S_WR_DONE  = 3'd6;
//reg define  
reg [2:0]   wr_state   ; 
reg [31:0]  reg_wr_adrs; 
reg         reg_awvalid; 

reg         reg_w_last ; 
reg [7:0]   reg_w_len  ; 
reg [7:0]   reg_w_stb  ;

wire         m_axi_ready_d1;
wire         m_axi_ready_d2;
wire         m_axi_last_d1;
wire         m_axi_last_d2;

reg [31:0] wr_addr_reg;
reg [9:0]  wr_len_reg;

assign WR_DONE = (wr_state == S_WR_DONE);

assign WR_FIFO_RE         = m_axi_ready_d2;

assign M_AXI_AWID         = 4'b0000;

assign M_AXI_AWADDR[31:0] = reg_wr_adrs[31:0];

assign M_AXI_AWLEN[7:0]   = wr_len_reg;

assign M_AXI_AWVALID      = reg_awvalid;

assign M_AXI_WDATA[255:0]  = WR_FIFO_DATA[255:0];
assign M_AXI_WSTRB[31:0]   = 32'hFFFF_FFFF;

// assign M_AXI_WLAST        = m_axi_last_d2;

assign WR_READY           = (wr_state == S_WR_IDLE)?1'b1:1'b0;

always @(posedge ACLK or negedge ARESETN) begin
    if(!ARESETN) begin
      wr_state            <= S_WR_IDLE;
      reg_wr_adrs[31:0]   <= 32'd0;
      wr_len_reg          <= 10'd0;
      reg_awvalid         <= 1'b0;
      reg_w_last          <= 1'b0;
      reg_w_len[7:0]      <= 8'd0;
      
  end else begin
      case(wr_state)
        S_WR_IDLE: begin
          if(WR_START) begin
            wr_state          <= S_WA_WAIT;
            reg_wr_adrs[31:0] <= WR_ADRS[31:0];
            wr_len_reg <= WR_LEN;
          end
          reg_awvalid         <= 1'b0;
          reg_w_len[7:0]      <= 8'd0;
        end
        S_WA_WAIT: begin
          wr_state        <= S_WA_START;
        end
        S_WA_START: begin
          wr_state        <= S_WD_WAIT;
          reg_awvalid     <= 1'b1;  
        end
        S_WD_WAIT: begin
          if(M_AXI_AWREADY) begin
            wr_state        <= S_WD_PROC;
            reg_w_len       <= wr_len_reg-'d1;
            reg_awvalid     <= 1'b0;
          end
        end
        S_WD_PROC: begin   
            if(m_axi_ready_d2)begin
              if(reg_w_len[7:0] == 8'd0) begin
                wr_state        <= S_WR_WAIT;
                reg_w_last      <= 1'b1;
                end           
                else begin
                reg_w_len[7:0]  <= reg_w_len[7:0] -8'd1;
              end
            end
          end
        S_WR_WAIT: begin
          reg_w_last        <=1'b0;
          wr_state          <= S_WR_DONE;
        
        end
        S_WR_DONE: begin    
            wr_state <= S_WR_IDLE;
          end
        
        default: begin
          wr_state <= S_WR_IDLE;
        end
      endcase
      end
  end


/* old version deprecated!
always @(posedge ACLK or negedge ARESETN) begin
  if(!ARESETN) begin
    m_axi_ready_d1 <= 1'd0;
    m_axi_ready_d2 <= 1'd0;
    m_axi_last_d1 <= 1'b0;
    m_axi_last_d2 <= 1'b0;
  end else begin
    m_axi_ready_d1 <= M_AXI_WREADY;
    m_axi_ready_d2 <= m_axi_ready_d1;
    m_axi_last_d1 <= M_AXI_WLAST;
    m_axi_last_d2 <= m_axi_last_d1;
  end
end
*/
assign m_axi_ready_d2 = M_AXI_WREADY;
assign m_axi_last_d2  = M_AXI_WLAST;


endmodule

