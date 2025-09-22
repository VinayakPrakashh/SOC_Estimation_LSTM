module sigmoid #(
    parameter WIDTH = 12,
    parameter FRAC_BITS = 6
) (
    input [WIDTH-1:0] in,
    output [WIDTH-1:0] out
);
    
parameter MAX_VAL = 12'b0_00110_000000 // 6.0 in Q6.6

always @(*) begin
    if()
end
fixed_point_comparator #(
    .WIDTH(WIDTH),
    .FRAC_BITS(FRAC_BITS)
) comparator (
    .a(in),
    .b(MAX_VAL),
    .a_gt_b(a_gt_b_max),
    .a_lt_b(a_lt_b_max),
    .a_eq_b(),
    .a_gte_b(),
    .a_lte_b()
);
fixed_point_comparator #(
    .WIDTH(WIDTH),
    .FRAC_BITS(FRAC_BITS)
) comparator_zero (
    .a(in),
    .b(0),
    .a_gt_b(),
    .a_lt_b(a_lt_b_zero),
    .a_eq_b(a_eq_b_zero),
    .a_gte_b(a_gte_b_zero),
    .a_lte_b()
);
endmodule