module second_pipeline_reg(clk, imem_rw_x, dmem_rw_x, reg_we_x, wb_sel_x, pc_sel_x, funct3_x, imux_nop_x, rst, 
                           clear, imem_rw_m, dmem_rw_m, reg_we_m, wb_sel_m, pc_sel_m, funct3_m, imux_nop_m);

    input [3:0] imem_rw_x, dmem_rw_x; 
    input [2:0] funct3_x;
    input [1:0] wb_sel_x, pc_sel_x;
    input reg_we_x, clk, imux_nop_x, rst, clear;

    output reg [3:0] imem_rw_m, dmem_rw_m; 
    output reg [2:0] funct3_m;
    output reg [1:0] wb_sel_m, pc_sel_m;
    output reg reg_we_m, imux_nop_m;
    initial begin
        pc_sel_m = 2'd0;
        imem_rw_m = 4'd0;
        dmem_rw_m = 4'd0;
        wb_sel_m = 2'd0;
        reg_we_m = 1'd0;
        funct3_m = 3'b0;
        imux_nop_m = 1'b0;
    end
        
    always @(posedge clk) begin
            if (!rst || !clear) begin
                pc_sel_m <= pc_sel_x;
                imem_rw_m <= imem_rw_x;
                dmem_rw_m <= dmem_rw_x;   
                wb_sel_m <= wb_sel_x;     
                reg_we_m <= reg_we_x;    
                funct3_m <= funct3_x;
                imux_nop_m <= imux_nop_x;
            end
    end
    always @(*) begin
        if (rst) begin 
            pc_sel_m = 2'd0;
            imem_rw_m = 4'd0;
            dmem_rw_m = 4'd0;
            wb_sel_m = 2'd1;
            reg_we_m = 1'd0;
            funct3_m = 3'b0;
            imux_nop_m = 1'b0;
        end
        if (clear) begin 
            pc_sel_m = 2'd0;
            imem_rw_m = 4'd0;
            dmem_rw_m = 4'd0;
            wb_sel_m = 2'd1;
            reg_we_m = 1'd0;
            funct3_m = 3'b0;
            imux_nop_m = 1'b0;
        end
    end


endmodule // REGISTER
