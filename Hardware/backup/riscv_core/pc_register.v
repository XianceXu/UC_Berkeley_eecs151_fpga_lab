// Register with reset value
module pc_register(q, d, rst, clk, reset_bool);
  parameter N = 1;
  parameter INIT = {N{1'b0}};
  output reg [N-1:0] q;
  input [N-1:0]      d;
  input 	      rst, clk;
  initial q = INIT;
  output reg reset_bool;

  always @(posedge clk) begin
    if (reset_bool ) begin 
      q <= INIT;
      if (!rst) reset_bool = 1'b0;
    end
    else q <= d;
  end

  always @(*) begin
    if (rst) begin
      reset_bool = 1'b1;
    end
  end
endmodule // REGISTER_R