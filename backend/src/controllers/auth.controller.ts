import { Request, Response, NextFunction } from 'express';
import authService from '../services/auth.services';
import { schemas } from '../utils/validation';
import { sendVerificationCode, verifyverificationCode } from '../services/verificaton.service';

export class AuthController {
  async register(req: Request, res: Response, next: NextFunction) {
    try {
      const validatedData = schemas.register.parse(req.body);

      const result = await authService.register(validatedData);

    // Send verification code to the user's email
    await sendVerificationCode(result.user.email);
      

      res.cookie('refreshToken', result.refreshToken, {
        httpOnly: true,
        secure: process.env.NODE_ENV === 'production',
        sameSite: 'strict',
        expires: result.refreshTokenExpiresAt,
      });

      res.status(201).json({
        success: true,
        message: 'Registration successful. Please check your email for the verification code.',
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

  async login(req: Request, res: Response, next: NextFunction) {
    try {
      const validatedData = schemas.login.parse(req.body);

      const result = await authService.login(validatedData);
      if (!result.user.isVerified) {
  throw new Error('Please verify your email before logging in.');
}

      res.cookie('refreshToken', result.refreshToken, {
        httpOnly: true,
        secure: process.env.NODE_ENV === 'production',
        sameSite: 'strict',
        expires: result.refreshTokenExpiresAt,
      });

      res.status(200).json({
        success: true,
        message: 'Login successful',
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

  async refresh(req: Request, res: Response, next: NextFunction) {
    try {
      const refreshToken = req.cookies?.refreshToken;

      if (!refreshToken) {
        return res.status(401).json({
          success: false,
          message: 'Refresh token is missing.',
        });
      }

      const result = await authService.refresh(refreshToken);

      res.cookie('refreshToken', result.refreshToken, {
        httpOnly: true,
        secure: process.env.NODE_ENV === 'production',
        sameSite: 'strict',
        expires: result.refreshTokenExpiresAt,
      });

      res.status(200).json({
        success: true,
        message: 'Token refreshed successfully.',
        data: {
          accessToken: result.accessToken,
          accessTokenExpiresAt: result.accessTokenExpiresAt,
        },
      });
    } catch (error) {
      next(error);
    }
  }

  async logout(req: Request, res: Response, next: NextFunction) {
    try {
      const refreshToken = req.cookies?.refreshToken;

      if (refreshToken) {
        await authService.logout(refreshToken);
      }

      res.clearCookie('refreshToken', {
        httpOnly: true,
        secure: process.env.NODE_ENV === 'production',
        sameSite: 'strict',
      });

      res.status(200).json({
        success: true,
        message: 'Logged out successfully.',
      });
    } catch (error) {
      next(error);
    }
  }

  async getMe(req: Request, res: Response, next: NextFunction) {
    try {
      if (!req.user) {
        return res.status(401).json({
          success: false,
          message: 'User not authenticated.',
        });
      }

      const user = await authService.getMe(req.user.id);

      res.status(200).json({
        success: true,
        data: user,
      });
    } catch (error) {
      next(error);
    }
  }

  async updateRole(req: Request, res: Response, next: NextFunction) {
    try {
      if (!req.user) {
        return res.status(401).json({
          success: false,
          message: 'User not authenticated.',
        });
      }

      const validatedData = schemas.updateRole.parse(req.body);

      const user = await authService.updateRole({
        userId: req.user.id,
        role: validatedData.role,
      });

      res.status(200).json({
        success: true,
        message: 'Role updated successfully.',
        data: user,
      });
    } catch (error) {
      next(error);
    }
  }
  async verifyEmail(
  req: Request,
  res: Response,
  next: NextFunction
) {
  try {
    const { email, code } = schemas.verifyEmail.parse(req.body);

    await verifyverificationCode(email, code);

    res.status(200).json({
      success: true,
      message: "Email verified successfully.",
    });
  } catch (error) {
    next(error);
  }
}

async resendVerification(
  req: Request,
  res: Response,
  next: NextFunction
) {
  try {
    const { email } = schemas.resendVerification.parse(req.body);

    await sendVerificationCode(email);

    res.status(200).json({
      success: true,
      message: "Verification code sent successfully.",
    });
  } catch (error) {
    next(error);
  }
}
  
}

export default new AuthController();