import { z } from 'zod';

const registerRoleSchema = z.enum(['STUDENT', 'INSTRUCTOR']);

// Register validation schema
export const registerSchema = z.object({
  email: z
    .string()
    .email('Invalid email format')
    .min(1, 'Email is required'),
  password: z
    .string()
    .min(8, 'Password must be at least 8 characters')
    .regex(/[A-Z]/, 'Password must contain at least one uppercase letter')
    .regex(/[a-z]/, 'Password must contain at least one lowercase letter')
    .regex(/[0-9]/, 'Password must contain at least one number')
    .regex(/[^A-Za-z0-9]/, 'Password must contain at least one special character'),
  firstName: z
    .string()
    .min(2, 'First name must be at least 2 characters')
    .max(50, 'First name must be less than 50 characters'),
  lastName: z
    .string()
    .min(2, 'Last name must be at least 2 characters')
    .max(50, 'Last name must be less than 50 characters'),
  role: registerRoleSchema.default('STUDENT'),
});

// Login validation schema
export const loginSchema = z.object({
  email: z
    .string()
    .email('Invalid email format')
    .min(1, 'Email is required'),
  password: z
    .string()
    .min(1, 'Password is required'),
});

// Get user profile validation (for query params if needed)
export const userIdSchema = z.object({
  id: z.string().cuid('Invalid user ID format'),
});

// Update profile validation
export const updateProfileSchema = z.object({
  firstName: z
    .string()
    .min(2, 'First name must be at least 2 characters')
    .max(50, 'First name must be less than 50 characters')
    .optional(),
  lastName: z
    .string()
    .min(2, 'Last name must be at least 2 characters')
    .max(50, 'Last name must be less than 50 characters')
    .optional(),
  bio: z
    .string()
    .max(500, 'Bio must be less than 500 characters')
    .optional(),
});

// Change password validation
export const changePasswordSchema = z.object({
  currentPassword: z
    .string()
    .min(1, 'Current password is required'),
  newPassword: z
    .string()
    .min(8, 'Password must be at least 8 characters')
    .regex(/[A-Z]/, 'Password must contain at least one uppercase letter')
    .regex(/[a-z]/, 'Password must contain at least one lowercase letter')
    .regex(/[0-9]/, 'Password must contain at least one number')
    .regex(/[^A-Za-z0-9]/, 'Password must contain at least one special character'),
});

// Forgot password validation
export const forgotPasswordSchema = z.object({
  email: z
    .string()
    .email('Invalid email format')
    .min(1, 'Email is required'),
});

// Reset password validation
export const resetPasswordSchema = z.object({
  token: z
    .string()
    .min(1, 'Token is required'),
  newPassword: z
    .string()
    .min(8, 'Password must be at least 8 characters')
    .regex(/[A-Z]/, 'Password must contain at least one uppercase letter')
    .regex(/[a-z]/, 'Password must contain at least one lowercase letter')
    .regex(/[0-9]/, 'Password must contain at least one number')
    .regex(/[^A-Za-z0-9]/, 'Password must contain at least one special character'),
});

// Email verification validation
export const verifyEmailSchema = z.object({
  token: z
    .string()
    .min(1, 'Token is required'),
});

// Update role validation
export const updateRoleSchema = z.object({
  role: z.enum(['STUDENT', 'INSTRUCTOR'], {
    errorMap: () => ({ message: 'Role must be either STUDENT or INSTRUCTOR' }),
  }),
});

// ============= COURSE MANAGEMENT SCHEMAS =============

// Course status enum
export const courseStatusSchema = z.enum(['DRAFT', 'UNDER_REVIEW', 'PUBLISHED'], {
  errorMap: () => ({ message: 'Invalid course status' }),
});

// Level enum (matches Prisma)
export const levelSchema = z.enum(['BEGINNER', 'INTERMEDIATE', 'ADVANCED'], {
  errorMap: () => ({ message: 'Invalid level' }),
});

// Create course schema
export const createCourseSchema = z.object({
  title: z.string().min(3, 'Title must be at least 3 characters').max(200, 'Title must be less than 200 characters'),
  description: z.string().max(5000, 'Description must be less than 5000 characters').optional(),
  thumbnail: z.string().url('Invalid thumbnail URL').optional().or(z.literal('')),
  price: z.number().min(0, 'Price cannot be negative').default(0),
  originalPrice: z.number().min(0, 'Original price cannot be negative').optional(),
  level: levelSchema.default('BEGINNER'),
  language: z.string().min(1, 'Language is required').max(50, 'Language must be less than 50 characters').default('English'),
  duration: z.string().max(50, 'Duration must be less than 50 characters').optional(),
  totalHours: z.number().min(0, 'Total hours cannot be negative').optional(),
  categoryId: z.string().cuid('Invalid category ID format'),
});

// Update course schema (all optional except title if provided)
export const updateCourseSchema = createCourseSchema.partial().extend({
  status: courseStatusSchema.optional(),
});

// Course ID param schema
export const courseIdSchema = z.object({
  id: z.string().cuid('Invalid course ID format'),
});

