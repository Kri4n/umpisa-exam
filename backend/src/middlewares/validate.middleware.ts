import { RequestHandler } from "express";
import { ZodType } from "zod";

type Source = "body" | "query" | "params";

// Validates part of the request and replaces it with the parsed (typed, coerced) value
export const validate =
  (schema: ZodType, source: Source = "body"): RequestHandler =>
  (req, _res, next) => {
    let raw: unknown = req[source];

    // Treat empty query params (e.g. ?status=&search=) as "not provided"
    if (source === "query") {
      raw = Object.fromEntries(Object.entries(req.query).filter(([, v]) => v !== ""));
    }

    const result = schema.safeParse(raw);
    if (!result.success) return next(result.error);

    (req as unknown as Record<Source, unknown>)[source] = result.data;
    next();
  };
