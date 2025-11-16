module alu (in1, in2, ctr, out);
input [31:0] in1, in2;
input [3:0] ctr;
output reg [31:0] out;




always @(*) begin 

    case(ctr)
        4'd0 out = a + b;                                               //add
        4'd1 out = a - b;                                               //subtract
        4'd2 out = a << b[4:0];                                         //shift left logical
        4'd3 out = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;           //set less than
        4'd4 out = ($unsigned(a) < $unsigned(b)) ? 32'd1 : 32'd0;       //set less than unsigned
        4'd5 out = a ^ b;                                               //xor
        4'd6 out = a | b;                                               //or
        4'd7 out = a & b;                                               //and 
        4'd8 out = a >> b[4:0];                                         //shift right logical
        4'd9 out = a >>> b[4:0];                                        //shift right arithmetic
        4'd11 out = a;                                                  //a
        4'd12 out = b;                                                  //b
        
 endcase
end


endmodule
