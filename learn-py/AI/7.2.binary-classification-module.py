import torch
import torch.nn as nn
import torch.optim as optim

device = torch.device("cuda")

class BinaryClassifier(nn.Module):
    def __init__(self):
        super().__init__()
        self.layer1 = nn.Linear(2, 1, device=device)

    def forward(self, x):
        z = self.layer1(x)
        return torch.sigmoid(z)

if __name__ == "__main__":
    torch.manual_seed(42)
    X = torch.rand(1000, 2, device=device) * 10
    noise = torch.randn(1000, 1, device=device) * 0.5
    true_w = torch.tensor([[2.0], [-0.5]], device=device)
    true_b = -7.5
    true_z = X @ true_w + true_b + noise
    true_y = torch.sigmoid(true_z)

    model = BinaryClassifier()
    optimizer = optim.Adam(model.parameters(), lr=0.1)
    criterion = nn.BCELoss()

    epochs = 5000
    for epoch in range(epochs + 1):
        predictions = model(X)
        loss = criterion(predictions, true_y)
        optimizer.zero_grad()
        loss.backward()
        optimizer.step()

        if epoch % 500 == 0 or epoch == 1:
            print(f"Epoch {epoch}: Loss = {loss.item():.4f}")
            print(f"Weight: {model.layer1.weight.detach().cpu().numpy()} - Bias: {model.layer1.bias.item()}")