import { z } from "zod";

const name = z.string().trim().min(1, "Name is required").max(100, "Name is too long");
const description = z.string().trim().max(1000, "Description is too long");

export const createProjectSchema = z.object({
  name,
  description: description.default(""),
});

// No defaults here, otherwise a PATCH would silently overwrite untouched fields
export const updateProjectSchema = z
  .object({
    name: name.optional(),
    description: description.optional(),
    archived: z.boolean().optional(),
  })
  .refine((data) => Object.keys(data).length > 0, {
    message: "At least one field is required",
  });

export const listProjectsQuerySchema = z.object({
  archived: z.enum(["true", "false", "all"]).default("false"),
  search: z.string().trim().max(100).optional(),
});

export type CreateProjectInput = z.infer<typeof createProjectSchema>;
export type UpdateProjectInput = z.infer<typeof updateProjectSchema>;
export type ListProjectsQuery = z.infer<typeof listProjectsQuerySchema>;
