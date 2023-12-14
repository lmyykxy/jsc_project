module one_hot_encoder (
    input   wire [15:0]     input_b ,
    output  reg  [4:0]      output_d
);

always @(*) begin
    case (input_b)
        16'b0000_0000_0000_0001: output_d = 5'd0;
        16'b0000_0000_0000_0010: output_d = 5'd1;
        16'b0000_0000_0000_0100: output_d = 5'd2;
        16'b0000_0000_0000_1000: output_d = 5'd3;
        16'b0000_0000_0001_0000: output_d = 5'd4;
        16'b0000_0000_0010_0000: output_d = 5'd5;
        16'b0000_0000_0100_0000: output_d = 5'd6;
        16'b0000_0000_1000_0000: output_d = 5'd7;
        16'b0000_0001_0000_0000: output_d = 5'd8;
        16'b0000_0010_0000_0000: output_d = 5'd9;
        16'b0000_0100_0000_0000: output_d = 5'd10;
        16'b0000_1000_0000_0000: output_d = 5'd11;
        16'b0001_0000_0000_0000: output_d = 5'd12;
        16'b0010_0000_0000_0000: output_d = 5'd13;
        16'b0100_0000_0000_0000: output_d = 5'd14;
        16'b1000_0000_0000_0000: output_d = 5'd15;
        default: output_d = 5'd16;
    endcase
end
    
endmodule