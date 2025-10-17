module ct_minus_1 #(
    parameter DATA_WIDTH = 12,
    parameter ADDRESS_BITS = 2
) (
    input clk,
    input rst,
    input we,
    input [ADDRESS_BITS-1:0] addr,
    input [ADDRESS_BITS-1:0] raddr,
    input [DATA_WIDTH-1:0] din,
    output [DATA_WIDTH-1:0] dout
);

    // Memory array
    reg [DATA_WIDTH-1:0] mem_array [0:(1<<ADDRESS_BITS)-1];

    // Initialize with Input gate activated values (S5.6 format)
     initial begin
         mem_array[0] = 12'h020;  // 0.75026011 ≈ 0.75 = 0*64 + 0.75*64 = 48 = 0x030
         mem_array[1] = 12'h026;  // 0.95689275 ≈ 0.96 = 0*64 + 0.96*64 = 61 = 0x03D
         mem_array[2] = 12'h02D;  // 0.98522597 ≈ 0.98 = 0*64 + 0.98*64 = 63 = 0x03F
         mem_array[3] = 12'h033;  // 0.86989153 ≈ 0.87 = 0*64 + 0.87*64 = 56 = 0x037
     end

    // Write operation
    always @(posedge clk) begin
        if (we) begin
            mem_array[addr] <= din;
        end
    end

    assign dout = mem_array[raddr];
endmodule