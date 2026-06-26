// middleware/validation.middleware.ts
import { Request, Response, NextFunction } from 'express';
import { ZodSchema, ZodError } from 'zod';

export const validate = (schema: ZodSchema) => {
  return async (req: Request, res: Response, next: NextFunction) => {
    try {
      // LOG: What's being sent
      console.log('📥 [Validation] Request body:', JSON.stringify(req.body, null, 2));
      console.log('📥 [Validation] Content-Type:', req.headers['content-type']);
      console.log('📥 [Validation] Fields received:', Object.keys(req.body));
      
      await schema.parseAsync(req.body);
      
      console.log('✅ [Validation] Validation passed');
      next();
    } catch (error) {
      if (error instanceof ZodError) {
        console.error('❌ [Validation] Validation failed:', error.issues);
        
        // LOG: What was actually sent
        console.error('📦 [Validation] Received data:', req.body);
        
        return res.status(400).json({
          success: false,
          message: 'Validation failed',
          errors: error.issues.map((err: any) => ({
            field: err.path.join('.'),
            message: err.message,
            // Add what was received for debugging
            received: err.path.length > 0 ? req.body[err.path[0]] : undefined,
          })),
          // Add this for debugging
          receivedBody: req.body,
        });
      }
      next(error);
    }
  };
};