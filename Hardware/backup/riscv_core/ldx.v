`include "opcode.vh" 

module ldx (load_out, addr_end, funct3, ldx_out);
    input [31:0] load_out;
    input [1:0] addr_end;
    input [2:0] funct3;

    output reg [31:0] ldx_out;

    always @(*) begin
        case (funct3)
            `FNC_LB:
                begin
                    if (addr_end == 2'b00) ldx_out = {{24{load_out[7]}}, load_out[7:0]};
                    else if (addr_end == 2'b01) ldx_out = {{24{load_out[15]}}, load_out[15:8]};
                    else if (addr_end == 2'b10) ldx_out = {{24{load_out[23]}}, load_out[23:16]};
                    else if (addr_end == 2'b11) ldx_out = {{24{load_out[31]}}, load_out[31:24]};
                end
            `FNC_LH:
                begin
                    if (addr_end == 2'b00) ldx_out = {{16{load_out[15]}}, load_out[15:0]};
                    else if (addr_end == 2'b01) ldx_out = {{16{load_out[15]}}, load_out[15:0]};
                    else if (addr_end == 2'b10) ldx_out = {{16{load_out[31]}}, load_out[31:16]};
                    else if (addr_end == 2'b11) ldx_out = {{16{load_out[31]}}, load_out[31:16]};
                end
            `FNC_LW:
                begin
                    ldx_out = load_out;
                end
            `FNC_LBU:
                begin
                    if (addr_end == 2'b00) ldx_out = {{24{1'b0}}, load_out[7:0]};
                    else if (addr_end == 2'b01) ldx_out = {{24{1'b0}}, load_out[15:8]};
                    else if (addr_end == 2'b10) ldx_out = {{24{1'b0}}, load_out[23:16]};
                    else if (addr_end == 2'b11) ldx_out = {{24{1'b0}}, load_out[31:24]};
                end
            `FNC_LHU:
                begin
                    if (addr_end == 2'b00) ldx_out = {{16{1'b0}}, load_out[15:0]};
                    else if (addr_end == 2'b01) ldx_out = {{16{1'b0}}, load_out[15:0]};
                    else if (addr_end == 2'b10) ldx_out = {{16{1'b0}}, load_out[31:16]};
                    else if (addr_end == 2'b11) ldx_out = {{16{1'b0}}, load_out[31:16]};
                end
        endcase
     

    end




endmodule