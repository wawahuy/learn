Trong TypeScript, có hai loại decorator:

- Class decorator: Là một hàm được sử dụng để thay đổi hoặc mở rộng một class hoặc nói cách khác là để thay đổi hoặc mở rộng một constructor. Ví dụ như sử dụng @logger để ghi lại thông tin về class hoặc @sealed để khóa class không cho thay đổi.

- Property decorator: Là một hàm được sử dụng để thay đổi hoặc mở rộng thuộc tính của class. Ví dụ như sử dụng @readonly để khóa thuộc tính không cho thay đổi hoặc @timeAgo để hiển thị thời gian của thuộc tính.

- Method decorator: là một hàm được sử dụng để thay đổi hoặc mở rộng một method của class. Ví dụ như sử dụng @log để ghi lại thông tin về method hoặc @timeit để đo thời gian thực thi của method.