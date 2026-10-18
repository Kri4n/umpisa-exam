import { Router } from "express";
import { TaskController } from "../controllers/task.controller";
import { authenticate } from "../middlewares/auth.middleware";
import { validate } from "../middlewares/validate.middleware";
import { asyncHandler } from "../utils/asyncHandler";
import { idParamSchema } from "../validators/common.validator";
import {
  createTaskSchema,
  listTasksQuerySchema,
  updateTaskSchema,
} from "../validators/task.validator";

const router = Router();

router.use(authenticate);

router.get("/", validate(listTasksQuerySchema, "query"), asyncHandler(TaskController.list));
router.post("/", validate(createTaskSchema), asyncHandler(TaskController.create));
router.get("/:id", validate(idParamSchema, "params"), asyncHandler(TaskController.getOne));
router.patch(
  "/:id",
  validate(idParamSchema, "params"),
  validate(updateTaskSchema),
  asyncHandler(TaskController.update)
);
router.delete("/:id", validate(idParamSchema, "params"), asyncHandler(TaskController.remove));

export default router;
