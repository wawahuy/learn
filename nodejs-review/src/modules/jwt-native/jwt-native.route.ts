import { Router } from "express";
import { loginController, testController, refrehController } from "./jwt-native.controller.js";
import { jwtNativeMiddleware } from "./jwt-native.middleware.js";


const route = Router();

route.post('/login', loginController);
route.post('/access_token', refrehController);

route.use(jwtNativeMiddleware);
route.get('/test', testController);

export default route;