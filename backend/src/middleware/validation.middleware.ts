// middleware/validation.middleware.ts
import { Request, Response, NextFunction } from 'express';
import { ZodSchema, ZodError } from 'zod';

type ValidationSource = 'body' | 'params' | 'query';

export const validate = (schema: ZodSchema, source: ValidationSource = 'body') => {
  return async (req: Request, res: Response, next: NextFunction) => {
    try {
      const data = req[source];

      // LOG: What's being validated
      console.log(`📥 [Validation] Source: ${source}`);
      console.log(`📥 [Validation] Data:`, JSON.stringify(data, null, 2));
      if (source === 'body') {
        console.log('📥 [Validation] Content-Type:', req.headers['content-type']);
      }

      const parsed = await schema.parseAsync(data);

      // Replace with the parsed (and defaulted/coerced) data so downstream
      // handlers get consistent types (e.g. paginationSchema's z.coerce.number())
      (req[source] as any) = parsed;

      console.log('✅ [Validation] Validation passed');
      next();
    } catch (error) {
      if (error instanceof ZodError) {
        const data = req[source];
        console.error('❌ [Validation] Validation failed:', error.issues);
        console.error(`📦 [Validation] Received ${source}:`, data);

        return res.status(400).json({
          success: false,
          message: 'Validation failed',
          errors: error.issues.map((err: any) => ({
            field: err.path.join('.'),
            message: err.message,
            received: err.path.length > 0 ? (data as any)?.[err.path[0]] : undefined,
          })),
          receivedBody: data,
        });
      }
      next(error);
    }
  };
};