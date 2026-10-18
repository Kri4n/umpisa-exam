import { Request } from "express";
import { ApiError } from "./ApiError";

// Reads the authenticated user's id (set by the `authenticate` middleware)
export const getUserId = (req: Request): string => {
  if (!req.user) throw ApiError.unauthorized();
  return req.user.sub;
};
