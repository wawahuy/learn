import { Request, Response } from "express";
import { JwtNativeService } from "./jwt-native.service.js";

export const testController = (req: Request, res: Response) => {
    res.json({ status: 'ok' });
}

export const loginController = (req: Request, res: Response) => {
    const data = req.body;
    const { username, password } = data;
    console.log(data);
    JwtNativeService.login(username, password)
        .then((data) => {
            res.json(data);
        })
        .catch((e) => {
            res.status(401).send({ msg: 'Unauthorization' })
        })
}

export const refrehController = (req: Request, res: Response) => {
    try {
        const { accessToken } = req.body;
        const data = JwtNativeService.getAccessToken(accessToken);
        res.json(data);
    } catch (e) {
        res.status(401).json({ msg: 'Unauthorization' });
    }
}