import crypto from "crypto";

export function generateVerificationCode(): string {
  return crypto.randomInt(100000, 999999).toString();
}