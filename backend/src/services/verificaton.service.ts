
import { prisma } from '../lib/prisma';
import { generateVerificationCode } from "../utils/generateVerificationCode";
import { hashCode, compareCode } from "../utils/hash";
import { sendVerificationEmail } from "./email.service";

export async function sendVerificationCode(email: string) {
  const pending = await prisma.pendingRegistration.findUnique({ where: { email } });
  if (!pending) {
    throw new Error('No pending registration found for this email');
  }

  const code = generateVerificationCode();
  const codeHash = await hashCode(code);
  const expiresInMinutes = Number(process.env.VERIFICATION_CODE_EXPIRES_MINUTES ?? 10);
  const expiresAt = new Date(Date.now() + expiresInMinutes * 60 * 1000);

  await prisma.pendingRegistration.update({
    where: { email },
    data: { codeHash, expiresAt },
  });

  await sendVerificationEmail(email, code);
}

export async function verifyverificationCode(
  email: string,
  code: string  
) {
  const pending = await prisma.pendingRegistration.findUnique({
    where: { email },
  });

  if (!pending) {
    throw new Error('Verification code not found.');
  }

  if (pending.expiresAt < new Date()) {
    throw new Error('Verification code has expired.');
  }

  const isValid = await compareCode(code, pending.codeHash);

  if (!isValid) {
    throw new Error('Invalid verification code.');
  }

  await prisma.$transaction([
    prisma.user.create({
      data: {
        email: pending.email,
        password: pending.passwordHash,
        firstName: pending.firstName,
        lastName: pending.lastName,
        role: pending.role as any,
        isVerified: true,
      },
    }),
    prisma.pendingRegistration.delete({
      where: { email },
    }),
  ]);

  return true;
}
