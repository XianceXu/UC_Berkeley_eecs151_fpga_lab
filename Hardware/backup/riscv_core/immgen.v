module immgen (
    input [2:0] immsel,
    input [24:0] inst_31_7,
    output reg [31:0] imm
);

    always @(*) begin // CL
        case (immsel)
        // 0: R-Type , 1: I-Type , 2: S-Type , 3: B-Type , 4: U-Type , 5: J- Type, 6: CSR- type
            3'h0: imm = 32'b0; // The value doesn ’t matter
            3'h1: imm = {{20{inst_31_7[24]}}, inst_31_7[24:13]};
            3'h2: imm = {{20{inst_31_7[24]}}, inst_31_7[24:18], inst_31_7[4:0]};
            3'h3: imm = {{19{inst_31_7[24]}}, inst_31_7[24], inst_31_7[0], inst_31_7[23:18], inst_31_7[4:1], 1'b0};
            3'h4: imm = {inst_31_7[24:5], 12'b0};
            3'h5: imm = {{12{inst_31_7[24]}}, inst_31_7[12:5], inst_31_7[13], inst_31_7[23:14], 1'b0};
            3'h6: imm = {{27{1'b0}}, inst_31_7[12:8]};
            default : imm = 32'b0;
        endcase
    end
endmodule
