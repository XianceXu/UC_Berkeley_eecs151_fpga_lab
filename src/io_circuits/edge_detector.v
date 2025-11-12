module edge_detector #(
    parameter WIDTH = 1
)(
    input clk,
    input [WIDTH-1:0] signal_in,
    output [WIDTH-1:0] edge_detect_pulse
);
    // TODO: implement a multi-bit edge detector that detects a rising edge of 'signal_in[x]'
    // and outputs a one-cycle pulse 'edge_detect_pulse[x]' at the next clock edge
    
    reg [WIDTH-1:0] delayed;
    reg [WIDTH-1:0] edge_detect_reg;
    integer i;
    always @(posedge clk) begin
	for (i = 0; i < WIDTH; i = i + 1) begin
	    delayed[i] <= signal_in[i];
	    edge_detect_reg[i] <= (~delayed[i]) & signal_in[i];
	end
    end
    genvar j;
    for (j = 0; j < WIDTH; j = j + 1) begin
        assign edge_detect_pulse[j] = edge_detect_reg[j];
    end
    
  
    
endmodule
