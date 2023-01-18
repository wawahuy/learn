export interface ISubject<T> {
    subscribe: (listener: (value: T) => void) => void;
    next: (value: T) => void;
}

class Subject<T> implements ISubject<T> {
    listener: ((value: T) => void)[] = [];
    
    next(value: T) {
        this.listener.forEach((listener) => listener(value));
    }

    subscribe(listener: (value: T) => void) {
        this.listener.push(listener);
    }
}

export function DSubject<T>(value?: T) {
    return function (target: any, key: string) {
        const subscribe = new Subject<T>;
        subscribe.next(value as T);
        Object.defineProperty(target, key, {
            get: function () {
                return subscribe
            },
            set: function () {
            }
        })
    }
}