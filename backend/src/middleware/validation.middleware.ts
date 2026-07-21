import { Request, Response, NextFunction } from 'express';
import { ZodSchema, ZodError } from 'zod';
import { logger } from '../utils/logger';

type ValidationSource = 'body' | 'params' | 'query';

export const validate = (schema: ZodSchema, source: ValidationSource = 'body') => {
  return async (req: Request, res: Response, next: NextFunction) => {
    try {
      const data = req[source];

      logger.debug(`Validating ${source}`);

      const parsed = await schema.parseAsync(data);

      (req[source] as any) = parsed;

      logger.debug(`Validation passed for ${source}`);
      next();
    } catch (error) {
      if (error instanceof ZodError) {
        logger.warn(`Validation failed for ${source}:`, {
          fields: error.issues.map(err => err.path.join('.')),
          errors: error.issues.map(err => ({
            field: err.path.join('.'),
            message: err.message,
          })),
        });

        return res.status(400).json({
          success: false,
          message: 'Validation failed',
          errors: error.issues.map(err => ({
            field: err.path.join('.'),
            message: err.message,
          })),
        });
      }
      next(error);
    }
  };
};
