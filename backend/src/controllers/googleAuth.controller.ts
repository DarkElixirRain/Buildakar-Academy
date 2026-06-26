import { Request, Response, NextFunction } from 'express';
import googleAuthService from '../services/googleAuth.service';

export class GoogleAuthController {
  async googleAuth(req: Request, res: Response, next: NextFunction) {
    try {
      const { code, codeVerifier, redirectUri } = req.body;

      if (!code) {
        return res.status(400).json({ success: false, message: 'Authorization code is required' });
      }

      const result = await googleAuthService.handleGoogleAuth({ code, codeVerifier, redirectUri });

      res.status(200).json({
        success: true,
        message: 'Login successful',
        data: result,
      });
    } catch (error) {
      next(error);
    }
  }
}

export default new GoogleAuthController();
