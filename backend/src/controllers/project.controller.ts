import { Request, Response } from "express";
import { ProjectService } from "../services/project.service";
import { getUserId } from "../utils/getUserId";
import {
  CreateProjectInput,
  ListProjectsQuery,
  UpdateProjectInput,
} from "../validators/project.validator";

export class ProjectController {
  static async list(req: Request, res: Response) {
    const data = await ProjectService.list(getUserId(req), req.query as unknown as ListProjectsQuery);
    res.json({ success: true, data });
  }

  static async getOne(req: Request, res: Response) {
    const data = await ProjectService.getById(getUserId(req), req.params.id);
    res.json({ success: true, data });
  }

  static async create(req: Request, res: Response) {
    const data = await ProjectService.create(getUserId(req), req.body as CreateProjectInput);
    res.status(201).json({ success: true, data });
  }

  static async update(req: Request, res: Response) {
    const data = await ProjectService.update(
      getUserId(req),
      req.params.id,
      req.body as UpdateProjectInput
    );
    res.json({ success: true, data });
  }
}
