import numpy as np
rng = np.random.default_rng(42)

# ví dụ để mô ta một hàm f(x) = sin(x), pt đường thẳng wx + b hoàn toàn không đáp ứng
# mục tiêu của chúng ta là phải ghép các pt đường thẳng lại thành đường cong sin
# hàm ReLU (Rectified Linear Unit) - hàm tuyến tính hiệu chỉnh
# ReLU(z) = max(0, z)

# z(x) = w1 * x + b1
# h(x) = relu(z(x))
# y_pred = w2 * h + b2
# e(x) = y_pred - y = w2 * h(x) + b2 - y
# l(x) = (y_pred - y)**2 = error**2

# L'(w2) = 2*error * e'(w2)
#        = 2*error * h * h'(w2)
#        = 2*error * h
# L'(b2) = 2*error * e'(b2)
#        = 2*error * h'(b2) * 1
#        = 2*erorr * 1      * 1

# L'(w1) = 2*error * e'(w1)
#        = 2*error * w2 * h'(w1)
#        = 2*error * w2 * (h > 0 ? 1 : 0) * z'(w1)
#        = 2*error * w2 * (h > 0 ? 1 : 0) * x
# L'(b1) = 2*error * e'(b1)
#        = 2*error * w2 * h'(b1)
#        = 2*error * w2 * (h > 0 ? 1 : 0) * 1

def relu(z):
    return np.maximum(0, z)

if __name__ == "__main__":
    x_real = np.linspace(-3.14, 3.14, 1000).reshape(-1, 1)
    print(x_real.shape)

    y_real = np.sin(x_real)
    print(y_real.shape)

    noise = rng.normal(loc=0, scale=0.5, size=(1000, 1))
    y = y_real + noise
    print(y.shape)

    W1 = rng.standard_normal((1, 16)) * 0.5
    print(W1.shape)

    b1 = rng.standard_normal(16) * 0.5
    print(b1.shape)

    W2 = rng.standard_normal((16, 1)) * 0.5
    print(W2.shape)

    b2 = rng.standard_normal(1) * 0.5
    print(b2.shape)

    lr = 0.1
    epchos = 5000
    for epcho in range(epchos + 1):
        z = x_real @ W1 + b1
        h = relu(z)
        y_pred = h @ W2 + b2
        error = y_pred - y # (1000,1)
        loss = np.mean(error ** 2)

        N = len(x_real)

        # 2*error * h
        dW2 = (2 / N) * (h.T @ error)
        # 2*erorr * 1 * 1
        db2 = (2 / N) * np.sum(error, axis=0)

        dH = error @ W2.T
        dZ = dH * (h > 0)
        # 2*error * w2 * (h > 0 ? 1 : 0) * x
        dW1 = (2 / N) * (x_real.T @ dZ )
        # 2*error * w2 * (h > 0 ? 1 : 0) * 1
        db1 = (2 / N) * np.sum(dZ, axis=0)

        W1 -= lr * dW1
        b1 -= lr * db1
        W2 -= lr * dW2
        b2 -= lr * db2

        if epcho % 500 == 0:
            print(f"epcho={epcho} loss={loss}")

            # infer
            z = np.array([[0], [3.14]]) @ W1 + b1
            h = relu(z)
            y_pred = h @ W2 + b2
            print(f"sin(0)={y_pred[0]}/{np.sin(0)}, sin(3.14)={y_pred[1]}/{np.sin(3.14)}")
