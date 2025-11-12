`include "opcode.vh" 


module sdx (data_reg_out, addr_end, funct3, sdx_out, sdx_en, rw_sig);
    input [31:0] data_reg_out;
    input [1:0] addr_end;
    input [2:0] funct3;
    input sdx_en;

    output reg [31:0] sdx_out;
    output reg [3:0] rw_sig;


    always @(*) begin
        case (funct3)
            `FNC_SB:
                begin
                    if (addr_end == 2'b00) begin
                        sdx_out = data_reg_out;
                        rw_sig = 4'b0001;
                    end
                    else if (addr_end == 2'b01)  begin
                        sdx_out = data_reg_out << 8;
                        rw_sig = 4'b0010;
                    end
                    else if (addr_end == 2'b10) begin
                        sdx_out = data_reg_out << 16;
                        rw_sig = 4'b0100;
                    end
                    else if (addr_end == 2'b11) begin
                        sdx_out = data_reg_out << 24;
                        rw_sig = 4'b1000;
                    end
                    else begin
                        sdx_out = data_reg_out;
                        rw_sig = 4'b1111;
                    end
                end
            `FNC_SH:
                begin
                    if (addr_end == 2'b00 || addr_end == 2'b01) begin
                        sdx_out = data_reg_out;
                        rw_sig = 4'b0011;
                    end
                    else if (addr_end == 2'b10 || addr_end == 2'b11) begin
                        sdx_out = data_reg_out << 16;
                        rw_sig = 4'b1100;
                    end
                    else begin
                        sdx_out = data_reg_out;
                        rw_sig = 4'b1111;
                    end
                end
            `FNC_SW:
                begin
                    sdx_out = data_reg_out;
                    rw_sig = 4'b1111;
                end
            default: begin
                    sdx_out = data_reg_out;
                    rw_sig = 4'b1111;
                end
        endcase
        if (!sdx_en) begin
            sdx_out = data_reg_out;
            rw_sig = 4'b0000;
        end


    end




endmodule