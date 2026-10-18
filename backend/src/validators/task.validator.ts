import { z } from "zod";
import { TASK_PRIORITIES, TASK_STATUSES } from "../models/task.model";
import { objectId } from "./common.validator";

const title = z.string().trim().min(1, "Title is required").max(200, "Title is too long");
const description = z.string().trim().max(2000, "Description is too long");
const status = z.enum(TASK_STATUSES);
const priority = z.enum(TASK_PRIORITIES);
const dueDate = z.coerce.date({ error: "Invalid due date" });

export const createTaskSchema = z.object({
  projectId: objectId,
  title,
  description: description.default(""),
  status: status.default("pending"),
  priority: priority.default("medium"),
  dueDate: dueDate.nullable().optional(),
});

// No defaults here, otherwise a PATCH would silently overwrite untouched fields.
// Send `dueDate: null` to clear the due date.
export const updateTaskSchema = z
  .object({
    projectId: objectId.optional(),
    title: title.optional(),
    description: description.optional(),
    status: status.optional(),
    priority: priority.optional(),
    dueDate: dueDate.nullable().optional(),
  })
  .refine((data) => Object.keys(data).length > 0, {
    message: "At least one field is required",
  });

export const listTasksQuerySchema = z.object({
  projectId: objectId.optional(),
  status: status.optional(),
  priority: priority.optional(),
  search: z.string().trim().max(100).optional(),
  sortBy: z.enum(["createdAt", "dueDate", "title"]).default("createdAt"),
  order: z.enum(["asc", "desc"]).default("desc"),
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
});

export type CreateTaskInput = z.infer<typeof createTaskSchema>;
export type UpdateTaskInput = z.infer<typeof updateTaskSchema>;
export type ListTasksQuery = z.infer<typeof listTasksQuerySchema>;
