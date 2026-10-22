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
    # e(x) = w*x+b-y
    # l(x) = e(x)**2
    # l'(w) = dl/dw = dl/de * de/dw = 2 * e * x
    #    + dl/de = 2 * e
    #    + de/dx = x
    # l'(b) = dl/dw = dl/de * de/db = 2 * e * 1

    error = y_pred - y
    loss = np.mean(error**2)
    dw = np.mean(2 * error * x)
    db = np.mean(2 * error)

    w = w - lr * dw
    b = b - lr * db

    if (epoch + 1) % 100 == 0:
        print(f"Epoch {epoch + 1}: Loss = {loss:.4f}, w = {w:.4f}, b = {b:.4f}")

print(f"y = {w}x + {b}")