import { Schema, Types, model } from "mongoose";

export interface IProject {
  userId: Types.ObjectId;
  name: string;
  description: string;
  archived: boolean;
  createdAt: Date;
  updatedAt: Date;
}

const projectSchema = new Schema<IProject>(
  {
    userId: { type: Schema.Types.ObjectId, ref: "User", required: true },
    name: { type: String, required: true, trim: true, maxlength: 100 },
    description: { type: String, default: "", trim: true, maxlength: 1000 },
    archived: { type: Boolean, default: false },
  },
  { timestamps: true }
);

projectSchema.index({ userId: 1, archived: 1, createdAt: -1 });

export const Project = model<IProject>("Project", projectSchema);
