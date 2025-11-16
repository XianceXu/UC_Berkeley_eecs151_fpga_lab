`include "opcode.vh" 

module sdx (data_reg_out, addr_end, funct3, sdx_out, sdx_en, store_haz, data_foward);
    input [31:0] data_reg_out, data_foward;
    input [1:0] addr_end;
    input [2:0] funct3;
    input sdx_en, store_haz;

    output reg [31:0] sdx_out;

    reg [31:0] data;

    assign data = (store_haz) ? data_foward : data_reg_out;

    always @(*) begin
        case (funct3)
            `FNC_SB:
                begin
                    if (addr_end == 2'b00) sdx_out = data;
                    else if (addr_end == 2'b01) sdx_out = data << 8;
                    else if (addr_end == 2'b10) sdx_out = data << 16;
                    else if (addr_end == 2'b11) sdx_out = data << 24;
                end
            `FNC_SH:
                begin
                    if (addr_end == 2'b00) sdx_out = data;
                    else if (addr_end == 2'b01) sdx_out = data;
                    else if (addr_end == 2'b10) sdx_out = data << 16;
                    else if (addr_end == 2'b11) sdx_out = data << 16;
                end
            `FNC_SW:
                begin
                    sdx_out = data;
                end
        endcase
        if (!sdx_en) sdx_out = data_reg_out;

    end




endmodule