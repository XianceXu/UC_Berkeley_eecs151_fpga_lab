module instruction_mux(bios_douta, imem_doutb, inst, pc_30);
    input [31:0] bios_douta, imem_doutb;
    input pc_30;
    output [31:0] inst;

    assign inst = (pc_30) ? bios_douta : imem_doutb;
endmodule
