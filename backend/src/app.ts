import express from 'express';
import type { Application, Request, Response, NextFunction } from 'express';

const app: Application = express();

app.use(express.json());
app.use(express.urlencoded({ extended: true }));



// 404 handler
app.use((_req: Request, res: Response) => {
  res.status(404).json({ message: 'Route not found' });
});

// Global error handler
app.use((err: Error, _req: Request, res: Response, _next: NextFunction) => {
  console.error(err.stack);
  res.status(500).json({ message: 'Internal server error' });
});

export default app;