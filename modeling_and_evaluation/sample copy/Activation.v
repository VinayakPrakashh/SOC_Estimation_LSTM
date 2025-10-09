module activate #(
    parameter DATA_WIDTH = 12,
    parameter ADDRESS_BITS = 2,

) (
    input clk,
    input rst,
    input start,
    // input gate
    input [DATA_WIDTH-1:0] in_data_i,
    input [ADDRESS_BITS-1:0] in_addr_i,
    // forget gate
    input [DATA_WIDTH-1:0] in_data_f,
    input [ADDRESS_BITS-1:0] in_addr_f,
    // candidate gate
    input [DATA_WIDTH-1:0] in_data_c,
    input [ADDRESS_BITS-1:0] in_addr_c,
    // output gate
    input [DATA_WIDTH-1:0] in_data_o,
    input [ADDRESS_BITS-1:0] in_addr_o,
);


endmodule