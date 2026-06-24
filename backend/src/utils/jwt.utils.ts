import jwt, { Secret, SignOptions } from 'jsonwebtoken';
import { config } from '../config';

export interface TokenPayload {
  userId: string;
  email: string;
  role: string;
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