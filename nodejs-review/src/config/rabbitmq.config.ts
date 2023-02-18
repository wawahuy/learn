import amqplib from 'amqplib';

export async function initASend() {
    const queueName = 'test';
    const hostname = process.env.RN_RABBITMQ_HOST;
    const port = Number(process.env.RN_RABBITMQ_PORT);
    const conn = await amqplib.connect({
        hostname,
        port
    })

    const channel = await conn.createChannel();
    await channel.assertQueue(queueName, { durable: false });
    channel.sendToQueue(queueName, Buffer.from('hello world'));
}



export async function initARecv() {
    const queueName = 'test';
    const hostname = process.env.RN_RABBITMQ_HOST;
    const port = Number(process.env.RN_RABBITMQ_PORT);
    const conn = await amqplib.connect({
        hostname,
        port
    })

    const channel = await conn.createChannel();
    await channel.assertQueue(queueName, { durable: false });
    await channel.consume(queueName, (msg) => {
        console.log('wtf -', msg?.content.toString('utf-8'));
    }, { noAck: true })
}


async function initBExchangePushliser() {
    const hostname = process.env.RN_RABBITMQ_HOST;
    const port = Number(process.env.RN_RABBITMQ_PORT);
    const conn = await amqplib.connect({
        hostname, port
    });
    const channel = await conn.createChannel();

}

async function initAExchangeConsumer() {
    const hostname = process.env.RN_RABBITMQ_HOST;
    const port = Number(process.env.RN_RABBITMQ_PORT);
    const conn = await amqplib.connect({
        hostname, port
    });
    const channel = await conn.createChannel();
    await channel.prefetch(1);
    
}

export async function test() {
    // await initARecv();
    // await initASend();
    await initAExchangeConsumer();
    await initBExchangePushliser();
};
