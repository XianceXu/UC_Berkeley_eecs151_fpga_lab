
module simple_addr_reg(d, q, clk);
    input [4:0] d;
    input clk;
    output reg [4:0] q;

    // assign out = (rst) ? INIT : (pc_sel) ? alu : add_4;
    always @(posedge clk) begin
        q <= d;
    end

endmodule // REGISTER
