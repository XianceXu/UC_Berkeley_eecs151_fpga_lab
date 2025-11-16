module pc_mux(add_4, alu, pc_sel, out);
    input [31:0] add_4, alu;
    input pc_sel;
    output [31:0] out;

    assign out = (pc_sel) ? add_4 : alu;
endmodule
