`include "opcode.vh"

module control_logic (inst, imem_rw, dmem_rw, pc_sel, imm_sel, b_equal, b_less, funct3, two_past_op, 
                      imux_nop, imux_nop_past, a_sel, rst, b_sel, b_unsigned, alu_sel, store_haz, past_inst,
                      clear_third_stage, curr_reg_we, newPC, reg_we, wb_sel, br_haz, addr_end_x, sdx_en, csr_sel, csr_en, addr_d, past_op);


    input [31:0] inst, past_inst;
    input [4:0] addr_d, past_op, two_past_op;
    input [1:0] addr_end_x;
    input b_equal, b_less, rst, imux_nop_past, curr_reg_we;
    output reg [3:0] imem_rw, dmem_rw, alu_sel;
    output reg [2:0] imm_sel, funct3, br_haz;
    output reg [1:0] wb_sel, newPC, a_sel, b_sel;
    output reg pc_sel, store_haz, b_unsigned, reg_we, sdx_en, imux_nop, clear_third_stage, csr_sel, csr_en;


    reg [4:0] opcode, addr_a, addr_b;
    reg funct7;

    initial begin
        pc_sel = 1'b0;
        imem_rw = 4'd0;
        dmem_rw = 4'd0;   
        wb_sel = 2'd1;     
        reg_we = 1'd0;
        alu_sel = 4'd0;
        imm_sel = 3'd0;
        a_sel = 2'd0;
        b_sel = 2'd0;
        b_unsigned = 1'd0;
        sdx_en = 1'b0;
        imux_nop = 1'b0;
        csr_sel = 1'd0;
        csr_en = 1'd0;
        br_haz = 3'd0;
        clear_third_stage = 1'b0;
        newPC = 2'd0;
        store_haz = 1'b0;
    end
        

    assign opcode = inst[6:2];
    assign funct3 = inst[14:12];
    assign funct7 = inst[30];

    assign addr_a = inst[19:15];
    assign addr_b = inst[24:20];


    always @(*) begin
        case(opcode)
            `OPC_LUI_5:
                begin
                    imem_rw = 4'b0;
                    dmem_rw = 4'b0;
                    pc_sel = 1'b0;
                    imm_sel = 3'd4;
                    a_sel = 2'b0;
                    b_sel = 2'd1;
                    b_unsigned = 1'b0;
                    alu_sel = 4'd12;
                    reg_we = 1'b1;
                    wb_sel = 2'd1;
                    sdx_en = 1'b0;
                    imux_nop = 1'b0;
                    csr_sel = 1'd0;
                    csr_en = 1'd0;
                    br_haz = 3'd0;
                    clear_third_stage = 1'b0;
                    store_haz = 1'b0;
                end
            `OPC_AUIPC_5:
                begin
                    imem_rw = 4'b0;
                    dmem_rw = 4'b0;
                    pc_sel = 1'b0;
                    imm_sel = 3'd4;
                    a_sel = 2'b1;
                    b_sel = 2'd1;
                    b_unsigned = 1'b0;
                    alu_sel = 4'd0;
                    reg_we = 1'b1;
                    wb_sel = 2'd1;
                    sdx_en = 1'b0;
                    imux_nop = 1'b0;
                    csr_sel = 1'd0;
                    csr_en = 1'd0;
                    br_haz = 3'd0;
                    clear_third_stage = 1'b0;
                    store_haz = 1'b0;
                end
            `OPC_JAL_5:
                begin
                    imem_rw = 4'b0;
                    dmem_rw = 4'b0;
                    pc_sel = 1'b1;
                    imm_sel = 3'd5;
                    a_sel = 2'b1;
                    b_sel = 2'd1;
                    b_unsigned = 1'b0;
                    alu_sel = 4'd0;
                    reg_we = 1'b1;
                    wb_sel = 2'd2;
                    sdx_en = 1'b0;
                    imux_nop = 1'b1;
                    csr_sel = 1'd0;
                    csr_en = 1'd0;
                    br_haz = 3'd0;
                    clear_third_stage = 1'b0;
                    store_haz = 1'b0;
                end
            `OPC_JALR_5:
                begin
                    imem_rw = 4'b0;
                    dmem_rw = 4'b0;
                    pc_sel = 1'b1;
                    imm_sel = 3'd1;
                    a_sel = 2'd0;
                    b_sel = 2'd1;
                    b_unsigned = 1'b0;
                    alu_sel = 4'd0;
                    reg_we = 1'b1;
                    wb_sel = 2'd2;
                    sdx_en = 1'b0;
                    imux_nop = 1'b1;
                    csr_sel = 1'd0;
                    csr_en = 1'd0;
                    br_haz = 3'd0;
                    clear_third_stage = 1'b0;
                    store_haz = 1'b0;
                end
            `OPC_BRANCH_5:
                begin
                    imem_rw = 4'b0;
                    dmem_rw = 4'b0;
                    imm_sel = 3'd3;
                    a_sel = 2'd1;
                    b_sel = 2'd1;
                    alu_sel = 4'd0;
                    reg_we = 1'b0;
                    wb_sel = 2'd0;
                    sdx_en = 1'b0;
                    csr_sel = 1'd0;
                    csr_en = 1'd0;
                    br_haz = 3'd0;
                    clear_third_stage = 1'b0;
                    store_haz = 1'b0;
                    //select pc_sel based on branching
                    if (funct3 == 3'b000) begin //beq
                        b_unsigned = 1'b0;
                        if (b_equal) begin
                            pc_sel = 1'b1;
                            imux_nop = 1'b1;
                        end else begin
                            pc_sel = 1'b0;
                            imux_nop = 1'b0;
                        end
                    end 
                    else if (funct3 == 3'b001) begin//bne
                        b_unsigned = 1'b0;
                        if (!b_equal) begin
                            pc_sel = 1'b1;
                            imux_nop = 1'b1;
                        end else begin
                            pc_sel = 1'b0;
                            imux_nop = 1'b0;
                        end
                    end 
                    else if (funct3 == 3'b100) begin//blt
                        b_unsigned = 1'b0;
                        if (b_less) begin
                            pc_sel = 1'b1;
                            imux_nop = 1'b1;
                        end else begin
                            pc_sel = 1'b0;
                            imux_nop = 1'b0;
                        end
                    end 
                    else if (funct3 == 3'b101) begin//bge
                        b_unsigned = 1'b0;
                        if (!b_less) begin
                            pc_sel = 1'b1;
                            imux_nop = 1'b1;
                        end else begin
                            pc_sel = 1'b0;
                            imux_nop = 1'b0;
                        end
                    end 
                    else if (funct3 == 3'b110) begin//bltu
                        b_unsigned = 1'b1;
                        if (b_less) begin
                            pc_sel = 1'b1;
                            imux_nop = 1'b1;
                        end else begin
                            pc_sel = 1'b0;
                            imux_nop = 1'b0;
                        end
                    end 
                    else if (funct3 == 3'b111) begin//bgeu
                        b_unsigned = 1'b1;
                        if (!b_less) begin
                            pc_sel = 1'b1;
                            imux_nop = 1'b1;
                        end else begin
                            pc_sel = 1'b0;
                            imux_nop = 1'b0;
                        end
                    end

                end
            `OPC_STORE_5:
                begin
                    imem_rw = 4'b0;
                    pc_sel = 1'b0;
                    imm_sel = 3'd2;
                    a_sel = 2'd0;
                    b_sel = 2'd1;
                    b_unsigned = 1'b0;
                    alu_sel = 4'd0;
                    reg_we = 1'b0;
                    wb_sel = 2'd0;
                    sdx_en = 1'b1;
                    imux_nop = 1'b0;
                    csr_sel = 1'd0;
                    csr_en = 1'd0;
                    br_haz = 3'd0;
                    clear_third_stage = 1'b0;
                    store_haz = 1'b0;
                    if (funct3 == `FNC_SW) dmem_rw = 4'b1111;
                    else if (funct3 == `FNC_SH) 
                    begin
                        if (addr_end_x == 2'b00) dmem_rw = 4'b0011;
                        else if (addr_end_x == 2'b01) dmem_rw = 4'b0011;
                        else if (addr_end_x == 2'b10) dmem_rw = 4'b1100;
                        else if (addr_end_x == 2'b11) dmem_rw = 4'b1100;
                    end
                    else if (funct3 == `FNC_SB)
                    begin
                        if      (addr_end_x == 2'b00) dmem_rw = 4'b0001;
                        else if (addr_end_x == 2'b01) dmem_rw = 4'b0010;
                        else if (addr_end_x == 2'b10) dmem_rw = 4'b0100;
                        else if (addr_end_x == 2'b11) dmem_rw = 4'b1000;
                    end

                end
            `OPC_LOAD_5:
                begin
                    if (inst[1:0] == 2'b11) begin
                        imem_rw = 4'b0;
                        dmem_rw = 4'b0;
                        pc_sel = 1'b0;
                        imm_sel = 3'd1;
                        a_sel = 2'd0;
                        b_sel = 2'd1;
                        b_unsigned = 1'b0;
                        alu_sel = 4'd0;
                        reg_we = 1'b1;
                        wb_sel = 2'd0;
                        sdx_en = 1'b0;
                        imux_nop = 1'b0;
                        csr_sel = 1'd0;
                        csr_en = 1'd0;
                        br_haz = 3'd0;
                        clear_third_stage = 1'b0;
                    store_haz = 1'b0;
                    end
                    else begin
                        imem_rw = 4'b0;
                        dmem_rw = 4'b0;
                        pc_sel = 1'b0;
                        imm_sel = 3'd0;
                        a_sel = 2'b0;
                        b_sel = 2'd0;
                        b_unsigned = 1'b0;
                        alu_sel = 4'd0;
                        reg_we = 1'b0;
                        wb_sel = 2'd1;
                        sdx_en = 1'b0;
                        imux_nop = 1'b0;
                        csr_sel = 1'd0;
                        csr_en = 1'd0;
                        br_haz = 3'd0;
                        clear_third_stage = 1'b0;
                    store_haz = 1'b0;
                    end
                end
            `OPC_ARI_RTYPE_5:
                begin
                    imem_rw = 4'b0;
                    dmem_rw = 4'b0;
                    pc_sel = 1'b0;
                    imm_sel = 3'd0;
                    a_sel = 2'd0;
                    b_sel = 2'd0;
                    b_unsigned = 1'b0;
                    reg_we = 1'b1;
                    wb_sel = 2'd1;
                    sdx_en = 1'b0;
                    imux_nop = 1'b0;
                    csr_sel = 1'd0;
                    csr_en = 1'd0;
                    br_haz = 3'd0;
                    clear_third_stage = 1'b0;
                    store_haz = 1'b0;
                    if (funct3 == `FNC_ADD_SUB) alu_sel = {{3{1'b0}}, funct7};
                    else if (funct3 == `FNC_SLL) alu_sel = 4'd2;
                    else if (funct3 == `FNC_SLT) alu_sel = 4'd3;
                    else if (funct3 == `FNC_SLTU) alu_sel = 4'd4;
                    else if (funct3 == `FNC_XOR) alu_sel = 4'd5;
                    else if (funct3 == `FNC_OR) alu_sel = 4'd6;
                    else if (funct3 == `FNC_AND) alu_sel = 4'd7;
                    else if (funct3 == `FNC_SRL_SRA) alu_sel = {1'b1, {2{1'b0}}, funct7};
                end
            `OPC_ARI_ITYPE_5:
                begin
                    imem_rw = 4'b0;
                    dmem_rw = 4'b0;
                    pc_sel = 1'b0;
                    imm_sel = 3'd1;
                    a_sel = 2'd0;
                    b_sel = 2'd1;
                    b_unsigned = 1'b0;
                    reg_we = 1'b1;
                    wb_sel = 2'd1;
                    sdx_en = 1'b0;
                    imux_nop = 1'b0;
                    csr_sel = 1'd0;
                    csr_en = 1'd0;
                    br_haz = 3'd0;
                    clear_third_stage = 1'b0;
                    store_haz = 1'b0;
                    if (funct3 == `FNC_ADD_SUB) alu_sel = 4'd0;
                    else if (funct3 == `FNC_SLL) alu_sel = 4'd2;
                    else if (funct3 == `FNC_SLT) alu_sel = 4'd3;
                    else if (funct3 == `FNC_SLTU) alu_sel = 4'd4;
                    else if (funct3 == `FNC_XOR) alu_sel = 4'd5;
                    else if (funct3 == `FNC_OR) alu_sel = 4'd6;
                    else if (funct3 == `FNC_AND) alu_sel = 4'd7;
                    else if (funct3 == `FNC_SRL_SRA) alu_sel = {1'b1, {2{1'b0}}, funct7};
                end
            default:
                begin
                    imem_rw = 4'b0;
                    dmem_rw = 4'b0;
                    pc_sel = 1'b0;
                    imm_sel = 3'd0;
                    a_sel = 2'b0;
                    b_sel = 2'd0;
                    b_unsigned = 1'b0;
                    alu_sel = 4'd0;
                    reg_we = 1'b0;
                    wb_sel = 2'd1;
                    sdx_en = 1'b0;
                    imux_nop = 1'b0;
                    csr_sel = 1'd0;
                    csr_en = 1'd0;
                    br_haz = 3'd0;
                    clear_third_stage = 1'b0;
                    store_haz = 1'b0;
                end

        endcase



        if (opcode == `OPC_BRANCH_5) begin
            if (addr_d == addr_a && addr_a != 5'd0) begin
                if (past_op == `OPC_LOAD_5 ) begin
                    br_haz = 3'd3;
                end else begin
                    br_haz = 3'd1;
                end
            end
            if (addr_d == addr_b && addr_b != 5'd0) begin
                if (past_op == `OPC_LOAD_5) begin
                    br_haz = 3'd4;
                end else begin
                    br_haz = 3'd2;
                end
            end

        end

        //mem->alu if load from mem 
        if (past_op == `OPC_LOAD_5 && past_inst != 32'd0 && !imux_nop && inst != 32'd0) begin
            if (addr_d == addr_a && a_sel == 2'd0) begin
                a_sel = 2'd3;
                br_haz = 3'd3;
            end
            if (addr_d == addr_b && b_sel == 2'd0) begin
                b_sel = 2'd3;
                br_haz = 3'd4;
            end

        end

        if (opcode == `OPC_STORE_5) begin
            if (addr_d == addr_b && curr_reg_we) begin
                store_haz = 1'b1;
            end
            if (addr_d == addr_a && curr_reg_we) begin
                if (past_op == `OPC_LOAD_5) a_sel = 2'd3;
                else a_sel = 2'd2;
            end
        end

        // if (inst == 32'd0 && past_op == `OPC_BRANCH_5) begin
        //     newPC = 2'd2;
        // end else newPC = 2'd0;

        //if j in execute stage, choos third stage pc
        // if b in m stage, choose alu out


        //alu forwarding for alu->alu, and alu->mem
        if (reg_we) begin
            if (addr_d == addr_a  && addr_a != 5'd0 && a_sel == 2'd0 && curr_reg_we == 1'b1) begin
                a_sel = 2'd2;
            end
            if (addr_d == addr_b  && addr_b != 5'd0 && b_sel == 2'd0 && curr_reg_we == 1'b1) begin
                b_sel = 2'd2;
            end

        end

        // if (past_inst == 32'd0  && two_past_op == `OPC_JAL_5) imux_nop = 1'b1;
        // if (past_inst == 32'd0 && two_past_op == `OPC_JALR_5) imux_nop = 1'b1;

        

        if (imux_nop_past) begin
                    imem_rw = 4'b0;
                    dmem_rw = 4'b0;
                    pc_sel = 1'b0;
                    imm_sel = 3'd1;
                    a_sel = 2'b0;
                    b_sel = 2'd0;
                    b_unsigned = 1'b0;
                    alu_sel = 4'd0;
                    reg_we = 1'b0;
                    wb_sel = 2'd1;
                    sdx_en = 1'b0;
                    imux_nop = 1'b0;
                    csr_sel = 2'd0;
                    br_haz = 3'd0;
                    clear_third_stage = 1'd0;
                    store_haz = 1'b0;
        end


        if (past_op == `OPC_JAL_5 && inst == 32'd0) imux_nop = 1'b1;
        if (past_op == `OPC_JALR_5 && inst == 32'd0) imux_nop = 1'b1;

        if (inst[7:0] == `OPC_CSR) begin
            imem_rw = 4'b0;
            dmem_rw = 4'b0;
            pc_sel = 1'b0;
            imm_sel = 3'd6;
            b_sel = 2'd1;
            b_unsigned = 1'b0;
            alu_sel = 4'd0;
            reg_we = 1'b0;
            wb_sel = 2'd1;
            sdx_en = 1'b0;
            imux_nop = 1'b0;
            br_haz = 3'd0;
            clear_third_stage = 1'b0;
            store_haz = 1'b0;
            csr_en = 1'd1;
            if (funct3 == 3'b001) csr_sel = 1'd0;
            else if (funct3 == 3'b101) csr_sel = 1'd1;
            if (addr_a == addr_d) a_sel = 2'd2;
            else a_sel = 2'd0;
        end


        if (rst || inst == 32'd0) begin
                    imem_rw = 4'b0;
                    dmem_rw = 4'b0;
                    pc_sel = 1'b0;
                    imm_sel = 3'd0;
                    a_sel = 2'b0;
                    b_sel = 2'd0;
                    b_unsigned = 1'b0;
                    alu_sel = 4'd0;
                    reg_we = 1'b0;
                    wb_sel = 2'd1;
                    sdx_en = 1'b0;
                    csr_sel = 2'd0;
                    br_haz = 3'd0;
                    clear_third_stage = 1'd0;
                    store_haz = 1'b0;
        end
    end
endmodule