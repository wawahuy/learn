import express from 'express';
import https from 'https';
import fs from 'fs';
import path from 'path';

const app = express();

app.get('/', (req, res) =>  {
    res.json({});
})

const certFolder = path.join(process.cwd(), 'cert');
const server = https.createServer({
    cert: fs.readFileSync(path.join(certFolder, 'localhost.crt')),
    key: fs.readFileSync(path.join(certFolder, 'localhost.key')),
    ca: [
        fs.readFileSync(path.join(certFolder, 'rootCA.crt'))
    ],
}, app)
server.listen(3000);