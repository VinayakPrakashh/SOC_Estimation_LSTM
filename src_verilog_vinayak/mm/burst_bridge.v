module bram_burst #(
    parameter DATA_WIDTH = 12,
    parameter ADDR_WIDTH = 10,
    parameter NUM_PORTS = 16
) (
    input clk,
    input rst,
    input start,
    input [DATA_WIDTH-1:0] data_in,
    input [ADDR_WIDTH-1:0] addr,
    output reg we,
    output reg [DATA_WIDTH-1:0] data_out_0,
    output reg [DATA_WIDTH-1:0] data_out_1,
    output reg [DATA_WIDTH-1:0] data_out_2,
    output reg [DATA_WIDTH-1:0] data_out_3,
    output reg [DATA_WIDTH-1:0] data_out_4,
    output reg [DATA_WIDTH-1:0] data_out_5,
    output reg [DATA_WIDTH-1:0] data_out_6,
    output reg [DATA_WIDTH-1:0] data_out_7,
    output reg [DATA_WIDTH-1:0] data_out_8,
    output reg [DATA_WIDTH-1:0] data_out_9,
    output reg [DATA_WIDTH-1:0] data_out_10,
    output reg [DATA_WIDTH-1:0] data_out_11,
    output reg [DATA_WIDTH-1:0] data_out_12,
    output reg [DATA_WIDTH-1:0] data_out_13,
    output reg [DATA_WIDTH-1:0] data_out_14,
    output reg [DATA_WIDTH-1:0] data_out_15,
    output reg done

);

parameter IDLE = 2'b00, READ = 2'b01, WRITE = 2'b10;
reg [1:0] state, next_state;
reg [DATA_WIDTH-1:0] ram [0:NUM_PORTS-1];
reg [4-1:0] count_main;
reg [ADDR_WIDTH-1:0] current_addr;
always @(posedge clk) begin
if(rst) begin
    state <= IDLE;
end
else state <= next_state;
end

always @(state) begin
    IDLE: begin
        if (start) begin
            next_state = READ;
        end else begin
            next_state = IDLE;
        end
    end
    READ: begin
        if (count_main < NUM_PORTS) begin
            next_state = READ;
        end else begin
            next_state = WRITE;
        end
    end
    WRITE: begin
        next_state = IDLE;
    end
end
always @(posedge clk) begin
    IDLE: begin
        count_main <= 0;
        current_addr <= base_addr;
        done <= 0;
        we <= 0;
        data_out_0 <= 0;
        data_out_1 <= 0;
        data_out_2 <= 0;
        data_out_3 <= 0;
        data_out_4 <= 0;
        data_out_5 <= 0;
        data_out_6 <= 0;
        data_out_7 <= 0;
        data_out_8 <= 0;
        data_out_9 <= 0;
        data_out_10 <= 0;
        data_out_11 <= 0;
        data_out_12 <= 0;
        data_out_13 <= 0;
        data_out_14 <= 0;
        data_out_15 <= 0;
    end
    LOAD: begin
        ram[count_main] <= data_in;
        count_main <= count_main + 1;
        if (count_main == NUM_PORTS - 1) begin
            count_main <= 0;
        end
    end
    WRITE: begin
        we <= 1;
        data_out_0 <= ram[0];
        data_out_1 <= ram[1];
        data_out_2 <= ram[2];
        data_out_3 <= ram[3];
        data_out_4 <= ram[4];
        data_out_5 <= ram[5];
        data_out_6 <= ram[6];
        data_out_7 <= ram[7];
        data_out_8 <= ram[8];
        data_out_9 <= ram[9];
        data_out_10 <= ram[10];
        data_out_11 <= ram[11];
        data_out_12 <= ram[12];
        data_out_13 <= ram[13];
        data_out_14 <= ram[14];
        data_out_15 <= ram[15];
        done <= 1;
    end
end
endmodule