import torch
import numpy as np
import os
from collections import OrderedDict

def extract_model_weights(model_path):
    """
    Extract and display weights from a PyTorch .pth file
    """
    if not os.path.exists(model_path):
        print(f"Model file not found: {model_path}")
        return None
    
    # Load the checkpoint
    print(f"Loading model from: {model_path}")
    checkpoint = torch.load(model_path, map_location='cpu')
    
    # Handle different checkpoint formats
    if isinstance(checkpoint, dict):
        if 'model_state_dict' in checkpoint:
            state_dict = checkpoint['model_state_dict']
            print("Found 'model_state_dict' in checkpoint")
            
            # Print other info if available
            if 'epoch' in checkpoint:
                print(f"Epoch: {checkpoint['epoch']}")
            if 'loss' in checkpoint:
                print(f"Loss: {checkpoint['loss']}")
            if 'optimizer_state_dict' in checkpoint:
                print("Optimizer state also saved")
                
        else:
            state_dict = checkpoint
            print("Using checkpoint as state_dict directly")
    else:
        state_dict = checkpoint
        print("Checkpoint is the state_dict")
    
    print("\n" + "="*60)
    print("MODEL ARCHITECTURE & WEIGHTS")
    print("="*60)
    
    # Display layer information
    total_params = 0
    for name, param in state_dict.items():
        param_count = param.numel()
        total_params += param_count
        
        print(f"\nLayer: {name}")
        print(f"  Shape: {list(param.shape)}")
        print(f"  Parameters: {param_count:,}")
        print(f"  Data type: {param.dtype}")
        print(f"  Min/Max: {param.min().item():.6f} / {param.max().item():.6f}")
        print(f"  Mean/Std: {param.mean().item():.6f} / {param.std().item():.6f}")
        
        # Show first few values for small tensors
        if param.numel() <= 20:
            print(f"  Values: {param.flatten().tolist()}")
        else:
            print(f"  First 10 values: {param.flatten()[:10].tolist()}")
    
    print(f"\nTotal Parameters: {total_params:,}")
    
    return state_dict

def save_weights_to_files(state_dict, output_dir="extracted_weights"):
    """
    Save individual weight matrices to separate files
    """
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    
    print(f"\nSaving weights to: {output_dir}/")
    
    for name, param in state_dict.items():
        # Clean filename
        filename = name.replace('.', '_') + '.txt'
        filepath = os.path.join(output_dir, filename)
        
        # Convert to numpy and save
        weight_array = param.detach().cpu().numpy()
        
        # Save in different formats based on dimensions
        if len(weight_array.shape) == 1:  # Bias vectors
            np.savetxt(filepath, weight_array, fmt='%.8f')
        elif len(weight_array.shape) == 2:  # Weight matrices
            np.savetxt(filepath, weight_array, fmt='%.8f')
        else:  # Multi-dimensional (LSTM weights)
            # Reshape to 2D for saving
            reshaped = weight_array.reshape(weight_array.shape[0], -1)
            np.savetxt(filepath, reshaped, fmt='%.8f', 
                      header=f"Original shape: {weight_array.shape}")
        
        print(f"  Saved: {filename} (shape: {weight_array.shape})")

def analyze_lstm_weights(state_dict):
    """
    Specifically analyze LSTM layer weights
    """
    print("\n" + "="*60)
    print("LSTM WEIGHT ANALYSIS")
    print("="*60)
    
    # LSTM weights are typically named like:
    # lstm.weight_ih_l0, lstm.weight_hh_l0, lstm.bias_ih_l0, lstm.bias_hh_l0
    
    layers = set()
    for name in state_dict.keys():
        if 'lstm' in name:
            # Extract layer number
            if '_l' in name:
                layer_num = name.split('_l')[1].split('_')[0] if '_' in name.split('_l')[1] else name.split('_l')[1]
                layers.add(int(layer_num))
    
    for layer in sorted(layers):
        print(f"\nLSTM Layer {layer}:")
        
        # Input-to-hidden weights
        ih_key = f"lstm.weight_ih_l{layer}"
        if ih_key in state_dict:
            ih_weight = state_dict[ih_key]
            print(f"  Input-to-Hidden weight: {list(ih_weight.shape)}")
            print(f"    (4 gates × hidden_size, input_size)")
            
        # Hidden-to-hidden weights  
        hh_key = f"lstm.weight_hh_l{layer}"
        if hh_key in state_dict:
            hh_weight = state_dict[hh_key]
            print(f"  Hidden-to-Hidden weight: {list(hh_weight.shape)}")
            print(f"    (4 gates × hidden_size, hidden_size)")
            
        # Biases
        ih_bias_key = f"lstm.bias_ih_l{layer}"
        hh_bias_key = f"lstm.bias_hh_l{layer}"
        
        if ih_bias_key in state_dict:
            ih_bias = state_dict[ih_bias_key]
            print(f"  Input-to-Hidden bias: {list(ih_bias.shape)}")
            
        if hh_bias_key in state_dict:
            hh_bias = state_dict[hh_bias_key]
            print(f"  Hidden-to-Hidden bias: {list(hh_bias.shape)}")

