// backend/src/utils/validation.ts
import { z } from 'zod';

// ============= USER SCHEMAS =============

const registerRoleSchema = z.enum(['STUDENT', 'INSTRUCTOR']);

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

export const loginSchema = z.object({
  email: z
    .string()
    .email('Invalid email format')
    .min(1, 'Email is required'),
  password: z
    .string()
    .min(1, 'Password is required'),
});

export const userIdSchema = z.object({
  id: z.string().cuid('Invalid user ID format'),
});

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

export const forgotPasswordSchema = z.object({
  email: z
    .string()
    .email('Invalid email format')
    .min(1, 'Email is required'),
});

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

export const verifyEmailSchema = z.object({
  token: z
    .string()
    .min(1, 'Token is required'),
});

export const updateRoleSchema = z.object({
  role: z.enum(['STUDENT', 'INSTRUCTOR'], {
    errorMap: () => ({ message: 'Role must be either STUDENT or INSTRUCTOR' }),
  }),
});

// ============= COURSE MANAGEMENT SCHEMAS =============

export const courseStatusSchema = z.enum(['DRAFT', 'UNDER_REVIEW', 'PUBLISHED'], {
  errorMap: () => ({ message: 'Invalid course status' }),
});

export const levelSchema = z.enum(['BEGINNER', 'INTERMEDIATE', 'ADVANCED'], {
  errorMap: () => ({ message: 'Invalid level' }),
});

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

export const updateCourseSchema = createCourseSchema.partial().extend({
  status: courseStatusSchema.optional(),
});

export const courseIdSchema = z.object({
  id: z.string().cuid('Invalid course ID format'),
});

export const createSectionSchema = z.object({
  title: z.string().min(1, 'Section title is required').max(200, 'Title must be less than 200 characters'),
  description: z.string().max(2000, 'Description must be less than 2000 characters').optional(),
  order: z.number().int().min(0, 'Order must be a positive integer').optional(),
});

export const updateSectionSchema = createSectionSchema.partial();

export const sectionIdSchema = z.object({
  id: z.string().cuid('Invalid section ID format'),
});

export const reorderSectionsSchema = z.object({
  sections: z.array(z.object({
    id: z.string().cuid('Invalid section ID format'),
    order: z.number().int().min(0, 'Order must be a positive integer'),
  })).min(1, 'At least one section required'),
});

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

export const reorderLessonsSchema = z.object({
  lessons: z.array(z.object({
    id: z.string().cuid('Invalid lesson ID format'),
    order: z.number().int().min(0, 'Order must be a positive integer'),
  })).min(1, 'At least one lesson required'),
});

export const videoUploadSchema = z.object({
  fileName: z.string().min(1, 'File name is required'),
  mimeType: z.string().min(1, 'MIME type is required'),
  fileSize: z.number().min(1, 'File size is required'),
});

export const updateCourseStatusSchema = z.object({
  status: courseStatusSchema,
});

export const paginationSchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(10),
  sortBy: z.enum(['newest', 'oldest', 'title', 'updatedAt']).default('newest'),
  search: z.string().optional(),
});

// ============= INSTRUCTOR MANAGEMENT SCHEMAS =============

export const updateInstructorProfileSchema = z.object({
  title: z.string().max(100, 'Title must be less than 100 characters').optional(),
  expertise: z.string().max(500, 'Expertise must be less than 500 characters').optional(),
  bio: z.string().max(2000, 'Bio must be less than 2000 characters').optional(),
  photo: z.string().url('Invalid photo URL').optional().or(z.literal('')),
  socialLinks: z.object({
    website: z.string().url('Invalid website URL').optional().or(z.literal('')),
    linkedin: z.string().url('Invalid LinkedIn URL').optional().or(z.literal('')),
    twitter: z.string().url('Invalid Twitter URL').optional().or(z.literal('')),
    youtube: z.string().url('Invalid YouTube URL').optional().or(z.literal('')),
    github: z.string().url('Invalid GitHub URL').optional().or(z.literal('')),
  }).optional(),
});

export const getInstructorsSchema = z.object({
  search: z.string().optional(),
  expertise: z.string().optional(),
  categoryId: z.string().cuid('Invalid category ID').optional(),
  limit: z.coerce.number().int().min(1).max(100).default(10),
  offset: z.coerce.number().int().min(0).default(0),
  sortBy: z.enum(['popular', 'rating', 'newest', 'courses']).default('popular'),
});

export const instructorIdSchema = z.object({
  instructorId: z.string().cuid('Invalid instructor ID format'),
});

// ============= ENROLLMENT SCHEMAS =============

export const enrollParamsSchema = z.object({
  courseId: z.string().cuid('Invalid course ID format'),
});

export const updateLessonProgressSchema = z.object({
  isCompleted: z.boolean().optional(),
});

export const enrollmentPaginationSchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(10),
  isCompleted: z
    .enum(['true', 'false'])
    .transform((val) => val === 'true')
    .optional(),
});

// ============= EXPORT ALL SCHEMAS =============

export const schemas = {
  // User schemas
  register: registerSchema,
  login: loginSchema,
  userId: userIdSchema,
  updateProfile: updateProfileSchema,
  changePassword: changePasswordSchema,
  forgotPassword: forgotPasswordSchema,
  resetPassword: resetPasswordSchema,
  verifyEmail: verifyEmailSchema,
  updateRole: updateRoleSchema,

  // Course schemas
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

  // Instructor schemas
  updateInstructorProfile: updateInstructorProfileSchema,
  getInstructors: getInstructorsSchema,
  instructorId: instructorIdSchema,

  // Enrollment schemas
  enrollParams: enrollParamsSchema,
  updateLessonProgress: updateLessonProgressSchema,
  enrollmentPagination: enrollmentPaginationSchema,
};

// ============= TYPE INFERENCE =============
export type RegisterInput = z.infer<typeof registerSchema>;
export type LoginInput = z.infer<typeof loginSchema>;
export type UpdateProfileInput = z.infer<typeof updateProfileSchema>;
export type ChangePasswordInput = z.infer<typeof changePasswordSchema>;
export type ForgotPasswordInput = z.infer<typeof forgotPasswordSchema>;
export type ResetPasswordInput = z.infer<typeof resetPasswordSchema>;
export type VerifyEmailInput = z.infer<typeof verifyEmailSchema>;
export type UpdateRoleInput = z.infer<typeof updateRoleSchema>;

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

export type UpdateInstructorProfileInput = z.infer<typeof updateInstructorProfileSchema>;
export type GetInstructorsInput = z.infer<typeof getInstructorsSchema>;
export type InstructorIdInput = z.infer<typeof instructorIdSchema>;

export type EnrollParamsInput = z.infer<typeof enrollParamsSchema>;
export type UpdateLessonProgressInput = z.infer<typeof updateLessonProgressSchema>;
export type EnrollmentPaginationInput = z.infer<typeof enrollmentPaginationSchema>;