import { Router } from "express";
import { AuthController } from "../controllers/auth.controller";
import { validate } from "../middlewares/validate.middleware";
import { loginSchema } from "../validators/auth.validator";
import { asyncHandler } from "../utils/asyncHandler";

const router = Router();

router.post("/login", validate(loginSchema), asyncHandler(AuthController.login));

export default router;
