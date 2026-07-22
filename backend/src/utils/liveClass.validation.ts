import { z } from "zod";

export const schemas = {
  createLiveClass: z.object({
    title: z
      .string()
      .trim()
      .min(3)
      .max(100),

    description: z
      .string()
      .trim()
      .max(1000)
      .optional(),

    scheduledAt: z.coerce
      .date()
      .optional(),

    maxParticipants: z
      .number()
      .int()
      .min(2)
      .max(500)
      .optional(),

    courseId: z.string().min(1, "Course is required").optional(),
  }),

  updateLiveClass: z.object({
    title: z.string().trim().min(3).max(100).optional(),

    description: z
      .string()
      .trim()
      .max(1000)
      .optional(),

    scheduledAt: z.coerce
      .date()
      .optional(),

    maxParticipants: z
      .number()
      .int()
      .min(2)
      .max(500)
      .optional(),
  }),

  liveClassId: z.object({
    id: z.string().min(1, "ID is required"),
  }),

  courseId: z.object({
    courseId: z.string().min(1, "Course ID is required"),
  }),
};