def extract_individual_gates(state_dict, layer=0, output_dir="extracted_weights"):
    """
    Extract individual gate weights from LSTM layer for FPGA implementation
    Splits the 376-dim weights into 4 gates of 94 neurons each
    """
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
        
    # Get layer weights
    weight_ih_key = f'lstm.weight_ih_l{layer}'
    weight_hh_key = f'lstm.weight_hh_l{layer}'
    bias_ih_key = f'lstm.bias_ih_l{layer}'
    bias_hh_key = f'lstm.bias_hh_l{layer}'
    
    if not all(key in state_dict for key in [weight_ih_key, weight_hh_key, bias_ih_key, bias_hh_key]):
        print(f"Layer {layer} weights not found!")
        return
        
    weight_ih = state_dict[weight_ih_key]  # [376, 5] or [376, 94]
    weight_hh = state_dict[weight_hh_key]  # [376, 94]
    bias_ih = state_dict[bias_ih_key]      # [376]
    bias_hh = state_dict[bias_hh_key]      # [376]
    
    # Calculate dimensions
    total_hidden = weight_hh.shape[0]  # Should be 376
    hidden_size = weight_hh.shape[1]   # Should be 94
    input_size = weight_ih.shape[1]    # 5 for layer 0, 94 for others
    
    neurons_per_gate = total_hidden // 4  # Should be 94
    
    print(f"\n" + "="*70)
    print(f"EXTRACTING LAYER {layer} INDIVIDUAL GATES FOR FPGA")
    print("="*70)
    print(f"Total hidden: {total_hidden}, Per gate: {neurons_per_gate}, Input size: {input_size}")
    
    # LSTM gate order in PyTorch: input, forget, cell, output
    gates = ['input', 'forget', 'cell', 'output']
    gate_descriptions = [
        'Controls what new information to store in cell state',
        'Controls what information to throw away from cell state', 
        'Creates new candidate values to add to cell state',
        'Controls what parts of cell state to output'
    ]
    
    for i, (gate_name, description) in enumerate(zip(gates, gate_descriptions)):
        start_idx = i * neurons_per_gate
        end_idx = (i + 1) * neurons_per_gate
        
        print(f"\n{gate_name.upper()} GATE (neurons {start_idx}-{end_idx-1}):")
        print(f"  Description: {description}")
        
        # Extract this gate's weights [94, input_size] and [94, 94]
        gate_wih = weight_ih[start_idx:end_idx, :].detach().cpu().numpy()  
        gate_whh = weight_hh[start_idx:end_idx, :].detach().cpu().numpy()  
        gate_bih = bias_ih[start_idx:end_idx].detach().cpu().numpy()       
        gate_bhh = bias_hh[start_idx:end_idx].detach().cpu().numpy()       
        
        print(f"  Weight matrices shapes:")
        print(f"    Input-to-Hidden weight: {gate_wih.shape}")
        print(f"    Hidden-to-Hidden weight: {gate_whh.shape}")
        print(f"    Input-to-Hidden bias: {gate_bih.shape}")
        print(f"    Hidden-to-Hidden bias: {gate_bhh.shape}")
        
        # Create FPGA-friendly filenames
        base_name = f"layer{layer}_{gate_name}_gate"
        
        # Save weight matrices with headers for FPGA implementation
        wih_file = os.path.join(output_dir, f"{base_name}_weight_ih.txt")
        whh_file = os.path.join(output_dir, f"{base_name}_weight_hh.txt")
        bih_file = os.path.join(output_dir, f"{base_name}_bias_ih.txt")
        bhh_file = os.path.join(output_dir, f"{base_name}_bias_hh.txt")
        
        # Save with FPGA-friendly format
        np.savetxt(wih_file, gate_wih, fmt='%.8f', 
                   header=f"Layer {layer} {gate_name.upper()} gate - Input to Hidden weights\n"
                         f"Shape: [{gate_wih.shape[0]} x {gate_wih.shape[1]}]\n"
                         f"Description: {description}\n"
                         f"Usage: multiply with input features [Voltage, Current, Temperature, Power, Capacity]")
        
        np.savetxt(whh_file, gate_whh, fmt='%.8f',
                   header=f"Layer {layer} {gate_name.upper()} gate - Hidden to Hidden weights\n"
                         f"Shape: [{gate_whh.shape[0]} x {gate_whh.shape[1]}]\n"
                         f"Description: {description}\n"
                         f"Usage: multiply with previous hidden state from same layer") 
        
        np.savetxt(bih_file, gate_bih, fmt='%.8f',
                   header=f"Layer {layer} {gate_name.upper()} gate - Input to Hidden bias\n"
                         f"Shape: [{gate_bih.shape[0]}]\n"
                         f"Description: {description}\n"
                         f"Usage: add to input-to-hidden multiplication result")
        
        np.savetxt(bhh_file, gate_bhh, fmt='%.8f',
                   header=f"Layer {layer} {gate_name.upper()} gate - Hidden to Hidden bias\n"
                         f"Shape: [{gate_bhh.shape[0]}]\n"
                         f"Description: {description}\n"
                         f"Usage: add to hidden-to-hidden multiplication result")
        
        print(f"  FPGA Files saved:")
        print(f"    ✓ {base_name}_weight_ih.txt")
        print(f"    ✓ {base_name}_weight_hh.txt") 
        print(f"    ✓ {base_name}_bias_ih.txt")
        print(f"    ✓ {base_name}_bias_hh.txt")

