module simple_register_rst(d, q, clk, rst, rst_val);
    input [31:0] d, rst_val;
    input clk, rst;
    output reg [31:0] q;

    // assign out = (rst) ? INIT : (pc_sel) ? alu : add_4;
    always @(posedge clk) begin
        if (rst) q <= rst_val;
        else begin
            q <= d;
        end
    end
endmodule // REGISTER