// Section schemas
export const createSectionSchema = z.object({
  title: z.string().min(1, 'Section title is required').max(200, 'Title must be less than 200 characters'),
  description: z.string().max(2000, 'Description must be less than 2000 characters').optional(),
  order: z.number().int().min(0, 'Order must be a positive integer').optional(),
});

export const updateSectionSchema = createSectionSchema.partial();

export const sectionIdSchema = z.object({
  id: z.string().cuid('Invalid section ID format'),
});

// Reorder sections schema
export const reorderSectionsSchema = z.object({
  sections: z.array(z.object({
    id: z.string().cuid('Invalid section ID format'),
    order: z.number().int().min(0, 'Order must be a positive integer'),
  })).min(1, 'At least one section required'),
});

// Lesson schemas
export const createLessonSchema = z.object({
  title: z.string().min(1, 'Lesson title is required').max(200, 'Title must be less than 200 characters'),
  description: z.string().max(5000, 'Description must be less than 5000 characters').optional(),
  videoUrl: z.string().url('Invalid video URL').optional().or(z.literal('')),
  duration: z.string().max(50, 'Duration must be less than 50 characters').optional(),
  isPreview: z.boolean().default(false),
  isFree: z.boolean().default(false),
  order: z.number().int().min(0, 'Order must be a positive integer').optional(),
});

export const updateLessonSchema = createLessonSchema.partial();

export const lessonIdSchema = z.object({
  id: z.string().cuid('Invalid lesson ID format'),
});

// Reorder lessons schema
export const reorderLessonsSchema = z.object({
  lessons: z.array(z.object({
    id: z.string().cuid('Invalid lesson ID format'),
    order: z.number().int().min(0, 'Order must be a positive integer'),
  })).min(1, 'At least one lesson required'),
});

// Video upload validation
export const videoUploadSchema = z.object({
  fileName: z.string().min(1, 'File name is required'),
  mimeType: z.string().min(1, 'MIME type is required'),
  fileSize: z.number().min(1, 'File size is required'),
});

// Course status transition schema
export const updateCourseStatusSchema = z.object({
  status: courseStatusSchema,
});

// Query params for pagination
export const paginationSchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(10),
  sortBy: z.enum(['newest', 'oldest', 'title', 'updatedAt']).default('newest'),
  search: z.string().optional(),
});

// Export all schemas
export const schemas = {
  // ... existing schemas
  register: registerSchema,
  login: loginSchema,
  userId: userIdSchema,
  updateProfile: updateProfileSchema,
  changePassword: changePasswordSchema,
  forgotPassword: forgotPasswordSchema,
  resetPassword: resetPasswordSchema,
  verifyEmail: verifyEmailSchema,
  updateRole: updateRoleSchema,
  // Course management schemas
  createCourse: createCourseSchema,
  updateCourse: updateCourseSchema,
  courseId: courseIdSchema,
  createSection: createSectionSchema,
  updateSection: updateSectionSchema,
  sectionId: sectionIdSchema,
  reorderSections: reorderSectionsSchema,
  createLesson: createLessonSchema,
  updateLesson: updateLessonSchema,
  lessonId: lessonIdSchema,
  reorderLessons: reorderLessonsSchema,
  videoUpload: videoUploadSchema,
  updateCourseStatus: updateCourseStatusSchema,
  pagination: paginationSchema,
};

// Type inference for TypeScript
export type RegisterInput = z.infer<typeof registerSchema>;
export type LoginInput = z.infer<typeof loginSchema>;
export type UpdateProfileInput = z.infer<typeof updateProfileSchema>;
export type ChangePasswordInput = z.infer<typeof changePasswordSchema>;
export type ForgotPasswordInput = z.infer<typeof forgotPasswordSchema>;
export type ResetPasswordInput = z.infer<typeof resetPasswordSchema>;
export type VerifyEmailInput = z.infer<typeof verifyEmailSchema>;
export type UpdateRoleInput = z.infer<typeof updateRoleSchema>;

// Course management types
export type CreateCourseInput = z.infer<typeof createCourseSchema>;
export type UpdateCourseInput = z.infer<typeof updateCourseSchema>;
export type CourseIdInput = z.infer<typeof courseIdSchema>;
export type CreateSectionInput = z.infer<typeof createSectionSchema>;
export type UpdateSectionInput = z.infer<typeof updateSectionSchema>;
export type SectionIdInput = z.infer<typeof sectionIdSchema>;
export type ReorderSectionsInput = z.infer<typeof reorderSectionsSchema>;
export type CreateLessonInput = z.infer<typeof createLessonSchema>;
export type UpdateLessonInput = z.infer<typeof updateLessonSchema>;
export type LessonIdInput = z.infer<typeof lessonIdSchema>;
export type ReorderLessonsInput = z.infer<typeof reorderLessonsSchema>;
export type VideoUploadInput = z.infer<typeof videoUploadSchema>;
export type UpdateCourseStatusInput = z.infer<typeof updateCourseStatusSchema>;
export type PaginationInput = z.infer<typeof paginationSchema>;