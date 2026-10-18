import functools
import time
from typing import Any, Callable

def retry(
        max_retries: int = 3,
        delay: float = 1.0,
        expections: tuple[type[Exception], ...] = (Exception,)
    ):
    def decorator(func: Callable) -> Callable:
        @functools.wraps(func)
        def wrapper(*args: Any, **kwargs: Any) -> Any:
            for attempt in range(max_retries):
                try:
                    return func(*args, **kwargs)
                except expections as e:
                    print(f"Attempt {attempt + 1} failed: {e}")
                    if attempt < max_retries - 1:
                        time.sleep(delay)
            raise
        return wrapper
    return decorator


test = 0

@retry(max_retries=3, delay=1.0)
def unreliable_function():
    global test
    """A function that randomly raises an exception to simulate unreliability."""
    if test < 2:
        test += 1
        raise ConnectionError("Simulated failure.")
    return "Success!"

if __name__ == "__main__":
    unreliable_function()