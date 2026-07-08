/*
  Warnings:

  - You are about to drop the `live_class_participants` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `live_classes` table. If the table is not empty, all the data it contains will be lost.

*/
-- DropForeignKey
ALTER TABLE "live_class_participants" DROP CONSTRAINT "live_class_participants_liveClassId_fkey";

-- DropForeignKey
ALTER TABLE "live_class_participants" DROP CONSTRAINT "live_class_participants_userId_fkey";

-- DropForeignKey
ALTER TABLE "live_classes" DROP CONSTRAINT "live_classes_courseId_fkey";

-- DropForeignKey
ALTER TABLE "live_classes" DROP CONSTRAINT "live_classes_instructorId_fkey";

-- DropTable
DROP TABLE "live_class_participants";

-- DropTable
DROP TABLE "live_classes";

-- DropEnum
DROP TYPE "LiveClassStatus";
