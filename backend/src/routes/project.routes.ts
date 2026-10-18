import { Router } from "express";
import { ProjectController } from "../controllers/project.controller";
import { authenticate } from "../middlewares/auth.middleware";
import { validate } from "../middlewares/validate.middleware";
import { asyncHandler } from "../utils/asyncHandler";
import { idParamSchema } from "../validators/common.validator";
import {
  createProjectSchema,
  listProjectsQuerySchema,
  updateProjectSchema,
} from "../validators/project.validator";

const router = Router();

router.use(authenticate);

router.get("/", validate(listProjectsQuerySchema, "query"), asyncHandler(ProjectController.list));
router.post("/", validate(createProjectSchema), asyncHandler(ProjectController.create));
router.get("/:id", validate(idParamSchema, "params"), asyncHandler(ProjectController.getOne));
router.patch(
  "/:id",
  validate(idParamSchema, "params"),
  validate(updateProjectSchema),
  asyncHandler(ProjectController.update)
);

export default router;
