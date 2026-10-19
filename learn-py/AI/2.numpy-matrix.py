import numpy as np
rng = np.random.default_rng(42)
X = rng.uniform(0, 10, size=(1000, 3))

true_w = np.array([3.0, -1.5, 0.5])
true_b = 2.0

noise = rng.normal(loc=0, scale=1, size=1000)

y = X @ true_w + true_b + noise

print(X.shape, y.shape, noise[:3])


w = np.zeros(3)
b = 0.0
lr = 0.01
epochs = 1000
for epoch in range(epochs):
    y_pred = X @ w + b
    error = y_pred - y
    loss = np.mean(error**2)
    dw = (2 / len(X)) * X.T @ error
    db = (2 / len(X)) * np.sum(error)

    w = w - lr * dw
    b = b - lr * db

    if (epoch + 1) % 100 == 0:
        print(f"Epoch {epoch + 1}: Loss = {loss:.4f}, w = {w}, b = {b}")

print(f"y = {w}x + {b}")