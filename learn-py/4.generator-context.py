from contextlib import contextmanager
import itertools
import random
import tracemalloc
from typing import Iterable


@contextmanager
def measure_performance():
    tracemalloc.start()
    try:
        yield
    finally:
        trace_mem = tracemalloc.get_traced_memory()
        print(f"Current memory usage: {trace_mem[0] / 1024:.2f} KB; Peak memory usage: {trace_mem[1] / 1024:.2f} KB")
        tracemalloc.stop()


def generate_mock_logs(total_lines=500_000):
    for i in range(total_lines):
        yield {
            "timestamp": f"2024-06-01 12:00:{i % 60:02d}",
            "level": random.choice(["INFO", "WARNING", "ERROR"]),
            "response_time_ms": random.randint(50, 2000)
        }

def filter_level(logs: Iterable[dict], level: str):
    for log in logs:
        if log["level"] == level:
            yield log

def filter_response_time(logs: Iterable[dict], min_ms: int):
    for log in logs:
        if log["response_time_ms"] > min_ms:
            yield log

def transform_alert(logs: Iterable[dict]):
    for log in filter_level(logs, "ERROR"):
        yield f"CRITICAL SLOW ERROR: {log['response_time_ms']}ms"


if __name__ == "__main__":
    with measure_performance():
        raw_stream = generate_mock_logs(500_000)
        error_stream = filter_level(raw_stream, "ERROR")
        slow_stream = filter_response_time(error_stream, min_ms=1000)
        alerts = transform_alert(slow_stream)
        for log in itertools.islice(alerts, 10):
            print(log)