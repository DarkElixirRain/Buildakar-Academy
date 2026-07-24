-- CreateTable
CREATE TABLE "InstructorReview" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "instructorId" TEXT NOT NULL,
    "rating" INTEGER NOT NULL,
    "comment" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "InstructorReview_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "InstructorReview_instructorId_idx" ON "InstructorReview"("instructorId");

-- CreateIndex
CREATE INDEX "InstructorReview_userId_idx" ON "InstructorReview"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "InstructorReview_userId_instructorId_key" ON "InstructorReview"("userId", "instructorId");

-- AddForeignKey
ALTER TABLE "InstructorReview" ADD CONSTRAINT "InstructorReview_instructorId_fkey" FOREIGN KEY ("instructorId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "InstructorReview" ADD CONSTRAINT "InstructorReview_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
