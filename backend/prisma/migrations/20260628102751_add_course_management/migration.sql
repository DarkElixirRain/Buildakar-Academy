-- CreateEnum
CREATE TYPE "CourseStatus" AS ENUM ('DRAFT', 'UNDER_REVIEW', 'PUBLISHED');

-- AlterTable
ALTER TABLE "Course" ADD COLUMN     "status" "CourseStatus" NOT NULL DEFAULT 'DRAFT';

-- AlterTable
ALTER TABLE "Lesson" ADD COLUMN     "sectionId" TEXT;

-- CreateTable
CREATE TABLE "Section" (
    "id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "order" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "courseId" TEXT NOT NULL,

    CONSTRAINT "Section_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "Section_courseId_idx" ON "Section"("courseId");

-- CreateIndex
CREATE INDEX "Section_order_idx" ON "Section"("order");

-- AddForeignKey
ALTER TABLE "Section" ADD CONSTRAINT "Section_courseId_fkey" FOREIGN KEY ("courseId") REFERENCES "Course"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Lesson" ADD CONSTRAINT "Lesson_sectionId_fkey" FOREIGN KEY ("sectionId") REFERENCES "Section"("id") ON DELETE SET NULL ON UPDATE CASCADE;
