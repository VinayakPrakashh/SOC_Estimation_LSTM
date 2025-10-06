module main_mem #(
    parameter DATA_WIDTH = 12,
    parameter ADDR_BITS = 14,
    parameter DEPTH = 96*96

) (
    input clk,
    input rst,
    input we,
    input [DATA_WIDTH-1:0] data_in,
    input [ADDR_BITS-1:0] addr;
    output [DATA_WIDTH-1:0] data_out
);

reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

always @(posedge clk) begin
    if (we) begin
        mem[addr] <= data_in;
    end
end
assign data_out = mem[addr];

endmodule