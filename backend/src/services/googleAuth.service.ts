import { PrismaClient } from '@prisma/client';
import { config } from '../config';
import { generateToken, TokenPayload } from '../utils/jwt.utils';
import { hashPassword } from '../utils/password.utils';

const prisma = new PrismaClient();

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

/**
 * Exchanges Google authorization code for tokens, fetches profile,
 * creates or links a local user, and returns the same shape as existing login.
 */
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

  // Fetch user profile
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

  const email: string = profile.email;
  const firstName: string = profile.given_name || (profile.name ? profile.name.split(' ')[0] : '');
  const lastName: string = profile.family_name || (profile.name ? profile.name.split(' ').slice(1).join(' ') : '');

  // Prefer provider id lookup first, then email fallback for linking existing accounts.
  let user = await prisma.user.findFirst({
    where: {
      OR: [{ googleId: profile.id }, { email }],
    },
  });

  if (!user) {
    // Create a new user. Password is required in existing schema, so create a random one.
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
    // Existing user: ensure active
    if (!user.isActive) {
      throw new Error('Account is deactivated');
    }
    // Optionally update name fields if empty
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

  // Generate our JWT using existing util
  const payload: TokenPayload = {
    userId: user.id,
    email: user.email,
    role: user.role,
  };

  const token = generateToken(payload);

  // Return user without password
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  const { password: _pw, ...userWithoutPassword } = user as any;

  return { user: userWithoutPassword, token };
};

export default { handleGoogleAuth };
