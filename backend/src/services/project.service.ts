import { Types } from "mongoose";
import { IProject, Project } from "../models/project.model";
import { Task } from "../models/task.model";
import { ApiError } from "../utils/ApiError";
import { escapeRegex } from "../utils/escapeRegex";
import {
  CreateProjectInput,
  ListProjectsQuery,
  UpdateProjectInput,
} from "../validators/project.validator";

type ProjectRecord = IProject & { _id: Types.ObjectId };
export interface TaskCounts {
  total: number;
  completed: number;
}

export class ProjectService {
  /** Finds a project owned by the user, or throws 404 */
  static async getOwned(userId: string, id: string) {
    const project = await Project.findOne({ _id: id, userId });
    if (!project) throw ApiError.notFound("Project not found");
    return project;
  }

  /** Task totals per project, in a single aggregation */
  static async getTaskCounts(projectIds: Types.ObjectId[]) {
    const rows = await Task.aggregate<{ _id: Types.ObjectId; total: number; completed: number }>([
      { $match: { projectId: { $in: projectIds } } },
      {
        $group: {
          _id: "$projectId",
          total: { $sum: 1 },
          completed: { $sum: { $cond: [{ $eq: ["$status", "completed"] }, 1, 0] } },
        },
      },
    ]);
    return new Map<string, TaskCounts>(
      rows.map((r) => [r._id.toString(), { total: r.total, completed: r.completed }])
    );
  }

  static toDTO(project: ProjectRecord, counts?: TaskCounts) {
    const total = counts?.total ?? 0;
    const completed = counts?.completed ?? 0;
    return {
      id: project._id.toString(),
      name: project.name,
      description: project.description,
      archived: project.archived,
      createdAt: project.createdAt,
      updatedAt: project.updatedAt,
      taskCount: total,
      completedCount: completed,
      pendingCount: total - completed,
      progress: total === 0 ? 0 : Math.round((completed / total) * 100),
    };
  }

  static async list(userId: string, query: ListProjectsQuery) {
    const filter: Record<string, unknown> = { userId };
    if (query.archived !== "all") filter.archived = query.archived === "true";
    if (query.search) filter.name = { $regex: escapeRegex(query.search), $options: "i" };

    const projects = await Project.find(filter).sort({ createdAt: -1 }).lean();
    const counts = await ProjectService.getTaskCounts(projects.map((p) => p._id));

    return projects.map((p) => ProjectService.toDTO(p, counts.get(p._id.toString())));
  }

  static async getById(userId: string, id: string) {
    const project = await ProjectService.getOwned(userId, id);
    const counts = await ProjectService.getTaskCounts([project._id]);
    return ProjectService.toDTO(project.toObject(), counts.get(project.id));
  }

  static async create(userId: string, input: CreateProjectInput) {
    const project = await Project.create({ userId: new Types.ObjectId(userId), ...input });
    return ProjectService.toDTO(project.toObject());
  }

  static async update(userId: string, id: string, input: UpdateProjectInput) {
    const project = await ProjectService.getOwned(userId, id);
    project.set(input);
    await project.save();
    const counts = await ProjectService.getTaskCounts([project._id]);
    return ProjectService.toDTO(project.toObject(), counts.get(project.id));
  }
}
