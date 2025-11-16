module a_mux(reg_file_data_a, pc, alu_forward, a_sel, a_out);
    input [31:0] reg_file_data_a, pc, alu_forward;
    input [1:0] a_sel;
    output reg [31:0] a_out;

    always @(*) begin
        case(a_sel)
            2'd0: a_out = reg_file_data_a;
            2'd1: a_out = pc;
            2'd2: a_out = alu_forward;
            2'd3: a_out = 0;
        endcase
    end
endmodule
