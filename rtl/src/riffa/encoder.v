module encoder (
    input   wire    [3:0]   in_ori_data,
    output  reg     [1:0]   out_enc_data
);

always @(*) begin
    case (in_ori_data)
        4'b0001:out_enc_data = 2'b00;
        4'b0011:out_enc_data = 2'b01;
        4'b0111:out_enc_data = 2'b10;
        4'b1111:out_enc_data = 2'b11; 
        default: out_enc_data = 2'b00;
    endcase
end
    
endmodule