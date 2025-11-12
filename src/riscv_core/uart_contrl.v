`include "opcode.vh"

module uart_contrl (uart_en, addr, opcode, uart_read, uart_write);
    input [7:0] addr;
    input [4:0] opcode;
    input [3:0] uart_en;

    output reg uart_read, uart_write;

    initial begin
        uart_read = 1'b0;
        uart_write = 1'b0;
    end


    always @(*) begin
        case (addr)
            8'h00: begin//uart control
                    if (uart_en == 4'h8 && opcode == `OPC_LOAD_5) uart_read = 1'b1;
                    else uart_read = 1'b0;

                    uart_write = 1'b0;

                end 
            8'h04: //uart receive datas
                begin
                    if (uart_en == 4'h8 && opcode == `OPC_LOAD_5) uart_read = 1'b1;
                    else uart_read = 1'b0;

                    uart_write = 1'b0;

                end
            8'h08: //uart transmit data
                begin
                    if (uart_en == 4'h8 && opcode == `OPC_STORE_5) uart_write = 1'b1;
                    else uart_write = 1'b0;

                    uart_read = 1'b0;   

                end
            8'h10: //cycle counter
                begin
                    if (uart_en == 4'h8 && opcode == `OPC_LOAD_5) uart_read = 1'b1;
                    else uart_read = 1'b0;

                    uart_write = 1'b0;

                end
            8'h14: //inst counter
                begin
                    if (uart_en == 4'h8 && opcode == `OPC_LOAD_5) uart_read = 1'b1;
                    else uart_read = 1'b0;

                    uart_write = 1'b0;

                end
            8'h18: //reset counte
                begin
                    if (uart_en == 4'h8 && opcode == `OPC_STORE_5) uart_write = 1'b1;
                    else uart_write = 1'b0;

                    uart_read = 1'b0;   
                end
            default: begin
                uart_read = 1'b0;
                uart_write = 1'b0;
            end



        endcase


    end




endmodule

        // .data_out(uart_rx_data_out),
        // .data_out_valid(uart_rx_data_out_valid),
        // .data_out_ready(uart_rx_data_out_ready), //needs this one

        // .serial_out(serial_out),
        // .data_in(uart_tx_data_in),
        // .data_in_valid(uart_tx_data_in_valid),  //needs this oine check address and funciton
        // .data_in_ready(uart_tx_data_in_ready)