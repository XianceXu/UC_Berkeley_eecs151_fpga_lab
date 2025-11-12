module pc_inst_mux(bios_douta, imem_doutb, inst, pc_30, imux_nop);
    input [31:0] bios_douta, imem_doutb;
    input pc_30, imux_nop;
    output reg [31:0] inst;

    always @(*) begin
        case (imux_nop)
            1'd0: inst = (pc_30) ? bios_douta : imem_doutb;
            1'd1: inst = 32'd0;
            default: inst = (pc_30) ? bios_douta : imem_doutb;
        endcase
    end
endmodule