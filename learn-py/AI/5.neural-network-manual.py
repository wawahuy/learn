import torch

def relu(z):
    return torch.clamp(z, min = 0)

def forward(x, W1, b1, W2, b2):
    hidden = relu(x @ W1 + b1)
    y_pred = hidden @ W2 + b2
    return y_pred

if __name__ == "__main__":
    # y = sin(x)
    x = torch.linspace(-3.14, 3.14, 200).unsqueeze(1)
    print(x.shape)

    y = torch.sin(x)
    print(y.shape)

    W1 = (torch.randn(1, 16) * 0.5).requires_grad_()
    print(W1)

    b1 = (torch.randn(16) * 0.5).requires_grad_()
    print(b1)

    W2 = (torch.randn(16, 1) * 0.5).requires_grad_()
    print(W2)

    b2 = (torch.randn(1) * 0.5).requires_grad_()
    print(b2)

    epochs = 5000
    lr = 0.01
    for epoch in range(epochs + 1):
        predictions = forward(x, W1, b1, W2, b2)
        error = predictions - y
        loss = (error ** 2).mean()
        loss.backward()
        with torch.no_grad():
            W1 -= lr * W1.grad
            b1 -= lr * b1.grad
            W2 -= lr * W2.grad
            b2 -= lr * b2.grad

        W1.grad.zero_()
        b1.grad.zero_()
        W2.grad.zero_()
        b2.grad.zero_()

        if epoch % 500 == 0 or epoch == 1:
            print(f"Epoch {epoch}: Loss = {loss.item():.4f}")


    # test
    test_x = torch.tensor([[0.0], [1.57], [3.0]])
    with torch.no_grad():
        test_pred = forward(test_x, W1, b1, W2, b2)
        print(f'sin({test_x.T}) = {test_pred.T}')
        print(f'True: {torch.sin(test_x).T}')