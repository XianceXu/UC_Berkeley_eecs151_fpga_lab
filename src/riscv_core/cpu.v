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
    wire csr_sel_d, csr_en_d;
    wire csr_sel_x, csr_en_x;

    reg [31:0] tohost_csr;
    reg [31:0] cycle_counter, inst_counter;



    // TODO: Your code to implement a fully functioning RISC-V core
    // Add as many modules as you want
    // Feel free to move the memory modules around



    wire third_stage_uart_read, kill_now;

    wire prev_stall, stall_again, kill_again;
    wire [31:0] alu_out, alu_m;
    wire [31:0] rd1_x, rd2_x;
    wire [31:0] pc_d, pc_x, pc_m;
    wire [31:0] inst_d, inst_x, inst_m, inst_w, data_w;
    wire [31:0] uart_raw_out, uart_read_out, third_stage_uart_out;
    wire [31:0] ldx_out, old_pc, older_pc;


    // control outputs
    wire b_un_d, a_sel_d, b_sel_d, kill_next_d, reg_we_d;
    wire sdx_en_d, imux_nop_d, pc_sel_d, stall;
    wire [1:0] wb_sel_d;
    wire [2:0] imm_sel_d;
    wire [3:0] alu_sel_d;
    
    wire a_sel_x, b_sel_x, reg_we_x, imux_nop_x;
    wire sdx_en_x, pc_sel_x;
    wire [1:0] wb_sel_x;
    wire [2:0] imm_sel_x;
    wire [3:0] alu_sel_x;
    
    wire reg_we_m, pc_sel_m;
    wire [1:0] wb_sel_m;
    
    wire reg_we_w, pc_sel_w;
    wire b_taken;
    
    assign pc_sel_x = inst_x[6:2] == `OPC_JAL_5 || inst_x[6:2] == `OPC_JALR_5 || b_taken;
    


    //firstStage ---------------------------------------------------- 
    //testing new branch
    

    // mux for pc reg
    // Chooses between pc+4, or alu_out from third stage
    wire [31:0] pc_plus_4;
    wire [31:0] pc_in_reg;
    wire [31:0] pc_out_reg;

    wire pc_rst_bool;

    // wire [1:0] better_pc_sel;

    // assign better_pc_sel = ((third_stage_inst[6:2] == `OPC_JAL_5 || third_stage_inst[6:2] == `OPC_JALR_5) && !pc_rst_bool) ? 2'd1 : (second_stage_inst[6:2] == `OPC_BRANCH_5 && imux_nop_d) ? 2'd2 : 2'd0;
    pc_mux #(.INIT(RESET_PC))pcm (
        .clk(clk),
        .add_4(pc_plus_4),
        .alu(alu_out),
        .pc_sel(pc_sel_x),
        .out(pc_in_reg),
        .rst(rst),
        .stall(stall|| prev_stall || stall_again ),
        .old_pc(older_pc)

    );

    // adder for program counter
    pc_add4 pc_incrementer (
        .pc(pc_out_reg),
        .out(pc_plus_4)
    );


    wire reset_bool_x;


  simple_register old_pc_reg (
      .q(old_pc),
      .d(pc_out_reg),
      .clk(clk)
  );
  simple_register older_pc_reg (
      .q(older_pc),
      .d(old_pc),
      .clk(clk)
  );

    pc_register #(.N(32), .INIT(RESET_PC)) pc_reg (
        .q(pc_out_reg),
        .d(pc_in_reg),
        .rst(rst),
        .clk(clk),
        .reset_bool(pc_rst_bool)
    ); 


    always @(posedge clk) begin
        if (pc_rst_bool) begin
            inst_counter = 32'd0;
            cycle_counter = 32'd0;
        end else begin
            cycle_counter = cycle_counter + 32'd1;
            if (!imux_nop_d) begin
                inst_counter = inst_counter + 32'd1;
            end
                
        end
    end

    //assign all the wires for pc register to bios/imem/adder

    
    assign bios_addra = (pc_rst_bool) ? RESET_PC[13:2] : pc_out_reg[13:2];
    assign imem_addrb = (pc_rst_bool) ? RESET_PC[15:2] : pc_out_reg[15:2];
    assign imem_ena = 1;
    assign bios_ena = 1;
    assign bios_enb = 1;
    assign dmem_en = 1;

    //instruction mux before at end of first stage
    // wire [31:0] first_stage_inst;
    one_bit_reg stall_reg (
        .q(prev_stall),
        .d(stall),
        .clk(clk)
    );

    one_bit_reg stall_again_reg (
        .q(stall_again),
        .d(prev_stall),
        .clk(clk)
        );

    one_bit_reg kill_again_reg (
        .q(kill_again),
        .d(pc_sel_x),
        .clk(clk)
        );

    instruction_mux i_mux (
        .bios_douta(bios_douta),
        .imem_doutb(imem_doutb),
        .inst(inst_d),
        .pc_30(pc_out_reg[30]), 
        .rst(reset_bool_x),
        .stall(prev_stall || stall_again || pc_sel_x || kill_again),
        .stall_val(32'h00000013)
    );  


    
    // pc reg
    simple_register_rst first_stage_pc_reg (
        .q(pc_d),
        .d(pc_out_reg),
        .clk(clk), 
        .rst(pc_rst_bool),
        .rst_val(RESET_PC)

    ); 
    //reset
    one_bit_reg reset_i_x_reg (
        .q(reset_bool_x),
        .d(pc_rst_bool),
        .clk(clk)
    ); 





    //secondStage instruction decode___________________________________________________________________________________________


    

    // Register file
    // Asynchronous read: read data is available in the same cycle
    // Synchronous write: write takes one cycle
    wire [4:0] reg_ra1, reg_ra2, reg_wa;
    wire [31:0] reg_wd;
    wire [31:0] reg_rd1, reg_rd2;

    reg_file rf (
        .clk(clk),
        .we(reg_we_w),
        .ra1(reg_ra1), .ra2(reg_ra2), .wa(reg_wa),
        .wd(reg_wd),
        .rd1(reg_rd1), .rd2(reg_rd2)
    );

    assign reg_ra1 = inst_d[19:15];
    assign reg_ra2 = inst_d[24:20];
    assign reg_wa = inst_w[11:7];
    assign reg_wd = data_w;







    //pc_d_x_reg
    simple_register_rst pc_d_x_reg (
        .q(pc_x),
        .d(pc_d),
        .clk(clk), 
        .rst(1'b0),
        .rst_val(32'd0)

    ); 
    //reg1_d_x_reg
    simple_register_rst reg1_d_x_reg (
        .q(rd1_x),
        .d(reg_rd1),
        .clk(clk), 
        .rst(1'b0),
        .rst_val(32'd0)

    ); 
    //reg2_d_x_reg
    simple_register_rst reg2_d_x_reg (
        .q(rd2_x),
        .d(reg_rd2),
        .clk(clk), 
        .rst(1'b0),
        .rst_val(32'd0)

    ); 
    //inst_d_x_reg
    simple_register_rst inst_d_x_reg (
        .q(inst_x),
        .d(inst_d),
        .clk(clk), 
        .rst(1'b0),
        .rst_val(32'd0)

    ); 

    




    //new excecute stage______________________________________________________________________________________________________________________________
     wire BrEq, BrLt;
    branch_comp bc (
        .data_a(rd1_x),
        .data_b(rd2_x), 
        .branch_unsigned(inst_x[13]),
        .branch_type({BrEq, BrLt})
    );
    execute_branch eb(
        .branch_x_en(inst_x[6:2] == `OPC_BRANCH_5),
        .b_equal(BrEq),
        .b_less(BrLt),
        .stall(prev_stall || stall_again),
        .funct3(inst_x[14:12]),
        .b_taken(b_taken)
    );

    //immediate generator
    wire [31:0] imm;
    immgen immediate_generator (
        .immsel(imm_sel_x),
        .inst_31_7(inst_x[31:7]),
        .imm(imm)
    );
    

    //a_sel mux
    wire [31:0] a_out;
    a_mux amux (
        .reg_file_data_a(rd1_x),
        .pc(pc_x),
        .a_sel(a_sel_x),
        .a_out(a_out)
    );

    //b_sel mux
    wire [31:0] b_out;

    b_mux bmux (
        .reg_file_data_b(rd2_x),
        .imm_gen_out(imm),
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
        if (csr_en_x) begin
            if (!csr_sel_x) begin
                tohost_csr <= a_out;
            end else  begin
                tohost_csr <= b_out;
            end

        end
    end



 
    //pc_x_m_reg
    simple_register_rst pc_x_m_reg (
        .q(pc_m),
        .d(pc_x),
        .clk(clk), 
        .rst(1'b0),
        .rst_val(32'd0)
    );  
    ///alu_x_m_reg
    simple_register_rst alu_x_m_reg (
        .q(alu_m),
        .d(alu_out),
        .clk(clk), 
        .rst(1'b0),
        .rst_val(32'd0)
    ); 
    //inst_x_m_reg
    simple_register_rst inst_x_m_reg (
        .q(inst_m),
        .d(inst_x),
        .clk(clk), 
        .rst(1'b0),
        .rst_val(32'd0)
    ); 





    //_______________________________________________________________________________ start memory stage

    wire [31:0] sdx_out;
    wire [3:0] rw_sig;
    sdx saveExtender (
        .data_reg_out(rd2_x),
        .addr_end(alu_out[1:0]),
        .funct3(inst_x[14:12]),
        .sdx_out(sdx_out), 
        .sdx_en(sdx_en_x),
        .rw_sig(rw_sig)
    );


    wire uart_read, uart_write;
    uart_contrl u_cntl (
        .uart_en(alu_out[31:28]),
        .addr(alu_out[7:0]),
        .opcode(inst_x[6:2]),
        .uart_read(uart_read),
        .uart_write(uart_write)
    );

    assign bios_addrb = alu_out[13:2];

    assign dmem_addr = alu_out[15:2];
    assign dmem_din = sdx_out;
    assign dmem_we = (alu_out[28]) ?  rw_sig : 4'd0;

    //need to add if we write to imem, or io
    assign imem_addra = alu_out[15:2];
    assign imem_dina = sdx_out;
    assign imem_wea = (pc_d[30] && alu_out[29]) ?  rw_sig : 4'd0;


    //io/ uart stuff


    assign uart_tx_data_in = sdx_out[7:0];
    assign uart_tx_data_in_valid = uart_write; 
    assign uart_rx_data_out_ready = third_stage_uart_read;

    uart_read uart_reader (
        .uart_en(alu_m[31:28]),
        .addr(alu_m[7:0]),
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
    one_bit_reg thirdstageUartread (
        .q(third_stage_uart_read),
        .d(uart_read),
        .clk(clk)
    );

    wire [31:0] pc_m_plus_4;
    //pipelined pc plus for
    pc_add4 pipe_add_4 (
        .pc(pc_m),
        .out(pc_m_plus_4)
    );




    //datamux
    wire [31:0] data_mux_out;

    data_mux dmux (
        .bios_doutb(bios_doutb),
        .dmem_dout(dmem_dout),
        .data(data_mux_out),
        .addr(alu_m[31:28]),
        .io_dout(uart_read_out)

    );

    ldx loadExtender (
        .load_out(data_mux_out),
        .addr_end(alu_m[1:0]),
        .funct3(inst_m[14:12]),
        .ldx_out(ldx_out)
    );

    //write back select mux
    wire [31:0] wb_mux_out;
    wb_mux wbmux (
        .dmem_out(ldx_out),
        .alu_out(alu_m),
        .pc_plus4(pc_m_plus_4),
        .wb_sel(wb_sel_m),
        .wb_out(wb_mux_out)
    );

  
    ///data_m_w_reg
    simple_register_rst data_m_w_reg (
        .q(data_w),
        .d(wb_mux_out),
        .clk(clk), 
        .rst(1'b0),
        .rst_val(32'd0)
    ); 
    //inst_m_w_reg
    simple_register_rst inst_m_w_reg (
        .q(inst_w),
        .d(inst_m),
        .clk(clk), 
        .rst(1'b0),
        .rst_val(32'd0)
    ); 

    //wb stage _____________________________________________________________________________________





    // ////hehehe we add controalllllllll
    reg pc_sel_fake;

    control_logic cl (
        .clk(clk),
        .inst(inst_d),
        .imm_sel(imm_sel_d),
        .a_sel(a_sel_d),
        .b_sel(b_sel_d),
        .b_unsigned(b_un_d),
        .b_equal(BrEq),
        .b_less(BrLt),
        .pc_sel(pc_sel_fake),
        .alu_sel(alu_sel_d),
        .reg_we(reg_we_d),
        .wb_sel(wb_sel_d),
        .rst(rst),
        .addr_end_x(alu_out[1:0]),
        .sdx_en(sdx_en_d),
        .imux_nop(imux_nop_d),
        .csr_sel(csr_sel_d),
        .csr_en(csr_en_d),
        .reg_we_x(reg_we_x),
        .reg_we_m(reg_we_m),
        .reg_we_w(reg_we_w),
        .kill_now(pc_sel_x),
        .stall(stall)
    );

    ctrl_pipe_d_x d_x_control_pipe (
        .clk(clk), 
        .a_sel_d(a_sel_d), 
        .b_sel_d(b_sel_d), 
        .reg_we_d(reg_we_d), 
        .sdx_en_d(sdx_en_d), 
        .wb_sel_d(wb_sel_d), 
        .imm_sel_d(imm_sel_d), 
        .alu_sel_d(alu_sel_d),
        .imux_nop_d(imux_nop_d),
        .csr_en_d(csr_en_d),
        .csr_sel_d(csr_sel_d),
        .a_sel_x(a_sel_x), 
        .b_sel_x(b_sel_x), 
        .reg_we_x(reg_we_x), 
        .sdx_en_x(sdx_en_x), 
        .wb_sel_x(wb_sel_x), 
        .imm_sel_x(imm_sel_x),
        .alu_sel_x(alu_sel_x),
        .imux_nop_x(imux_nop_x),
        .csr_en_x(csr_en_x),
        .csr_sel_x(csr_sel_x),
        .rst(rst)
    );

    ctrl_pipe_x_m x_m_control_pipe (
        .clk(clk), 
        .reg_we_x(reg_we_x), 
        .wb_sel_x(wb_sel_x), 
        .reg_we_m(reg_we_m), 
        .wb_sel_m(wb_sel_m), 
        .rst(rst)
    );

    ctrl_pipe_m_w m_w_control_pipe (
        .clk(clk), 
        .reg_we_x(reg_we_m), 
        .reg_we_m(reg_we_w), 
        .rst(rst)
    );




    // assert property (@(posedge clk) (rst) |-> (pc_in_reg==RESET_PC));
    // assert property (@(posedge clk) (reg_ra1 == 5'd0) |-> (reg_rd1 == 32'd0));
    // assert property (@(posedge clk) (reg_ra2 == 5'd0) |-> (reg_rd2 == 32'd0));

    // assert property (@(posedge clk) (inst_m[6:2] == `OPC_LOAD_5 && inst_m[14:12] == `FNC_LB) |-> (ldx_out[31:8] == 24'd0 || ldx_out[31:8] == {24{1'd1}}));
    // assert property (@(posedge clk) (inst_m[6:2] == `OPC_LOAD_5 && inst_m[14:12] == `FNC_LH) |-> (ldx_out[31:8] == 16'd0 || ldx_out[31:16] == {16{1'd1}}));
    // // assert property (@(posedge clk) (inst_x[6:2] == `OPC_STORE_5 && inst_x[14:12] == `FNC_SB) |-> (rw_sig == 4'b0001 || rw_sig == 4'b0010 || rw_sig == 4'b0100 || rw_sig == 4'b1000, $display("rw_sig=0b%0b",rw_sig))); 
    // // assert property (@(posedge clk) (inst_x[6:2] == `OPC_STORE_5 && inst_x[14:12] == `FNC_SH) |-> (rw_sig == 4'b0011 || rw_sig == 4'b1100, $display("rw_sig=0b%0b",rw_sig)));
    // assert property (@(posedge clk) (inst_x[6:2] == `OPC_STORE_5 && inst_x[14:12] == `FNC_SW) |-> (rw_sig == 4'b1111, $display("rw_sig=0b%0b",rw_sig)));
    

endmodule
