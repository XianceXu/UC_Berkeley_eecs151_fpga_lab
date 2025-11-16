module reg_file (
    input clk,
    input we,
    input [4:0] ra1, ra2, wa,
    input [31:0] wd,
    output [31:0] rd1, rd2
);
    parameter DEPTH = 32;
    reg [31:0] mem [0:31];
    assign rd1 = mem[ra1];
    assign rd2 = mem[ra2];

    //syncronous write
    always @(posedge clk) begin
        if (we && wa != 5'd0) begin
            mem[wa] <= wd;
        end
    end

endmodule
