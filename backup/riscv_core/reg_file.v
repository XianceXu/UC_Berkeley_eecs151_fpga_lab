module reg_file (
    input clk,
    input we,
    input [4:0] ra1, ra2, wa,
    input [31:0] wd,
    output [31:0] rd1, rd2
);
    parameter DEPTH = 32;
    reg [31:0] mem [0:31];

    reg [31:0] testreg5;
    reg [31:0] testreg7;

    //syncronous write
    always @(posedge clk) begin
        if (we && wa != 5'd0) begin
            mem[wa] <= wd;
        end
    end

    assign rd1 = (ra1 == 0) ? 32'b0 : mem[ra1];
    assign rd2 = (ra2 == 0) ? 32'b0 : mem[ra2];
    assign testreg5 = mem[5'd5];
    assign testreg7 = mem[5'd7];

endmodule
