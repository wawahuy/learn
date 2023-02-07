import inspector from 'inspector';
import module from 'node:module';
import path from 'node:path';
console.log(import.meta.url)
console.log(path.dirname(import.meta.url).substring(7, import.meta.url.length - 7))