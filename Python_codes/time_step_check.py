# Calculate memory and computation requirements
def calculate_hardware_requirements(sequence_length, hidden_size=94, num_layers=4, input_size=5):
    """
    Estimate hardware requirements for different sequence lengths
    """
    # Memory for hidden states (per layer)
    hidden_state_memory = hidden_size * 32  # bits per timestep
    
    # Total memory for all layers
    total_memory_bits = hidden_state_memory * num_layers * 2  # h and c states
    total_memory_kb = total_memory_bits / (8 * 1024)
    
    # Computation (MACs per timestep)
    # Each LSTM cell: 4 gates × (hidden_size × (hidden_size + input_size))
    macs_per_cell_layer0 = 4 * hidden_size * (hidden_size + input_size)
    macs_per_cell_other = 4 * hidden_size * (hidden_size + hidden_size)
    
    macs_per_timestep = macs_per_cell_layer0 + (num_layers - 1) * macs_per_cell_other
    total_macs = macs_per_timestep * sequence_length
    
    # FC layer MACs
    fc_macs = hidden_size * 1
    total_macs += fc_macs
    
    print(f"\nHardware Requirements for sequence_length = {sequence_length}:")
    print(f"  Memory: {total_memory_kb:.2f} KB")
    print(f"  Total MACs: {total_macs:,}")
    print(f"  MACs per timestep: {macs_per_timestep:,}")
    
    # Clock cycles (assuming sequential, no pipeline)
    clock_cycles_sequential = total_macs
    clock_cycles_pipelined = sequence_length * num_layers + 3  # With pipeline
    
    # At 100 MHz
    time_sequential_us = clock_cycles_sequential / 100e6 * 1e6
    time_pipelined_us = clock_cycles_pipelined / 100e6 * 1e6
    
    print(f"  Sequential: {clock_cycles_sequential:,} cycles ({time_sequential_us:.2f} µs @ 100MHz)")
    print(f"  Pipelined:  {clock_cycles_pipelined:,} cycles ({time_pipelined_us:.2f} µs @ 100MHz)")
    
    return {
        'memory_kb': total_memory_kb,
        'total_macs': total_macs,
        'time_pipelined_us': time_pipelined_us
    }

print("="*60)
print("HARDWARE RESOURCE COMPARISON")
print("="*60)

for seq_len in [5, 10, 15, 20, 30, 40, 50]:
    calculate_hardware_requirements(seq_len)