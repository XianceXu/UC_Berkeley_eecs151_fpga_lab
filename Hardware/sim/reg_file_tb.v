'timescale 1ns/1ns

module reg_file_tb();

    reg clk = 0;
    reg in1, in2, writeIn, out1, out2, writeEn, writeData, out1, out2;

    always #(4) clock <= ~clock;

    reg_file daReg (.clk(clk), .we(writeEn), .ra1(in1),
                    .ra2(in2), .wa(writeIn), .wd(writeData), .rd1(out1), .rd2(out2));

    initial begin
        `ifdef IVERILOG
	    $dumbfile("counter_tb.fst");
	    $dumpvars(0, counter.tb);
	`endif
	`ifndef IVERILOG
	    $vcdpluson;
	`endif

    fork 
        begin
            #(8);
            writeEn = 1;
            writeData = 32'd39;
            writeIn = 32'd5;
            #(8);
            writeData = 32'd32;
            writeIn = 32'd4;
            #(8);
            writeEn = 0;
            in1 = 32'd5;
            in2 = 32'd4;
        end

        begin
            #(24);
            assert(out1 == 32'd39);
            assert(out2 == 32'd32);
        end
    join



    `ifndef IVERILOG
	    $vcdplusoff;
	`endif
	$finish();
    end
endmodule
