import { NextFunction, Request, Response } from "express";
import { JwtNativeService } from "./jwt-native.service.js";

export const jwtNativeMiddleware = (req: Request, res: Response, next: NextFunction) => {
    const authorization = req.headers.authorization as string;
    try {
        if (authorization) {
            const accessToken = authorization.slice(7);
            const payload = JwtNativeService.verifyAccessToken(accessToken) as any;
            (req as any).user = payload.username;
            next();
        } else {
            throw false;
        }
    } catch (e: any) {
        res.status(401).send({ msg: e && e.message });
    }
}