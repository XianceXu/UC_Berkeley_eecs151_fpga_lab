// module pc();
//     input [1:0]pc_sel;
//     input [31:0]pc_plus4;
//     input [31:0]pc_jalr;
//     output [31:0]pc;

//     wire [31:0]pc_plus4;
//     reg [31:0]pc;

//     assign pc_plus4 = pc + 32'd4;

//     always @(*)begin

//             case(pc_sel)
//             2'b00: pc <= pc_plus4;
//             2'b01: pc <= pc_jalr;
//             default: pc <= pc_plus4;
//             endcase

//         end//trett
//     end

// endmodule