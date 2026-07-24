// backend/src/lib/prisma.ts
import { PrismaClient } from "@prisma/client";

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined;
};

export const prisma =
  globalForPrisma.prisma ??
  new PrismaClient({
    log:
      process.env.NODE_ENV === "development"
        ? ["query", "error", "warn"]
        : ["error"],
  });

if (process.env.PRISMA_LOG_QUERIES === "true") {
  prisma.$use(async (params, next) => {
    const start = Date.now();
    const result = await next(params);
    const duration = Date.now() - start;
    return result;
  });
}

// Prevent Neon compute suspension by keeping both pooler and direct connections warm
// Pooler warm: plain SELECT 1
// Direct warm: $transaction (routes through DIRECT_URL)
const keepAlive = async () => {
  try {
    await prisma.$queryRaw`SELECT 1`;
  } catch {
    // ignore keep-alive errors
  }
  try {
    await prisma.$transaction(async (tx) => {
      await tx.$queryRaw`SELECT 1`;
    });
  } catch {
    // ignore keep-alive errors
  }
};
keepAlive();
setInterval(keepAlive, 30_000);

if (process.env.NODE_ENV !== "production") globalForPrisma.prisma = prisma;