`include "opcode.vh"

module control_logic (clk, inst, imm_sel, b_equal, b_less, pc_sel,
                      imux_nop, a_sel, rst, b_sel, b_unsigned, alu_sel,
                      reg_we_x, kill_now, reg_we_m, reg_we_w, stall, reg_we, wb_sel, addr_end_x, sdx_en, csr_sel, csr_en);


    input [31:0] inst;
    input [1:0] addr_end_x;
    input clk, b_equal, b_less, rst, reg_we_x, reg_we_m, reg_we_w, kill_now;
    output reg [3:0] alu_sel;
    output reg [2:0] imm_sel;
    output reg [1:0] wb_sel;
    output reg b_unsigned, stall, a_sel, b_sel, reg_we, sdx_en, imux_nop, csr_sel, csr_en, pc_sel;

    reg kill_next;
    reg need_a_bool, need_b_bool;

    reg [4:0] opcode, addr_a, addr_b;
    reg [2:0] funct3;
    reg funct7;
    wire [4:0] addr_x, addr_m, addr_w;

    // one_bit_reg kill_next_reg (
    //     .q(kill_now),
    //     .d(kill_next),
    //     .clk(clk)
    // ); 

    assign need_a_bool = (opcode != `OPC_JAL_5) && (opcode != `OPC_AUIPC_5) && (opcode != `OPC_LUI_5) || (inst[6:0] == `OPC_CSR && funct3 == 3'b001);

    assign need_b_bool = (opcode != `OPC_LUI_5) &&
                         (opcode != `OPC_AUIPC_5) &&
                         (opcode != `OPC_JAL_5) &&
                         (opcode != `OPC_JALR_5) &&
                         (opcode != `OPC_LOAD_5) &&
                         (opcode != `OPC_ARI_ITYPE_5);

    assign stall =  (((addr_a == addr_x)&& reg_we_x ||
                      (addr_a == addr_m)&& reg_we_m ||
                      (addr_a == addr_w)&& reg_we_w)&& 
                      addr_a != 5'd0 && need_a_bool)||
                    (((addr_b == addr_x)&& reg_we_x ||
                      (addr_b == addr_m)&& reg_we_m||
                      (addr_b == addr_w)&& reg_we_w)&& 
                      addr_b != 5'd0 && need_b_bool) && inst != 32'd0;



    initial begin
        wb_sel = 2'd1;     
        reg_we = 1'd0;
        alu_sel = 4'd0;
        imm_sel = 3'd0;
        a_sel = 1'd0;
        b_sel = 1'd0;
        b_unsigned = 1'd0;
        sdx_en = 1'b0;
        imux_nop = 1'b0;
        csr_sel = 1'd0;
        csr_en = 1'd0;
        pc_sel = 1'b0;
        kill_next = 1'b0;
    end
        

    assign opcode = inst[6:2];
    assign funct3 = inst[14:12];
    assign funct7 = inst[30];

    assign addr_a = inst[19:15];
    assign addr_b = inst[24:20];

    // assign pc_sel = (opcode == OPC_JAL_5 || opcode == OPC_JALR_5 || opcode == OPC_BRANCH_5)

    simple_addr_reg rd_d_x_reg (
        .d(inst[11:7]),
        .q(addr_x),
        .clk(clk)
    ); 
    simple_addr_reg rd_x_m_reg(
        .d(addr_x), 
        .q(addr_m), 
        .clk(clk)
    );
    simple_addr_reg rd_m_w_reg(
        .d(addr_m), 
        .q(addr_w), 
        .clk(clk)
    );



    always @(*) begin
        case(opcode)
            `OPC_LUI_5:
                begin
                    imm_sel = 3'd4;
                    a_sel = 1'b0;
                    b_sel = 1'd1;
                    b_unsigned = 1'b0;
                    alu_sel = 4'd12;
                    reg_we = 1'b1;
                    wb_sel = 2'd1;
                    sdx_en = 1'b0;
                    imux_nop = 1'b0;
                    csr_sel = 1'd0;
                    csr_en = 1'd0;
                    pc_sel = 1'b0;
                    kill_next = 1'b0;
                end
            `OPC_AUIPC_5:
                begin
                    imm_sel = 3'd4;
                    a_sel = 1'b1;
                    b_sel = 1'd1;
                    b_unsigned = 1'b0;
                    alu_sel = 4'd0;
                    reg_we = 1'b1;
                    wb_sel = 2'd1;
                    sdx_en = 1'b0;
                    imux_nop = 1'b0;
                    csr_sel = 1'd0;
                    csr_en = 1'd0;
                    pc_sel = 1'b0;
                    kill_next = 1'b0;
                end
            `OPC_JAL_5:
                begin
                    imm_sel = 3'd5;
                    a_sel = 1'b1;
                    b_sel = 1'd1;
                    b_unsigned = 1'b0;
                    alu_sel = 4'd0;
                    reg_we = 1'b1;
                    wb_sel = 2'd2;
                    sdx_en = 1'b0;
                    imux_nop = 1'b0;
                    csr_sel = 1'd0;
                    csr_en = 1'd0;
                    pc_sel = 1'b1;
                    kill_next = 1'b1;
                end
            `OPC_JALR_5:
                begin
                    imm_sel = 3'd1;
                    a_sel = 1'd0;
                    b_sel = 1'd1;
                    b_unsigned = 1'b0;
                    alu_sel = 4'd0;
                    reg_we = 1'b1;
                    wb_sel = 2'd2;
                    sdx_en = 1'b0;
                    imux_nop = 1'b0;
                    csr_sel = 1'd0;
                    csr_en = 1'd0;
                    pc_sel = 1'b1;
                    kill_next = 1'b1;
                end
            `OPC_BRANCH_5:
                begin
                    imm_sel = 3'd3;
                    a_sel = 1'd1;
                    b_sel = 1'd1;
                    alu_sel = 4'd0;
                    reg_we = 1'b0;
                    wb_sel = 2'd0;
                    sdx_en = 1'b0;
                    csr_sel = 1'd0;
                    csr_en = 1'd0;
                    imux_nop = 1'b0;
                    //select pc_sel based on branching
                    if (funct3 == 3'b000) begin //beq
                        b_unsigned = 1'b0;
                        if (b_equal) begin
                            pc_sel = 1'b1;
                            kill_next = 1'b1;
                        end else begin
                            pc_sel = 1'b0;
                            kill_next = 1'b0;
                        end
                    end 
                    else if (funct3 == 3'b001) begin//bne
                        b_unsigned = 1'b0;
                        if (!b_equal) begin
                            pc_sel = 1'b1;
                            kill_next = 1'b1;
                        end else begin
                            pc_sel = 1'b0;
                            kill_next = 1'b0;
                        end
                    end 
                    else if (funct3 == 3'b100) begin//blt
                        b_unsigned = 1'b0;
                        if (b_less) begin
                            pc_sel = 1'b1;
                            kill_next = 1'b1;
                        end else begin
                            pc_sel = 1'b0;
                            kill_next = 1'b0;
                        end
                    end 
                    else if (funct3 == 3'b101) begin//bge
                        b_unsigned = 1'b0;
                        if (!b_less) begin
                            pc_sel = 1'b1;
                            kill_next = 1'b1;
                        end else begin
                            pc_sel = 1'b0;
                            kill_next = 1'b0;
                        end
                    end 
                    else if (funct3 == 3'b110) begin//bltu
                        b_unsigned = 1'b1;
                        if (b_less) begin
                            pc_sel = 1'b1;
                            kill_next = 1'b1;
                        end else begin
                            pc_sel = 1'b0;
                            kill_next = 1'b0;
                        end
                    end 
                    else if (funct3 == 3'b111) begin//bgeu
                        b_unsigned = 1'b1;
                        if (!b_less) begin
                            pc_sel = 1'b1;
                            kill_next = 1'b1;
                        end else begin
                            pc_sel = 1'b0;
                            kill_next = 1'b0;
                        end
                    end
                    else begin
                        b_unsigned = 1'b0;
                        pc_sel = 1'b0;
                        kill_next = 1'b0;

                    end

                end
            `OPC_STORE_5:
                begin
                    imm_sel = 3'd2;
                    a_sel = 1'd0;
                    b_sel = 1'd1;
                    b_unsigned = 1'b0;
                    alu_sel = 4'd0;
                    reg_we = 1'b0;
                    wb_sel = 2'd0;
                    sdx_en = 1'b1;
                    imux_nop = 1'b0;
                    csr_sel = 1'd0;
                    csr_en = 1'd0;
                    pc_sel = 1'b0;
                    kill_next = 1'b0;

                end
            `OPC_LOAD_5:
                begin
                    if (inst[1:0] == 2'b11) begin
                        imm_sel = 3'd1;
                        a_sel = 1'd0;
                        b_sel = 1'd1;
                        b_unsigned = 1'b0;
                        alu_sel = 4'd0;
                        reg_we = 1'b1;
                        wb_sel = 2'd0;
                        sdx_en = 1'b0;
                        imux_nop = 1'b0;
                        csr_sel = 1'd0;
                        csr_en = 1'd0;
                        pc_sel = 1'b0;
                        kill_next = 1'b0;
                    end
                    else begin
                        imm_sel = 3'd0;
                        a_sel = 1'b0;
                        b_sel = 1'd0;
                        b_unsigned = 1'b0;
                        alu_sel = 4'd0;
                        reg_we = 1'b0;
                        wb_sel = 2'd1;
                        sdx_en = 1'b0;
                        imux_nop = 1'b0;
                        csr_sel = 1'd0;
                        csr_en = 1'd0;
                        pc_sel = 1'b0;
                        kill_next = 1'b0;
                    end
                end
            `OPC_ARI_RTYPE_5:
                begin
                    imm_sel = 3'd0;
                    a_sel = 1'd0;
                    b_sel = 1'd0;
                    b_unsigned = 1'b0;
                    reg_we = 1'b1;
                    wb_sel = 2'd1;
                    sdx_en = 1'b0;
                    imux_nop = 1'b0;
                    csr_sel = 1'd0;
                    csr_en = 1'd0;
                    pc_sel = 1'b0;
                    kill_next = 1'b0;
                    if (funct3 == `FNC_ADD_SUB) alu_sel = {{3{1'b0}}, funct7};
                    else if (funct3 == `FNC_SLL) alu_sel = 4'd2;
                    else if (funct3 == `FNC_SLT) alu_sel = 4'd3;
                    else if (funct3 == `FNC_SLTU) alu_sel = 4'd4;
                    else if (funct3 == `FNC_XOR) alu_sel = 4'd5;
                    else if (funct3 == `FNC_OR) alu_sel = 4'd6;
                    else if (funct3 == `FNC_AND) alu_sel = 4'd7;
                    else if (funct3 == `FNC_SRL_SRA) alu_sel = {1'b1, {2{1'b0}}, funct7};
                    else alu_sel = 4'd0;
                end
            `OPC_ARI_ITYPE_5:
                begin
                    imm_sel = 3'd1;
                    a_sel = 1'd0;
                    b_sel = 1'd1;
                    b_unsigned = 1'b0;
                    reg_we = 1'b1;
                    wb_sel = 2'd1;
                    sdx_en = 1'b0;
                    imux_nop = 1'b0;
                    csr_sel = 1'd0;
                    csr_en = 1'd0;
                    pc_sel = 1'b0;
                    kill_next = 1'b0;
                    if (funct3 == `FNC_ADD_SUB) alu_sel = 4'd0;
                    else if (funct3 == `FNC_SLL) alu_sel = 4'd2;
                    else if (funct3 == `FNC_SLT) alu_sel = 4'd3;
                    else if (funct3 == `FNC_SLTU) alu_sel = 4'd4;
                    else if (funct3 == `FNC_XOR) alu_sel = 4'd5;
                    else if (funct3 == `FNC_OR) alu_sel = 4'd6;
                    else if (funct3 == `FNC_AND) alu_sel = 4'd7;
                    else if (funct3 == `FNC_SRL_SRA) alu_sel = {1'b1, {2{1'b0}}, funct7};
                    else alu_sel = 4'd0;
                end
            default:
                begin
                    imm_sel = 3'd0;
                    a_sel = 1'b0;
                    b_sel = 1'd0;
                    b_unsigned = 1'b0;
                    alu_sel = 4'd0;
                    reg_we = 1'b0;
                    wb_sel = 2'd1;
                    sdx_en = 1'b0;
                    imux_nop = 1'b0;
                    csr_sel = 1'd0;
                    csr_en = 1'd0;
                    pc_sel = 1'b0;
                    kill_next = 1'b0;
                end

        endcase




        
        //kills instructions after jumping
        if (kill_now || stall) begin
            imm_sel = 3'd0;
            a_sel = 1'b0;
            b_sel = 1'd0;
            b_unsigned = 1'b0;
            alu_sel = 4'd0;
            reg_we = 1'b0;
            wb_sel = 2'd1;
            sdx_en = 1'b0;
            imux_nop = 1'b1;
            csr_sel = 2'd0;
            pc_sel = 1'b0;
            kill_next = 1'b0;
        end





        if (inst[6:0] == `OPC_CSR && !stall) begin
            imm_sel = 3'd6;
            a_sel = 1'd0;
            b_sel = 1'd1;
            b_unsigned = 1'b0;
            alu_sel = 4'd0;
            reg_we = 1'b0;
            wb_sel = 2'd1;
            sdx_en = 1'b0;
            imux_nop = 1'b0;
            csr_en = 1'd1;
            pc_sel = 1'b0;
            kill_next = 1'b0;
            if (funct3 == 3'b001) csr_sel = 1'd0;
            else if (funct3 == 3'b101) csr_sel = 1'd1;
        end


        if (rst || inst == 32'd0) begin
            imm_sel = 3'd0;
            a_sel = 1'b0;
            b_sel = 1'd0;
            b_unsigned = 1'b0;
            alu_sel = 4'd0;
            reg_we = 1'b0;
            wb_sel = 2'd1;
            sdx_en = 1'b0;
            csr_sel = 2'd0;
            pc_sel = 1'b0;
            kill_next = 1'b0;
        end
    end
endmodule