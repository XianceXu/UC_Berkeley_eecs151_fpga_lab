module synchronizer #(parameter WIDTH = 1) (
    input [WIDTH-1:0] async_signal,
    input clk,
    output [WIDTH-1:0] sync_signal
);
    // TODO: Create your 2 flip-flop synchronizer here
    // This module takes in a vector of WIDTH-bit asynchronous
    // (from different clock domain or not clocked, such as button press) signals
    // and should output a vector of WIDTH-bit synchronous signals
    // that are synchronized to the input clk

    reg [WIDTH-1:0] async_reg;
    reg [WIDTH-1:0] sync_reg;

    //always @(posedge async_signal) begin
    //    async_reg <= async_signal;
    //end
    
    //always @(posedge clk) begin
    //    sync_reg <= async_reg;
    //    async_reg <= 1'b0;
    //end

    always @(posedge clk) begin
        async_reg <= async_signal;
        sync_reg <= async_reg;
    end
    assign sync_signal = sync_reg;
    ///////////////////////////////////////////////////

        

endmodule
