module cpu #(
    parameter CPU_CLOCK_FREQ = 50_000_000,
    parameter RESET_PC = 32'h4000_0000,
    parameter BAUD_RATE = 115200
) (
    input clk,
    input rst,
    input bp_enable,
    input serial_in,
    output serial_out
);
    // BIOS Memory
    // Synchronous read: read takes one cycle
    // Synchronous write: write takes one cycle
    wire [11:0] bios_addra, bios_addrb;
    wire [31:0] bios_douta, bios_doutb;
    wire bios_ena, bios_enb;
    bios_mem bios_mem (
      .clk(clk),
      .ena(bios_ena),
      .addra(bios_addra),
      .douta(bios_douta),
      .enb(bios_enb),
      .addrb(bios_addrb),
      .doutb(bios_doutb)
    );

    // Data Memory
    // Synchronous read: read takes one cycle
    // Synchronous write: write takes one cycle
    // Write-byte-enable: select which of the four bytes to write
    wire [13:0] dmem_addr;
    wire [31:0] dmem_din, dmem_dout;
    wire [3:0] dmem_we;
    wire dmem_en;
    dmem dmem (
      .clk(clk),
      .en(dmem_en),
      .we(dmem_we),
      .addr(dmem_addr),
      .din(dmem_din),
      .dout(dmem_dout)
    );

    // Instruction Memory
    // Synchronous read: read takes one cycle
    // Synchronous write: write takes one cycle
    // Write-byte-enable: select which of the four bytes to write
    wire [31:0] imem_dina, imem_doutb;
    wire [13:0] imem_addra, imem_addrb;
    wire [3:0] imem_wea;
    wire imem_ena;
    imem imem (
      .clk(clk),
      .ena(imem_ena),
      .wea(imem_wea),
      .addra(imem_addra),
      .dina(imem_dina),
      .addrb(imem_addrb),
      .doutb(imem_doutb)
    );

    // On-chip UART
    //// UART Receiver
    wire [7:0] uart_rx_data_out;
    wire uart_rx_data_out_valid;
    wire uart_rx_data_out_ready;
    //// UART Transmitter
    wire [7:0] uart_tx_data_in;
    wire uart_tx_data_in_valid;
    wire uart_tx_data_in_ready;
    uart #(
        .CLOCK_FREQ(CPU_CLOCK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) on_chip_uart (
        .clk(clk),
        .reset(rst),

        .serial_in(serial_in),
        .data_out(uart_rx_data_out),
        .data_out_valid(uart_rx_data_out_valid),
        .data_out_ready(uart_rx_data_out_ready),

        .serial_out(serial_out),
        .data_in(uart_tx_data_in),
        .data_in_valid(uart_tx_data_in_valid),
        .data_in_ready(uart_tx_data_in_ready)
    );

    reg [31:0] tohost_csr = 0;

    // TODO: Your code to implement a fully functioning RISC-V core
    // Add as many modules as you want
    // Feel free to move the memory modules around

    //firstStage ----------------------------------------------------

    // mux for pc reg
    // Chooses between pc+4, or alu_out from third stage
    wire pc_sel;
    wire [31:0] pc_plus_4;
    wire [31:0] alu_out_3;
    wire [31:0] pc_in_reg;
    wire [31:0] pc_out_reg;
    pc_mux pcm (
        .add_4(pc_plus_4),
        .alu(alu_out_3),
        .pc_sel(pc_sel),
        .out(pc_in_reg)
    );

    // adder for program counter
    pc_add4 pc_incrementer (
        .pc(pc_out_reg)
        .out(pc_plus_4)
    );

    //pc_register
    pc_register #(.N(32), .INIT(RESET_PC)) pc_reg (
        .q(pc_in_reg),
        .d(pc_out_reg),
        .rst(rst),
        .clk(clk)
    ); 
    //assign all the wires for pc register to bios/imem/adder
    assign bios_addra = pc_out_reg[11:0];
    assign imem_addrb = pc_out_reg[13:0];

    //instruction mux before at end of first stage
    wire first_stage_inst;
    instruction_mux i_mux (
        .bios_douta(bios_douta),
        .imem_doutb(imem_doutb),
        .inst(i_mux_inst)
    );


    //wire outputs into the second stage
    wire second_stage_inst;
    wire second_stage_pc;
    wire second_stage_pc_plus4;
    //first stage pipeline registers
    // inst reg
    simple_register #(.N(32)) first_stage_inst_reg (
        .q(first_stage_inst),
        .d(second_stage_inst),
        .clk(clk)
    ); 
    // pc reg
    simple_register #(.N(32)) first_stage_pc_reg (
        .q(pc_out_reg),
        .d(second_stage_pc),
        .clk(clk)
    ); 
    // inst reg
    simple_register #(.N(32)) first_stage_pc_plus4_reg (
        .q(pc_plus_4),
        .d(second_stage_pc_plus4),
        .clk(clk)
    ); 





    //secondStage


    

    // Register file
    // Asynchronous read: read data is available in the same cycle
    // Synchronous write: write takes one cycle
    wire reg_we;
    wire [4:0] reg_ra1, reg_ra2, reg_wa;
    wire [31:0] reg_wd;
    wire [31:0] reg_rd1, reg_rd2;
    reg_file rf (
        .clk(clk),
        .we(reg_we),
        .ra1(reg_ra1), .ra2(reg_ra2), .wa(reg_wa),
        .wd(reg_wd),
        .rd1(reg_rd1), .rd2(reg_rd2)
    );

    assign reg_ra1 = second_stage_inst[19:15];
    assign reg_ra2 = second_stage_inst[24:20];
    assign reg_wa = second_stage_inst[11:7];
    // assign reg_wd =           add from third stage
    // assign reg_we = 
 

    //immediate generator
    wire [2:0] immsel;
    wire [31:0] imm;
    immgen immediate_generator (
        .immsel(immsel),
        .inst_31_7(second_stage_inst[31:7]),
        .imm(imm)
    );

    //Branch Comparator
    wire BrUn, BrEq, BrLt;
    branch_comparator bc (
        .BrUn(BrUn),
        .a_in(reg_ra1),
        .b_in(reg_ra2),
        .BrEq(BrEq),
        .BrLt(BrLt)
    );
    

    //a_sel mux
    wire a_sel, a_out;
    a_mux amux (
        .reg_file_data_a(reg_ra1),
        .pc(pc_out_reg),
        .alu_forward(),
        .a_sel(a_sel),
        .a_out(a_out)
    );

    //b_sel mux

    //alu

    //thirdStage
endmodule
