module a_mux(reg_file_data_a, pc, a_sel, a_out);
    input [31:0] reg_file_data_a, pc;
    input a_sel;
    output reg [31:0] a_out;

    assign a_out = (!a_sel) ? reg_file_data_a : pc;

endmodule