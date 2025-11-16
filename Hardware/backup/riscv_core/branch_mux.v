module branch_mux(br_haz, data_a, data_b, alu_forward, dmem_foward, branch_mux_out_a, branch_mux_out_b);
    input [2:0] br_haz;
    input [31:0] data_a, data_b, alu_forward, dmem_foward;
    output reg [31:0] branch_mux_out_a, branch_mux_out_b;

    always @(*) begin
        case(br_haz)
            3'd0:
                begin
                    branch_mux_out_a = data_a;
                    branch_mux_out_b = data_b;
                end
            3'd1:
                begin
                    branch_mux_out_a = alu_forward;
                    branch_mux_out_b = data_b;
                end
            3'd2: 
                begin
                    branch_mux_out_a = data_a;
                    branch_mux_out_b = alu_forward;
                end
            3'd3:
                begin
                    branch_mux_out_a = dmem_foward;
                    branch_mux_out_b = data_b;
                end
            3'd4: 
                begin
                    branch_mux_out_a = data_a;
                    branch_mux_out_b = dmem_foward;
                end
            default:
                begin
                    branch_mux_out_a = data_a;
                    branch_mux_out_b = data_b;
                end

        endcase
    end
endmodule