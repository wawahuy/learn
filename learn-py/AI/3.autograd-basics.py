import torch
import torch.nn as nn
import torch.optim as optim

def train():
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    print(f"Device: {torch.cuda.get_device_name(0)}")

    # y = wx + b
    x = torch.tensor([[-40.0], [-10.0], [0.0], [8.0], [15.0], [22.0], [38.0]], device=device)
    y = torch.tensor([[-40.0], [14.0], [32.0], [46.4], [59.0], [71.6], [100.4]], device=device)

    # w = 1x1 and bias = 1
    model = nn.Linear(in_features=1, out_features=1).to(device)

    # mean square error
    criterion = nn.MSELoss()
    optimizer = optim.Adam(model.parameters(), lr=0.1)

    print("\n--- START ---")
    epochs = 500

    for epoch in range(1, epochs + 1):
        # forward pass
        # y_pred = X @ w + b
        # <=> y_pred = (X @ model.weight.T + model.bias)
        predictions = model(x)

        # loss function
        # error = y_pred - y
        # loss = np.mean(error**2)
        loss = criterion(predictions, y)

        # gradient
        # dw = (2/N) * X.T @ error
        # db = (2/N) * np.sum(error)
        optimizer.zero_grad()
        loss.backward()

        # update weight
        optimizer.step()

        if epoch % 100 == 0 or epoch == 1:
            w = model.weight.item()
            b = model.bias.item()
            print(f"Epoch [{epoch:4d}/{epochs}] | Loss: {loss.item():.4f} | W = {w:.4f} (hope 1.8), b = {b:.4f} (hope 32.0)")

    print("\n--- Dpme ---")
    final_w = model.weight.item()
    final_b = model.bias.item()
    print(f"F = {final_w:.4f} * C + {final_b:.4f}")

    # infer
    test_c = torch.tensor([[100.0]], device=device)
    with torch.no_grad():
        pred_f = model(test_c).item()
    print(f"Test: 100C -> infer: {pred_f:.2f}F (Thực tế: 212.0F)")

if __name__ == "__main__":
    train()