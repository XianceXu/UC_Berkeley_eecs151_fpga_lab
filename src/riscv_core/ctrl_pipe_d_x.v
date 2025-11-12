module ctrl_pipe_d_x(clk, rst, a_sel_d, b_sel_d, reg_we_d, sdx_en_d, wb_sel_d, 
                                imm_sel_d, alu_sel_d, imux_nop_d, csr_sel_d, csr_en_d,
                                a_sel_x, b_sel_x, reg_we_x, sdx_en_x, wb_sel_x, 
                                imm_sel_x, alu_sel_x, imux_nop_x, csr_sel_x, csr_en_x);


    input clk, rst, a_sel_d, b_sel_d, reg_we_d, imux_nop_d;
    input sdx_en_d, csr_sel_d, csr_en_d;
    input [1:0] wb_sel_d;
    input [2:0] imm_sel_d;
    input [3:0] alu_sel_d;


    output reg a_sel_x, b_sel_x, reg_we_x, imux_nop_x;
    output reg sdx_en_x, csr_sel_x, csr_en_x;
    output reg [1:0] wb_sel_x;
    output reg [2:0] imm_sel_x;
    output reg [3:0] alu_sel_x;

    initial begin
        a_sel_x = 1'b0;
        b_sel_x = 1'b0;
        reg_we_x = 1'b0;
        sdx_en_x = 1'b0;
        imux_nop_x = 1'b0;
        csr_en_x = 1'b0;
        csr_sel_x = 1'b0;
        wb_sel_x = 2'd0;
        imm_sel_x = 3'd0;
        alu_sel_x = 4'd0;
    end
        

    always @(posedge clk or posedge rst) begin
            if (rst) begin
                a_sel_x   <= 1'b0;
                b_sel_x   <= 1'b0;
                reg_we_x  <= 1'b0;
                sdx_en_x  <= 1'b0;
                imux_nop_x <= 1'b0;
                csr_en_x <= 1'b0;
                csr_sel_x <= 1'b0;
                wb_sel_x  <= 2'd0;
                imm_sel_x <= 3'd0;
                alu_sel_x <= 4'd0;
            end else begin
                a_sel_x   <= a_sel_d;
                b_sel_x   <= b_sel_d;
                reg_we_x  <= reg_we_d;
                sdx_en_x  <= sdx_en_d;
                imux_nop_x <= imux_nop_d;
                csr_en_x <= csr_en_d;
                csr_sel_x <= csr_sel_d;
                wb_sel_x  <= wb_sel_d;
                imm_sel_x <= imm_sel_d;
                alu_sel_x <= alu_sel_d;
            end
    end



endmodule // REGISTER