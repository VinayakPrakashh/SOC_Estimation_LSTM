`timescale 1ns / 1ps



module tile_load_top #(
    parameter DATA_WIDTH = 12,
    parameter ADDR_BITS = 14,
    parameter DEPTH = 16*16,
    parameter GATE_MEM_BTS = 4  // 4 bits for 16 addresses (0-15)

) (
    input clk,
    input rst,
    input start,
    output done,
    output [DATA_WIDTH-1:0] final_ht // Input gate
    
);

wire [DATA_WIDTH-1:0] data_out_mem;
wire [DATA_WIDTH-1:0] data_out_0, data_out_1, data_out_2, data_out_3, data_out_4, data_out_5, data_out_6, data_out_7,
                      data_out_8, data_out_9, data_out_10, data_out_11, data_out_12, data_out_13, data_out_14, data_out_15;
wire [ADDR_BITS-1:0] current_addr;
wire [ADDR_BITS-1:0] waddr_systolic;
wire we_sys;
wire fifo_full, fifo_empty;
wire [DATA_WIDTH-1:0] pe1, pe2, pe3, pe4, pe5, pe6, pe7, pe8, pe9, pe10, pe11, pe12, pe13, pe14, pe15, pe16;
wire [DATA_WIDTH-1:0] data_row_in;
wire [DATA_WIDTH-1:0] data_row_out;
wire [ADDR_BITS-1:0] row_addr;
wire wr_en_row;
wire done_sys;
wire we_gates;
wire [ADDR_BITS-1:0] waddr_gates;
wire [DATA_WIDTH-1:0] data_out_i, data_out_f;
wire [DATA_WIDTH-1:0] data_out_o, data_out_g;
wire [DATA_WIDTH-1:0] bias_data;
wire [GATE_MEM_BTS-1:0] raddr_bias;
wire done_activate;
wire [DATA_WIDTH-1:0] data_from_i, data_from_f;
wire [DATA_WIDTH-1:0] data_from_o, data_from_g;
wire [ADDR_BITS-1:0] addr_g, addr_f, addr_i, addr_o;
wire [DATA_WIDTH-1:0] out_me_i, out_me_f;
wire [DATA_WIDTH-1:0] out_me_o, out_me_g;
wire we_me_i, we_me_f;
wire we_me_o, we_me_g;
wire [ADDR_BITS-1:0] addr_me; // Address for activated memory
wire done_me;
wire [ADDR_BITS-1:0] addr_element; // Address for element wise operation
wire [DATA_WIDTH-1:0] register_i, register_f;
wire [DATA_WIDTH-1:0] register_o, register_g;
wire [DATA_WIDTH-1:0] ct; // C(t-1) previous cell state

assign final_ht = bias_data; // Output the hidden state h(t) from output gate buffer

main_mem #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_BITS(ADDR_BITS),
    .DEPTH(256)
) u_main_mem (
    .clk(clk),
    .rst(rst),
    .we(1'b0),
    .data_in(),
    .waddr(),
    .raddr(current_addr),
    .data_out(data_out_mem)
);

bram_burst #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_WIDTH(ADDR_BITS),
    .NUM_PORTS(16),
    .MATRIX_WIDTH(16)
) u_bram_burst (
    .clk(clk),
    .rst(rst),
    .start(start),
    .data_in(data_out_mem),
    .base_addr(0), // Starting address for reading from main memory
    .base_addr_row(0), // Starting address for writing rows
    .waddr_row(waddr_data), // Address for writing rows
    .data_row_in(data_row_in), // Data input for writing rows
    .data_row_out(data_row_out), // Data output for writing rows
    .row_addr(row_addr), // Address for row memory
    .wr_en_row(wr_en_row), // Write enable for row memory
    .we(we_sys),
    .data_out_0(data_out_0),
    .data_out_1(data_out_1),
    .data_out_2(data_out_2),
    .data_out_3(data_out_3),
    .data_out_4(data_out_4),
    .data_out_5(data_out_5),
    .data_out_6(data_out_6),
    .data_out_7(data_out_7),
    .data_out_8(data_out_8),
    .data_out_9(data_out_9),
    .data_out_10(data_out_10),
    .data_out_11(data_out_11),
    .data_out_12(data_out_12),
    .data_out_13(data_out_13),
    .data_out_14(data_out_14),
    .data_out_15(data_out_15),
    .current_addr(current_addr),
    .done(done),
    .waddr(waddr_sys)
);

top_16_by_1 #(
    .DATA_WIDTH(DATA_WIDTH),
    .OUTPUT_WIDTH(DATA_WIDTH),
    .FIFO_DEPTH(16)
) u_top_16_by_1 (
    .clk(clk),
    .rst(rst),
    .wr_en(we_sys),
    .wr_en_data(wr_en_row),
    .data_r1(data_row_out), // row data rows of the matrix 
    .weight_c1(data_out_0),.weight_c2(data_out_1),.weight_c3(data_out_2),.weight_c4(data_out_3),.weight_c5(data_out_4),.weight_c6(data_out_5),.weight_c7(data_out_6),.weight_c8(data_out_7),.weight_c9(data_out_8),.weight_c10(data_out_9),.weight_c11(data_out_10),.weight_c12(data_out_11),.weight_c13(data_out_12),.weight_c14(data_out_13),.weight_c15(data_out_14),.weight_c16(data_out_15),// column of the matrix 
    .pe1(pe1),.pe2(pe2),.pe3(pe3),.pe4(pe4),.pe5(pe5),.pe6(pe6),.pe7(pe7),.pe8(pe8),.pe9(pe9),.pe10(pe10),.pe11(pe11),.pe12(pe12),.pe13(pe13),.pe14(pe14),.pe15(pe15),.pe16(pe16),// processing element outputs
    .fifo_full(fifo_full),
    .fifo_empty(fifo_empty),
    .done(done_sys)
);

data_mem #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_BITS(ADDR_BITS),
    .DEPTH(DEPTH)
) u_data_mem (
    .clk(clk),
    .rst(rst),
    .we(0),
    .data_in(0), // Example: writing pe1 output to memory
    .waddr(0),
    .raddr(row_addr),
    .data_out(data_row_in)
);


store_gates #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_BITS(ADDR_BITS),
    .GATE_MEM_BTS(4), // 16 locations per gate
    .BIASES(16)
) u_store_gates (
    .clk(clk),
    .rst(rst),
    .start(done_sys),
    .done(done_activate),
    .we(we_gates),
    .waddr(waddr_gates),
    .data_out_i(data_out_i),
    .data_out_f(data_out_f),
    .data_out_o(data_out_o),
    .data_out_g(data_out_g),
    //load bias
    .bias_data(bias_data),
    .raddr_bias(raddr_bias),
    .pe1(pe1),
    .pe2(pe2),
    .pe3(pe3),
    .pe4(pe4),
    .pe5(pe5),
    .pe6(pe6),
    .pe7(pe7),
    .pe8(pe8),
    .pe9(pe9),
    .pe10(pe10),
    .pe11(pe11),
    .pe12(pe12),
    .pe13(pe13),
    .pe14(pe14),
    .pe15(pe15),
    .pe16(pe16)
);
buffer_i #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDRESS_BITS(2)
) u_buffer_i (
    .clk(clk),
    .rst(rst),
    .we(we_gates),
    .addr(waddr_gates),
    .raddr(addr_i),
    .din(data_out_i),
    .dout(data_from_i)
);
buffer_f #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDRESS_BITS(2)
) u_buffer_f (
    .clk(clk),
    .rst(rst),
    .we(we_gates),
    .addr(waddr_gates),
    .raddr(addr_f),
    .din(data_out_f),
    .dout(data_from_f)
);
buffer_o #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDRESS_BITS(2)
) u_buffer_o (
    .clk(clk),
    .rst(rst),
    .we(we_gates),
    .addr(waddr_gates),
    .raddr(addr_o),
    .din(data_out_o),
    .dout(data_from_o)
);
buffer_g #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDRESS_BITS(2)
) u_buffer_g (
    .clk(clk),
    .rst(rst),
    .we(we_gates),
    .addr(waddr_gates),
    .raddr(addr_g),
    .din(data_out_g),
    .dout(data_from_g)
);
bias_mem #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_BITS(4),          // 4 bits for 16 addresses (0-15)
    .DEPTH(16)              // 16 bias values
) u_bias_mem (
    .clk(clk),
    .rst(rst),
    .raddr(raddr_bias),      // Read address (0-15)
    .data_out(bias_data), // Combinational output
    
    // Optional write interface
    .we(0),                         // Write enable
    .waddr(0),      // Write address
    .data_in(0)    // Write data
);

activate #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDRESS_BITS(2)
) u_activate (
    .clk(clk),
    .rst(rst),
    .start(done_activate),
    // input gate
    .in_data_i(data_from_i),
    .in_addr_i(addr_i),
    .out_data_i(out_me_i),
    .we_i(we_me_i),
    // forget gate
    .in_data_f(data_from_f),
    .in_addr_f(addr_f),
    .out_data_f(out_me_f),
    .we_f(we_me_f),
    // candidate gate
    .in_data_c(data_from_g),
    .in_addr_c(addr_g),
    .out_data_c(out_me_g),
    .we_c(we_me_g),
    // output gate
    .in_data_o(data_from_o),
    .in_addr_o(addr_o),
    .out_data_o(out_me_o),
    .we_o(we_me_o),
    .address(addr_me),
    .done(done_me)
);


buffer_i_me #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDRESS_BITS(2)
) u_buffer_i_me (
    .clk(clk),
    .rst(rst),
    .we(we_me_i),
    .addr(addr_me),
    .raddr(addr_element),
    .din(out_me_i),
    .dout(register_i)
);
buffer_f_me #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDRESS_BITS(2)
) u_buffer_f_me (
    .clk(clk),
    .rst(rst),
    .we(we_me_f),
    .addr(addr_me),
    .raddr(addr_element),
    .din(out_me_f),
    .dout(register_f)
);

buffer_o_me #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDRESS_BITS(2)
) u_buffer_o_me (
    .clk(clk),
    .rst(rst),
    .we(we_me_o),
    .addr(addr_me),
    .raddr(addr_element),
    .din(out_me_o),
    .dout(register_o)
);
buffer_g_me #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDRESS_BITS(2)
) u_buffer_g_me (
    .clk(clk),
    .rst(rst),
    .we(we_me_g),
    .addr(addr_me),
    .raddr(addr_element),
    .din(out_me_g),
    .dout(register_g)
);

element_wise #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDRESS_BITS(2)
) u_element_wise (
    .clk(clk),
    .rst(rst),
    .start(done_me),
    
    // Activated gate values from buffers
    .i_register_i(register_i),  // Input gate (i)
    .f_register_i(register_f),  // Forget gate (f)
    .c_register_i(register_g),  // Cell gate (g)
    .o_register_i(register_o),  // Output gate (o)
    
    // Previous cell state input
    .ct_minus_1(ct),    // C(t-1)
    
    // Address outputs to read from buffers
    .o_addr_o(addr_element),
    
    // LSTM outputs
    .ct_output(),    // New cell state C(t)
    .ht_output(),    // Hidden state h(t)
    .done(),
    .we()
);
ct_minus_1 #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDRESS_BITS(2)
) u_ct_minus_1 (
    .clk(clk),
    .rst(rst),
    .we(),
    .addr(),
    .raddr(addr_element),
    .din(),
    .dout(ct)
);
endmodule
