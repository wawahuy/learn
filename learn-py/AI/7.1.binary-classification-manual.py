import numpy as np
rng = np.random.default_rng(42)

def sigmoid(z):
    return 1 / (1 + np.exp(-z))

def bce_loss(y_pred, y_true):
    eps = 1e-15
    y_pred = np.clip(y_pred, eps, 1 - eps)
    return -np.mean(y_true * np.log(y_pred) + (1 - y_true) * np.log(1 - y_pred))

def train():
    X = rng.uniform(0, 10, size=(1000, 2))
    noise = rng.normal(loc=0, scale=1, size=1000)
    true_w = np.array([2, -0.5])
    true_b = 2.0
    true_z = X @ true_w + true_b + noise
    true_y = sigmoid(true_z)
    true_predicted_classes = (true_y >= 0.5).astype(int)

    print(true_predicted_classes)

    w = np.zeros(2)
    b = 0.0
    lr = 0.1
    epchos = 5000
    for epcho in range(epchos):
        z = X @ w + b
        y_pred = sigmoid(z)
        error = y_pred - true_y
        dw = (1 / len(X)) * (X.T @ error)
        db = (1 / len(X)) * np.sum(error)

        w = w - lr * dw
        b = b - lr * db

        loss = bce_loss(y_pred, true_y)
        if epcho % 100 == 0 or epcho == 1:
            print(f"w={w}, b={b}, loss={loss}")
    

if __name__ == "__main__":
    train()