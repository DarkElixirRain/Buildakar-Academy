import { Request, Response, NextFunction } from 'express';
import { ZodError } from 'zod';
import { Prisma } from '@prisma/client';
import { AppError } from '../utils/AppError';

export const errorHandler = (
  err: Error,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  console.error('Error:', err.message);
  console.error('Stack:', err.stack);

  if (err instanceof ZodError) {
    return res.status(400).json({
      success: false,
      message: 'Validation failed',
      errors: err.issues.map((e) => ({
        field: e.path.join('.'),
        message: e.message,
      })),
    });
  }

  if (err instanceof AppError) {
    return res.status(err.statusCode).json({
      success: false,
      message: err.message,
    });
  }

  if (err instanceof Prisma.PrismaClientKnownRequestError) {
    if (err.code === 'P2002') {
      const field = Array.isArray(err.meta?.target) ? err.meta.target[0] : err.meta?.target;
      return res.status(409).json({
        success: false,
        message: `${field} already exists`,
      });
    }
    if (err.code === 'P2003') {
      return res.status(400).json({
        success: false,
        message: 'Referenced record not found',
      });
    }
    if (err.code === 'P2025') {
      return res.status(404).json({
        success: false,
        message: 'Record not found',
      });
    }
  }

  if (err instanceof Prisma.PrismaClientValidationError) {
    return res.status(400).json({
      success: false,
      message: 'Invalid data provided',
    });
  }

  const message = err.message.toLowerCase();
  let statusCode = 500;
  let errorMessage = 'Internal server error';

  if (message.includes('invalid credentials') || message.includes('unauthorized')) {
    statusCode = 401;
    errorMessage = 'Invalid credentials';
  } else if (message.includes('not found')) {
    statusCode = 404;
    errorMessage = err.message;
  } else if (message.includes('already exists') || message.includes('duplicate') || message.includes('unique constraint')) {
    statusCode = 409;
    errorMessage = err.message;
  } else if (message.includes('not authorized') || message.includes('forbidden') || message.includes('unauthorized')) {
    statusCode = 403;
    errorMessage = 'Not authorized';
  } else if (message.includes('deactivated') || message.includes('inactive')) {
    statusCode = 403;
    errorMessage = 'Account is deactivated';
  } else if (message.includes('validation') || message.includes('invalid')) {
    statusCode = 400;
    errorMessage = err.message;
  }

  return res.status(statusCode).json({
    success: false,
    message: errorMessage,
  });
};