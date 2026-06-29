-- CreateEnum
CREATE TYPE "InstructorAnalyticsPeriod" AS ENUM ('DAY', 'WEEK', 'MONTH', 'YEAR');

-- AlterTable
ALTER TABLE "User" ADD COLUMN     "averageRating" DOUBLE PRECISION NOT NULL DEFAULT 0,
ADD COLUMN     "bio" TEXT,
ADD COLUMN     "expertise" TEXT,
ADD COLUMN     "isVerifiedInstructor" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "payoutMethod" TEXT,
ADD COLUMN     "photo" TEXT,
ADD COLUMN     "socialLinks" JSONB,
ADD COLUMN     "stripeAccountId" TEXT,
ADD COLUMN     "title" TEXT,
ADD COLUMN     "totalCourses" INTEGER NOT NULL DEFAULT 0,
ADD COLUMN     "totalRevenue" DOUBLE PRECISION NOT NULL DEFAULT 0,
ADD COLUMN     "totalReviews" INTEGER NOT NULL DEFAULT 0,
ADD COLUMN     "totalStudents" INTEGER NOT NULL DEFAULT 0;

-- CreateTable
CREATE TABLE "InstructorFollow" (
    "id" TEXT NOT NULL,
    "followerId" TEXT NOT NULL,
    "instructorId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "InstructorFollow_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "InstructorAnalytics" (
    "id" TEXT NOT NULL,
    "instructorId" TEXT NOT NULL,
    "period" "InstructorAnalyticsPeriod" NOT NULL,
    "date" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "coursesSold" INTEGER NOT NULL DEFAULT 0,
    "revenue" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "studentsEnrolled" INTEGER NOT NULL DEFAULT 0,
    "courseViews" INTEGER NOT NULL DEFAULT 0,
    "avgWatchTime" DOUBLE PRECISION,
    "completionRate" DOUBLE PRECISION,

    CONSTRAINT "InstructorAnalytics_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "InstructorFollow_instructorId_idx" ON "InstructorFollow"("instructorId");

-- CreateIndex
CREATE INDEX "InstructorFollow_followerId_idx" ON "InstructorFollow"("followerId");

-- CreateIndex
CREATE UNIQUE INDEX "InstructorFollow_followerId_instructorId_key" ON "InstructorFollow"("followerId", "instructorId");

-- CreateIndex
CREATE INDEX "InstructorAnalytics_instructorId_idx" ON "InstructorAnalytics"("instructorId");

-- CreateIndex
CREATE INDEX "InstructorAnalytics_date_idx" ON "InstructorAnalytics"("date");

-- CreateIndex
CREATE UNIQUE INDEX "InstructorAnalytics_instructorId_period_date_key" ON "InstructorAnalytics"("instructorId", "period", "date");

-- AddForeignKey
ALTER TABLE "InstructorFollow" ADD CONSTRAINT "InstructorFollow_followerId_fkey" FOREIGN KEY ("followerId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "InstructorFollow" ADD CONSTRAINT "InstructorFollow_instructorId_fkey" FOREIGN KEY ("instructorId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "InstructorAnalytics" ADD CONSTRAINT "InstructorAnalytics_instructorId_fkey" FOREIGN KEY ("instructorId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
