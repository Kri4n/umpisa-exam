import jwt, { SignOptions } from "jsonwebtoken";
import { env } from "../config/env";
import { User } from "../models/user.model";
import { ApiError } from "../utils/ApiError";

export interface JwtPayload {
  sub: string;
  role: string;
}

export class AuthService {
  static async login(email: string, password: string) {
    // password is `select: false` on the schema, so opt in explicitly
    const user = await User.findOne({ email }).select("+password");

    // Same message for both cases to avoid leaking which emails exist
    if (!user || !(await user.comparePassword(password))) {
      throw ApiError.unauthorized("Invalid email or password");
    }

    const token = AuthService.signToken({ sub: user.id, role: user.role });

    return { token, user: user.toJSON() };
  }

  static signToken(payload: JwtPayload): string {
    return jwt.sign(payload, env.JWT_SECRET, {
      expiresIn: env.JWT_EXPIRES_IN as SignOptions["expiresIn"],
    });
  }

  static verifyToken(token: string): JwtPayload {
    try {
      return jwt.verify(token, env.JWT_SECRET) as unknown as JwtPayload;
    } catch {
      throw ApiError.unauthorized("Invalid or expired token");
    }
  }
}
