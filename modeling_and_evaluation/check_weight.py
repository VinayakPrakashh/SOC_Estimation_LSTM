def verify_extracted_weights(state_dict, output_dir="extracted_weights"):
    """
    Verify that extracted individual gate weights match original weights
    """
    print("\n" + "="*70)
    print("VERIFYING EXTRACTED WEIGHTS CORRECTNESS")
    print("="*70)
    
    # Find LSTM layers
    layers = set()
    for name in state_dict.keys():
        if 'lstm.weight_ih_l' in name:
            layer_num = int(name.split('_l')[1])
            layers.add(layer_num)
    
    all_correct = True
    
    for layer in sorted(layers):
        print(f"\nVerifying Layer {layer}:")
        
        # Get original weights
        orig_weight_ih = state_dict[f'lstm.weight_ih_l{layer}'].detach().cpu().numpy()
        orig_weight_hh = state_dict[f'lstm.weight_hh_l{layer}'].detach().cpu().numpy()
        orig_bias_ih = state_dict[f'lstm.bias_ih_l{layer}'].detach().cpu().numpy()
        orig_bias_hh = state_dict[f'lstm.bias_hh_l{layer}'].detach().cpu().numpy()
        
        neurons_per_gate = orig_weight_hh.shape[0] // 4  # Should be 94
        gates = ['input', 'forget', 'cell', 'output']
        
        for i, gate_name in enumerate(gates):
            start_idx = i * neurons_per_gate
            end_idx = (i + 1) * neurons_per_gate
            
            # Expected gate weights from original
            expected_wih = orig_weight_ih[start_idx:end_idx, :]
            expected_whh = orig_weight_hh[start_idx:end_idx, :]
            expected_bih = orig_bias_ih[start_idx:end_idx]
            expected_bhh = orig_bias_hh[start_idx:end_idx]
            
            # Load extracted files
            base_name = f"layer{layer}_{gate_name}_gate"
            try:
                extracted_wih = np.loadtxt(os.path.join(output_dir, f"{base_name}_weight_ih.txt"))
                extracted_whh = np.loadtxt(os.path.join(output_dir, f"{base_name}_weight_hh.txt"))
                extracted_bih = np.loadtxt(os.path.join(output_dir, f"{base_name}_bias_ih.txt"))
                extracted_bhh = np.loadtxt(os.path.join(output_dir, f"{base_name}_bias_hh.txt"))
                
                # Compare shapes
                wih_shape_match = expected_wih.shape == extracted_wih.shape
                whh_shape_match = expected_whh.shape == extracted_whh.shape
                bih_shape_match = expected_bih.shape == extracted_bih.shape
                bhh_shape_match = expected_bhh.shape == extracted_bhh.shape
                
                # Compare values (with small tolerance for floating point)
                wih_values_match = np.allclose(expected_wih, extracted_wih, rtol=1e-7, atol=1e-8)
                whh_values_match = np.allclose(expected_whh, extracted_whh, rtol=1e-7, atol=1e-8)
                bih_values_match = np.allclose(expected_bih, extracted_bih, rtol=1e-7, atol=1e-8)
                bhh_values_match = np.allclose(expected_bhh, extracted_bhh, rtol=1e-7, atol=1e-8)
                
                gate_correct = all([wih_shape_match, whh_shape_match, bih_shape_match, bhh_shape_match,
                                  wih_values_match, whh_values_match, bih_values_match, bhh_values_match])
                
                if gate_correct:
                    print(f"  ✓ {gate_name.upper()} gate: CORRECT")
                else:
                    print(f"  ✗ {gate_name.upper()} gate: MISMATCH")
                    if not wih_shape_match:
                        print(f"    Weight IH shape mismatch: {expected_wih.shape} vs {extracted_wih.shape}")
                    if not whh_shape_match:
                        print(f"    Weight HH shape mismatch: {expected_whh.shape} vs {extracted_whh.shape}")
                    if not bih_shape_match:
                        print(f"    Bias IH shape mismatch: {expected_bih.shape} vs {extracted_bih.shape}")
                    if not bhh_shape_match:
                        print(f"    Bias HH shape mismatch: {expected_bhh.shape} vs {extracted_bhh.shape}")
                    if not wih_values_match:
                        print(f"    Weight IH values mismatch (max diff: {np.max(np.abs(expected_wih - extracted_wih)):.2e})")
                    if not whh_values_match:
                        print(f"    Weight HH values mismatch (max diff: {np.max(np.abs(expected_whh - extracted_whh)):.2e})")
                    if not bih_values_match:
                        print(f"    Bias IH values mismatch (max diff: {np.max(np.abs(expected_bih - extracted_bih)):.2e})")
                    if not bhh_values_match:
                        print(f"    Bias HH values mismatch (max diff: {np.max(np.abs(expected_bhh - extracted_bhh)):.2e})")
                    
                    all_correct = False
                    
            except FileNotFoundError as e:
                print(f"  ✗ {gate_name.upper()} gate: FILE NOT FOUND - {e}")
                all_correct = False
            except Exception as e:
                print(f"  ✗ {gate_name.upper()} gate: ERROR - {e}")
                all_correct = False
    
    if all_correct:
        print(f"\n✓ ALL EXTRACTED WEIGHTS ARE CORRECT!")
    else:
        print(f"\n✗ SOME EXTRACTED WEIGHTS HAVE ISSUES!")
    
    return all_correct

