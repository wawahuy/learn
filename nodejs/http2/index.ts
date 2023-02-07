import http2 from 'http2';

/**
 * Server side
 */
const server = http2.createServer()

server.on('error', (err) => {
    console.log(err);
})

server.on('stream', (stream, headers) => {
  console.log(stream);
  stream.respond({
    'content-type': 'text/html; charset=utf-8',
    ':status': 200,
  });
  stream.on('error', (error) => console.error(error));
  stream.end('<h1>Hello World</h1>');
});

server.listen(3000);

/**
 * Client side
 */

const client = http2.connect('http://localhost:3000');
client.on('error', (err) => console.error(err));

const req = client.request({ ':path': '/' });

req.on('response', (headers, flags) => {
  for (const name in headers) {
    console.log(`${name}: ${headers[name]}`);
  }
});

req.setEncoding('utf8');
let data = '';
req.on('data', (chunk) => { data += chunk; });
req.on('end', () => {
  console.log(`\n${data}`);
  client.close();
});
req.end();