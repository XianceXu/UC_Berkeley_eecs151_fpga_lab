module wb_mux(dmem_out, alu_out, pc_plus4, wb_sel, wb_out);
    input [31:0] dmem_out, alu_out, pc_plus4;
    input [1:0] wb_sel;
    output reg [31:0] wb_out;

    always @(*) begin
        case(wb_sel)
            2'd0: wb_out = dmem_out;
            2'd1: wb_out = alu_out;
            2'd2: wb_out = pc_plus4;
            2'd3: wb_out = 0;
        endcase
    end
endmodule
