module ctrl_pipe_x_m(clk, rst, reg_we_x, wb_sel_x,
                     reg_we_m, wb_sel_m);


    input clk, rst, reg_we_x;
    input [1:0] wb_sel_x;


    output reg reg_we_m;
    output reg [1:0] wb_sel_m;

    initial begin
        reg_we_m = 1'b0;
        wb_sel_m = 2'd0;

    end
        

    always @(posedge clk or posedge rst) begin
            if (rst) begin
                reg_we_m  <= 1'b0;
                wb_sel_m  <= 2'd0;
            end else begin
                reg_we_m  <= reg_we_x;
                wb_sel_m  <= wb_sel_x;
            end
    end



endmodule // REGISTER