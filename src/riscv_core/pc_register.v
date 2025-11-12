// Register with reset value
module pc_register(q, d, rst, clk, reset_bool);
  parameter N = 32;
  parameter INIT = {N{1'b0}};
  output reg [N-1:0] q;
  input [N-1:0]      d;
  input 	      rst, clk;
  initial q = INIT;
  output reg reset_bool;

  reg rst_reg_out;

  one_bit_reg rst_test_reg (
    .q(rst_reg_out),
    .d(rst),
    .clk(clk)
  );

  assign reset_bool = (rst||rst_reg_out);

  always @(posedge clk) begin
      if (reset_bool) q <= INIT;
      else q <= d;
  end

  // always @(posedge clk or posedge rst) begin
  //   if (rst) reset_bool <= 1'b1;
  //   else if (reset_bool) begin 
  //     q <= INIT;
  //     if (!rst) reset_bool <= 1'b0;
  //     else reset_bool <= 1'b1;
  //   end
  //   else begin
  //     q <= d;
  //     reset_bool <= 1'b0;
  //   end
  // end

endmodule // REGISTER_R