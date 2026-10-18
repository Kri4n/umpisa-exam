import { RequestHandler } from "express";
import { AuthService, JwtPayload } from "../services/auth.service";
import { ApiError } from "../utils/ApiError";

declare global {
  namespace Express {
    interface Request {
      user?: JwtPayload;
    }
  }
}

// Protect routes: router.get("/me", authenticate, handler)
export const authenticate: RequestHandler = (req, _res, next) => {
  const header = req.headers.authorization;
  if (!header?.startsWith("Bearer ")) {
    return next(ApiError.unauthorized("Missing bearer token"));
  }
  try {
    req.user = AuthService.verifyToken(header.slice(7));
    next();
  } catch (err) {
    next(err);
  }
};

export const authorize =
  (...roles: string[]): RequestHandler =>
  (req, _res, next) => {
    if (!req.user || !roles.includes(req.user.role)) {
      return next(ApiError.forbidden());
    }
    next();
  };
