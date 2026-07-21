import { prisma } from '../lib/prisma';
import { hashPassword, comparePassword } from '../utils/password.utils';
import {
  generateTokenPair,
  hashRefreshToken,
  AccessTokenPayload,
} from '../utils/jwt.utils';

interface RegisterData {
  email: string;
  password: string;
  firstName: string;
  lastName: string;
  role?: 'STUDENT' | 'INSTRUCTOR';
}

interface LoginData {
  email: string;
  password: string;
}

interface UpdateRoleData {
  userId: string;
  role: 'STUDENT' | 'INSTRUCTOR';
}

export class AuthService {
  async register(data: RegisterData) {
    const { email, password, firstName, lastName, role = 'STUDENT' } = data;

    const existingUser = await prisma.user.findUnique({
      where: { email },
    });

    if (existingUser) {
      throw new Error('User already exists with this email');
    }

    const hashedPassword = await hashPassword(password);

    const user = await prisma.user.create({
      data: {
        email,
        password: hashedPassword,
        firstName,
        lastName,
        role,
      },
    });

    const payload: AccessTokenPayload = {
      userId: user.id,
      email: user.email,
      role: user.role,
    };

    const tokens = generateTokenPair(payload);

    await prisma.refreshToken.create({
      data: {
        tokenHash: hashRefreshToken(tokens.refreshToken),
        userId: user.id,
        expiresAt: tokens.refreshTokenExpiresAt,
      },
    });

    const { password: _, ...userWithoutPassword } = user;

    return {
      user: userWithoutPassword,
      ...tokens,
    };
  }

  async login(data: LoginData) {
    const { email, password } = data;

    const user = await prisma.user.findUnique({
      where: { email },
    });

    if (!user) {
      throw new Error('Invalid credentials');
    }

    if (!user.isActive) {
      throw new Error('Account is deactivated');
    }

    const isPasswordValid = await comparePassword(
      password,
      user.password,
    );

    if (!isPasswordValid) {
      throw new Error('Invalid credentials');
    }

    const payload: AccessTokenPayload = {
      userId: user.id,
      email: user.email,
      role: user.role,
    };

    const tokens = generateTokenPair(payload);

    await prisma.refreshToken.deleteMany({
      where: {
        userId: user.id,
      },
    });

    await prisma.refreshToken.create({
      data: {
        tokenHash: hashRefreshToken(tokens.refreshToken),
        userId: user.id,
        expiresAt: tokens.refreshTokenExpiresAt,
      },
    });

    const { password: _, ...userWithoutPassword } = user;

    return {
      user: userWithoutPassword,
      ...tokens,
    };
  }

  async refresh(refreshToken: string) {
    const tokenHash = hashRefreshToken(refreshToken);

    const storedToken = await prisma.refreshToken.findUnique({
      where: {
        tokenHash,
      },
      include: {
        user: true,
      },
    });

    if (!storedToken) {
      throw new Error('Invalid refresh token');
    }

    if (storedToken.expiresAt < new Date()) {
      await prisma.refreshToken.delete({
        where: {
          id: storedToken.id,
        },
      });

      throw new Error('Refresh token expired');
    }

    if (!storedToken.user.isActive) {
      throw new Error('Account is deactivated');
    }

    const payload: AccessTokenPayload = {
      userId: storedToken.user.id,
      email: storedToken.user.email,
      role: storedToken.user.role,
    };

    const tokens = generateTokenPair(payload);

    // Rotate refresh token
    await prisma.$transaction([
      prisma.refreshToken.delete({
        where: {
          id: storedToken.id,
        },
      }),
      prisma.refreshToken.create({
        data: {
          tokenHash: hashRefreshToken(tokens.refreshToken),
          userId: storedToken.user.id,
          expiresAt: tokens.refreshTokenExpiresAt,
        },
      }),
    ]);

    return tokens;
  }

  async logout(refreshToken: string) {
    const tokenHash = hashRefreshToken(refreshToken);

    await prisma.refreshToken.deleteMany({
      where: {
        tokenHash,
      },
    });

    return {
      success: true,
    };
  }

  async getMe(userId: string) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        email: true,
        firstName: true,
        lastName: true,
        role: true,
        isVerified: true,
        isActive: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    if (!user) {
      throw new Error('User not found');
    }

    return user;
  }

  async updateRole(data: UpdateRoleData) {
    const { userId, role } = data;

    const user = await prisma.user.update({
      where: {
        id: userId,
      },
      data: {
        role,
        hasCompletedOnboarding: true,
      },
      select: {
        id: true,
        email: true,
        firstName: true,
        lastName: true,
        role: true,
        isVerified: true,
        isActive: true,
        hasCompletedOnboarding: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    return user;
  }
}

export default new AuthService();