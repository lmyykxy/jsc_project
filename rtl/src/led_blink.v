module led_blink (
    input   wire    blink_clk       ,
    input   wire    sys_rst_n       ,

    output  reg     blink_led       
);

reg [31:0] counter = 0;
reg toggle = 0;

always @(posedge blink_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        toggle <= 1'd0;
        counter <= 32'd0;
    end else begin
        if (counter == 32'd50000000) begin
            toggle <= ~toggle;
            counter <= 0;
        end else begin
            counter <= counter + 1;
        end
    end
end

always @(posedge blink_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        blink_led <= 1'd0;
    end else begin
        if (toggle) begin
            blink_led <= 1'b1;
        end else begin
            blink_led <= 1'b0;
        end
    end
end
    
endmodule