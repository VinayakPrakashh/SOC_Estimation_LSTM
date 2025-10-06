module burst_top #(
    parameter DATA_WIDTH = 12,

) (
    input clk
    input rst,
    input start,
    output done
);

bram_burst #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_WIDTH(10),
    .NUM_PORTS(16)
) burst_inst (
    .clk(clk),
    .rst(rst),
    .start(start),
    .data_in(0), // Not used in this example
    .addr(0),    // Base address for burst operation
    .we(we),
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
    .done(done)
);

lutram_simple #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_BITS(4),
    .DEPTH(16)
) lutram_inst_0 (
    .clk(clk),
    .we(we),
    .addr(0), // Address to write/read
    .data_in(data_out_0), // Example data input
    .data_out(data_out_lutram) // Example data output
);
lutram_simple #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_BITS(4),
    .DEPTH(16)
) lutram_inst_1 (
    .clk(clk),
    .we(we),
    .addr(1), // Address to write/read
    .data_in(data_out_1), // Example data input
    .data_out(data_out_lutram_1) // Example data output
);
lutram_simple #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_BITS(4),
    .DEPTH(16)
) lutram_inst_2 (
    .clk(clk),
    .we(we),
    .addr(2), // Address to write/read
    .data_in(data_out_2), // Example data input
    .data_out(data_out_lutram_2) // Example data output
);
lutram_simple #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_BITS(4),
    .DEPTH(16)
) lutram_inst_3 (
    .clk(clk),
    .we(we),
    .addr(3), // Address to write/read
    .data_in(data_out_3), // Example data input
    .data_out(data_out_lutram_3) // Example data output
);
lutram_simple #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_BITS(4),
    .DEPTH(16)
) lutram_inst_4 (
    .clk(clk),
    .we(we),
    .addr(4), // Address to write/read
    .data_in(data_out_4), // Example data input
    .data_out(data_out_lutram_4) // Example data output
);
lutram_simple #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_BITS(4),
    .DEPTH(16)
) lutram_inst_5 (
    .clk(clk),
    .we(we),
    .addr(5), // Address to write/read
    .data_in(data_out_5), // Example data input
    .data_out(data_out_lutram_5) // Example data output
);
lutram_simple #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_BITS(4),
    .DEPTH(16)
) lutram_inst_6 (
    .clk(clk),
    .we(we),
    .addr(6), // Address to write/read
    .data_in(data_out_6), // Example data input
    .data_out(data_out_lutram_6) // Example data output
);
lutram_simple #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_BITS(4),
    .DEPTH(16)
) lutram_inst_7 (
    .clk(clk),
    .we(we),
    .addr(7), // Address to write/read
    .data_in(data_out_7), // Example data input
    .data_out(data_out_lutram_7) // Example data output
);
lutram_simple #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_BITS(4),
    .DEPTH(16)
) lutram_inst_8 (
    .clk(clk),
    .we(we),
    .addr(8), // Address to write/read
    .data_in(data_out_8), // Example data input
    .data_out(data_out_lutram_8) // Example data output
);
lutram_simple #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_BITS(4),
    .DEPTH(16)
) lutram_inst_9 (
    .clk(clk),
    .we(we),
    .addr(9), // Address to write/read
    .data_in(data_out_9), // Example data input
    .data_out(data_out_lutram_9) // Example data output
);
lutram_simple #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_BITS(4),
    .DEPTH(16)
) lutram_inst_10 (
    .clk(clk),
    .we(we),
    .addr(10), // Address to write/read
    .data_in(data_out_10), // Example data input
    .data_out(data_out_lutram_10) // Example data output
);

lutram_simple #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_BITS(4),
    .DEPTH(16)
) lutram_inst_11 (
    .clk(clk),
    .we(we),
    .addr(11), // Address to write/read
    .data_in(data_out_11), // Example data input
    .data_out(data_out_lutram_11) // Example data output
);
lutram_simple #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_BITS(4),
    .DEPTH(16)
) lutram_inst_12 (
    .clk(clk),
    .we(we),
    .addr(12), // Address to write/read
    .data_in(data_out_12), // Example data input
    .data_out(data_out_lutram_12) // Example data output
);
lutram_simple #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_BITS(4),
    .DEPTH(16)
) lutram_inst_13 (
    .clk(clk),
    .we(we),
    .addr(13), // Address to write/read
    .data_in(data_out_13), // Example data input
    .data_out(data_out_lutram_13) // Example data output
);
lutram_simple #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_BITS(4),
    .DEPTH(16)
) lutram_inst_14 (
    .clk(clk),
    .we(we),
    .addr(14), // Address to write/read
    .data_in(data_out_14), // Example data input
    .data_out(data_out_lutram_14) // Example data output
);
lutram_simple #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_BITS(4),
    .DEPTH(16)
) lutram_inst_15 (
    .clk(clk),
    .we(we),
    .addr(15), // Address to write/read
    .data_in(data_out_15), // Example data input
    .data_out(data_out_lutram_15) // Example data output
);

endmodule
module lutram_simple #(
    parameter DATA_WIDTH = 12,
    parameter ADDR_BITS = 4,     // 64 locations (typical for LUTRAM)
    parameter DEPTH = 16
) (
    input clk,
    input we,
    input [ADDR_BITS-1:0] addr,
    input [DATA_WIDTH-1:0] data_in,
    output reg [DATA_WIDTH-1:0] data_out
);
