module b_mux(reg_file_data_b, imm_gen_out, b_sel, b_out);
    input [31:0] reg_file_data_b, imm_gen_out;
    input b_sel;
    output reg [31:0] b_out;

    assign b_out = (!b_sel) ? reg_file_data_b : imm_gen_out;
endmodule