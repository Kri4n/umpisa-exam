import app from "./app";
import { connectDB, disconnectDB } from "./config/db";
import { env } from "./config/env";

export async function bootstrap(): Promise<void> {
  await connectDB();

  const server = app.listen(env.PORT, "0.0.0.0", () => {
    console.log(`🚀 Server running on http://localhost:${env.PORT}`);
  });

  const shutdown = () => {
    console.log("Shutting down...");
    server.close(async () => {
      await disconnectDB();
      process.exit(0);
    });
  };
  process.on("SIGINT", shutdown);
  process.on("SIGTERM", shutdown);
}

if (require.main === module) {
  bootstrap().catch((err) => {
    console.error("Failed to start server:", err);
    process.exit(1);
  });
}
