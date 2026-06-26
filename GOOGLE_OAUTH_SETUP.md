# Google OAuth 2.0 Setup Guide

This guide explains how to configure Google OAuth 2.0 for Buildakar Academy (both web and mobile).

## Prerequisites

- Google Cloud Console project created
- OAuth 2.0 Client ID generated (Web Application type)

## Step 1: Get Your Client ID

Your current Google OAuth Client ID is:
```
743824025812-73jkos8mjp03muupgkuj9h24p4chh7hk.apps.googleusercontent.com
```

This is already configured in `frontend/.env`.

## Step 2: Configure Redirect URIs in Google Cloud Console

You need to register the following redirect URIs in your Google Cloud Console OAuth app settings:

### For Development (Expo Go with Proxy)

When you run the app with Expo, it will use this proxy redirect URI:
```
https://auth.expo.io/@sujib/buildakar-academy/callback
```

**How to find the exact URI:**
1. Run the frontend: `npm run start` from `frontend/`
2. Open the app in Expo Go
3. Attempt Google sign-in and check the console for:
   ```
   [Google Auth] Using redirect URI: https://auth.expo.io/@...
   ```
4. Copy the full URI shown and register it in Google Cloud Console

### For Production (Standalone App)

When you build a standalone APK/IPA, configure:
```
com.buildakar.academy://oauth-callback
```

## Step 3: Register Redirect URIs

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project
3. Navigate to **APIs & Services** → **Credentials**
4. Click your OAuth 2.0 Client ID (Web Application)
5. Under **Authorized redirect URIs**, add:
   - `https://auth.expo.io/@sujib/buildakar-academy/callback` (Development)
   - `com.buildakar.academy://oauth-callback` (Production - if using standalone)
6. Save

## Step 4: Backend Configuration

Ensure your backend `.env` has:

```env
GOOGLE_CLIENT_ID=743824025812-73jkos8mjp03muupgkuj9h24p4chh7hk.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=your-client-secret-here
```

The backend needs the client secret to exchange the authorization code for tokens.

## Step 5: Test the Flow

1. Backend running: `npm run dev` from `backend/`
2. Frontend running: `npm run start` from `frontend/`
3. Go to Login screen
4. Tap "Continue with Google"
5. You should be redirected to Google's consent screen
6. After signing in, you should be logged into the app

## Troubleshooting

### Error: `redirect_uri_mismatch`

This means the redirect URI the app is sending doesn't match Google Cloud Console.

**Solution:**
1. Check the console log for `[Google Auth] Using redirect URI: ...`
2. Make sure that exact URI is registered in Google Cloud Console
3. Clear browser cache and try again
4. If using Android emulator, make sure you're using the proxy redirect (not a custom scheme)

### Error: `invalid_client`

Client ID is incorrect or doesn't exist.

**Solution:**
- Verify the client ID in `frontend/.env` matches Google Cloud Console
- Ensure it's a **Web Application** type credential, not Android/iOS native

### Error: `invalid_scope`

Requested scopes are not allowed.

**Solution:**
- The app requests: `openid`, `profile`, `email`
- These should be available by default in Google Cloud

### Token not working after exchange

Backend is not exchanging code correctly.

**Solution:**
1. Check `GOOGLE_CLIENT_SECRET` is set in backend `.env`
2. Verify both `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET` match Google Cloud Console
3. Check backend logs for token exchange errors
4. The `redirectUri` sent from frontend must match what was used in the initial request

## Security Notes

- `GOOGLE_CLIENT_SECRET` must only be in backend `.env`, never in frontend
- The frontend only sends the authorization code to your backend
- Your backend exchanges the code for Google tokens (never exposed to frontend)
- Your backend then returns your app's JWT token to the frontend
- The frontend uses the JWT token for all subsequent requests

## Database Migration

After configuring Google OAuth, run the Prisma migration:

```bash
cd backend
npm run prisma:migrate
```

This adds OAuth fields (`authProvider`, `googleId`) to the User table, enabling account linking.
