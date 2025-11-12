`include "opcode.vh"

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
        .data_out_valid(uart_rx_data_out_valid), //output
        .data_out_ready(uart_rx_data_out_ready), //needs this one check address and function load

        .serial_out(serial_out),
        .data_in(uart_tx_data_in), //need to set
        .data_in_valid(uart_tx_data_in_valid),  //needs this oine check address and funciton save
        .data_in_ready(uart_tx_data_in_ready)   //output
    );

    wire [31:0] csr_save;
    wire csr_sel, csr_en;

    reg [31:0] tohost_csr;
    reg [31:0] cycle_counter, inst_counter;

    // TODO: Your code to implement a fully functioning RISC-V core
    // Add as many modules as you want
    // Feel free to move the memory modules around


    wire br_un_x, reg_we_x, imux_nop_x, store_haz;
    wire [1:0] a_sel_x, b_sel_x, wb_sel_x, pc_sel_x;
    wire [2:0] imm_sel_x, f3_x;
    wire [3:0] imem_rw_x, dmem_rw_x, alu_sel_x;
    wire reg_we_m, imux_nop_m;
    wire [1:0] wb_sel_m, pc_sel_m;
    wire [2:0] f3_m;
    wire [3:0] imem_rw_m, dmem_rw_m;
    wire [31:0] alu_out;
    wire [31:0] third_stage_inst, fourth_stage_inst;
    wire [31:0] second_stage_inst;
    wire [31:0] uart_raw_out, uart_read_out, third_stage_uart_out, third_stage_uart_read;

    //firstStage ----------------------------------------------------

    // mux for pc reg
    // Chooses between pc+4, or alu_out from third stage
    wire [31:0] pc_plus_4;
    wire [31:0] pc_in_reg;
    wire [31:0] pc_out_reg;
    // alu
    wire [31:0] third_stage_alu;
    wire pc_rst_bool;

    wire [1:0] better_pc_sel;

    assign better_pc_sel = ((third_stage_inst[6:2] == `OPC_JAL_5 || third_stage_inst[6:2] == `OPC_JALR_5) && !pc_rst_bool) ? 2'd1 : (second_stage_inst[6:2] == `OPC_BRANCH_5 && imux_nop_x) ? 2'd2 : 2'd0;
    pc_mux #(.INIT(RESET_PC))pcm (
        .add_4(pc_plus_4),
        .alu(third_stage_alu),
        .pc_sel(better_pc_sel),
        // .alu(third_stage_alu),
        // .pc_sel(pc_sel_m),
        .out(pc_in_reg),
        .rst(rst), 
        .alu_forward(alu_out)
    );

    // adder for program counter
    pc_add4 pc_incrementer (
        .pc(pc_out_reg),
        .out(pc_plus_4)
    );

    //pc_register
    wire reset_bool_x;
    pc_register #(.N(32), .INIT(RESET_PC)) pc_reg (
        .q(pc_out_reg),
        .d(pc_in_reg),
        .rst(rst),
        .clk(clk),
        .reset_bool(pc_rst_bool)
    ); 

    //assign all the wires for pc register to bios/imem/adder

    
    assign bios_addra = (pc_rst_bool) ? RESET_PC[13:2] : pc_out_reg[13:2];
    assign imem_addrb = (pc_rst_bool) ? RESET_PC[15:2] : pc_out_reg[15:2];
    assign imem_ena = 1;
    assign bios_ena = 1;
    assign bios_enb = 1;
    assign dmem_en = 1;

    //instruction mux before at end of first stage
    // wire [31:0] first_stage_inst;
    instruction_mux i_mux (
        .bios_douta(bios_douta),
        .imem_doutb(imem_doutb),
        .inst(second_stage_inst),
        .pc_30(pc_out_reg[30]), 
        .imux_nop(reset_bool_x || imux_nop_m)
    );  


    //wire outputs into the second stage
    wire [31:0] second_stage_pc;
    wire [31:0] second_stage_pc_plus4;
    //first stage pipeline registers
    // inst reg
    // simple_register #(.N(32)) first_stage_inst_reg (
    //     .q(second_stage_inst),
    //     .d(first_stage_inst),
    //     .clk(clk)
    // ); 
    // pc reg
    simple_register_rst first_stage_pc_reg (
        .q(second_stage_pc),
        .d(pc_out_reg),
        .clk(clk), 
        .rst(pc_rst_bool),
        .rst_val(RESET_PC)

    ); 
    // inst reg
    simple_register_rst first_stage_pc_plus4_reg (
        .q(second_stage_pc_plus4),
        .d(pc_plus_4),
        .clk(clk),
        .rst(pc_rst_bool),
        .rst_val(RESET_PC + 32'd4)
    ); 
    //reset
    simple_register reset_i_x_reg (
        .q(reset_bool_x),
        .d(pc_rst_bool),
        .clk(clk)
    ); 





    //secondStage


    

    // Register file
    // Asynchronous read: read data is available in the same cycle
    // Synchronous write: write takes one cycle
    wire [4:0] reg_ra1, reg_ra2, reg_wa;
    wire [31:0] reg_wd;
    wire [31:0] reg_rd1, reg_rd2;
    reg_file rf (
        .clk(clk),
        .we(reg_we_m),
        .ra1(reg_ra1), .ra2(reg_ra2), .wa(reg_wa),
        .wd(reg_wd),
        .rd1(reg_rd1), .rd2(reg_rd2)
    );

    assign reg_ra1 = second_stage_inst[19:15];
    assign reg_ra2 = second_stage_inst[24:20];
    assign reg_wa = third_stage_inst[11:7];// need to chang to third stage
 

    //immediate generator
    wire [31:0] imm;
    immgen immediate_generator (
        .immsel(imm_sel_x),
        .inst_31_7(second_stage_inst[31:7]),
        .imm(imm)
    );

    //Branch Comparator
    wire BrEq, BrLt;
    wire [2:0] br_haz;
    wire [31:0] branch_mux_out_a, branch_mux_out_b;
    wire [31:0] ldx_out;

    branch_mux br_mux (
        .br_haz(br_haz),
        .data_a(reg_rd1),
        .data_b(reg_rd2),
        .alu_forward(third_stage_alu),
        .dmem_foward(ldx_out),
        .branch_mux_out_a(branch_mux_out_a),
        .branch_mux_out_b(branch_mux_out_b)
    );

    branch_comp bc (
        .data_a(branch_mux_out_a),
        .data_b(branch_mux_out_b), 
        .branch_unsigned(br_un_x),
        .branch_type({BrEq, BrLt})
    );
    

    //a_sel mux
    wire [31:0] a_out;
    a_mux amux (
        .reg_file_data_a(reg_rd1),
        .pc(second_stage_pc),
        .alu_forward(third_stage_alu),
        .dmem_foward(ldx_out),
        .a_sel(a_sel_x),
        .a_out(a_out)
    );

    //b_sel mux
    wire [31:0] b_out;
    //datamux
    wire [31:0] data_mux_out;

    b_mux bmux (
        .reg_file_data_b(reg_rd2),
        .imm_gen_out(imm),
        .alu_forward(third_stage_alu),
        .dmem_foward(ldx_out),
        .b_sel(b_sel_x),
        .b_out(b_out)
    );

    //alu
    alu daAlu (
        .a(a_out),
        .b(b_out),
        .ctr(alu_sel_x),
        .out(alu_out)
    );


    always @(posedge clk) begin
        if (rst) tohost_csr <= 0;
        if (csr_en) begin
            if (!csr_sel) begin
                tohost_csr <= a_out;
            end else  begin
                tohost_csr <= b_out;
            end
        end
    end


    wire [31:0] third_stage_pc_plus4;
    //second stage pipeline registers
    // p cplus four reg
    simple_register_rst second_stage_pc_plus4_reg (
        .q(third_stage_pc_plus4),
        .d(pc_plus_4),
        .clk(clk), 
        .rst(pc_rst_bool),
        .rst_val(RESET_PC)
    ); 
    simple_register second_stage_alu_reg (
        .q(third_stage_alu),
        .d(alu_out),
        .clk(clk)
    ); 
    // regfile data b
    wire [31:0] third_stage_dataB_reg;
    simple_register second_stage_dataB_reg (
        .q(third_stage_dataB_reg),
        .d(reg_rd2),
        .clk(clk)
    ); 
    //reg for theirs stagte instruction
    simple_register third_stage_inst_reg (
        .q(third_stage_inst),
        .d(second_stage_inst),
        .clk(clk)
    );
    //reg for theirs stagte instruction
    simple_register fourth_stage_inst_reg (
        .q(fourth_stage_inst),
        .d(third_stage_inst),
        .clk(clk)
    );
    


    //thirdStage
    wire [31:0] sdx_out;
    wire sdx_en;
    sdx saveExtender (
        .data_reg_out(reg_rd2),
        .addr_end(alu_out[1:0]),
        .funct3(f3_x),
        .sdx_out(sdx_out), 
        .sdx_en(sdx_en), 
        .data_foward(reg_wd), 
        .store_haz(store_haz)
    );


    wire uart_read, uart_write;
    uart_contrl u_cntl (
        .uart_en(alu_out[31:28]),
        .addr(alu_out[7:0]),
        .opcode(second_stage_inst[6:2]),
        .uart_read(uart_read),
        .uart_write(uart_write)
    );

    assign bios_addrb = alu_out[13:2];

    assign dmem_addr = alu_out[15:2];
    assign dmem_din = sdx_out;
    assign dmem_we = (alu_out[28]) ?  dmem_rw_x : 4'd0;

    //need to add if we write to imem, or io
    assign imem_addra = alu_out[15:2];
    assign imem_dina = sdx_out;
    assign imem_wea = (second_stage_pc[30] && alu_out[29]) ?  dmem_rw_x : 4'd0;


    //io/ uart stuff


    assign uart_tx_data_in = sdx_out[7:0];
    assign uart_tx_data_in_valid = uart_write; 
    assign uart_rx_data_out_ready = third_stage_uart_read;

    uart_read uart_reader (
        .uart_en(third_stage_alu[31:28]),
        .addr(third_stage_alu[7:0]),
        .raw_rx_data(uart_rx_data_out),
        .cyc_count(cycle_counter),
        .inst_count(inst_counter),
        .data_out(uart_read_out),
        .rx_valid(uart_rx_data_out_valid),
        .tx_ready(uart_tx_data_in_ready)
    );

    //reg for theirs stagte instruction
    simple_register thirdstageUart (
        .q(third_stage_uart_out),
        .d(uart_read_out),
        .clk(clk)
    );

    //reg for theirs stagte instruction
    simple_register thirdstageUartread (
        .q(third_stage_uart_read),
        .d(uart_read),
        .clk(clk)
    );





    data_mux dmux (
        .bios_doutb(bios_doutb),
        .dmem_dout(dmem_dout),
        .data(data_mux_out),
        .addr(third_stage_alu[31:28]),
        .pc_30(second_stage_pc[30]),
        .io_dout(uart_read_out)
    );

    ldx loadExtender (
        .load_out(data_mux_out),
        .addr_end(third_stage_alu[1:0]),
        .funct3(f3_m),
        .ldx_out(ldx_out)
    );

    //write back select mux
    wb_mux wbmux (
        .dmem_out(ldx_out),
        .alu_out(third_stage_alu),
        .pc_plus4(second_stage_pc),
        .wb_sel(wb_sel_m),
        .wb_out(reg_wd)
    );





    // ////hehehe we add controalllllllll
    // wire pc_sel_i, br_un_i, reg_we_i;
    // wire [1:0] a_sel_i, b_sel_i, wb_sel_i;
    // wire [2:0] imm_sel_i;
    // wire [3:0] imem_rw_i, dmem_rw_i, alu_sel_i;
    wire clear_third_stage;

    control_logic cl (
        .inst(second_stage_inst),
        .imem_rw(imem_rw_x),
        .dmem_rw(dmem_rw_x),
        .pc_sel(pc_sel_x),
        .imm_sel(imm_sel_x),
        .a_sel(a_sel_x),
        .b_sel(b_sel_x),
        .b_unsigned(br_un_x),
        .alu_sel(alu_sel_x),
        .reg_we(reg_we_x),
        .wb_sel(wb_sel_x),
        .b_equal(BrEq),
        .b_less(BrLt),
        .rst(rst),
        .funct3(f3_x),
        .addr_end_x(alu_out[1:0]),
        .sdx_en(sdx_en),
        .imux_nop(imux_nop_x),
        .imux_nop_past(imux_nop_m),
        .csr_sel(csr_sel),
        .csr_en(csr_en),
        .addr_d(third_stage_inst[11:7]),
        .past_op(third_stage_inst[6:2]),
        .two_past_op(fourth_stage_inst[6:2]), 
        .br_haz(br_haz), 
        .clear_third_stage(clear_third_stage),
        .store_haz(store_haz),
        .curr_reg_we(reg_we_m),
        .past_inst(third_stage_inst)
    );

    // //first pipeline for control signals

    // first_pipeline_reg first_pip (
    //     .clk(clk),
    //     .imem_rw_i(imem_rw_i),
    //     .dmem_rw_i(dmem_rw_i),
    //     .pc_sel_i(pc_sel_i),
    //     .imm_sel_i(imm_sel_i),
    //     .a_sel_i(a_sel_i),
    //     .b_sel_i(b_sel_i),
    //     .b_unsigned_i(br_un_i),
    //     .alu_sel_i(alu_sel_i),
    //     .reg_we_i(reg_we_i),
    //     .wb_sel_i(wb_sel_i),
    //     .imem_rw_x(imem_rw_x),
    //     .dmem_rw_x(dmem_rw_x),
    //     .pc_sel_x(pc_sel_x),
    //     .imm_sel_x(imm_sel_x),
    //     .a_sel_x(a_sel_x),
    //     .b_sel_x(b_sel_x),
    //     .b_unsigned_x(br_un_x),
    //     .alu_sel_x(alu_sel_x),
    //     .reg_we_x(reg_we_x),
    //     .wb_sel_x(wb_sel_x)
    // );




    //second pipeling for control signals
    second_pipeline_reg second_pipe (
        .clk(clk), 
        .pc_sel_x(pc_sel_x),
        .imem_rw_x(imem_rw_x), 
        .dmem_rw_x(dmem_rw_x), 
        .reg_we_x(reg_we_x), 
        .wb_sel_x(wb_sel_x), 
        .funct3_x(f3_x),
        .imux_nop_x(imux_nop_x),
        .pc_sel_m(pc_sel_m),
        .imem_rw_m(imem_rw_m), 
        .dmem_rw_m(dmem_rw_m), 
        .reg_we_m(reg_we_m), 
        .wb_sel_m(wb_sel_m),
        .funct3_m(f3_m), 
        .imux_nop_m(imux_nop_m),
        .rst(rst),
        .clear(clear_third_stage)
    );


    // assert property (@(posedge clk) (rst) |-> (pc_out_reg==RESET_PC));
    // assert property (@(posedge clk) )
    //
    // assert property (@(posedge clk) (second_state_inst==`OPC_LOAD))

    // assert property (@(posedge clk) (data_in_valid && !tx_running) |-> (data_in_ready==0) [* (SYMBOL_EDGE_TIME*10)] ##1 (data_in_ready==1));
    // assert property (@(posedge clk) (tx_running) |-> (data_in_ready==0) [* (SYMBOL_EDGE_TIME)*10] ##1 (data_in_ready==1));

endmodule
