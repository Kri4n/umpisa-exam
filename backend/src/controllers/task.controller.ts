import { Request, Response } from "express";
import { TaskService } from "../services/task.service";
import { getUserId } from "../utils/getUserId";
import { CreateTaskInput, ListTasksQuery, UpdateTaskInput } from "../validators/task.validator";

export class TaskController {
  static async list(req: Request, res: Response) {
    const { items, pagination } = await TaskService.list(
      getUserId(req),
      req.query as unknown as ListTasksQuery
    );
    res.json({ success: true, data: items, pagination });
  }

  static async getOne(req: Request, res: Response) {
    const data = await TaskService.getById(getUserId(req), req.params.id);
    res.json({ success: true, data });
  }

  static async create(req: Request, res: Response) {
    const data = await TaskService.create(getUserId(req), req.body as CreateTaskInput);
    res.status(201).json({ success: true, data });
  }

  static async update(req: Request, res: Response) {
    const data = await TaskService.update(getUserId(req), req.params.id, req.body as UpdateTaskInput);
    res.json({ success: true, data });
  }

  static async remove(req: Request, res: Response) {
    await TaskService.remove(getUserId(req), req.params.id);
    res.json({ success: true, message: "Task deleted" });
  }
}
