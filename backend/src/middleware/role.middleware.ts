// backend/src/middleware/role.middleware.ts
import { Request, Response, NextFunction } from 'express';
import { Role } from '@prisma/client';

type AuthenticatedUser = {
  id: string;
  email: string;
  role: Role;
  firstName: string;
  lastName: string;
  isVerified: boolean;
  isActive: boolean;
};

/**
 * Role-based access control middleware
 * @param allowedRoles - Array of roles that are allowed to access the route
 * @returns Express middleware function
 */
export const roleMiddleware = (allowedRoles: Role[]) => {
  return (req: Request, res: Response, next: NextFunction): void => {
    try {
      // Check if user exists on request (set by auth middleware)
      const user = req.user as AuthenticatedUser | undefined;

      if (!user) {
        res.status(401).json({
          success: false,
          message: 'Authentication required. Please log in.',
        });
        return;
      }

      // Check if user is active
      if (!user.isActive) {
        res.status(403).json({
          success: false,
          message: 'Your account has been deactivated. Please contact support.',
        });
        return;
      }

      // Check if user's role is allowed
      if (!allowedRoles.includes(user.role)) {
        res.status(403).json({
          success: false,
          message: `Access denied. Required roles: ${allowedRoles.join(', ')}. Your role: ${user.role}`,
        });
        return;
      }

      // User has required role, proceed to next middleware/controller
      next();
    } catch (error) {
      console.error('Role middleware error:', error);
      res.status(500).json({
        success: false,
        message: 'An error occurred while checking permissions',
      });
    }
  };
};

/**
 * Middleware to check if user is an admin
 * Shortcut for roleMiddleware([Role.ADMIN])
 */
export const isAdmin = roleMiddleware([Role.ADMIN]);

/**
 * Middleware to check if user is an instructor or admin
 * Shortcut for roleMiddleware([Role.INSTRUCTOR, Role.ADMIN])
 */
export const isInstructorOrAdmin = roleMiddleware([Role.INSTRUCTOR, Role.ADMIN]);

/**
 * Middleware to check if user is a student (any authenticated user)
 * Shortcut for roleMiddleware([Role.STUDENT, Role.INSTRUCTOR, Role.ADMIN])
 */
export const isAuthenticatedUser = roleMiddleware([Role.STUDENT, Role.INSTRUCTOR, Role.ADMIN]);

/**
 * Middleware to check if user is an instructor
 * Shortcut for roleMiddleware([Role.INSTRUCTOR])
 */
export const isInstructor = roleMiddleware([Role.INSTRUCTOR]);

/**
 * Middleware to check if user is a student
 * Shortcut for roleMiddleware([Role.STUDENT])
 */
export const isStudent = roleMiddleware([Role.STUDENT]);

/**
 * Custom role checker for more complex role validation
 * @param req - Express Request object
 * @param allowedRoles - Array of allowed roles
 * @returns boolean - true if user has required role
 */
export const hasRole = (req: Request, allowedRoles: Role[]): boolean => {
  const user = req.user as AuthenticatedUser | undefined;
  if (!user) return false;
  if (!user.isActive) return false;
  return allowedRoles.includes(user.role);
};

/**
 * Check if user has any of the specified roles
 * @param req - Express Request object
 * @param roles - Array of roles to check
 * @returns boolean
 */
export const hasAnyRole = (req: Request, roles: Role[]): boolean => {
  const user = req.user as AuthenticatedUser | undefined;
  if (!user) return false;
  if (!user.isActive) return false;
  return roles.includes(user.role);
};

/**
 * Check if user has all specified roles
 * @param req - Express Request object
 * @param roles - Array of roles to check
 * @returns boolean
 */
export const hasAllRoles = (req: Request, roles: Role[]): boolean => {
  const user = req.user as AuthenticatedUser | undefined;
  if (!user) return false;
  if (!user.isActive) return false;
  return roles.every(role => role === user.role);
};

/**
 * Get current authenticated user
 * @param req - Express Request object
 * @returns AuthenticatedUser or null
 */
export const getCurrentUser = (req: Request): AuthenticatedUser | null => {
  return (req.user as AuthenticatedUser) || null;
};

/**
 * Check if user is the owner of a resource
 * @param req - Express Request object
 * @param resourceUserId - The user ID of the resource owner
 * @returns boolean
 */
export const isResourceOwner = (req: Request, resourceUserId: string): boolean => {
  const user = req.user as AuthenticatedUser | undefined;
  if (!user) return false;
  return user.id === resourceUserId;
};

/**
 * Middleware to check if user is the owner or has admin role
 * @param getResourceUserId - Function that returns the resource owner ID from the request
 * @returns Express middleware function
 */
export const isOwnerOrAdmin = (getResourceUserId: (req: Request) => string | Promise<string>) => {
  return async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const user = req.user as AuthenticatedUser | undefined;
      
      if (!user) {
        res.status(401).json({
          success: false,
          message: 'Authentication required',
        });
        return;
      }

      // Admin can access any resource
      if (user.role === Role.ADMIN) {
        next();
        return;
      }

      // Check if user is the resource owner
      const resourceUserId = await getResourceUserId(req);
      if (user.id === resourceUserId) {
        next();
        return;
      }

      res.status(403).json({
        success: false,
        message: 'You do not have permission to access this resource',
      });
    } catch (error) {
      console.error('Owner/Admin middleware error:', error);
      res.status(500).json({
        success: false,
        message: 'An error occurred while checking permissions',
      });
    }
  };
};