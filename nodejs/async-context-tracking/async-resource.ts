import express from 'express';
import http from 'http';
import { AsyncResource, AsyncLocalStorage } from 'async_hooks';
import os from 'node:os';

const app = express();
const store = new AsyncLocalStorage;

app.use((req, res, next) => {
    const asyncResource = new AsyncResource('test');
    asyncResource.runInAsyncScope(() => {
        store.run(asyncResource, () => {
            next();
        })
    })
    res.on('finish', () => {
        console.log('oop finised');
        asyncResource.emitDestroy();
    });
})

app.get('/', async (req, res) => {
    res.json({ status: true });
    await new Promise((res) => setTimeout(res, 1000));
    console.log('oop');
})

app.listen(3000);

for(let i=0; i<1; i++) {
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