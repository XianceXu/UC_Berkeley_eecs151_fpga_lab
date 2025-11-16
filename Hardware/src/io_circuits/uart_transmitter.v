module uart_transmitter #(
    parameter CLOCK_FREQ = 125_000_000,
    parameter BAUD_RATE = 115_200)
(
    input clk,
    input reset,

    input [7:0] data_in,
    input data_in_valid,
    output data_in_ready,

    output serial_out
);
    // See diagram in the lab guide
    localparam  SYMBOL_EDGE_TIME    =   CLOCK_FREQ / BAUD_RATE;
    localparam  SAMPLE_TIME         =   SYMBOL_EDGE_TIME / 2;
    localparam  CLOCK_COUNTER_WIDTH =   $clog2(SYMBOL_EDGE_TIME);
    
    wire symbol_edge;
    wire sample;
    wire start;
    wire stop;
    wire tx_running;
    wire full_cycle_start;

    reg [9:0] tx_shift;
    reg [3:0] bit_counter;
    reg [CLOCK_COUNTER_WIDTH-1:0] clock_counter;


    //----------------SIGNAL ASSIGNMENTS--------------------

    // goes high at every symbol edge
    /* verilator lint_off WIDTH */ 
    assign symbol_edge = clock_counter == (SYMBOL_EDGE_TIME - 1);
    /* lint_on */

    // goes high halfway through each symbol
    /* verilator lint_off WIDTH */
    assign sample = clock_counter == SAMPLE_TIME;
    /* lint_on */

    //goes high when it is time to start transmiting a new character
    assign start = data_in_valid && data_in_ready;

    //goes high while we are transmitting a character
    assign tx_running = bit_counter != 4'd0;

    //goes high if on last stop cycle
    assign stop = bit_counter == 1'b1;

    //outputs
    assign serial_out =  tx_shift[0];
    assign data_in_ready = !tx_running;


    //------------------COUTNERS-----------------------------

    //counts cycles until a single symbol is done
    always @(posedge clk) begin
        clock_counter <= (start || reset || symbol_edge) ? 0 : clock_counter + 1; 
    end

    //counts up to 10 bits for every charactor
    always @(posedge clk) begin
        if (reset) begin
            bit_counter <= 0;
	end else if (data_in_valid && !tx_running) begin
	    bit_counter <= 10;
	end else if (symbol_edge && tx_running) begin
	    bit_counter <= bit_counter - 1;
        end
    end


    //-----------------SHIFT REGISTER----------------------
    always @(posedge clk) begin
	if (data_in_valid) tx_shift <= {1'b1, data_in, 1'b0};
	else if (symbol_edge && tx_running) tx_shift <= {1'b1, tx_shift[9:1]};
	else if (reset) tx_shift <= {10'b11_1111_1111};
    end

    //-----------------VERIFICATION---------------------------
    // assert property (@(posedge clk) (!tx_running) |-> (data_in_ready && serial_out));
    // assert property (@(posedge clk) (data_in_valid && !tx_running) |-> (data_in_ready==0) [* (SYMBOL_EDGE_TIME*10)] ##1 (data_in_ready==1));
    // assert property (@(posedge clk) (tx_running) |-> (data_in_ready==0) [* (SYMBOL_EDGE_TIME)*10] ##1 (data_in_ready==1));



endmodule
