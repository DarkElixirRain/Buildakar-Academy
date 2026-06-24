import { Request, Response, NextFunction } from 'express';
import authService from '../services/auth.services';
import { schemas } from '../utils/validation';

export class AuthController {
  async register(req: Request, res: Response, next: NextFunction) {
    try {
      // The validation is already done by middleware, but we can still use it here
      const validatedData = schemas.register.parse(req.body);
      
      const result = await authService.register(validatedData);

      res.status(201).json({
        success: true,
        message: 'Registration successful',
        data: result,
      });
    } catch (error) {
      next(error);
    }
  }

  async login(req: Request, res: Response, next: NextFunction) {
    try {
      // The validation is already done by middleware
      const validatedData = schemas.login.parse(req.body);
      
      const result = await authService.login(validatedData);

      res.status(200).json({
        success: true,
        message: 'Login successful',
        data: result,
      });
    } catch (error) {
      next(error);
    }
  }

  async getMe(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.user?.id;
      
      if (!userId) {
        return res.status(401).json({
          success: false,
          message: 'User not authenticated',
        });
      }

      const user = await authService.getMe(userId);
      
      res.status(200).json({
        success: true,
        data: user,
      });
    } catch (error) {
      next(error);
    }
  }
}

export default new AuthController();