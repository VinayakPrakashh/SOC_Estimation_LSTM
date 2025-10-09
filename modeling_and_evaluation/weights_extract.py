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

def main():
    # Your model path
    model_path = "soc_lstm_model.pth"  # Change this to your actual path
    
    # Extract weights
    state_dict = extract_model_weights(model_path)
    
    if state_dict is not None:
        # Analyze LSTM specifically
        analyze_lstm_weights(state_dict)
        
        # Save weights to files
        save_weights_to_files(state_dict)
        
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