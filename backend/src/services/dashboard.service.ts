import { Project } from "../models/project.model";
import { Task } from "../models/task.model";
import { ProjectService } from "./project.service";
import { TaskService } from "./task.service";

const RECENT_PROJECTS_LIMIT = 5;
const UPCOMING_DEADLINES_LIMIT = 5;

export class DashboardService {
  static async get(userId: string) {
    const now = new Date();

    // Archived projects (and their tasks) are left out of the dashboard
    const projects = await Project.find({ userId, archived: false })
      .sort({ createdAt: -1 })
      .select("name description archived createdAt updatedAt userId")
      .lean();

    const projectIds = projects.map((p) => p._id);
    const inActiveProjects = { projectId: { $in: projectIds } };

    const [statusRows, overdue, upcoming] = await Promise.all([
      Task.aggregate<{ _id: string; count: number }>([
        { $match: inActiveProjects },
        { $group: { _id: "$status", count: { $sum: 1 } } },
      ]),
      Task.countDocuments({
        ...inActiveProjects,
        status: { $ne: "completed" },
        dueDate: { $lt: now },
      }),
      Task.find({
        ...inActiveProjects,
        status: { $ne: "completed" },
        dueDate: { $gte: now },
      })
        .sort({ dueDate: 1 })
        .limit(UPCOMING_DEADLINES_LIMIT)
        .lean(),
    ]);

    const byStatus = Object.fromEntries(statusRows.map((r) => [r._id, r.count]));
    const completed = byStatus.completed ?? 0;
    const pending = byStatus.pending ?? 0;
    const inProgress = byStatus.in_progress ?? 0;

    const recent = projects.slice(0, RECENT_PROJECTS_LIMIT);
    const counts = await ProjectService.getTaskCounts(recent.map((p) => p._id));
    const projectMap = new Map(projects.map((p) => [p._id.toString(), p]));

    return {
      projects: { total: projects.length },
      tasks: {
        total: completed + pending + inProgress,
        completed,
        pending,
        inProgress,
        overdue, // not completed and past due (can overlap with pending / inProgress)
      },
      recentProjects: recent.map((p) => ProjectService.toDTO(p, counts.get(p._id.toString()))),
      upcomingDeadlines: upcoming.map((t) =>
        TaskService.toDTO(t, projectMap.get(t.projectId.toString()))
      ),
    };
  }
}
