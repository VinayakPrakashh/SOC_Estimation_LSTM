`timescale 1ns / 1ps

module bias_mem #(
    parameter DATA_WIDTH = 12,
    parameter ADDR_BITS = 4,          // 4 bits for 16 addresses (0-15)
    parameter DEPTH = 16              // 16 bias values
)(
    input clk,
    input rst,
    input [ADDR_BITS-1:0] raddr,      // Read address (0-15)
    output [DATA_WIDTH-1:0] data_out, // Combinational output
    
    // Optional write interface
    input we,                         // Write enable
    input [ADDR_BITS-1:0] waddr,      // Write address
    input [DATA_WIDTH-1:0] data_in    // Write data
);

// Bias memory array
reg [DATA_WIDTH-1:0] bias_memory [0:DEPTH-1];

// Initialize bias values
   initial begin
        $readmemh("bias.mem", bias_memory);
        $display("Weight memory initialized from file");
    end

// COMBINATIONAL READ - no clock dependency
assign data_out = bias_memory[raddr];

// SEQUENTIAL WRITE - only write operations need clock
always @(posedge clk) begin
    if (we && !rst) begin
        bias_memory[waddr] <= data_in;
    end
end

endmodule