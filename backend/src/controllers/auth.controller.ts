import { Request, Response } from "express";
import { AuthService } from "../services/auth.service";
import { LoginInput } from "../validators/auth.validator";

export class AuthController {
  static async login(req: Request, res: Response) {
    const { email, password } = req.body as LoginInput;
    const result = await AuthService.login(email, password);
    res.status(200).json({ success: true, data: result });
  }
}
