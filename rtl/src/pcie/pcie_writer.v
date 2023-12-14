module pcie_writer (
    input   wire            sys_clk         ,
    input   wire            sys_rst_n       ,

    input   wire            pclk_div2       ,
    input   wire            core_rst_n      ,

    output  wire            wr_en           ,
    input   wire [15:0]     wr_data         ,

    input   wire            rd_en           ,
    input   wire [11:0]     rd_addr         ,
    output  wire [15:0]     rd_data               
) ;


localparam S_WR_IDLE  = 3'd0;
localparam S_WR_START = 3'd1;
localparam S_WR_DONE  = 3'd2;

reg  [2:0]         wr_state                         ;
reg  [2:0]         wr_state_next                    ;

wire                rd_en_posedge   ;
reg                 rd_en_posedge_d1;

wire                rd_en_negedge   ;
reg                 rd_en_negedge_d1;

reg                 rd_en_d1        ;

reg [15:0]          line_count      ;

assign rd_en_posedge = ~rd_en_d1 & rd_en;
assign rd_en_negedge = rd_en_d1 & ~rd_en;

assign wr_en = (wr_state == S_WR_START) ? 1'd1 : 1'd0;

always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        wr_state <= 3'd0;
    end else begin
        wr_state <= wr_state_next;
    end
end

always @(*) begin
    case (wr_state)
        S_WR_IDLE : begin
            if(rd_en_posedge_d1) begin
                wr_state_next = S_WR_START;
            end else begin
                wr_state_next = S_WR_IDLE;
            end
        end 

        S_WR_START : begin
            if(rd_en_negedge_d1 || line_count == ((16'd1920) - 1)) begin
                wr_state_next = S_WR_DONE;
            end else begin
                wr_state_next = S_WR_START;
            end
        end

        S_WR_DONE : begin
            wr_state_next = S_WR_IDLE;
        end

        default: 
            wr_state_next = S_WR_IDLE;
    endcase
end

always @(posedge pclk_div2 or negedge core_rst_n) begin
    if(!core_rst_n) begin
        rd_en_posedge_d1 <= 1'd0;
        rd_en_negedge_d1 <= 1'd0;
        rd_en_d1 <= 1'd0;
    end else begin
        rd_en_posedge_d1 <= rd_en_posedge;
        rd_en_negedge_d1 <= rd_en_negedge;
        rd_en_d1 <= rd_en;
    end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        line_count <= 16'd0;
    end else begin
        if(wr_state == S_WR_START) begin
            line_count <= line_count + 1'd1;
        end else begin
            line_count <= 16'd0;
        end
    end
end

ram_16in_16out u_ram_16in_16out 
(
    .wr_clk             (sys_clk             ),  // input
    .wr_rst             (~sys_rst_n          ),  // input
    .wr_en              (wr_en               ),  // input
    .wr_byte_en         (2'b11               ),  // input [1:0]
    .wr_addr            (line_count[11:0]    ),  // input [11:0]
    .wr_data            (wr_data             ),  // input [15:0]
    
    .rd_clk             (pclk_div2             ),  // input
    .rd_rst             (~core_rst_n          ),  // input
    .rd_clk_en          (rd_en               ),  // input
    .rd_addr            (rd_addr[11:0]       ),  // input [11:0]
    .rd_data            (rd_data             )   // output [15:0]
);



endmodule