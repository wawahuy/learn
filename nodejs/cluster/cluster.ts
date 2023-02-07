import express from 'express';
import cluster from 'node:cluster';
import http from 'node:http';

if (cluster.isPrimary) {
    for (let i = 0; i<2; i++) {
        console.log('create cluster...');
        const clus = cluster.fork();
    }
    cluster.on('exit', (worker, code, signal) => {
        console.log(`worker ${worker.process.pid} died`);
    })

    setTimeout(() => {
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
    }, 5000)
} else {
    const app = express();
    app.get('/', (req, res) => {
        res.json({ status: true });
    })
    app.listen(3000, () => {
        console.log(`listen 3000... pid: ${process.pid}`);
    });
}