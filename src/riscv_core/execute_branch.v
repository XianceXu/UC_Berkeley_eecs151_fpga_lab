module execute_branch(branch_x_en, b_equal, b_less, stall, funct3, b_taken);
input branch_x_en, b_equal, b_less, stall;
input [2:0] funct3;

reg b_temp;

output reg b_taken;

assign b_taken = (!stall) ? (branch_x_en & b_temp) : 1'b0;

always @(*) begin
        if (funct3 == 3'b000) begin //beq
            b_temp = (b_equal) ? 1'd1 : 1'd0;
        end 
        else if (funct3 == 3'b001) begin//bne
            b_temp = (!b_equal) ? 1'd1 : 1'd0;
        end 
        else if (funct3 == 3'b100 || funct3 == 3'b110) begin//blt
            b_temp = (b_less) ? 1'd1 : 1'd0;
        end 
        else if (funct3 == 3'b101 || funct3 == 3'b111) begin//bge
            b_temp = (!b_less) ? 1'd1 : 1'd0;
        end 
        else begin
            b_temp = 1'b0;
        end
end


endmodule