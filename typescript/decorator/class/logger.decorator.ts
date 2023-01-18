
/**
 * Trong ví dụ trên, chúng ta sử dụng một hàm decorator @logger để ghi lại thông tin về class MyClass.
 * Hàm decorator này nhận vào một constructor và trả về một class mới kế thừa từ constructor gốc.
 * Trong constructor mới, chúng ta ghi lại thông tin về tên class và gọi super(...args) để gọi constructor gốc.
 * Khi khởi tạo một instance của MyClass, nó sẽ ghi lại thông tin "create class" ra console.
 */

/**
 * T extends { new(...args: any[]): {} } là một generic type trong TypeScript.
 * Nó đại diện cho một class hoặc một constructor.
 * new(...args: any[]): {} là một type signature cho constructor, 
 * nghĩa là nó là một hàm có thể được gọi bằng cách sử dụng từ khóa new, nhận bất kỳ số lượng tham số nào và trả về một object.
 * Với những gì đã nói, T extends { new(...args: any[]): {} } nghĩa là T là một class hoặc một 
 * constructor có thể được gọi bằng cách sử dụng từ khóa new và trả về một object.
 * Vậy nó đang định nghĩa rằng T là một class, và chúng ta sẽ sử dụng T để kế thừa và mở rộng chức năng của class đó.
 */

export function DLogger<T extends { new(...args: any[]): {} }>(constructor: T) {
    return class extends constructor {
        constructor(...args: any[]) {
            super(...args);
            console.log('create class', constructor);
        }
    }
}