module b_mux(reg_file_data_b, imm_gen_out, alu_forward, dmem_foward, b_sel, b_out);
    input [31:0] reg_file_data_b, imm_gen_out, alu_forward, dmem_foward;
    input [1:0] b_sel;
    output reg [31:0] b_out;

    always @(*) begin
        case(b_sel)
            2'd0: b_out = reg_file_data_b;
            2'd1: b_out = imm_gen_out;
            2'd2: b_out = alu_forward;
            2'd3: b_out = dmem_foward;
        endcase
    end
endmodule