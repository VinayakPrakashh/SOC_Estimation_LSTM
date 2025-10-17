import numpy as np

def lstm_with_concat():
    x = np.array([3.7, -2.0, 25.0, -7.4, 2.5])     # Input vector, shape: (5,)
    h_prev = np.array([0.1, 0.2, 0.3, 0.4])        # Hidden state, shape: (4,)
    c_prev = np.array([0.5, 0.6, 0.7, 0.8])        # Cell state, shape: (4,)
    x_concat = np.concatenate((x, h_prev))         # Shape: (5+4,) = (9,)
    print("x_concat shape:", x_concat.shape)
    Wxi = np.array([[0.1, 0.2, 0.0, -0.1, 0.1],
                    [0.2, 0.1, 0.1, 0.0, 0.0],
                    [0.0, 0.1, 0.2, 0.1, 0.0],
                    [0.1, 0.0, 0.1, 0.2, 0.1]])   # Shape: (4,5)
    Whi = np.array([[0.1, 0.0, 0.1, 0.0],
                    [0.0, 0.1, 0.0, 0.1],
                    [0.1, 0.0, 0.1, 0.0],
                    [0.0, 0.1, 0.0, 0.1]])        # Shape: (4,4)

    Wxf = np.array([[0.5, 0.1, 0.0, 0.0, 0.0],
                    [0.1, 0.5, 0.0, 0.0, 0.0],
                    [0.0, 0.1, 0.5, 0.0, 0.0],
                    [0.0, 0.0, 0.1, 0.5, 0.0]])   # Shape: (4,5)
    Whf = np.array([[0.2, 0.0, 0.0, 0.0],
                    [0.0, 0.2, 0.0, 0.0],
                    [0.0, 0.0, 0.2, 0.0],
                    [0.0, 0.0, 0.0, 0.2]])        # Shape: (4,4)

    Wxc = 0.5 * Wxi
    Whc = 0.3 * Whi
    Wxo = 0.8 * Wxi
    Who = 0.4 * Whi
    Wi = np.hstack((Wxi, Whi))  
    Wf = np.hstack((Wxf, Whf))  
    Wc = np.hstack((Wxc, Whc)) 
    Wo = np.hstack((Wxo, Who))  
    W_all = np.vstack((Wi, Wf, Wc, Wo))
    print("W_all shape:", W_all)
    b_i = np.array([0.1, 0.0, 0.1, 0.2])
    b_f = np.array([1.0, 1.0, 1.0, 1.0])
    b_c = np.array([0.0, 0.1, 0.0, 0.1])
    b_o = np.array([0.2, 0.1, 0.2, 0.1])
    b_all = np.concatenate((b_i, b_f, b_c, b_o))
    z = W_all @ x_concat + b_all
    z_i, z_f, z_c, z_o = np.split(z, 4)
    i = 1 / (1 + np.exp(-z_i))
    f = 1 / (1 + np.exp(-z_f))
    g = np.tanh(z_c)
    o = 1 / (1 + np.exp(-z_o))
    i = 1 / (1 + np.exp(-z_i))
    f = 1 / (1 + np.exp(-z_f))
    g = np.tanh(z_c)
    o = 1 / (1 + np.exp(-z_o))
    c_t = f * c_prev + i * g
    h_t = o * np.tanh(c_t)
print("New cell state c_t:",c_t)
print("New hidden state h_t:", h_t)
lstm_with_concat()
