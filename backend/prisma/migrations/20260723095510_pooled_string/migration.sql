-- AlterEnum
ALTER TYPE "CourseStatus" ADD VALUE 'PENDING_APPROVAL';

-- DropForeignKey
ALTER TABLE "live_classes" DROP CONSTRAINT "live_classes_courseId_fkey";

-- AlterTable
ALTER TABLE "live_classes" ALTER COLUMN "courseId" DROP NOT NULL;

-- CreateTable
CREATE TABLE "PendingRegistration" (
    "id" SERIAL NOT NULL,
    "email" TEXT NOT NULL,
    "firstName" TEXT NOT NULL,
    "lastName" TEXT NOT NULL,
    "passwordHash" TEXT NOT NULL,
    "role" TEXT NOT NULL DEFAULT 'STUDENT',
    "codeHash" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PendingRegistration_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "PendingRegistration_email_key" ON "PendingRegistration"("email");

-- CreateIndex
CREATE INDEX "PendingRegistration_email_idx" ON "PendingRegistration"("email");

-- AddForeignKey
ALTER TABLE "live_classes" ADD CONSTRAINT "live_classes_courseId_fkey" FOREIGN KEY ("courseId") REFERENCES "Course"("id") ON DELETE SET NULL ON UPDATE CASCADE;