def test_reconstruction(state_dict, output_dir="extracted_weights"):
    """
    Test if we can reconstruct the original 376-dim weights from individual gates
    """
    print("\n" + "="*70)
    print("TESTING WEIGHT RECONSTRUCTION")
    print("="*70)
    
    layers = set()
    for name in state_dict.keys():
        if 'lstm.weight_ih_l' in name:
            layer_num = int(name.split('_l')[1])
            layers.add(layer_num)
    
    for layer in sorted(layers):
        print(f"\nTesting Layer {layer} reconstruction:")
        
        # Get original weights
        orig_weight_ih = state_dict[f'lstm.weight_ih_l{layer}'].detach().cpu().numpy()
        orig_weight_hh = state_dict[f'lstm.weight_hh_l{layer}'].detach().cpu().numpy()
        orig_bias_ih = state_dict[f'lstm.bias_ih_l{layer}'].detach().cpu().numpy()
        orig_bias_hh = state_dict[f'lstm.bias_hh_l{layer}'].detach().cpu().numpy()
        
        # Reconstruct from individual gates
        gates = ['input', 'forget', 'cell', 'output']
        reconstructed_wih = []
        reconstructed_whh = []
        reconstructed_bih = []
        reconstructed_bhh = []
        
        for gate_name in gates:
            base_name = f"layer{layer}_{gate_name}_gate"
            
            gate_wih = np.loadtxt(os.path.join(output_dir, f"{base_name}_weight_ih.txt"))
            gate_whh = np.loadtxt(os.path.join(output_dir, f"{base_name}_weight_hh.txt"))
            gate_bih = np.loadtxt(os.path.join(output_dir, f"{base_name}_bias_ih.txt"))
            gate_bhh = np.loadtxt(os.path.join(output_dir, f"{base_name}_bias_hh.txt"))
            
            reconstructed_wih.append(gate_wih)
            reconstructed_whh.append(gate_whh)
            reconstructed_bih.append(gate_bih)
            reconstructed_bhh.append(gate_bhh)
        
        # Stack gates back together
        reconstructed_wih = np.vstack(reconstructed_wih)
        reconstructed_whh = np.vstack(reconstructed_whh)
        reconstructed_bih = np.concatenate(reconstructed_bih)
        reconstructed_bhh = np.concatenate(reconstructed_bhh)
        
        # Compare with original
        wih_match = np.allclose(orig_weight_ih, reconstructed_wih, rtol=1e-7, atol=1e-8)
        whh_match = np.allclose(orig_weight_hh, reconstructed_whh, rtol=1e-7, atol=1e-8)
        bih_match = np.allclose(orig_bias_ih, reconstructed_bih, rtol=1e-7, atol=1e-8)
        bhh_match = np.allclose(orig_bias_hh, reconstructed_bhh, rtol=1e-7, atol=1e-8)
        
        print(f"  Original shapes: WIH={orig_weight_ih.shape}, WHH={orig_weight_hh.shape}")
        print(f"  Reconstructed shapes: WIH={reconstructed_wih.shape}, WHH={reconstructed_whh.shape}")
        
        if wih_match and whh_match and bih_match and bhh_match:
            print(f"  ✓ Perfect reconstruction - all weights match!")
        else:
            print(f"  ✗ Reconstruction failed:")
            if not wih_match:
                print(f"    WIH mismatch (max diff: {np.max(np.abs(orig_weight_ih - reconstructed_wih)):.2e})")
            if not whh_match:
                print(f"    WHH mismatch (max diff: {np.max(np.abs(orig_weight_hh - reconstructed_whh)):.2e})")
            if not bih_match:
                print(f"    BIH mismatch (max diff: {np.max(np.abs(orig_bias_ih - reconstructed_bih)):.2e})")
            if not bhh_match:
                print(f"    BHH mismatch (max diff: {np.max(np.abs(orig_bias_hh - reconstructed_bhh)):.2e})")

