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

    courseId: z.string().cuid(),
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
    id: z.string().cuid(),
  }),

  courseId: z.object({
    courseId: z.string().cuid(),
  }),
};