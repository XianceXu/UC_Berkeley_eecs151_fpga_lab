module first_pipeline_reg(clk, imem_rw_i, dmem_rw_i, reg_we_i, wb_sel_i, pc_sel_i,
                               imm_sel_i, alu_sel_i, a_sel_i, b_sel_i, b_unsigned_i,
                               imem_rw_x, dmem_rw_x, reg_we_x, wb_sel_x, pc_sel_x,
                               imm_sel_x, alu_sel_x, a_sel_x, b_sel_x, b_unsigned_x);

    input [3:0] imem_rw_i, dmem_rw_i, alu_sel_i; 
    input [2:0] imm_sel_i;
    input [1:0] wb_sel_i, a_sel_i, b_sel_i;
    input pc_sel_i, reg_we_i, clk, b_unsigned_i;

    output reg [3:0] imem_rw_x, dmem_rw_x, alu_sel_x; 
    output reg [2:0] imm_sel_x;
    output reg [1:0] wb_sel_x, a_sel_x, b_sel_x;
    output reg pc_sel_x, reg_we_x, b_unsigned_x;
    initial begin
        pc_sel_x = 1'b0;
        imem_rw_x = 4'd0;
        dmem_rw_x = 4'd0;   
        wb_sel_x = 2'd1;     
        reg_we_x = 1'd0;
        alu_sel_x = 4'd0;
        imm_sel_x = 3'd0;
        a_sel_x = 2'd0;
        b_sel_x = 2'd0;
        b_unsigned_x = 1'd0;
    end
        
    always @(posedge clk) begin
        pc_sel_x <= pc_sel_i;
        imem_rw_x <= imem_rw_i;
        dmem_rw_x <= dmem_rw_i;   
        wb_sel_x <= wb_sel_i;     
        reg_we_x <= reg_we_i;
        alu_sel_x <= alu_sel_i;
        imm_sel_x <= imm_sel_i;
        a_sel_x <= a_sel_i;
        b_sel_x <= b_sel_i;
        b_unsigned_x <= b_unsigned_i;
    end


endmodule // REGISTER
