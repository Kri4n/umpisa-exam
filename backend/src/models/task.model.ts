import { Schema, Types, model } from "mongoose";

export const TASK_STATUSES = ["pending", "in_progress", "completed"] as const;
export const TASK_PRIORITIES = ["low", "medium", "high"] as const;

export type TaskStatus = (typeof TASK_STATUSES)[number];
export type TaskPriority = (typeof TASK_PRIORITIES)[number];

export interface ITask {
  projectId: Types.ObjectId;
  title: string;
  description: string;
  status: TaskStatus;
  priority: TaskPriority;
  dueDate: Date | null;
  createdAt: Date;
  updatedAt: Date;
}

const taskSchema = new Schema<ITask>(
  {
    projectId: { type: Schema.Types.ObjectId, ref: "Project", required: true },
    title: { type: String, required: true, trim: true, maxlength: 200 },
    description: { type: String, default: "", trim: true, maxlength: 2000 },
    status: { type: String, enum: TASK_STATUSES, default: "pending" },
    priority: { type: String, enum: TASK_PRIORITIES, default: "medium" },
    dueDate: { type: Date, default: null },
  },
  { timestamps: true }
);

taskSchema.index({ projectId: 1, status: 1 });
taskSchema.index({ projectId: 1, dueDate: 1 });

export const Task = model<ITask>("Task", taskSchema);
