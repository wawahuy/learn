import express from 'express';
import http from 'http';
import { Server } from 'socket.io';
import session from 'express-session';

(async () => {
    const app = express();
    app.use(session({
        secret: 'helloworld',
        resave: true,
        saveUninitialized: true,
        cookie: {
            maxAge: 60 * 1000
        }
    }));

    app.get('/', (req, res) => {
        const t = req.session as any;
        t.test = (t.test || 0) + 1;
        res.send(req.session.id + ' --- ' + (t.test));
    })
    
    const server = http.createServer(app);
    const io = new Server(server);
    io.on('connection', function (socket) {
        console.log(socket);
        socket.conn.once('disconnect', function () {

        })
    })
    
    server.listen(3000);
})()