def extract_all_layers_gates(state_dict, output_dir="extracted_weights"):
    """
    Extract individual gates for all LSTM layers
    """
    # Find how many LSTM layers exist
    layers = set()
    for name in state_dict.keys():
        if 'lstm.weight_ih_l' in name:
            layer_num = int(name.split('_l')[1])
            layers.add(layer_num)
    
    print(f"\nFound LSTM layers: {sorted(layers)}")
    
    for layer in sorted(layers):
        extract_individual_gates(state_dict, layer, output_dir)

def create_fpga_summary(state_dict, output_dir="extracted_weights"):
    """
    Create a summary file for FPGA implementation
    """
    summary_file = os.path.join(output_dir, "FPGA_IMPLEMENTATION_SUMMARY.txt")
    
    with open(summary_file, 'w') as f:
        f.write("="*80 + "\n")
        f.write("LSTM MODEL WEIGHTS FOR FPGA IMPLEMENTATION\n")
        f.write("="*80 + "\n\n")
        
        f.write("MODEL SPECIFICATIONS:\n")
        f.write("-" * 50 + "\n")
        f.write("Input features: 5 (Voltage, Current, Temperature, Power, Capacity)\n")
        f.write("Hidden size: 94 neurons per layer\n")
        f.write("Number of layers: 4\n")
        f.write("Output: 1 (State of Charge)\n\n")
        
        f.write("LAYER STRUCTURE:\n")
        f.write("-" * 50 + "\n")
        
        layers = set()
        for name in state_dict.keys():
            if 'lstm.weight_ih_l' in name:
                layer_num = int(name.split('_l')[1])
                layers.add(layer_num)
        
        for layer in sorted(layers):
            weight_ih = state_dict[f'lstm.weight_ih_l{layer}']
            input_size = weight_ih.shape[1]
            
            f.write(f"\nLayer {layer}:\n")
            f.write(f"  Input size: {input_size}\n")
            f.write(f"  Hidden size: 94\n")
            f.write(f"  Gates: 4 (input, forget, cell, output)\n")
            f.write(f"  Files generated:\n")
            
            gates = ['input', 'forget', 'cell', 'output']
            for gate in gates:
                base_name = f"layer{layer}_{gate}_gate"
                f.write(f"    - {base_name}_weight_ih.txt   [94 x {input_size}]\n")
                f.write(f"    - {base_name}_weight_hh.txt   [94 x 94]\n")
                f.write(f"    - {base_name}_bias_ih.txt     [94]\n")
                f.write(f"    - {base_name}_bias_hh.txt     [94]\n")
        
        # Final linear layer
        if 'fc.weight' in state_dict:
            fc_weight = state_dict['fc.weight']
            f.write(f"\nFinal Layer (fc):\n")
            f.write(f"  Weight: fc_weight.txt {list(fc_weight.shape)}\n")
            f.write(f"  Bias: fc_bias.txt {list(state_dict['fc.bias'].shape)}\n")
        
        f.write("\n" + "="*80 + "\n")
        f.write("FPGA IMPLEMENTATION NOTES:\n")
        f.write("="*80 + "\n")
        f.write("1. Each gate requires matrix multiplication: W*x + U*h + b\n")
        f.write("2. Activations: sigmoid for input/forget/output gates, tanh for cell gate\n")
        f.write("3. Memory requirements: ~89K parameters total\n")
        f.write("4. Precision: 32-bit floating point (can be quantized for FPGA)\n")
        f.write("5. Processing: Sequential (20 time steps) for each input sequence\n")
    
    print(f"\n✓ FPGA implementation summary saved: {summary_file}")

def main():
    # Your model path
    model_path = "soc_lstm_model.pth"  # Change this to your actual path
    
    # Extract weights
    state_dict = extract_model_weights(model_path)
    
    if state_dict is not None:
        # Analyze LSTM specifically
        analyze_lstm_weights(state_dict)
        
        # Save original weights to files
        save_weights_to_files(state_dict)
        
        # *** NEW: Extract individual gates for all layers ***
        extract_all_layers_gates(state_dict)
        
        # *** NEW: Create FPGA implementation summary ***
        create_fpga_summary(state_dict)
        
        # Create a summary
        print("\n" + "="*60)
        print("WEIGHT SUMMARY FOR HARDWARE IMPLEMENTATION")
        print("="*60)
        
        for name, param in state_dict.items():
            print(f"{name}:")
            print(f"  Dimensions: {list(param.shape)}")
            print(f"  Total elements: {param.numel()}")
            print(f"  Memory (float32): {param.numel() * 4} bytes")
            print()

if __name__ == "__main__":
    main()