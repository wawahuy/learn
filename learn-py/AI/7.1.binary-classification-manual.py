import numpy as np
rng = np.random.default_rng(42)

# thay vì dự đoán số thực bất kỳ như các hàm ở bài 1, bài 3
# thì ta dự đoán 1 xác suất 0 hoặc 1
# để giải quyết bài toán đó ta dùng hàm sigmoid
# hàm này sẽ uống đường thẳng thành chữ S nằm gọn trong khoản (0, 1)

# y(z) = sigmod(z) = 1 / (1 + np.exp(-z))
# z -> +oo -> e^-z = 0    => sigmod(z) = 1 / (1 + 0) = 1
# z -> 0   -> e^0  = 1    => sigmod(z) = 1 / (1 + 1) = 0.5
# z -> -oo -> e^z  = +oo  => sigmod(z) = 1 / (1 + +oo) = 0

# dùng hằng số e thay vì cơ sô khác vì
# de^x/dx = e^x * ln(e) = e^x
# đạo hàm của nó cũng chính xác là nó, do đó nó rất phù hợp trong gradient descent

# BCE Loss
# L=−[yln(y(z))+(1−y)ln(1−y(z​)]
# hmmmmm


def sigmoid(z):
    return 1 / (1 + np.exp(-z))

def bce_loss(y_pred, y_true):
    eps = 1e-15
    y_pred = np.clip(y_pred, eps, 1 - eps)
    return -np.mean(y_true * np.log(y_pred) + (1 - y_true) * np.log(1 - y_pred))

def train():
    X = rng.uniform(0, 10, size=(1000, 2))
    noise = rng.normal(loc=0, scale=0.5, size=1000)
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