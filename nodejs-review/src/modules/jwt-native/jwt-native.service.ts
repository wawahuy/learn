import jwt from 'jsonwebtoken';

export class JwtNativeService {
    static readonly accessSecret = 'secretblabla';
    static readonly accessExpiresIn = 60 * 1000;
    static readonly refreshSecret = 'refreshblabla';

    static login(username: string, password: string): 
        Promise<{ accessToken: string, refreshToken: string, expired: number }> 
    {

        if (username === 'test' && password === 'test') {
            const payload = { username };

            // access token
            const accessToken = this.generationAccessToken(payload);

            // refresh token
            const refreshExpiresIn = 60 * 60 * 1000;
            const refreshToken = jwt.sign(payload, this.refreshSecret, {
                expiresIn: refreshExpiresIn / 1000 + 's'
            });

            return Promise.resolve({
                refreshToken, 
                accessToken, 
                expired: new Date().getTime() + this.accessExpiresIn
            })
        } else {
            return Promise.reject();
        }
    }

    static getAccessToken(refreshToken: string) {
        // verify refresh token
        const { username } = jwt.verify(refreshToken, this.refreshSecret) as any;
        const payload = { username };
        // access token
        const accessToken = this.generationAccessToken(payload);
        return {
            accessToken, 
            expired: new Date().getTime() + this.accessExpiresIn
        }
    }

    static verifyAccessToken(token: string) {
        return jwt.verify(token, this.accessSecret);
    }

    static generationAccessToken(payload: any) {
        return jwt.sign(payload, this.accessSecret, {
            expiresIn: this.accessExpiresIn / 1000 + 's'
        });
    }
}