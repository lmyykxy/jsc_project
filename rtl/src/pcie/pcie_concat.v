module pcie_concat (
    input   wire        pclk_div2       /* synthesis PAP_MARK_DEBUG=”true”*/,
    input   wire        core_rst_n      ,

    input   wire [31:0] wr_addr         ,
    input   wire        wr_en           /* synthesis PAP_MARK_DEBUG=”true”*/,
    input   wire [15:0] wr_data_16_in   /* synthesis PAP_MARK_DEBUG=”true”*/,

    output  wire        wr_en_32_out    /* synthesis PAP_MARK_DEBUG=”true”*/,
    output  wire [31:0] wr_data_32_out  /* synthesis PAP_MARK_DEBUG=”true”*/ 
);

reg [31:0]  wr_data_32_out_reg  ;
reg         hex_point           ;
reg         wr_en_32_out_reg    ;

assign wr_data_32_out = wr_data_32_out_reg;
assign wr_en_32_out = wr_en_32_out_reg;

always @(posedge pclk_div2 or negedge core_rst_n) begin
    if(core_rst_n == 0) begin
        wr_data_32_out_reg <= 32'd0;
        wr_en_32_out_reg <= 1'd0;
    end else begin
        if(wr_en) begin
            if(hex_point == 0) begin
                wr_data_32_out_reg <= {16'd0, wr_data_16_in};
                wr_en_32_out_reg <= 1'b0;
            end else begin
                wr_data_32_out_reg <= {wr_data_16_in, wr_data_32_out_reg[15:0]};
                wr_en_32_out_reg <= 1'b1;
            end
        end else begin
            wr_data_32_out_reg <= 32'd0;
            wr_en_32_out_reg <= 1'b0;
        end
    end
end

always @(posedge pclk_div2 or negedge core_rst_n) begin
    if(core_rst_n == 0) begin
        hex_point <= 1'd0;
    end else begin
        if(wr_en) begin
            hex_point <= ~hex_point; 
        end else begin
            hex_point <= 1'b0;
        end
    end
end

reg [19:0] sec_count;
reg sec_record,sec_record_d1/* synthesis PAP_MARK_DEBUG=”true”*/;
always @(posedge pclk_div2 or negedge core_rst_n) begin
    if(core_rst_n == 0) begin
        sec_count <= 20'd0;
        sec_record <= 1'd0;
        sec_record_d1<= 1'd0;
    end else begin
        if(sec_count <= 125000) begin
            sec_count <= sec_count + 1'b1;
            sec_record<= sec_record;
        end else begin
            sec_count <= 20'd1;
            sec_record <= ~sec_record;
        end
        sec_record_d1 <= sec_count;
    end
end

reg [31:0] frame_cnt,frame_rate/* synthesis PAP_MARK_DEBUG=”true”*/;
always @(posedge pclk_div2 or negedge core_rst_n) begin
    if(core_rst_n == 0) begin
        frame_cnt <= 32'd0;
        frame_rate <= 32'd0;
    end else begin
        if(!sec_record_d1 && sec_record) begin
            frame_cnt <= 32'd0;
            frame_rate <= frame_rate;
        end else if(sec_record == 1 && wr_en == 0 && wr_addr == 32'd512) begin
            frame_cnt <= frame_cnt + 1'b1; 
            frame_rate <= frame_rate;
        end else if(sec_record == 0 && wr_en == 0 && wr_addr == 32'd512) begin
            frame_cnt <= frame_cnt;
            frame_rate <= frame_cnt;
        end else begin
            frame_cnt <= frame_cnt;
            frame_rate <= frame_rate;
        end
    end
end
    
endmodule