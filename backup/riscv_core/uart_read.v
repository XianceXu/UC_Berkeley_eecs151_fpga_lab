module uart_read (uart_en, addr, raw_rx_data, rx_valid, tx_ready, data_out, cyc_count, inst_count);
    input [3:0] uart_en;
    input [7:0] addr;
    input [7:0] raw_rx_data;
    input [31:0] cyc_count, inst_count;
    input rx_valid, tx_ready;

    output reg [31:0] data_out;

    initial begin
        data_out = 32'd0;
    end

    always @(*) begin
        case (addr)
            8'h00: begin//uart control
                    data_out = {{30{1'b0}}, rx_valid, tx_ready};
                end 
            8'h04: //uart receive datas
                begin
                    data_out = {{24{1'b0}}, raw_rx_data};
                end
            8'h10: //cycle counter
                begin
                    data_out = cyc_count;
                end
            8'h14: //inst counter
                begin
                    data_out = inst_count;
                end
            default: data_out = 32'd0;


        endcase

        if (uart_en != 4'd8) data_out = 32'd0;


    end




endmodule