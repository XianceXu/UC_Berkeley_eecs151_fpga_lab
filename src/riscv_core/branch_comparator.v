module branch_comparator ( BrUn, a_in, b_in, BrEq, BrLt);
    input BrUn;
    input [31:0] a_in, b_in;
    output reg BrEq, BrLt;


    wire signed [31:0] a, b;
    assign a = (BrUn) ? $signed(a_in) : $unsigned(a_in);
    assign b = (BrUn) ? $signed(b_in) : $unsigned(b_in);

    assign BrEq = (a == b) ? 1'b1 : 1'b0;
    assign BrLt = (a < b) ? 1'b1 : 1'b0;


endmodule
