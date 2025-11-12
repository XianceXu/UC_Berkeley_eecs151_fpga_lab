
module simple_register(d, q, clk);
    input [31:0] d;
    input clk;
    output reg [31:0] q;

    // assign out = (rst) ? INIT : (pc_sel) ? alu : add_4;
    always @(posedge clk) begin
        q <= d;
    end

endmodule // REGISTER
