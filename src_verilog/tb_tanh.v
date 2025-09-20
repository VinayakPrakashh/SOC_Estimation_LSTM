`timescale 1ns / 1ps

module tb_tanh;

    // Parameters
    parameter WIDTH = 12;
    parameter FRAC_BITS = 6;
    parameter SCALE_FACTOR = 64; // 2^6
    
    // Testbench signals
    reg [WIDTH-1:0] in;
    wire [WIDTH-1:0] out;
    
    // Test control
    integer i;
    real input_real, output_real, expected_tanh;
    real error, max_error = 0.0;
    integer test_count = 0;
    integer pass_count = 0;
    
    // DUT instantiation
    tanh_calc #(
        .WIDTH(WIDTH),
        .FRAC_BITS(FRAC_BITS)
    ) dut (
        .in(in),
        .out(out)
    );
    
    // Function to convert fixed-point to real
    function real fixed_to_real;
        input [WIDTH-1:0] fixed_val;
        begin
            if (fixed_val[WIDTH-1]) begin
                // Negative number - convert from two's complement
                fixed_to_real = -($signed(~fixed_val + 1)) / real(SCALE_FACTOR);
            end else begin
                // Positive number
                fixed_to_real = fixed_val / real(SCALE_FACTOR);
            end
        end
    endfunction
    
    // Function to convert real to fixed-point
    function [WIDTH-1:0] real_to_fixed;
        input real real_val;
        reg [WIDTH-1:0] temp;
        begin
            if (real_val >= 0) begin
                temp = $rtoi(real_val * SCALE_FACTOR);
            end else begin
                temp = $rtoi((-real_val) * SCALE_FACTOR);
                temp = ~temp + 1; // Two's complement
            end
            real_to_fixed = temp;
        end
    endfunction
    
    // Task to test a single value
    task test_value;
        input real test_input;
        input string test_name;
        begin
            in = real_to_fixed(test_input);
            #10; // Wait for combinational logic to settle
            
            input_real = fixed_to_real(in);
            output_real = fixed_to_real(out);
            
            // Calculate expected tanh value
            if (test_input > 3.0) expected_tanh = 1.0;
            else if (test_input < -3.0) expected_tanh = -1.0;
            else if (test_input > -0.25 && test_input < 0.25) expected_tanh = test_input;
            else expected_tanh = (2.0 / (1.0 + $exp(-2.0 * test_input))) - 1.0;
            
            error = $abs(output_real - expected_tanh);
            if (error > max_error) max_error = error;
            
            test_count = test_count + 1;
            if (error < 0.05) pass_count = pass_count + 1; // 5% tolerance
            
            $display("Test %s: Input=%.3f (0x%03h), Output=%.6f (0x%03h), Expected=%.6f, Error=%.6f", 
                     test_name, input_real, in, output_real, out, expected_tanh, error);
        end
    endtask
    
    initial begin
        $display("========================================");
        $display("TANH Calculator Testbench");
        $display("Fixed-point format: S1.5.6 (12-bit)");
        $display("========================================");
        
        // Test 1: Zero
        $display("\n--- Test 1: Zero ---");
        test_value(0.0, "Zero");
        
        // Test 2: Small positive values (linear region)
        $display("\n--- Test 2: Small Positive Values (Linear Region) ---");
        test_value(0.01, "Small_pos_1");
        test_value(0.1, "Small_pos_2");
        test_value(0.2, "Small_pos_3");
        test_value(0.24, "Small_pos_4");
        
        // Test 3: Small negative values (linear region)
        $display("\n--- Test 3: Small Negative Values (Linear Region) ---");
        test_value(-0.01, "Small_neg_1");
        test_value(-0.1, "Small_neg_2");
        test_value(-0.2, "Small_neg_3");
        test_value(-0.24, "Small_neg_4");
        
        // Test 4: LUT boundary values
        $display("\n--- Test 4: LUT Boundary Values ---");
        test_value(0.25, "LUT_min_pos");
        test_value(-0.25, "LUT_min_neg");
        test_value(3.0, "LUT_max_pos");
        test_value(-3.0, "LUT_max_neg");
        
        // Test 5: Values within LUT range
        $display("\n--- Test 5: Values Within LUT Range ---");
        test_value(0.5, "LUT_mid_1");
        test_value(1.0, "LUT_mid_2");
        test_value(1.5, "LUT_mid_3");
        test_value(2.0, "LUT_mid_4");
        test_value(2.5, "LUT_mid_5");
        test_value(-0.5, "LUT_mid_neg_1");
        test_value(-1.0, "LUT_mid_neg_2");
        test_value(-1.5, "LUT_mid_neg_3");
        test_value(-2.0, "LUT_mid_neg_4");
        test_value(-2.5, "LUT_mid_neg_5");
        
        // Test 6: Saturation values (large inputs)
        $display("\n--- Test 6: Saturation Values ---");
        test_value(4.0, "Large_pos_1");
        test_value(10.0, "Large_pos_2");
        test_value(31.0, "Large_pos_3");
        test_value(-4.0, "Large_neg_1");
        test_value(-10.0, "Large_neg_2");
        test_value(-31.0, "Large_neg_3");
        
        // Test 7: Edge cases around boundaries
        $display("\n--- Test 7: Edge Cases ---");
        test_value(0.249, "Just_below_LUT");
        test_value(0.251, "Just_above_LUT");
        test_value(2.99, "Just_below_max");
        test_value(3.01, "Just_above_max");
        test_value(-0.249, "Just_below_LUT_neg");
        test_value(-0.251, "Just_above_LUT_neg");
        test_value(-2.99, "Just_below_max_neg");
        test_value(-3.01, "Just_above_max_neg");
        
        // Test 8: Specific LUT increment values
        $display("\n--- Test 8: LUT Increment Values ---");
        for (i = 25; i <= 300; i = i + 25) begin
            test_value(i * 0.01, $sformatf("LUT_step_%0d", i));
        end
        
        // Summary
        $display("\n========================================");
        $display("TEST SUMMARY");
        $display("========================================");
        $display("Total tests: %0d", test_count);
        $display("Passed tests: %0d", pass_count);
        $display("Failed tests: %0d", test_count - pass_count);
        $display("Pass rate: %.1f%%", (real(pass_count) / real(test_count)) * 100.0);
        $display("Maximum error: %.6f", max_error);
        
        if (pass_count == test_count) begin
            $display("*** ALL TESTS PASSED ***");
        end else begin
            $display("*** SOME TESTS FAILED ***");
        end
        
        $display("========================================");
        $finish;
    end
    
    // Monitor for debugging
    initial begin
        $monitor("Time=%0t: in=0x%03h (%.3f), out=0x%03h (%.6f), addr=%0d, in_range=%b, sign=%b", 
                 $time, in, fixed_to_real(in), out, fixed_to_real(out), 
                 dut.address, dut.in_range, dut.sign_bit);
    end
    
    // Dump waveforms for debugging
    initial begin
        $dumpfile("tb_tanh.vcd");
        $dumpvars(0, tb_tanh);
    end

endmodule