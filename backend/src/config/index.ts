import dotenv from 'dotenv';
import { z } from 'zod';

dotenv.config();

const envSchema = z.object({
  PORT: z.coerce.number().default(3000),
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  DATABASE_URL: z.string().min(1, 'DATABASE_URL is required'),
  JWT_SECRET: z.string().min(1, 'JWT_SECRET is required'),
  JWT_EXPIRES_IN: z.string().default('7d'),
  GOOGLE_CLIENT_ID: z.string().default(''),
  GOOGLE_CLIENT_SECRET: z.string().default(''),
  FRONTEND_URL: z.string().default('http://localhost:8081'),
});

const parsed = envSchema.safeParse(process.env);

if (!parsed.success) {
  console.error('\x1b[31m❌ Invalid environment variables:\x1b[0m');
  const errors = parsed.error.flatten().fieldErrors;
  for (const [key, msgs] of Object.entries(errors)) {
    console.error(`  \x1b[31m• ${key}: ${msgs?.join(', ')}\x1b[0m`);
  }
  process.exit(1);
}

export const config = {
  port: parsed.data.PORT,
  nodeEnv: parsed.data.NODE_ENV,
  jwt: {
    secret: parsed.data.JWT_SECRET,
    expiresIn: parsed.data.JWT_EXPIRES_IN,
  },
  google: {
    clientId: parsed.data.GOOGLE_CLIENT_ID,
    clientSecret: parsed.data.GOOGLE_CLIENT_SECRET,
  },
  frontendUrl: parsed.data.FRONTEND_URL,
  isDevelopment: parsed.data.NODE_ENV === 'development',
  isProduction: parsed.data.NODE_ENV === 'production',
  databaseUrl: parsed.data.DATABASE_URL,
};
