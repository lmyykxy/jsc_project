module WRport_arbitor_v2#(
    parameter W_NUM_CHNL = 4'd4,
    parameter R_NUM_CHNL = 4'd5
) (
    input   wire                            ui_clk                  ,
    input   wire                            ui_rst                  ,

    input   wire                            rd_rst                  ,

    input   wire [W_NUM_CHNL-1:0]           Wport_wr_burst_req      ,
    input   wire [(W_NUM_CHNL*32)-1:0]      Wport_wr_burst_addr     ,
    input   wire [(W_NUM_CHNL*10)-1:0]      Wport_wr_burst_len      ,
    output  wire [W_NUM_CHNL-1:0]           Wport_wr_ready          ,
    output  wire [W_NUM_CHNL-1:0]           Wport_wr_fifo_re        ,
    input   wire [(W_NUM_CHNL*256)-1:0]     Wport_wr_fifo_data      ,
    output  wire [W_NUM_CHNL-1:0]           Wport_wr_burst_finish   ,

    input   wire [R_NUM_CHNL-1:0]           Rport_rd_burst_req      ,
    input   wire [(R_NUM_CHNL*32)-1:0]      Rport_rd_burst_addr     ,
    input   wire [(R_NUM_CHNL*10)-1:0]      Rport_rd_burst_len      ,
    output  wire [R_NUM_CHNL-1:0]           Rport_rd_ready          ,
    output  wire [R_NUM_CHNL-1:0]           Rport_rd_fifo_we        ,
    output  wire [(R_NUM_CHNL*256)-1:0]     Rport_rd_fifo_data      ,
    output  wire [R_NUM_CHNL-1:0]           Rport_rd_burst_finish   ,

    output  wire                            wr_burst_req            , 
    output  wire  [31:0]                    wr_burst_addr           , 
    output  wire  [9:0]                     wr_burst_len            , 
    input   wire                            wr_ready                , 
    input   wire                            wr_fifo_re              , 
    output  wire [255:0]                    wr_fifo_data            , 
    input   wire                            wr_burst_finish         , 

    output  wire                            rd_burst_req            , 
    output  wire  [31:0]                    rd_burst_addr           , 
    output  wire  [9:0]                     rd_burst_len            , 
    input   wire                            rd_ready                , 
    input   wire                            rd_fifo_we              , 
    input   wire [255:0]                    rd_fifo_data            , 
    input   wire                            rd_burst_finish   
);

// Write Port
wire                            W_grant_valid;
wire    [W_NUM_CHNL-1:0]        Wport_grant;

reg     [W_NUM_CHNL-1:0]        Wgrant_reg  ;
reg     [(W_NUM_CHNL*32)-1:0]   Wport_wr_burst_addr_reg;
reg     [(W_NUM_CHNL*10)-1:0]   Wport_wr_burst_len_reg;



