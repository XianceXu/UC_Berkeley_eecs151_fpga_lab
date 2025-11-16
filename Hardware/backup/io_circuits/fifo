module fifo #(
    parameter WIDTH = 8,
    parameter DEPTH = 32,
    parameter POINTER_WIDTH = $clog2(DEPTH)
) (
    input clk, rst,

    // Write side
    input wr_en,
    input [WIDTH-1:0] din,
    output full,

    // Read side
    input rd_en,
    output [WIDTH-1:0] dout,
    output empty
);

    //vars
    reg [POINTER_WIDTH:0] size;
    integer i;

    //registers :)
    reg [POINTER_WIDTH-1:0] r_ptr;
    reg [POINTER_WIDTH-1:0] w_ptr;
    reg [WIDTH-1:0] buff [DEPTH-1:0];
    reg [WIDTH-1:0] out_reg;

    //assign size to be distance of read and write pointers
    //assign size = w_ptr - r_ptr;

    //assign out dout to the out reg
    assign dout = out_reg;
    
    //assign full if size is max or empty if opposite
    assign full = size == DEPTH;
    assign empty = size == 0;


    always @(posedge clk) begin
	if (rst) begin
	    for (i = 0; i < DEPTH; i = i + 1) begin
                buff[i] <= 0;
	    end
	    size <= 0;
	    w_ptr <= 0;	
	    r_ptr <= 0;
    	end
	else begin
        if (rd_en && wr_en && !empty && !full) begin
	        out_reg <= buff[r_ptr];
		    r_ptr <= r_ptr + 1;
		    buff[w_ptr] <= din;
		    w_ptr <= w_ptr + 1;
	    end
	    else if (rd_en && !empty && !wr_en) begin
            	out_reg <= buff[r_ptr];
            	r_ptr <= r_ptr + 1;
            	size <= size - 1;
	    end
    	else if (wr_en && !full && !rd_en) begin
	    	buff[w_ptr] <= din;
	    	w_ptr <= w_ptr + 1;
	    	size <= size + 1;
        end
	end
    end

    //VERIFICATION
    // assert property (@(posedge clk) (full && wr_en && rst) |-> (w_ptr == ($past(w_ptr))));
    // assert property (@(posedge clk) (empty && rd_en && rst) |-> (r_ptr == ($past(r_ptr))));
    // assert property (@(posedge clk) (rst) |-> ##1 ((r_ptr == 0)&&(w_ptr == 0)&&!full));

   
endmodule
