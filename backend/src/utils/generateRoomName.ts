// backend/src/utils/generateRoomName.ts
import crypto from "crypto";

export function generateRoomName(courseId?: string) {
    const random = crypto.randomBytes(8).toString("hex");
    if (courseId) {
        return `course_${courseId}_${random}`;
    }
    return `live_${random}`;
}