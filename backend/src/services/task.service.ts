import { Types } from "mongoose";
import { Project } from "../models/project.model";
import { ITask, Task } from "../models/task.model";
import { ApiError } from "../utils/ApiError";
import { escapeRegex } from "../utils/escapeRegex";
import { CreateTaskInput, ListTasksQuery, UpdateTaskInput } from "../validators/task.validator";
import { ProjectService } from "./project.service";

type TaskRecord = ITask & { _id: Types.ObjectId };
export type ProjectRef = { _id: Types.ObjectId; name: string; archived: boolean };

export class TaskService {
  static toDTO(task: TaskRecord, project?: ProjectRef | null) {
    const isOverdue =
      task.status !== "completed" && !!task.dueDate && task.dueDate.getTime() < Date.now();

    return {
      id: task._id.toString(),
      projectId: task.projectId.toString(),
      project: project
        ? { id: project._id.toString(), name: project.name, archived: project.archived }
        : null,
      title: task.title,
      description: task.description,
      status: task.status,
      priority: task.priority,
      dueDate: task.dueDate,
      isOverdue,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
    };
  }

  /** The project must exist, belong to the user, and not be archived */
  private static async getUsableProject(userId: string, projectId: string) {
    const project = await ProjectService.getOwned(userId, projectId);
    if (project.archived) throw ApiError.badRequest("Project is archived");
    return project;
  }

  /** Tasks have no userId, so ownership is checked through the parent project */
  private static async getOwned(userId: string, taskId: string) {
    const task = await Task.findById(taskId);
    if (!task) throw ApiError.notFound("Task not found");

    const project = await Project.findOne({ _id: task.projectId, userId }).select("name archived");
    if (!project) throw ApiError.notFound("Task not found");

    return { task, project };
  }

  static async list(userId: string, query: ListTasksQuery) {
    // Projects whose tasks are visible: the requested one, or all non-archived ones
    const projects: ProjectRef[] = query.projectId
      ? [await ProjectService.getOwned(userId, query.projectId)]
      : await Project.find({ userId, archived: false }).select("name archived").lean();

    const filter: Record<string, unknown> = {
      projectId: { $in: projects.map((p) => p._id) },
    };
    if (query.status) filter.status = query.status;
    if (query.priority) filter.priority = query.priority;
    if (query.search) filter.title = { $regex: escapeRegex(query.search), $options: "i" };

    const direction = query.order === "asc" ? 1 : -1;
    const sort: Record<string, 1 | -1> = { [query.sortBy]: direction, _id: -1 };

    const [tasks, total] = await Promise.all([
      Task.find(filter)
        .sort(sort)
        .skip((query.page - 1) * query.limit)
        .limit(query.limit)
        .lean(),
      Task.countDocuments(filter),
    ]);

    const projectMap = new Map(projects.map((p) => [p._id.toString(), p]));

    return {
      items: tasks.map((t) => TaskService.toDTO(t, projectMap.get(t.projectId.toString()))),
      pagination: {
        page: query.page,
        limit: query.limit,
        total,
        totalPages: Math.max(1, Math.ceil(total / query.limit)),
      },
    };
  }

  static async getById(userId: string, id: string) {
    const { task, project } = await TaskService.getOwned(userId, id);
    return TaskService.toDTO(task.toObject(), project);
  }

  static async create(userId: string, input: CreateTaskInput) {
    const project = await TaskService.getUsableProject(userId, input.projectId);

    const task = await Task.create({
      ...input,
      projectId: project._id,
      dueDate: input.dueDate ?? null,
    });

    return TaskService.toDTO(task.toObject(), project);
  }

  static async update(userId: string, id: string, input: UpdateTaskInput) {
    const { task, project: currentProject } = await TaskService.getOwned(userId, id);
    const { projectId, ...fields } = input;

    let project = currentProject;
    if (projectId && projectId !== task.projectId.toString()) {
      project = await TaskService.getUsableProject(userId, projectId);
      task.projectId = project._id;
    }

    task.set(fields);
    await task.save();

    return TaskService.toDTO(task.toObject(), project);
  }

  static async remove(userId: string, id: string) {
    const { task } = await TaskService.getOwned(userId, id);
    await task.deleteOne();
  }
}
