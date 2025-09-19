module add_fixed #(
    parameter WIDTH = 12,
    parameter FRAC_BITS = 6  // Number of fractional bits (for Q6.6 format)
) (
    input   [WIDTH-1:0] a,
    input   [WIDTH-1:0] b,
    output  [WIDTH-1:0] sum,
    output  overflow
);

// Internal signals
wire [WIDTH:0] temp_sum;  // One extra bit for overflow detection
wire sign_a, sign_b, sign_result;

// Extend inputs to detect overflow
assign temp_sum = {a[WIDTH-1], a} + {b[WIDTH-1], b};

// Extract signs
assign sign_a = a[WIDTH-1];
assign sign_b = b[WIDTH-1];
assign sign_result = temp_sum[WIDTH-1];

// Overflow detection for signed addition
// Overflow occurs when:
// 1. Adding two positive numbers gives negative result
// 2. Adding two negative numbers gives positive result
assign overflow = (~sign_a & ~sign_b & sign_result) |  // (+) + (+) = (-)
                  (sign_a & sign_b & ~sign_result);    // (-) + (-) = (+)

// Saturation constants
localparam [WIDTH-1:0] MAX_POSITIVE = {1'b0, {(WIDTH-1){1'b1}}};  // 0111...111
localparam [WIDTH-1:0] MAX_NEGATIVE = {1'b1, {(WIDTH-1){1'b0}}};  // 1000...000

// Saturation logic
assign sum = overflow ? 
             (sign_a ? MAX_NEGATIVE : MAX_POSITIVE) :  // Saturate to limits
             temp_sum[WIDTH-1:0];                      // Normal result

endmodule