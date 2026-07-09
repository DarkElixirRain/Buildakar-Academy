import jwt, { Secret, SignOptions } from 'jsonwebtoken';
import { config } from '../config';
import crypto from 'crypto'

export interface TokenPayload {
  userId: string;
  email: string;
  role: string;
}
export interface AccessTokenPayload {
  userId: string;
  email: string;
  role: string;
}
 
export interface TokenPair {
  accessToken: string;
  refreshToken: string;
  accessTokenExpiresAt: Date;
  refreshTokenExpiresAt: Date;
}

export const generateToken = (payload: TokenPayload): string => {
  const secret: Secret = config.jwt.secret;

  const options: SignOptions = {
    expiresIn: config.jwt.expiresIn as SignOptions['expiresIn'],
  };

  return jwt.sign(payload, secret, options);
};

export const verifyToken = (token: string): TokenPayload => {
  const secret: Secret = config.jwt.secret;

  return jwt.verify(token, secret) as TokenPayload;
};

export function generateAccessToken(payload: AccessTokenPayload): string {
  const secret = process.env.JWT_ACCESS_SECRET!;
  return jwt.sign(payload, secret, {
    expiresIn: '15m',
    issuer: 'buildakar-academy',
  });
}
 
export function verifyAccessToken(token: string): AccessTokenPayload {
  const secret = process.env.JWT_ACCESS_SECRET!
  return jwt.verify(token, secret, {
    issuer: 'buildakar-academy',
  }) as AccessTokenPayload;
}

export function generateRefreshToken(): string {
  // 64 bytes of randomness → 128 hex chars
  return crypto.randomBytes(64).toString('hex');
}
 
export function hashRefreshToken(token: string): string {
  return crypto.createHash('sha256').update(token).digest('hex');
}
 
export function getRefreshTokenExpiry(): Date {
  const expiry = new Date();
  expiry.setDate(expiry.getDate() + 7); // 7 days
  return expiry;
}

// GENERATE BOTH AT ONCE
export function generateTokenPair(payload: AccessTokenPayload): {
  accessToken: string;
  refreshToken: string;
  accessTokenExpiresAt: Date;
  refreshTokenExpiresAt: Date;
} {
  const accessToken = generateAccessToken(payload);
  const refreshToken = generateRefreshToken();
 
  const accessTokenExpiresAt = new Date(Date.now() + 15 * 60 * 1000); // 15 min
  const refreshTokenExpiresAt = getRefreshTokenExpiry();              // 7 days
 
  return {
    accessToken,
    refreshToken,
    accessTokenExpiresAt,
    refreshTokenExpiresAt,
  };
}