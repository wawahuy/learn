import numpy as np
rng = np.random.default_rng(42)
x = rng.uniform(0, 10, size=1000)
noise = rng.normal(loc=0, scale=1, size=1000)
y = 3 * x + 2 + noise

print(x[:5])
print(y[:5])

w = 0.0
b = 0.0

lr = 0.01
epochs = 1000
for epoch in range(epochs):
    y_pred = w * x + b
    # L=(wx+b−y)**2 
    # L=(error)**2 => dL= 2*error
    # f(w) = wx+b−y => f'(w) = x
    # f(b) = wx+b−y => f'(b) = 1
    # dL/dw = 2*error*x
    # dL/db = 2*error
    error = y_pred - y
    loss = np.mean(error**2)
    dw = np.mean(2 * error * x)
    db = np.mean(2 * error)

    w = w - lr * dw
    b = b - lr * db

    if (epoch + 1) % 100 == 0:
        print(f"Epoch {epoch + 1}: Loss = {loss:.4f}, w = {w:.4f}, b = {b:.4f}")

print(f"y = {w}x + {b}")