wire [4:0] W_select/* synthesis PAP_MARK_DEBUG="1" */;
one_hot_encoder W_encoder(
    .input_b(16'b0 | Wport_grant),
    .output_d(W_select)
);

assign wr_burst_addr = (W_select == 5'd16) ? 32'd0 : Wport_wr_burst_addr_reg[32*W_select +:32];
assign wr_burst_len = (W_select == 5'd16) ? 10'd0 : Wport_wr_burst_len_reg[10*W_select +:10];
assign wr_burst_req = (W_select == 5'd16) ? 1'd0 : 1'd1;


always @(posedge ui_clk or posedge ui_rst) begin
    if(ui_rst) begin
        Wgrant_reg <= 'b0;
    end else begin
        if(W_grant_valid) begin
            Wgrant_reg <= Wport_grant;
        end
    end
end

genvar i;
generate
	for (i = 0; i < W_NUM_CHNL; i = i + 1) begin 
		always @(posedge ui_clk or posedge ui_rst) begin
            if(ui_rst) begin
                Wport_wr_burst_addr_reg[32*i +:32] <= 'd0;
                Wport_wr_burst_len_reg[10*i +:10] <= 'd0;
            end else begin
                if(Wport_wr_burst_req[i]) begin
                    Wport_wr_burst_addr_reg[32*i +:32] <= Wport_wr_burst_addr[32*i +:32];
                    Wport_wr_burst_len_reg[10*i +:10] <= Wport_wr_burst_len[10*i +:10];
                end
            end
        end
	end
endgenerate

generate
	for (i = 0; i < W_NUM_CHNL; i = i + 1) begin 
		assign Wport_wr_ready[i] = wr_ready;
	end
endgenerate

generate
    for (i = 0; i < W_NUM_CHNL; i = i + 1) begin
        assign Wport_wr_fifo_re[i] = (Wgrant_reg == (1 << i)) ? wr_fifo_re : 1'd0;
    end
endgenerate



assign wr_fifo_data = (W_select == 5'd16) ? {256{1'b0}} : Wport_wr_fifo_data[256*W_select+:256];


generate
    for (i = 0; i < W_NUM_CHNL; i = i + 1) begin
        assign Wport_wr_burst_finish[i] = (Wgrant_reg == (1 << i)) ? wr_burst_finish : 1'd0;
    end
endgenerate 


// Arbitor
arbiter #(
    .PORTS                 ( W_NUM_CHNL ),
    .ARB_TYPE_ROUND_ROBIN  ( 1 ),
    .ARB_BLOCK             ( 1 ),
    .ARB_BLOCK_ACK         ( 1 ),
    .ARB_LSB_HIGH_PRIORITY ( 0 )
) u_Warbiter (
    .clk                   ( ui_clk                 ),
    .rst                   ( ui_rst                 ),

    .request               ( Wport_wr_burst_req     ),
    .acknowledge           ( Wport_wr_burst_finish  ),

    .grant                 ( Wport_grant            ),
    .grant_valid           ( W_grant_valid          ),
    .grant_encoded         ()
);


//Rport A & B
wire R_RST = rd_rst || ui_rst;

wire    R_grant_valid;

wire    [R_NUM_CHNL-1:0]        Rport_grant;


reg     [R_NUM_CHNL-1:0]        Rgrant_reg;


reg     [(R_NUM_CHNL*32)-1:0]   Rport_rd_burst_addr_reg;
reg     [(R_NUM_CHNL*10)-1:0]   Rport_rd_burst_len_reg;

wire [4:0] R_select/* synthesis PAP_MARK_DEBUG="1" */;
one_hot_encoder R_encoder(
    .input_b(16'b0 | Rport_grant),
    .output_d(R_select)
);

assign rd_burst_addr = (R_select == 5'd16) ? 32'd0 : Rport_rd_burst_addr_reg[32*R_select +:32];
assign rd_burst_len = (R_select == 5'd16) ? 10'd0 : Rport_rd_burst_len_reg[10*R_select +:10];
assign rd_burst_req = (R_select == 5'd16) ? 1'd0 : 1'd1;

always @(posedge ui_clk or posedge ui_rst) begin
    if(ui_rst) begin
        Rgrant_reg <= 'b0;
    end else begin
        if(R_grant_valid) begin
            Rgrant_reg <= Rport_grant;
        end
    end
end

generate
	for (i = 0; i < R_NUM_CHNL; i = i + 1) begin
		always @(posedge ui_clk or posedge ui_rst) begin
            if(ui_rst) begin
                Rport_rd_burst_addr_reg[32*i +:32] <= 32'd0;
                Rport_rd_burst_len_reg[10*i +:10] <= 10'd0;
            end else begin
                if(Rport_rd_burst_req[i]) begin
                    Rport_rd_burst_addr_reg[32*i +:32] <= Rport_rd_burst_addr[32*i +:32];
                    Rport_rd_burst_len_reg[10*i +:10] <= Rport_rd_burst_len[10*i +:10];
                end
            end
        end
	end
endgenerate

generate
	for (i = 0; i < R_NUM_CHNL; i = i + 1) begin 
		assign Rport_rd_ready[i] = rd_ready;
	end
endgenerate

generate
    for (i = 0; i < R_NUM_CHNL; i = i + 1) begin
        assign Rport_rd_fifo_we[i] = (Rgrant_reg == (1 << i)) ? rd_fifo_we : 1'd0;
    end
endgenerate


generate
    for (i = 0; i < R_NUM_CHNL; i = i + 1) begin
        assign Rport_rd_fifo_data[256*i +: 256] = (Rgrant_reg == (1 << i)) ? rd_fifo_data : {256{1'b0}};
    end
endgenerate

generate
    for (i = 0; i < R_NUM_CHNL; i = i + 1) begin
        assign Rport_rd_burst_finish[i] = (Rgrant_reg == (1 << i)) ? rd_burst_finish : 1'd0;
    end
endgenerate 

// Arbitor
arbiter #(
    .PORTS                 ( R_NUM_CHNL ),
    .ARB_TYPE_ROUND_ROBIN  ( 1 ),
    .ARB_BLOCK             ( 1 ),
    .ARB_BLOCK_ACK         ( 1 ),
    .ARB_LSB_HIGH_PRIORITY ( 0 )
) u_Rarbiter (
    .clk                   ( ui_clk                 ),
    .rst                   ( ui_rst                  ),

    .request               ( Rport_rd_burst_req     ), 
    .acknowledge           ( Rport_rd_burst_finish  ), 

    .grant                 ( Rport_grant            ), 
    .grant_valid           ( R_grant_valid          ), 
    .grant_encoded         ()
);

endmodule