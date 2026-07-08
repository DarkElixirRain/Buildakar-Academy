-- CreateTable
CREATE TABLE "live_class_participants" (
    "id" TEXT NOT NULL,
    "liveClassId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "joinedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "leftAt" TIMESTAMP(3),

    CONSTRAINT "live_class_participants_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "live_class_participants_liveClassId_idx" ON "live_class_participants"("liveClassId");

-- CreateIndex
CREATE INDEX "live_class_participants_userId_idx" ON "live_class_participants"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "live_class_participants_liveClassId_userId_key" ON "live_class_participants"("liveClassId", "userId");

-- AddForeignKey
ALTER TABLE "live_class_participants" ADD CONSTRAINT "live_class_participants_liveClassId_fkey" FOREIGN KEY ("liveClassId") REFERENCES "live_classes"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "live_class_participants" ADD CONSTRAINT "live_class_participants_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
