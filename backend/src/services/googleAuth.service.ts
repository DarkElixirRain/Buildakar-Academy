import { prisma } from '../lib/prisma';
import { config } from '../config';
import {
  generateTokenPair,
  hashRefreshToken,
  AccessTokenPayload,
} from '../utils/jwt.utils';
import { hashPassword } from '../utils/password.utils';

interface GoogleTokenResponse {
  access_token: string;
  expires_in: number;
  refresh_token?: string;
  scope: string;
  token_type: string;
  id_token?: string;
}

interface GoogleProfile {
  id: string;
  email: string;
  name?: string;
  given_name?: string;
  family_name?: string;
}

const createOrLinkUser = async (profile: GoogleProfile) => {
  const { email } = profile;
  const firstName: string = profile.given_name || (profile.name ? profile.name.split(' ')[0] : '');
  const lastName: string = profile.family_name || (profile.name ? profile.name.split(' ').slice(1).join(' ') : '');

  let user = await prisma.user.findFirst({
    where: {
      OR: [{ googleId: profile.id }, { email }],
    },
  });

  if (!user) {
    const randomPassword = Math.random().toString(36).slice(-12) + Date.now();
    const hashed = await hashPassword(randomPassword);

    user = await prisma.user.create({
      data: {
        email,
        password: hashed,
        firstName: firstName || 'Google',
        lastName: lastName || 'User',
        googleId: profile.id,
        authProvider: 'GOOGLE',
        isVerified: true,
      },
    });
  } else {
    if (!user.isActive) {
      throw new Error('Account is deactivated');
    }
    const updates: any = {};
    if (!user.firstName && firstName) updates.firstName = firstName;
    if (!user.lastName && lastName) updates.lastName = lastName;
    if (!user.googleId) updates.googleId = profile.id;
    if (user.authProvider !== 'GOOGLE') updates.authProvider = 'GOOGLE';
    if (!user.isVerified) updates.isVerified = true;
    if (Object.keys(updates).length > 0) {
      user = await prisma.user.update({ where: { id: user.id }, data: updates });
    }
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

  const { password: _pw, ...userWithoutPassword } = user;

  return {
    user: userWithoutPassword,
    ...tokens,
  };
};

export const handleGoogleAuth = async (params: {
  code: string;
  codeVerifier?: string | null;
  redirectUri?: string;
}) => {
  const { code, codeVerifier, redirectUri } = params;

  const tokenUrl = 'https://oauth2.googleapis.com/token';

  const body = new URLSearchParams({
    code,
    client_id: config.google.clientId,
    grant_type: 'authorization_code',
  });

  if (redirectUri) body.append('redirect_uri', redirectUri);
  if (codeVerifier) body.append('code_verifier', codeVerifier);
  if (config.google.clientSecret) body.append('client_secret', config.google.clientSecret);

  const tokenRes = await fetch(tokenUrl, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: body.toString(),
  });

  if (!tokenRes.ok) {
    const text = await tokenRes.text();
    throw new Error(`Failed to exchange code for tokens: ${text}`);
  }

  const tokenData = (await tokenRes.json()) as GoogleTokenResponse;

  const userInfoRes = await fetch('https://www.googleapis.com/oauth2/v2/userinfo', {
    headers: {
      Authorization: `Bearer ${tokenData.access_token}`,
    },
  });

  if (!userInfoRes.ok) {
    const text = await userInfoRes.text();
    throw new Error(`Failed to fetch Google user profile: ${text}`);
  }

  const profile = (await userInfoRes.json()) as GoogleProfile;

  return createOrLinkUser(profile);
};

export const handleGoogleIdToken = async (params: {
  idToken: string;
}) => {
  const { idToken } = params;

  // Validate the ID token using Google's token info endpoint
  const verifyRes = await fetch(
    `https://oauth2.googleapis.com/tokeninfo?id_token=${idToken}`
  );

  if (!verifyRes.ok) {
    const text = await verifyRes.text();
    throw new Error(`Failed to verify Google ID token: ${text}`);
  }

  const payload = await verifyRes.json() as {
    sub: string;
    email: string;
    name?: string;
    given_name?: string;
    family_name?: string;
    email_verified?: string;
  };

  if (!payload.email) {
    throw new Error('Google account has no email');
  }

  const profile: GoogleProfile = {
    id: payload.sub,
    email: payload.email,
    name: payload.name,
    given_name: payload.given_name,
    family_name: payload.family_name,
  };

  return createOrLinkUser(profile);
};

export default { handleGoogleAuth, handleGoogleIdToken };
