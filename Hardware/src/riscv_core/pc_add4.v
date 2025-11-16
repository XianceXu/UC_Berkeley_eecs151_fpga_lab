module pc_add4(pc, out);
    input [31:0] pc;
    output [31:0] out;

    assign out = pc + 31'd4;
endmodule
