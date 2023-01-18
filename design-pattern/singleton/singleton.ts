export class Singleton {
    private static _instance: Singleton;
    test: number;

    constructor () {
        if (Singleton._instance) {
            return Singleton._instance;
        }
        this.test = 1;

        // save instance
        Singleton._instance = this;
    }
}