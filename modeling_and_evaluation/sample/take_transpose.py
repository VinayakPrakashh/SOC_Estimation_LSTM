import numpy as np

# Read the padded matrix
matrix = np.loadtxt("W_all_matrix_padded.csv", delimiter=",")

# Transpose it
transposed = matrix.T

# Save the transposed matrix
np.savetxt("W_all_matrix_padded_transposed.csv", transposed, delimiter=",", fmt="%.6f")

print(f"Original shape: {matrix.shape}")
print(f"Transposed shape: {transposed.shape}")
print("Transposed matrix saved!")

# Display first few rows for verification
print("\nOriginal (first 3 rows):")
print(matrix[:3, :])
print("\nTransposed (first 3 rows):")
print(transposed[:3, :])