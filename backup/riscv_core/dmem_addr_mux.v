module dmem_addr_mux (alu, fowarded_alu, dmem_inst_sel, dmem_addr);
input [31:0] alu, fowarded_alu;
input dmem_inst_sel;
output reg [31:0] dmem_addr;

assign dmem_addr = (dmem_inst_sel) ? fowarded_alu : alu;

endmodule