import express from "express";
import cors from "cors";
import helmet from "helmet";
import morgan from "morgan";

import { userRoutes } from "./routes/user.routes";
import { errorHandler } from "./middleware/error.middleware";
import { notFound } from "./middleware/notFound.middleware";

const app = express();

// ── Security & utility middleware ──────────────────────────────────────────
app.use(helmet());
app.use(cors());
app.use(morgan("dev"));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// ── Health check ───────────────────────────────────────────────────────────
app.get("/health", (_req, res) => {
  res.json({ status: "ok", timestamp: new Date().toISOString() });
});

// ── Routes ─────────────────────────────────────────────────────────────────
app.use("/api/users", userRoutes);

// ── Error handling ─────────────────────────────────────────────────────────
app.use(notFound);
app.use(errorHandler);

export default app;
