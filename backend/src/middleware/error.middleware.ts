import { Request, Response, NextFunction } from "express";

export function errorHandler(
  err: Error,
  _req: Request,
  res: Response,
  _next: NextFunction
) {
  console.error("❌ Error:", err.message);

  // Prisma unique constraint violation
  if ((err as any).code === "P2002") {
    res.status(409).json({ success: false, error: "Record already exists" });
    return;
  }

  // Prisma record not found
  if ((err as any).code === "P2025") {
    res.status(404).json({ success: false, error: "Record not found" });
    return;
  }

  res.status(500).json({
    success: false,
    error:
      process.env.NODE_ENV === "production" ? "Internal server error" : err.message,
  });
}
