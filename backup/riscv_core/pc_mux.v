module pc_mux(add_4, alu, alu_forward, pc_sel, out, rst);
    input [31:0] add_4, alu, alu_forward;
    input [1:0] pc_sel;
    input rst;
    output reg [31:0] out;
    parameter INIT = {32'b0};

    // assign out = (rst) ? INIT : (pc_sel) ? alu : add_4;
    always @(*) begin
        if (rst) out = INIT;
        else begin
            if (pc_sel == 2'd0) out = add_4;
            else if (pc_sel == 2'd1) out = alu;
            else if (pc_sel == 2'd2) out = alu_forward;
        end
    end
    
endmodule