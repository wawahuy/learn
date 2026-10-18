import asyncio
import random
import time


async def asyncBatchFetch():
    sem = asyncio.Semaphore(4)

    async def fetch(url):
        rand_error = random.random()
        if rand_error < 0.1:
            raise ConnectionError(f"Failed to fetch {url}")
        sleep_time = random.uniform(0.2, 1.5)
        await asyncio.sleep(sleep_time)
        return { "status": 200, "data": f"Data from {url}" }

    async def worker(url):
        async with sem:
            try:
                async with asyncio.timeout(1.0):
                    result = await fetch(url)
                    return {
                        "url": url,
                        "data": result["data"],
                    }
            except asyncio.TimeoutError:
                print(f"Timeout while fetching {url}")
                return {
                    "url": url,
                    "error": "Timeout",
                }
            except ConnectionError as e:
                print(e)
                return {
                    "url": url,
                    "error": str(e),
                }

    tasks = [
        worker(f"https://api.example.com/item/{i}")
        for i in range(20)
    ]

    results = await asyncio.gather(*tasks, return_exceptions=True)

    report = {
        "successes": [
            result for result in results if isinstance(result, dict) and "data" in result
        ],
        "failures": [
            result for result in results if isinstance(result, dict) and "error" in result
        ],
    }

    print("Report:", report)

if __name__ == "__main__":
    asyncio.run(asyncBatchFetch())