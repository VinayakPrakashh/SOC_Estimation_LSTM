module main_mem #(
    parameter DATA_WIDTH = 12,
    parameter ADDR_BITS = 14,
    parameter DEPTH = 96*96

) (
    input clk,
    input rst,
    input we,
    input [DATA_WIDTH-1:0] data_in,
    input [ADDR_BITS-1:0] waddr,
    input [ADDR_BITS-1:0] raddr,
    output [DATA_WIDTH-1:0] data_out
);

reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
        integer i;
    // Fill memory with values 1-5 in a repeating pattern
    initial begin

        for (i = 0; i < DEPTH; i = i + 1) begin
            mem[i] = (i % 5) + 1;  // Values: 1, 2, 3, 4, 5, 1, 2, 3, 4, 5, ...
        end
        $display("Memory initialized with values 1-5");
    end
    
always @(posedge clk) begin
    if (we) begin
        mem[waddr] <= data_in;
    end
end
assign data_out = mem[raddr];

endmodule