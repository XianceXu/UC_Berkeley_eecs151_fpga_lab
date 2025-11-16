module branch_comp()
input [31:0]data_a;
input [31:0]data_b;
input [1:0]branch_type;
output reg branch_taken;

always @(*)begin
    case (branch_type)
         2'b00: branch_taken = (data_a = data_b);    //b_eq
         2'b01: branch_taken = ($signed(data_a) < $signed(data_b));   //b_less
         default: branch_takenm = 1'b0;
    endcase
end

endmodule
