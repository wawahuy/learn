import http from 'node:http';
import { AsyncLocalStorage } from 'node:async_hooks';

/**
 * Test base
 */
const asyncLocalStorage = new AsyncLocalStorage();

function logWithId(msg: string) {
  const id = asyncLocalStorage.getStore();
  console.log(`${id !== undefined ? id : '-'}:`, msg);
}

async function test2() {
    await new Promise(res => setTimeout(res, 1000));
    logWithId('end')
}

let idReq = 0;
function test() {
    return asyncLocalStorage.run(idReq++, async () => {
        logWithId('start')
        await test2();
    })
}

for(let i=0; i<2; i++) {
    test();
}

/**
 * Test with express
 * save request to store
 * 
 */
import express from 'express';

const store = new AsyncLocalStorage;
const app = express();

app.use((req, res, next) => {
    store.run({ req, res }, () => {
        next();
    })
})

app.get('/', () => {
    const { res } = store.getStore() as any;
    res.json({ status: true });
})

app.listen(3000);

for(let i=0; i<2; i++) {
    http.get('http://localhost:3000', (res) => {
        let data = '';
        res.on('data', (c: any) => {
            data += c.toString();
        })
        res.on('end', () => {
            console.log(data);
        })
    });
}