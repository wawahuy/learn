export function DSingleton<T extends { new(...args: any[]): {} }>(constructor: T) {
    return class extends constructor {
        constructor(...args: any[]) {
            // check instance
            const t = constructor as any;
            if (t._instance) {
                return t._instance;
            }

            super(...args);

            // save instance
            t._instance = this;
        }
    }
} 