import cors from "cors";
import express from "express";
import helmet from "helmet";
import routes from "./routes";
import { errorHandler, notFoundHandler } from "./middlewares/error.middleware";

const app = express();

app.use(helmet());
app.use(cors());
app.use(express.json());

app.use("/api/v1", routes);

app.use(notFoundHandler);
app.use(errorHandler);

export default app;
