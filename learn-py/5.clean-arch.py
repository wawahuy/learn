from typing import Protocol, runtime_checkable
from pydantic import BaseModel, Field, computed_field

class OrderItem(BaseModel):
    product_id: str
    quantity: int = Field(gt = 0)
    price: float

class Order(BaseModel):
    id: str
    customer_id: str
    items: list[OrderItem]
    status: str

    @computed_field
    @property
    def total_amount(self) -> float:
        return sum(item.quantity * item.price for item in self.items)

@runtime_checkable
class OrderRepository(Protocol):
    def save(self, order: Order) -> None:
        ...

    def get_by_id(self, order_id: str) -> Order | None:
        ...


class InMemoryOrderRepository(OrderRepository):
    def __init__(self):
        self.orders: dict[str, Order] = {}

    def save(self, order: Order) -> None:
        self.orders[order.id] = order

    def get_by_id(self, order_id: str) -> Order | None:
        return self.orders.get(order_id)

class SQLOrderRepository(OrderRepository):
    def __init__(self, db_connection):
        self.db_connection = db_connection

    def save(self, order: Order) -> None:
        # Implement SQL logic to save the order
        print(f"[SQL] Executing INSERT INTO orders (id, customer_id, status) VALUES ('{order.id}', '{order.customer_id}', '{order.status}')")
        pass

    def get_by_id(self, order_id: str) -> Order | None:
        # Implement SQL logic to retrieve the order by ID
        print(f"[SQL] Executing SELECT * FROM orders WHERE id = '{order_id}'")
        pass

class OrderService:
    def __init__(self, order_repository: OrderRepository):
        self.order_repository = order_repository

    def create_order(self, order: Order) -> None:
        self.order_repository.save(order)

    def get_order(self, order_id: str) -> Order | None:
        return self.order_repository.get_by_id(order_id)

if __name__ == "__main__":
    # Example in-memory repository usage
    print("--- In-Memory Repository Example ---")
    order_repo = InMemoryOrderRepository()
    order_service = OrderService(order_repo)

    order_item1 = OrderItem(product_id="prod-1", quantity=2, price=10.0)
    order_item2 = OrderItem(product_id="prod-2", quantity=1, price=20.0)
    order = Order(id="order-1", customer_id="cust-1", items=[order_item1, order_item2], status="pending")

    order_service.create_order(order)
    retrieved_order = order_service.get_order("order-1")
    print(retrieved_order)


    # Example SQL repository usage
    print("\n--- SQL Repository Example ---")
    sql_order_repo = SQLOrderRepository(db_connection=None)  # Replace with actual DB connection
    sql_order_service = OrderService(sql_order_repo)

    sql_order_service.create_order(order)
    retrieved_sql_order = sql_order_service.get_order("order-1")
    print(retrieved_sql_order)
    
