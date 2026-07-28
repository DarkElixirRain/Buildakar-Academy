import { Request, Response, NextFunction } from 'express';
import authService from '../services/auth.services';
import { schemas } from '../utils/validation';
import { sendVerificationCode, verifyverificationCode } from '../services/verificaton.service';
import { sendVerificationEmail } from '../services/email.service';
import { prisma } from '../lib/prisma';
import { hashPassword } from '../utils/password.utils';
import { hashCode } from '../utils/hash';
import { generateVerificationCode } from '../utils/generateVerificationCode';

export class AuthController {
  async register(req: Request, res: Response, next: NextFunction) {
    try {
      const { email, password, firstName, lastName, role } = schemas.register.parse(req.body);

      const existingUser = await prisma.user.findUnique({ where: { email } });
      if (existingUser) {
        throw new Error('User already exists with this email');
      }

      const passwordHash = await hashPassword(password);
      const code = generateVerificationCode();
      const codeHash = await hashCode(code);
      const expiresInMinutes = Number(process.env.VERIFICATION_CODE_EXPIRES_MINUTES ?? 10);
      const expiresAt = new Date(Date.now() + expiresInMinutes * 60 * 1000);

      await prisma.pendingRegistration.upsert({
        where: { email },
        update: { firstName, lastName, passwordHash, role: role ?? 'STUDENT', codeHash, expiresAt },
        create: { email, firstName, lastName, passwordHash, role: role ?? 'STUDENT', codeHash, expiresAt },
      });

      await sendVerificationEmail(email, code);

      res.status(201).json({
        success: true,
        message: 'Registration successful. Please check your email for the verification code.',
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

      const isProduction = process.env.NODE_ENV === 'production';

      res.cookie('refreshToken', result.refreshToken, {
        httpOnly: true,
        secure: isProduction,
        sameSite: isProduction ? 'none' : 'lax',
        expires: result.refreshTokenExpiresAt,
      });

      res.status(200).json({
        success: true,
        message: 'Login successful',
        data: {
          user: result.user,
          accessToken: result.accessToken,
          accessTokenExpiresAt: result.accessTokenExpiresAt,
          refreshToken: result.refreshToken,
          refreshTokenExpiresAt: result.refreshTokenExpiresAt,
        },
      });
    } catch (error) {
      next(error);
    }
  }

  async refresh(req: Request, res: Response, next: NextFunction) {
    try {
      const refreshToken = req.cookies?.refreshToken || req.body?.refreshToken;

      if (!refreshToken) {
        return res.status(401).json({
          success: false,
          message: 'Refresh token is missing.',
        });
      }

      const result = await authService.refresh(refreshToken);

      const isProduction = process.env.NODE_ENV === 'production';

      res.cookie('refreshToken', result.refreshToken, {
        httpOnly: true,
        secure: isProduction,
        sameSite: isProduction ? 'none' : 'lax',
        expires: result.refreshTokenExpiresAt,
      });

      res.status(200).json({
        success: true,
        message: 'Token refreshed successfully.',
        data: {
          accessToken: result.accessToken,
          accessTokenExpiresAt: result.accessTokenExpiresAt,
          refreshToken: result.refreshToken,
          refreshTokenExpiresAt: result.refreshTokenExpiresAt,
        },
      });
    } catch (error) {
      next(error);
    }
  }

  async logout(req: Request, res: Response, next: NextFunction) {
    try {
      const refreshToken = req.cookies?.refreshToken || req.body?.refreshToken;

      if (refreshToken) {
        await authService.logout(refreshToken);
      }

      const isProduction = process.env.NODE_ENV === 'production';

      res.clearCookie('refreshToken', {
        httpOnly: true,
        secure: isProduction,
        sameSite: isProduction ? 'none' : 'lax',
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