import torch
import torch.nn as nn
import torch.optim as optim

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
print(f"Device: {torch.cuda.get_device_name(0)}")


class SinNet(nn.Module):
    def __init__(self):
        super().__init__()
        self.layer_1 = nn.Linear(in_features=1, out_features=16, device=device)
        self.layer_2 = nn.Linear(in_features=16, out_features=1, device=device)
        self.relu = nn.ReLU()

    def forward(self, x):
        return self.layer_2(self.relu(self.layer_1(x)))


if __name__ == "__main__":
    # y = sin(x)
    x = torch.linspace(-3.14, 3.14, 20000, device=device).unsqueeze(1)
    y = torch.sin(x)

    model = SinNet()
    print(f'Number of parameters: {sum(p.numel() for p in model.parameters())}')

    optimizer = optim.Adam(model.parameters(), lr=0.01)
    criterion = nn.MSELoss()
    
    epochs = 5000
    for epoch in range(epochs + 1):
        predictions = model(x)
        loss = criterion(predictions, y)
        optimizer.zero_grad()
        loss.backward()
        optimizer.step()

        if epoch % 500 == 0 or epoch == 1:
            print(f"Epoch {epoch}: Loss = {loss.item():.4f}")

    # test
    test_x = torch.tensor([[0.0], [1.57], [3.0]], device=device)
    with torch.no_grad():
        test_pred = model(test_x)
        print(f'sin({test_x.T}) = {test_pred.T}')
        print(f'True: {torch.sin(test_x).T}')