import crypto from "crypto";

export function generateRoomName(courseId: string) {
    const random = crypto.randomBytes(8).toString("hex");

    return `course_${courseId}_${random}`;
}