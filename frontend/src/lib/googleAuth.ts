import * as AuthSession from 'expo-auth-session';
import * as WebBrowser from 'expo-web-browser';

WebBrowser.maybeCompleteAuthSession();

const CLIENT_ID =
  process.env.EXPO_PUBLIC_GOOGLE_CLIENT_ID ||
  '743824025812-73jkos8mjp03muupgkuj9h24p4chh7hk.apps.googleusercontent.com';

// Use Expo proxy for stable redirect URI that works across platforms
const REDIRECT_URI = AuthSession.makeRedirectUri({
  preferLocalhost: false,
});

console.log('[Google Auth] Using redirect URI:', REDIRECT_URI);

const GOOGLE_DISCOVERY = {
  authorizationEndpoint: 'https://accounts.google.com/o/oauth2/v2/auth',
  tokenEndpoint: 'https://oauth2.googleapis.com/token',
  revocationEndpoint: 'https://oauth2.googleapis.com/revoke',
};

export const signInWithGoogle = async () => {
  if (!CLIENT_ID) throw new Error('Missing EXPO_PUBLIC_GOOGLE_CLIENT_ID');

  const request = new AuthSession.AuthRequest({
    clientId: CLIENT_ID,
    responseType: AuthSession.ResponseType.Code,
    scopes: ['openid', 'profile', 'email'],
    usePKCE: true,
    redirectUri: REDIRECT_URI,
    extraParams: {
      access_type: 'offline',
      prompt: 'consent',
    },
  });

  await request.makeAuthUrlAsync(GOOGLE_DISCOVERY);
  const result = await request.promptAsync(GOOGLE_DISCOVERY);

  if (result.type === 'success' && result.params?.code) {
    return {
      code: result.params.code,
      codeVerifier: request.codeVerifier,
      redirectUri: REDIRECT_URI,
    };
  }

  throw new Error('Google sign-in cancelled or failed');
};

export default { signInWithGoogle };
