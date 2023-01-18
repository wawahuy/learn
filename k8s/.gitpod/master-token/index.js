const http = require('http');
const { exec } = require('child_process');

http.createServer(function (req, res) {
    exec('kubeadm token create --print-join-command', (err, out) => {
        if (err) {
            res.write(`echo 'Loi roi'`);
            res.end()
            return
        }
        res.write(out);
        res.end();
    });
}).listen(6999);