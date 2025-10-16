module store_gates #(
    parameter DATA_WIDTH = 12,
    parameter ADDR_BITS = 14,
    parameter GATE_MEM_BTS = 4, // 16 locations per gate
    parameter BIASES = 16

) (
    input clk,
    input rst,
    input start,
    output reg done,
    output reg we,
    output reg [ADDR_BITS-1:0] waddr,
    output  [DATA_WIDTH-1:0] data_out_i,
    output  [DATA_WIDTH-1:0] data_out_f,
    output  [DATA_WIDTH-1:0] data_out_o,
    output  [DATA_WIDTH-1:0] data_out_g,
    //load bias
    input [DATA_WIDTH-1:0] bias_data,
    output reg [GATE_MEM_BTS-1:0] raddr_bias,
    input [DATA_WIDTH-1:0] pe1,
    input [DATA_WIDTH-1:0] pe2,
    input [DATA_WIDTH-1:0] pe3,
    input [DATA_WIDTH-1:0] pe4,
    input [DATA_WIDTH-1:0] pe5,
    input [DATA_WIDTH-1:0] pe6,
    input [DATA_WIDTH-1:0] pe7,
    input [DATA_WIDTH-1:0] pe8,
    input [DATA_WIDTH-1:0] pe9,
    input [DATA_WIDTH-1:0] pe10,
    input [DATA_WIDTH-1:0] pe11,
    input [DATA_WIDTH-1:0] pe12,
    input [DATA_WIDTH-1:0] pe13,
    input [DATA_WIDTH-1:0] pe14,
    input [DATA_WIDTH-1:0] pe15,
    input [DATA_WIDTH-1:0] pe16

);

parameter [2:0] WAIT = 3'b000,
                STORE_BIAS = 3'b001,
                CALC = 3'b010,
                DONE = 3'b011;
reg [2:0] state, next_state;
reg [DATA_WIDTH-1:0] gate_i [0:3]; // 4 PEs for input gate
reg [DATA_WIDTH-1:0] gate_f [0:3]; // 4 PEs for forget gate
reg [DATA_WIDTH-1:0] gate_o [0:3]; // 4 PEs for output gate
reg [DATA_WIDTH-1:0] gate_g [0:3]; // 4 PEs for cell gate
reg [DATA_WIDTH-1:0] bias [0:BIASES-1];   // 4 biases
reg [2:0] counter; // counts 0 to 15 for 16 PEs
wire [DATA_WIDTH-1:0] sum_out_i, sum_out_f, sum_out_o, sum_out_g;
always @(posedge clk) begin
    if (rst) begin
        state <= WAIT;
    end else begin
        state <= next_state;
    end
end

always @(*) begin
    case (state)
        WAIT: begin
            if (start) begin
                next_state = STORE_BIAS;
            end else begin
                next_state = WAIT;
            end
        end
        STORE_BIAS: begin
            if (raddr_bias == BIASES-1) begin
                next_state = CALC;
            end else begin
                next_state = STORE_BIAS;
            end
        end
        CALC: begin
            if (waddr == 3) begin
                next_state = DONE;
            end else begin
                next_state = CALC;
            end
        end
        DONE: begin
            next_state = WAIT;
        end
        default: next_state = WAIT;
    endcase
end
always @(posedge clk) begin
    case (state)
        WAIT: begin
            if (start) begin

            // Input Gate
            gate_i[0] <= pe1;
            gate_i[1] <= pe2;
            gate_i[2] <= pe3;
            gate_i[3] <= pe4;
            // Forget Gate
            gate_f[0] <= pe5;
            gate_f[1] <= pe6;
            gate_f[2] <= pe7;
            gate_f[3] <= pe8;
            // Cell Gate
            gate_o[0] <= pe9;
            gate_o[1] <= pe10;
            gate_o[2] <= pe11;
            gate_o[3] <= pe12;
            // Output Gate
            gate_g[0] <= pe13;
            gate_g[1] <= pe14;
            gate_g[2] <= pe15;
            gate_g[3] <= pe16;
            // Write to memory
            end
else begin


            raddr_bias <= 0;
            waddr <= 0;
            we <= 0;
            done <= 0;

end
        end
        STORE_BIAS : begin
            raddr_bias <= raddr_bias + 1;
            bias[raddr_bias] <= bias_data;
            if (raddr_bias == BIASES-1) begin
                we <= 1;
                
            end
        end
        CALC: begin
            if (waddr == 3) begin
                we <= 0;
            end 
            raddr_bias <= 0;
        
            waddr <= waddr + 1;
        end
        DONE: begin

            done <= 1;
        end
        default: begin
            
            done <= 0;
        end
    endcase
end

add_fixed #(
    .WIDTH(DATA_WIDTH),
    .FRAC_BITS(6),
    .INT_BITS(5)
) adder_inst_i (
    .a(gate_i[waddr]), // Select input gate based on counter
    .b(bias[waddr]),         // Select corresponding bias
    .sum(data_out_i),         // Output sum
    .overflow()               // Overflow not used here
);
add_fixed #(
    .WIDTH(DATA_WIDTH),
    .FRAC_BITS(6),
    .INT_BITS(5)
) adder_inst_f (
    .a(gate_f[waddr]), // Select forget gate based on counter
    .b(bias[waddr + 4]),     // Select corresponding bias
    .sum(data_out_f),         // Output sum
    .overflow()               // Overflow not used here
);
add_fixed #(
    .WIDTH(DATA_WIDTH),
    .FRAC_BITS(6),
    .INT_BITS(5)
) adder_inst_o (
    .a(gate_o[waddr]), // Select output gate based on counter
    .b(bias[waddr + 8]),     // Select corresponding bias
    .sum(data_out_o),         // Output sum
    .overflow()               // Overflow not used here
);
add_fixed #(
    .WIDTH(DATA_WIDTH),
    .FRAC_BITS(6),
    .INT_BITS(5)
) adder_inst_g (
    .a(gate_g[waddr]), // Select cell gate based on counter
    .b(bias[waddr + 12]),    // Select corresponding bias
    .sum(data_out_g),         // Output sum
    .overflow()               // Overflow not used here
);


endmodule

