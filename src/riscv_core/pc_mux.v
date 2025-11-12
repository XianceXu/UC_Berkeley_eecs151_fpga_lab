module pc_mux(clk, add_4, alu, pc_sel, out, rst, stall, old_pc);
    input [31:0] add_4, alu, old_pc;
    input pc_sel, rst, stall, clk;

    output reg [31:0] out;
    parameter INIT = {32'b0};
    // assign out = (rst) ? INIT : (pc_sel) ? alu : add_4;
    always @(*) begin
        if (rst) out = INIT;
        else begin
            if (stall) out = old_pc; 
            else if (pc_sel) out = alu;
            else out = add_4;
        end
    end

    
endmodule