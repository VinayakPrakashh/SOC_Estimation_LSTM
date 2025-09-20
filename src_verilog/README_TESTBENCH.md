# TANH Calculator Testbench

This directory contains a comprehensive testbench for the hardware tanh calculator implementation.

## Files

- `tb_tanh.v` - Main testbench file
- `run_tb.bat` - Windows batch script to compile and run
- `run_tb.sh` - Linux shell script to compile and run  
- `tanh.v` - Main tanh calculator module
- `tanh_address_calc.v` - Address calculator for LUT
- `tanh_lut.v` - LUT RAM containing tanh values

## Requirements

- **Icarus Verilog** (iverilog) for compilation and simulation
- **GTKWave** (optional) for waveform viewing

### Installation

**Windows:**
- Download from: http://bleyer.org/icarus/
- Add to PATH environment variable

**Linux (Ubuntu/Debian):**
```bash
sudo apt-get install iverilog gtkwave
```

**macOS:**
```bash
brew install icarus-verilog gtkwave
```

## Running the Testbench

### Windows
```cmd
run_tb.bat
```

### Linux/macOS
```bash
chmod +x run_tb.sh
./run_tb.sh
```

### Manual Compilation
```bash
iverilog -o tb_tanh tb_tanh.v tanh.v tanh_address_calc.v tanh_lut.v
vvp tb_tanh
```

## Test Coverage

The testbench validates the following scenarios:

### 1. **Zero Input**
- Tests tanh(0) = 0

### 2. **Linear Region** (|x| < 0.25)
- Tests small positive and negative values
- Verifies tanh(x) ≈ x approximation

### 3. **LUT Region** (0.25 ≤ |x| ≤ 3.0)
- Tests values within the lookup table range
- Verifies proper sign handling for negative inputs
- Tests boundary conditions

### 4. **Saturation Region** (|x| > 3.0)
- Tests large positive values → +1
- Tests large negative values → -1

### 5. **Edge Cases**
- Values just above/below LUT boundaries
- Specific increment values matching LUT entries

## Expected Output

The testbench will display:
- Individual test results with input/output values
- Error analysis compared to mathematical tanh
- Pass/fail summary with percentage
- Maximum error encountered

## Fixed-Point Format

- **Format**: S1.5.6 (1 sign + 5 integer + 6 fractional bits)
- **Total Width**: 12 bits
- **Scale Factor**: 64 (2^6)
- **Range**: -32.0 to +31.984375
- **Resolution**: 1/64 ≈ 0.015625

## Success Criteria

- Pass rate should be > 95%
- Maximum error should be < 0.05 (5%)
- All boundary conditions should work correctly

## Debugging

If tests fail:

1. **Check waveforms**: Open `tb_tanh.vcd` in GTKWave
2. **Verify LUT files**: Ensure all module files are present
3. **Check fixed-point conversion**: Verify input/output scaling
4. **Monitor signals**: Use the built-in monitor for debugging

## Common Issues

1. **Compilation errors**: Check if all module files exist
2. **LUT not found**: Ensure `tanh_lut.v` contains the full 276-entry table
3. **Wrong results**: Verify fixed-point format matches implementation
4. **Negative number issues**: Check two's complement handling

## Waveform Analysis

Open the generated VCD file in GTKWave to analyze:
- Input/output timing
- Internal address calculation
- LUT access patterns
- Sign bit handling