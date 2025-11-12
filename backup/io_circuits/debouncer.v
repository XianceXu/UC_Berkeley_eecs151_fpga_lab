module debouncer #(
    parameter WIDTH              = 1,
    parameter SAMPLE_CNT_MAX     = 62500,
    parameter PULSE_CNT_MAX      = 200,
    parameter WRAPPING_CNT_WIDTH = $clog2(SAMPLE_CNT_MAX),
    parameter SAT_CNT_WIDTH      = $clog2(PULSE_CNT_MAX) + 1
) (
    input clk,
    input [WIDTH-1:0] glitchy_signal,
    output [WIDTH-1:0] debounced_signal
);
    // TODO: fill in neccesary logic to implement the wrapping counter and the saturating counters
    // Some initial code has been provided to you, but feel free to change it however you like
    // One wrapping counter is required, one saturating counter is needed for each bit of glitchy_signal
    // You need to think of the conditions for reseting, clock enable, etc. those registers
    // Refer to the block diagram in the spec

    // Remove this line once you have created your debouncer
    //assign debounced_signal = 0;

    reg [SAT_CNT_WIDTH-1:0] saturating_counter [WIDTH-1:0];
    reg [WRAPPING_CNT_WIDTH-1:0] wrapping_counter;
    wire sample_pulse_out;
    
    integer q;
    initial begin
        for (q = 0; q < WIDTH; q = q + 1) begin
            saturating_counter[q] = 0;
	end
	wrapping_counter = 0;
    end

    //sample pule generator
    always @(posedge clk) begin
        if (wrapping_counter < SAMPLE_CNT_MAX) begin
	    wrapping_counter <= wrapping_counter + 1;
	end else begin
	    wrapping_counter <= 0;
	end
    end
    
    assign sample_pulse_out = (wrapping_counter == SAMPLE_CNT_MAX);

    //saturating counter
    integer i, c;
    genvar j; 
    always @(posedge clk) begin
	for (i = 0; i < WIDTH; i = i + 1) begin
	    if (sample_pulse_out == 1) begin
	        if (glitchy_signal != 0 && saturating_counter[i] != PULSE_CNT_MAX) begin
	            saturating_counter[i] = saturating_counter[i] + 1;
	        end
	    end else if (glitchy_signal == 0) begin
                for (c = 0; c < WIDTH; c = c + 1) begin
		     saturating_counter[c] = 0;
	        end
	    end
	end
    end

    for (j = 0; j < WIDTH; j = j + 1) begin
        assign debounced_signal[j] = saturating_counter[j] == PULSE_CNT_MAX;
    end
endmodule

