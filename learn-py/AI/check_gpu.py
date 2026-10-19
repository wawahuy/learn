
# learn-py/check_gpu.py
import time
import torch

def verify_gpu():
    print("=" * 50)
    print("KIỂM TRA MÔI TRƯỜNG PYTORCH & GPU")
    print("=" * 50)
    
    print(f"PyTorch Version : {torch.__version__}")
    print(f"CUDA Available   : {torch.cuda.is_available()}")
    
    if not torch.cuda.is_available():
        print("CẢNH BÁO: PyTorch chưa nhận GPU! Đang chạy trên CPU.")
        return

    device_name = torch.cuda.get_device_name(0)
    vram_bytes = torch.cuda.get_device_properties(0).total_memory
    vram_gb = vram_bytes / (1024 ** 3)
    cuda_arch = torch.cuda.get_device_capability(0)

    print(f"Tên GPU         : {device_name}")
    print(f"Tổng VRAM       : {vram_gb:.2f} GB")
    print(f"Compute Capability: {cuda_arch[0]}.{cuda_arch[1]}")
    print("=" * 50)

    # -------------------------------------------------------------
    # BENCHMARK: Nhân 2 ma trận lớn (10,000 x 10,000) trên CPU vs GPU
    # -------------------------------------------------------------
    size = 8000
    print(f"\nĐang benchmark nhân 2 ma trận kích thước {size}x{size}...")

    # 1. Chạy trên CPU
    print("Đang tính toán trên CPU...")
    x_cpu = torch.randn(size, size)
    y_cpu = torch.randn(size, size)
    
    start_cpu = time.perf_counter()
    _ = torch.matmul(x_cpu, y_cpu)
    cpu_time = time.perf_counter() - start_cpu
    print(f"CPU Thời gian: {cpu_time:.4f} giây")

    # 2. Chạy trên GPU (CUDA)
    print(" Đang tính toán trên GPU (CUDA)...")
    device = torch.device("cuda")
    x_gpu = torch.randn(size, size, device=device)
    y_gpu = torch.randn(size, size, device=device)

    # Warm-up GPU (để khởi tạo CUDA context)
    _ = torch.matmul(x_gpu, y_gpu)
    torch.cuda.synchronize()

    start_gpu = time.perf_counter()
    _ = torch.matmul(x_gpu, y_gpu)
    torch.cuda.synchronize()  # Bắt buộc phải đồng bộ vì CUDA chạy async
    gpu_time = time.perf_counter() - start_gpu
    print(f" GPU Thời gian: {gpu_time:.4f} giây")

    speedup = cpu_time / gpu_time
    print(f"\nKẾT LUẬN: GPU RTX 5050 nhanh gấp {speedup:.1f} lần so với CPU!")

if __name__ == "__main__":
    verify_gpu()