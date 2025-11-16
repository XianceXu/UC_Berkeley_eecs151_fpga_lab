module data_mux(bios_doutb, dmem_dout, data, addr, pc_30, io_dout);
    input [31:0] bios_doutb, dmem_dout, io_dout;
    input [3:0] addr;
    input pc_30;
    output reg [31:0] data;

    // assign data = (addr) ? bios_doutb : dmem_dout;
    always @(*) begin
        case(addr)
            4'b0001, 4'b0011: data = dmem_dout;
            4'b0100: data = bios_doutb;
            4'b1000: data = io_dout;
            default: data = dmem_dout;

        endcase
    end
endmodule