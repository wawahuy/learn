import { Singleton } from "./singleton";
import { DSingleton } from "./singleton.decorator";

const s1 = new Singleton();
const s2 = new Singleton();

console.log("before update 'test'");
console.log('s1=', s1, '\ts2=', s2)

console.log("after");
s1.test = 2;
console.log('s1=', s1, '\ts2=', s2)

/**
 * Decrator create instance
 */
console.log('\r\nDecorator singleton');
@DSingleton
class Test {
    test: number = 0;
}

const o1 = new Test;
const o2 = new Test;
o2.test = 2;
console.log(o1, o2);