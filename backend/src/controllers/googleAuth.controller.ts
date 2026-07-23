import { Request, Response, NextFunction } from 'express';
import googleAuthService from '../services/googleAuth.service';

export class GoogleAuthController {
  async googleAuth(req: Request, res: Response, next: NextFunction) {
    try {
      const { code, idToken, codeVerifier, redirectUri } = req.body;

      let result;

      if (idToken) {
        result = await googleAuthService.handleGoogleIdToken({ idToken });
      } else if (code) {
        result = await googleAuthService.handleGoogleAuth({
          code,
          codeVerifier,
          redirectUri,
        });
      } else {
        return res.status(400).json({
          success: false,
          message: 'Authorization code or ID token is required',
        });
      }

      // Store refresh token in HttpOnly cookie
      res.cookie('refreshToken', result.refreshToken, {
        httpOnly: true,
        secure: process.env.NODE_ENV === 'production',
        sameSite: 'strict',
        expires: result.refreshTokenExpiresAt,
      });

      res.status(200).json({
        success: true,
        message: 'Google login successful',
        data: {
          user: result.user,
          accessToken: result.accessToken,
          accessTokenExpiresAt: result.accessTokenExpiresAt,
        },
      });
    } catch (error) {
      next(error);
    }
  }
}

export default new GoogleAuthController();