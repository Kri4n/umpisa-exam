import { Request, Response } from "express";
import { DashboardService } from "../services/dashboard.service";
import { getUserId } from "../utils/getUserId";

export class DashboardController {
  static async get(req: Request, res: Response) {
    const data = await DashboardService.get(getUserId(req));
    res.json({ success: true, data });
  }
}
