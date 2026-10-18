import { NextFunction, Request, RequestHandler, Response } from "express";

// Forwards rejected promises to Express's error middleware (needed in Express 4)
export const asyncHandler =
  (fn: (req: Request, res: Response, next: NextFunction) => Promise<unknown>): RequestHandler =>
  (req, res, next) => {
    fn(req, res, next).catch(next);
  };
