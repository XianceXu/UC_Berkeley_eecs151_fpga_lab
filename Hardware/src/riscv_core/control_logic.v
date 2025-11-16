`include "opcode.vh"

module control_logic (inst, b_equal, b_less, imem_rw, bios_rwa, bios_rwb,
                      dmem_rw, pc_sel, imm_sel, a_sel, b_sel, b_taken, alu_sel,
                      reg_we, wb_sel);

    input [31:0] inst;
    input b_equal, b_less;
    output [3:0] imem_rw, dmem_rw, alu_sel;
    output [2:0] imm_sel;
    output [1:0] wb_sel, a_sel, b_sel;
    output pc_sel, b_taken, reg_we, bios_rwa, bios_rwb;


    reg [4:0] opcode;
    reg [2:0] funct3;
    reg funct7;

    assign opcode = inst[6:2];
    assign funct3 = inst[14:12];
    assign funct7 = inst[30]


    always @(*) begin
        case(opcode)
            OPC_LUI_5:
                begin
                    imem_rw = 4'b0;
                    bios_rwa = 1'b0;
                    bios_rwb = 1'b0;
                    dmem_rw = 4'b0;
                    pc_sel = 1'b0;
                    imm_sel = 3'd4;
                    a_sel = 2'b0;
                    b_sel = 2'd1;
                    b_taken = 1'b0;
                    alu_sel = 4'd12;
                    reg_we = 1'b1;
                    wb_sel = 2'd1;
                end
            OPC_AUIPC_5:
                begin
                    imem_rw = 4'b0;
                    bios_rwa = 1'b0;
                    bios_rwb = 1'b0;
                    dmem_rw = 4'b0;
                    pc_sel = 1'b0;
                    imm_sel = 3'd4;
                    a_sel = 2'b1;
                    b_sel = 2'd1;
                    b_taken = 1'b0;
                    alu_sel = 4'd0;
                    reg_we = 1'b1;
                    wb_sel = 2'd1;
                end
            OPC_JAL_5:
                begin
                    imem_rw = 4'b0;
                    bios_rwa = 1'b0;
                    bios_rwb = 1'b0;
                    dmem_rw = 4'b0;
                    pc_sel = 1'b0;
                    imm_sel = 3'd4;
                    a_sel = 2'b1;
                    b_sel = 2'd1;
                    b_taken = 1'b0;
                    alu_sel = 4'd0;
                    reg_we = 1'b1;
                    wb_sel = 2'd1;
                end
            OPC_JALR_5;:
                begin

                end
            OPC_BRANCH_5:
                begin

                end
            OPC_STORE_5:
                begin

                end
            OPC_LOAD_5:
                begin

                end
            OPC_ARI_RTYPE_5:
                begin
                    imem_rw = 4'b0;
                    bios_rwa = 1'b0;
                    bios_rwb = 1'b0;
                    dmem_rw = 4'b0;
                    pc_sel = 1'b0;
                    imm_sel = 3'd0;
                    a_sel = 2'd0;
                    b_sel = 2'd0;
                    b_taken = 1'b0;
                    alu_sel = {3{1'b0}, funct7};
                    reg_we = 1'b1;
                    wb_sel = 2'd1;
                    if (funct3 == FNC_ADD_SUB) alu_sel = {3{1'b0}, funct7};
                    else if (funct3 == FNC_SLL) alu_sel = 4'd2;
                    else if (funct3 == FNC_SLT) alu_sel = 4'd3;
                    else if (funct3 == FNC_SLTU) alu_sel = 4'd4;
                    else if (funct3 == FNC_XOR) alu_sel = 4'd5;
                    else if (funct3 == FNC_OR) alu_sel = 4'd6;
                    else if (funct3 == FNC_AND) alu_sel = 4'd7;
                    else if (funct3 == FNC_SRL) alu_sel = 4'd8;
                    else if (funct3 == FNC_SRA) alu_sel = 4'd9;
                end
            OPC_ARI_ITYPE_5:
                begin
                    imem_rw = 4'b0;
                    bios_rwa = 1'b0;
                    bios_rwb = 1'b0;
                    dmem_rw = 4'b0;
                    pc_sel = 1'b0;
                    imm_sel = 3'd0;
                    a_sel = 2'd0;
                    b_sel = 2'd1;
                    b_taken = 1'b0;
                    alu_sel = {3{1'b0}, funct7};
                    reg_we = 1'b1;
                    wb_sel = 2'd1;
                    if (funct3 == FNC_ADD_SUB) alu_sel = {3{1'b0}, funct7};
                    else if (funct3 == FNC_SLL) alu_sel = 4'd2;
                    else if (funct3 == FNC_SLT) alu_sel = 4'd3;
                    else if (funct3 == FNC_SLTU) alu_sel = 4'd4;
                    else if (funct3 == FNC_XOR) alu_sel = 4'd5;
                    else if (funct3 == FNC_OR) alu_sel = 4'd6;
                    else if (funct3 == FNC_AND) alu_sel = 4'd7;
                    else if (funct3 == FNC_SRL) alu_sel = 4'd8;
                    else if (funct3 == FNC_SRA) alu_sel = 4'd9;
                end

        endcase
    end
endmodule
