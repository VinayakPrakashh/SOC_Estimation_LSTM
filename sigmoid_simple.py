import math

# sigmoid_simple.py
# Simplest sigmoid implementation


def sigmoid(x):
    """Scalar sigmoid function."""
    return 1.0 / (1.0 + math.exp(-x))

def sigmoid_derivative(x):
    """Derivative of sigmoid for scalar x."""
    s = sigmoid(x)
    return s * (1.0 - s)

if __name__ == "__main__":
    # simple demonstration
    for v in (-0.12, -1, 0, 1, 3):
        print(f"x={v:>2}  sigmoid={sigmoid(v):.6f}  derivative={sigmoid_derivative(v):.6f}")