import yaml from 'yaml';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { spawn } from 'node:child_process';
import url from 'node:url';

const __filename = url.fileURLToPath(import.meta.url);
const __dirname = url.fileURLToPath(new URL('.', import.meta.url));

let allSpawn = [];

const fileConfig = path.join(__dirname, '.gpserver.yaml');
if (!fs.existsSync(fileConfig)) {
    console.log('Need config file: ', fileConfig);
    process.exit();
}

const fileSSHPrivateKey = path.join(os.homedir(), '.ssh/id_rsa_gitpod');
console.log('spk', fileSSHPrivateKey);
if (!fs.existsSync(fileSSHPrivateKey)) {
    console.log('Need ssh file: ', fileSSHPrivateKey);
    process.exit();
}

if (!fs.existsSync(path.join(__dirname, './gpkeep.js'))) {
    console.log('Need gitpod keep file Js: ', fileConfig);
    process.exit();
}

import keepAliveFetchs from './gpkeep.js';


function getConfig() {
    const content = fs.readFileSync(fileConfig).toString();
    const data = yaml.parse(content);
    return data;
}

function getShellRemote2Local(local, remote, connection) {
    return ['-o StrictHostKeychecking=no', '-L',  `${local}:localhost:${remote}`,  connection];
}

function getShellLocal2Remote(local, remote, connection) {
    return ['-o StrictHostKeychecking=no', '-R', `${remote}:localhost:${local}`, connection];
}

function transferSPKLocal2Remote(p, connection) {
    const t = `${connection}:~/.ssh`;
    console.log(p, '-->', t);
    return new Promise((resolve, reject) => {
        const proc = spawn(
            'scp',
            [
                '-o', 'StrictHostKeychecking=no',
                p,
                t
            ]
        );
        allSpawn.push(proc);
        proc.on('close', () => {
            allSpawn = allSpawn.filter(sp => sp != proc);
            resolve()
        })
        proc.stderr.on("data", data => {
            reject(data.toString())
        });
        proc.stdout.on('data', (data) => {
            // console.log(`stdout: `, data.toString());
        })
    })
}

class SSHTerminal {
    isConnected = false;

    constructor(connection, vpn) {
        this.connection = connection;
        this.vpn = vpn;
        this.proc = spawn('ssh', ['-tt', '-o', 'StrictHostKeychecking=no', connection]);
        allSpawn.push(this.proc);

        this.proc.on('close', () => {
            allSpawn = allSpawn.filter(sp => sp != this.proc);
            console.log(`exit:`, this.connection);
        })
        this.proc.stderr.on("data", data => {
            console.log(`stderr: ${data}`);
        });
        this.proc.stdout.on('data', (data) => {
            const content = data.toString();
            if (!this.isConnected) {
                if (content.indexOf('gitpod') > -1 && content.indexOf('/workspace') > -1) {
                    this.onConnected();
                }
            } else {
                // if has vpn, it is forward port
                if (this.vpn) {
                    // check if is forward closed
                    // re forward
                    console.log('\r\n\r\n-------------------------------');
                    console.log('[host]', connection)
                    console.log('-------------------------------');
                    console.log(`stdout: `, data.toString());
                }
            }
        })
    }

    ping() {
        this.proc.stdin.write('ls \r\n');
    }

    async onConnected() {
        console.log('[Connected]', this.connection)
        this.isConnected = true;
        if (this.vpn) {
            // if has vpn, it forward port
            await this.pushSSHPrivateKey();
            await this.forwardPortVPN();
        }
    }

    async forwardPortVPN() {
        const op = getShellRemote2Local(1194, this.vpn.port, this.vpn.connection);
        const shell = `ssh -i ~/.ssh/id_rsa_gitpod  ${op.join(' ')} \r\n`;
        this.proc.stdin.write(shell);
    }

    async pushSSHPrivateKey() {
        await transferSPKLocal2Remote(fileSSHPrivateKey, this.connection);
        console.log('[Push RSA]', this.connection)
    }

    release() {
        this.proc.kill();
    }
}

function keepAlive() {
    keepAliveFetchs.forEach((kl) => {
        kl().then((r) => r.text()).then((r) => r != 'OK' && console.log(r));
    })
}

(async () => {
    const config = getConfig();
    const vpn = config.vpn;
    const clients = config.clients;

    console.log('[Client]');
    const terminalForwardClients = clients.map((client) => {
        return new SSHTerminal(client, vpn);
    })

    console.log('[Ping]');
    const terminalPingClients = [...clients, vpn.connection].map((client) => {
        return new SSHTerminal(client);
    })

    console.log('[Host]');
    const proc = spawn('ssh', getShellRemote2Local(1194, vpn.port, vpn.connection));
    allSpawn.push(proc);

    while(true) {
        await new Promise((res) =>setTimeout(res, 5000));
        terminalPingClients.forEach((cl) => cl.ping());
        // keepAlive();
    }
})()


process.stdin.resume();//so the program will not close instantly

function exitHandler(options, exitCode) {
    if (options.cleanup) {
        allSpawn.map(sp => {
            sp.kill();
            console.log('kill ...')
        })
    }
    if (exitCode || exitCode === 0) console.log(exitCode);
    if (options.exit) process.exit();
}

//do something when app is closing
process.on('exit', exitHandler.bind(null,{cleanup:true}));

//catches ctrl+c event
process.on('SIGINT', exitHandler.bind(null, {exit:true}));

// catches "kill pid" (for example: nodemon restart)
process.on('SIGUSR1', exitHandler.bind(null, {exit:true}));
process.on('SIGUSR2', exitHandler.bind(null, {exit:true}));

//catches uncaught exceptions
process.on('uncaughtException', exitHandler.bind(null, {exit:true}));