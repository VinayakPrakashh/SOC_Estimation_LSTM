`timescale 1ns / 1ps

module tanh_calc #(
    parameter WIDTH = 12,
    parameter FRAC_BITS = 6
) (
    input [WIDTH-1:0] in,
    output reg [WIDTH-1:0] out
);

    // Parameters for LUT
    parameter [WIDTH-1:0] LUT_MIN = 12'd16;    // 0.25 in S1.5.6
    parameter [WIDTH-1:0] LUT_MAX = 12'd192;   // 3.0 in S1.5.6
    parameter [WIDTH-1:0] NEG_LUT_MIN = 12'b100000010000;
    parameter [WIDTH-1:0] NEG_LUT_MAX = 12'b111111001000; // -3.0 in S1.5.6


wire [8:0] address;
wire in_range,sign_bit;
wire [11:0] tanh_lut_out;

always @(*) begin
    if( (in < LUT_MIN) && (in > 0) ) begin
        out = in; // tanh(x) ≈ x for small x
    end
    else if( (in > NEG_LUT_MIN) && (in < 0) ) begin
        out = in; // tanh(x) ≈ x for small x
    end
    else if( in > LUT_MAX ) begin
        out = 12'd64; // tanh(x) ≈ 1 for large x, 1 in S1.5.6 is 0.111111 = 63
    end
    else if( in < -LUT_MAX ) begin
        out = -12'd64; // tanh(x) ≈ -1 for large negative x, -1 in S1.5.6 is 1.000001 = -63
    end
    else if( in == 0 ) begin
        out = 0; // tanh(0) = 0
    end
    else if( in >= LUT_MIN && in <= LUT_MAX ) begin
        out = tanh_lut_out; // Use LUT output with sign
    end
    else if(in <= -LUT_MIN && in >= -LUT_MAX) begin
        out = -tanh_lut_out;
    end
    else begin
        out = 0; // Default case (should not occur)
    end
end

tanh_address_calculator addr_calc_inst (
    .input_value(in),
    .address(address),         // Connect to LUT address input
    .in_range(in_range),       // Can be used for additional logic if needed
    .sign_bit(sign_bit)        // Can be used for additional logic if needed
);
tanh_lut_ram lut_inst (
    .addr(address),          // Connect from addr_calc_inst.address
    .tanh_out(tanh_lut_out)    // Connect to output
);

endmodule