def show_weight_samples(state_dict, output_dir="extracted_weights", layer=0, gate='input', num_samples=5):
    """
    Show sample values to manually verify correctness
    """
    print(f"\n" + "="*70)
    print(f"SAMPLE WEIGHT VALUES COMPARISON - Layer {layer}, {gate.upper()} Gate")
    print("="*70)
    
    # Get original weights for this gate
    orig_weight_ih = state_dict[f'lstm.weight_ih_l{layer}'].detach().cpu().numpy()
    neurons_per_gate = orig_weight_ih.shape[0] // 4
    
    gate_idx = ['input', 'forget', 'cell', 'output'].index(gate)
    start_idx = gate_idx * neurons_per_gate
    end_idx = (gate_idx + 1) * neurons_per_gate
    
    expected_gate_wih = orig_weight_ih[start_idx:end_idx, :]
    
    # Load extracted weights
    base_name = f"layer{layer}_{gate}_gate"
    extracted_gate_wih = np.loadtxt(os.path.join(output_dir, f"{base_name}_weight_ih.txt"))
    
    print(f"Comparing first {num_samples} neurons for Input-to-Hidden weights:")
    print(f"{'Neuron':<8} {'Original':<15} {'Extracted':<15} {'Match':<8}")
    print("-" * 55)
    
    for i in range(min(num_samples, expected_gate_wih.shape[0])):
        for j in range(expected_gate_wih.shape[1]):
            orig_val = expected_gate_wih[i, j]
            extr_val = extracted_gate_wih[i, j]
            match = "✓" if np.isclose(orig_val, extr_val, rtol=1e-7, atol=1e-8) else "✗"
            print(f"[{i},{j}]    {orig_val:<15.8f} {extr_val:<15.8f} {match:<8}")
        if i < num_samples - 1:
            print()

# Update your main() function to include verification:
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
        
        # Extract individual gates for all layers
        extract_all_layers_gates(state_dict)
        
        # *** NEW: VERIFY EXTRACTED WEIGHTS ***
        verification_passed = verify_extracted_weights(state_dict)
        
        if verification_passed:
            print("\n🎉 All weights verified successfully!")
        else:
            print("\n⚠️ Weight verification failed - check the issues above")
        
        # *** NEW: TEST RECONSTRUCTION ***
        test_reconstruction(state_dict)
        
        # *** NEW: SHOW SAMPLE VALUES ***
        show_weight_samples(state_dict, layer=0, gate='input')
        
        # Create FPGA implementation summary
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