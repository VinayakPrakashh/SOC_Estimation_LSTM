module mul_fixed #(
    parameter WIDTH = 12,
    parameter FRAC_BITS = 6
) (
    input  signed [WIDTH-1:0] a,
    input  signed [WIDTH-1:0] b,
    output signed [WIDTH-1:0] prod,
    output overflow
);

    // Full-precision multiply
    wire signed [(2*WIDTH)-1:0] full_prod = a * b;

    // Adjust for fixed point
    wire signed [(2*WIDTH)-1:0] shifted = full_prod >>> FRAC_BITS;

    // Take lower WIDTH bits
    wire signed [WIDTH-1:0] result = shifted[WIDTH-1:0];

    // Overflow detection: upper discarded bits must all equal sign bit
    assign overflow = shifted[(2*WIDTH)-1:WIDTH] != { (WIDTH){result[WIDTH-1]} };

    // Saturation constants
    localparam signed [WIDTH-1:0] MAX_POSITIVE = {1'b0, {(WIDTH-1){1'b1}}};
    localparam signed [WIDTH-1:0] MAX_NEGATIVE = {1'b1, {(WIDTH-1){1'b0}}};

    // Apply saturation if overflow
    assign prod = overflow ?
                  (shifted[(2*WIDTH)-1] ? MAX_NEGATIVE : MAX_POSITIVE) :
                  result;

endmodule
