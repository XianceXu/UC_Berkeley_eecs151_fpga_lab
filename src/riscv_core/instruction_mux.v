module instruction_mux(bios_douta, imem_doutb, inst, pc_30, rst, stall, stall_val);
    input [31:0] bios_douta, imem_doutb, stall_val;
    input pc_30, rst, stall;
    output reg [31:0] inst;
    
    always @(*) begin
        if (rst) inst = 32'd0;
        else if (stall) inst = stall_val;
        else if (pc_30) inst = bios_douta;
        else inst = imem_doutb;
    end
endmodule