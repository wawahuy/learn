# Lộ trình học AI

Nguyên tắc: mỗi bài tự viết tay trước rồi mới dùng thư viện. Xong bài thì giải thích toán và ứng dụng thực tế.

## Đã hoàn thành
- [x] 1. Gradient descent bằng numpy
- [x] 2. Linear regression dạng ma trận bằng numpy
- [x] 3. Autograd cơ bản (`nn.Linear`, `Adam`)
- [x] 4. Hồi quy nhiều biến bằng PyTorch
- [x] 5. Neural network tự viết tay (ReLU, backprop) trên `sin(x)`
- [x] 6. `nn.Linear`, `nn.ReLU`, optimizer và `nn.Module`

## Phần 1: Nền tảng deep learning
- [ ] 7. Phân loại nhị phân: sigmoid, binary cross-entropy
- [ ] 8. Softmax và phân loại nhiều lớp
- [ ] 9. Đạo hàm của cross-entropy, tự viết backward tay
- [ ] 10. Tự viết một mini autograd (giống micrograd)
- [ ] 11. Train, validation, test split, overfitting và underfitting
- [ ] 12. `Dataset`, `DataLoader`, mini-batch và SGD
- [ ] 13. Tự viết momentum, RMSProp, Adam
- [ ] 14. Learning rate schedule và warmup
- [ ] 15. Khởi tạo trọng số: Xavier, He, và vì sao quan trọng
- [ ] 16. Vanishing và exploding gradient, gradient clipping
- [ ] 17. Regularization: dropout, weight decay, early stopping
- [ ] 18. Chuẩn hóa dữ liệu, BatchNorm, LayerNorm
- [ ] 19. MNIST với mạng fully connected
- [ ] 20. Đánh giá model: accuracy, precision, recall, F1, confusion matrix
- [ ] 21. Lưu và tải model, checkpoint, chạy trên GPU

## Phần 2: Ảnh
- [ ] 22. Tự viết convolution bằng tensor
- [ ] 23. Pooling, padding, stride
- [ ] 24. CNN cho MNIST
- [ ] 25. CIFAR-10 và data augmentation
- [ ] 26. Residual connection, tự dựng ResNet nhỏ
- [ ] 27. Transfer learning và fine-tune ResNet
- [ ] 28. Trực quan hóa: model đang nhìn vào đâu
- [ ] 29. Object detection cơ bản
- [ ] 30. Segmentation với U-Net

## Phần 3: Chuỗi và ngôn ngữ
- [ ] 31. Tokenization: ký tự, từ, và BPE tự viết tay
- [ ] 32. Embedding và word2vec
- [ ] 33. RNN tự viết tay
- [ ] 34. LSTM và GRU
- [ ] 35. Seq2seq: dịch câu ngắn
- [ ] 36. Attention tự viết tay
- [ ] 37. Self-attention và multi-head attention
- [ ] 38. Positional encoding
- [ ] 39. Transformer block hoàn chỉnh
- [ ] 40. Mini GPT sinh văn bản theo ký tự
- [ ] 41. Mini GPT với BPE trên dữ liệu tiếng Việt
- [ ] 42. Sampling: temperature, top-k, top-p
- [ ] 43. KV cache: tăng tốc sinh văn bản

## Phần 4: Model sinh (generative)
- [ ] 44. Autoencoder
- [ ] 45. Variational autoencoder (VAE)
- [ ] 46. GAN
- [ ] 47. Diffusion model đơn giản

## Phần 5: Làm việc với LLM thật
- [ ] 48. Hugging Face: tải và chạy model có sẵn
- [ ] 49. Fine-tune một model ngôn ngữ nhỏ
- [ ] 50. LoRA tự viết tay, rồi dùng thư viện PEFT
- [ ] 51. Quantization: chạy model lớn trên RTX 5050
- [ ] 52. Instruction tuning và định dạng chat
- [ ] 53. Đánh giá LLM

## Phần 6: Ứng dụng AI
- [ ] 54. Gọi API OpenAI hoặc Anthropic, streaming
- [ ] 55. Structured output với Pydantic
- [ ] 56. Embeddings và tìm kiếm ngữ nghĩa
- [ ] 57. Vector database (`pgvector` hoặc Qdrant)
- [ ] 58. RAG cơ bản, tự viết từng bước
- [ ] 59. RAG nâng cao: chunking, reranking, hybrid search
- [ ] 60. Tool calling và agent tự viết tay
- [ ] 61. Đóng gói thành API với FastAPI, deploy và theo dõi
- [ ] 62. Dự án cuối: chatbot hỏi đáp trên tài liệu riêng, chạy model local trên GPU
