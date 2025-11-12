module ctrl_pipe_m_w(clk, rst, reg_we_x, reg_we_m);
    input clk, rst, reg_we_x;

    output reg reg_we_m;

    initial begin
        reg_we_m = 1'b0;
    end
        
    always @(posedge clk or posedge rst) begin
            if (rst) begin
                reg_we_m <= 1'b0;
            end else begin
                reg_we_m <= reg_we_x;
            end
    end



endmodule // REGISTER