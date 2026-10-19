import torch
import torch.nn as nn
import torch.optim as optim
import numpy as np

def train():
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    print(f"Device: {torch.cuda.get_device_name(0)}")

    # y=3.0⋅x1​−1.5⋅x2​+0.5⋅x3​+2.0+noise
    true_w = np.array([3.0, -1.5, 0.5])
    true_b = 2.0

    rng = np.random.default_rng(42)
    noise = rng.normal(loc=0, scale=1, size=1000)
    real_x = rng.uniform(0, 10, size=(1000, 3))
    real_y = real_x @ true_w + true_b + noise

    x = torch.tensor(real_x, dtype=torch.float32, device=device)
    y = torch.tensor(real_y[:, np.newaxis], dtype=torch.float32, device=device)

    model = nn.Linear(in_features=3, out_features=1).to(device)
    criterion = nn.MSELoss()
    optimizer = optim.Adam(model.parameters(), lr=0.01)

    epochs = 2000
    for epoch in range(1, epochs + 1):
        predictions = model(x)
        loss = criterion(predictions, y)
        optimizer.zero_grad()
        loss.backward()
        optimizer.step()

        if epoch % 100 == 0 or epoch == 1:
            w = model.weight.detach().cpu().numpy()
            b = model.bias.item()
            print(w, b)

if __name__ == "__main__":
    train()