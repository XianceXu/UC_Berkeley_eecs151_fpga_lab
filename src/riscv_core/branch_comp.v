module branch_comp(data_a, data_b, branch_unsigned, branch_type);
input [31:0]data_a;
input [31:0]data_b;
input branch_unsigned;
output reg [1:0]branch_type;


//first bit equal_____________second bit lessthan


wire unsigned greater_u, lessthan_u;
wire signed   greater_s, lessthan_s;



assign greater_u = $unsigned(data_a) > $unsigned(data_b);
assign lessthan_u = $unsigned(data_a) < $unsigned(data_b);
assign greater_s = $signed(data_a) > $signed(data_b);
assign lessthan_s = $signed(data_a) < $signed(data_b);

always @(*)begin
    if (branch_unsigned) begin
        if (greater_u) branch_type = 2'b00;
        else if (lessthan_u) branch_type = 2'b01;
        else branch_type = 2'b10;
    end else begin
        if (greater_s) branch_type = 2'b00;
        else if (lessthan_s) branch_type = 2'b01;
        else branch_type = 2'b10;
    end 

end

endmodule