import { DLogger } from "./class/logger.decorator";
import { FLogger } from "./method/logger.decorator";
import { FReverce } from "./method/reverse.decorator";
import { PTimeAgo } from "./property/timeAgo.decorator";

@DLogger
class TestDLogger {
    @PTimeAgo
    createdAt: number;

    @FLogger
    @FReverce
    test(): string {
        return "hello";
    }
}

const o = new TestDLogger;
console.log(o.createdAt);
console.log(o.test());
