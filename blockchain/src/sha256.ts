
export class SHA256 {

    static toBin(data: Buffer) {
        return BigInt("0x" + data.toString('hex'))
            .toString(2)
            .padStart(data.length * 8, '0')
            .split('')
            .map((b) => Number(b));
    }

    static numToBin(n: number, pad = 64) {
        return n.toString(2)
            .padStart(pad, '0')
            .split('')
            .map((b) => Number(b));
    }
    

    static encrypt(data: Buffer) {
        // 256bit = 32 byte
        // to bin
        let arrBin = SHA256.toBin(data);

        // nối '1' sau chuỗi nhị phân
        arrBin.push(1);

        // nối 0 cho đến khi dữ liệu là bội của 512 & ít hơn 64 bit
        while (arrBin.length % 512 !== 0) {
            arrBin.push(0);
        }
        console.log(arrBin.join(''));
        
        // nối 64 bit (big-endian) vào cuối, nó là độ dài của số bit đầu vào
        arrBin.splice(arrBin.length - 64, arrBin.length);
        arrBin = arrBin.concat(this.numToBin(data.length))
        console.log(arrBin.join(''));

        // kết quả mong đợi cuối cùng là dữ liệu có độ dài là bội của 512 bit
        // khởi tạo giá trị bâm (h)


        // khởi tạo hằng số tròn (k)

        // vòng lặp chunk

        // tạo lịch trình tin nhắn (w)

        // nén

        // sửa đổi giá trị

        // kết hợp băm


    }
}