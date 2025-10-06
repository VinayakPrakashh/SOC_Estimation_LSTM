module mm_main #(
    parameter DATA_WIDTH = 12,
    parameter OUTPUT_WIDTH = 12,
    parameter MATRIX_SIZE = 94,
    parameter VECTOR_SIZE = 64,
    parameter INPUT_SIZE = 16
) (
    input clk,
    input rst,
    input start,
    input [DATA_WIDTH-1:0] bram_0,
    input [DATA_WIDTH-1:0] bram_1,
    input [DATA_WIDTH-1:0] bram_2,
    input [DATA_WIDTH-1:0] bram_3,
    input [DATA_WIDTH-1:0] bram_4,
    input [DATA_WIDTH-1:0] bram_5,
    input [DATA_WIDTH-1:0] bram_6,
    input [DATA_WIDTH-1:0] bram_7,
    input [DATA_WIDTH-1:0] bram_8,
    input [DATA_WIDTH-1:0] bram_9,
    input [DATA_WIDTH-1:0] bram_10,
    input [DATA_WIDTH-1:0] bram_11,
    input [DATA_WIDTH-1:0] bram_12,
    input [DATA_WIDTH-1:0] bram_13,
    input [DATA_WIDTH-1:0] bram_14, 
    input [DATA_WIDTH-1:0] bram_15,
    input [DATA_WIDTH-1:0] bram_15,
    output reg [ADDR_WIDTH-1:0] bram_addr_0,
    output reg [ADDR_WIDTH-1:0] bram_addr_1,
    output reg [ADDR_WIDTH-1:0] bram_addr_2,
    output reg [ADDR_WIDTH-1:0] bram_addr_3,
    output reg [ADDR_WIDTH-1:0] bram_addr_4,
    output reg [ADDR_WIDTH-1:0] bram_addr_5,
    output reg [ADDR_WIDTH-1:0] bram_addr_6,
    output reg [ADDR_WIDTH-1:0] bram_addr_7,
    output reg [ADDR_WIDTH-1:0] bram_addr_8,
    output reg [ADDR_WIDTH-1:0] bram_addr_9,
    output reg [ADDR_WIDTH-1:0] bram_addr_10,
    output reg [ADDR_WIDTH-1:0] bram_addr_11,
    output reg [ADDR_WIDTH-1:0] bram_addr_12,
    output reg [ADDR_WIDTH-1:0] bram_addr_13,
    output reg [ADDR_WIDTH-1:0] bram_addr_14,
    output reg [ADDR_WIDTH-1:0] bram_addr_15,
    output reg done,   
);

parameter IDLE = 2'b00, LOAD = 2'b01, COMPUTE = 2'b10, DONE = 2'b11;
reg [1:0] state, next_state;
reg [2:0] tile_id;
reg [2:0] column_set_id;
reg [6:0] column_counter;
reg [3:0] cycle_counter;
reg [OUTPUT_WIDTH-1:0] input_reg [0:INPUT_SIZE-1];
always @(posedge clk) begin
    if(rst) begin
        state <= IDLE;
    end else begin
        state <= next_state;
    end
end

always @(state) begin
    case (state)
        IDLE: begin
            if (rst) begin
            // Reset all addresses to 0
            bram_addr_0 <= 0;  bram_addr_1 <= 0;  bram_addr_2 <= 0;  bram_addr_3 <= 0;
            bram_addr_4 <= 0;  bram_addr_5 <= 0;  bram_addr_6 <= 0;  bram_addr_7 <= 0;
            bram_addr_8 <= 0;  bram_addr_9 <= 0;  bram_addr_10 <= 0; bram_addr_11 <= 0;
            bram_addr_12 <= 0; bram_addr_13 <= 0; bram_addr_14 <= 0; bram_addr_15 <= 0;
            
            tile_id <= 0;
            column_set_id <= 0;
            column_counter <= 0;
            cycle_counter <= 0;
            done <= 1'b0;
            end else if (start) begin
                state <= LOAD;
            end else begin
                next_state = IDLE;
            end
        end
        LOAD: begin
            // Load data from BRAMs
            next_state = COMPUTE;
        end
        COMPUTE: begin
            // Perform matrix-vector multiplication
            next_state = DONE;
        end
        DONE: begin
            done = 1'b1;
            next_state = IDLE;
        end
        default: next_state = IDLE;
    endcase
end

endmodule