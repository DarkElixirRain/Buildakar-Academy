
import { prisma } from '../lib/prisma';
import { generateVerificationCode } from "../utils/generateVerificationCode";
import { hashCode, compareCode } from "../utils/hash";
import { sendVerificationEmail } from "./email.service";

export async function sendVerificationCode(email: string) {
  // Delete any existing code
  await prisma.emailVerification.deleteMany({
    where: { email },
  });

  // Generate new code
  const code = generateVerificationCode();
  const codeHash = await hashCode(code);

  // Set expiration
  const expiresInMinutes = Number(
  process.env.VERIFICATION_CODE_EXPIRES_MINUTES ?? 10
);

const expiresAt = new Date(
  Date.now() + expiresInMinutes * 60 * 1000
);

  // Save the new code
  await prisma.emailVerification.create({
    data: {
      email,
      codeHash,
      expiresAt,
    },
  });

  // Send email
  await sendVerificationEmail(email, code);
}

export async function verifyverificationCode(
  email: string,
  code: string  
) {
  const verification = await prisma.emailVerification.findFirst({
    where: { email },
    orderBy: {
      createdAt: "desc",
    },
  });

  if (!verification) {
    throw new Error("Verification code not found.");
  }

  if (verification.expiresAt < new Date()) {
    throw new Error("Verification code has expired.");
  }

  const isValid = await compareCode(code, verification.codeHash);

  if (!isValid) {
    throw new Error("Invalid verification code.");
  }

  await prisma.$transaction([
    prisma.user.update({
      where: { email },
      data: {
        isVerified: true,
      },
    }),
    prisma.emailVerification.deleteMany({
      where: { email },
    }),
  ]);

  return true;
}

