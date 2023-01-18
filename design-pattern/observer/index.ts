import { DSubject, ISubject } from "./observer.decorator";

/* -------------------------------------------------
 * Observer
 * -------------------------------------------------
 */
class Observer {
    constructor(private readonly name: string) {
    }

    listen() {
        console.log('listen', this.name);
    }
}

class Subject {
    listener: Observer[] = [];

    subscribe(ob: Observer) {
        this.listener.push(ob);
        return {
            unsubscribe: () => {
                this.listener = this.listener.filter((observer) => observer != ob);
            }
        }
    }

    notify() {
        this.listener.forEach((observer) => observer.listen());
    }
}

const sj = new Subject;
sj.subscribe(new Observer('Huy'));
sj.subscribe(new Observer('Thuy'));
const phuongObserver = sj.subscribe(new Observer('Phuong'));
sj.notify();

console.log('unsubscribe');
phuongObserver.unsubscribe();
sj.notify();

/* -------------------------------------------------
 * Observer Decorator
 * -------------------------------------------------
 */
console.log('\r\n\r\n')

class DTest {
    @DSubject<string>()
    test: ISubject<string>;
}

const dt = new DTest;
dt.test.subscribe((v) => console.log(v));
dt.test.next("1");
