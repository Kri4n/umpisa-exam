import { Router } from "express";
import authRoutes from "./auth.routes";
import dashboardRoutes from "./dashboard.routes";
import projectRoutes from "./project.routes";
import taskRoutes from "./task.routes";

const router = Router();

router.get("/health", (_req, res) => {
  res.json({ status: "ok", uptime: process.uptime() });
});

router.use("/auth", authRoutes);
router.use("/dashboard", dashboardRoutes);
router.use("/projects", projectRoutes);
router.use("/tasks", taskRoutes);

export default router;
