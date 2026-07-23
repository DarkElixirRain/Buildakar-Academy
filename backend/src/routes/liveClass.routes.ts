import express from "express";
import { Role } from "@prisma/client";

import { authenticate } from "../middleware/auth.middleware";
import { roleMiddleware } from "../middleware/role.middleware";
import { validate } from "../middleware/validation.middleware";
import { schemas } from "../utils/liveClass.validation";
import { 
  cancelliveClass, 
  createliveClass, 
  endliveClass, 
  getcourseLiveClasses, 
  getinstructorLiveClasses, 
  getliveClassById, 
  joinliveClass, 
  startliveClass, 
  updateliveClass,
  getstudentLiveClasses,
  getUpcomingStudentLiveClassesController,
  getCurrentStudentLiveClassesController,
  getStudentLiveClassesWithStatsController,
  getAllStudentLiveClassesController  // Add this import
} from "../controllers/liveClass.controller";

const router = express.Router();

const instructorOrAdmin = roleMiddleware([
  Role.INSTRUCTOR,
  Role.ADMIN,
]);

const studentOrAdmin = roleMiddleware([
  Role.STUDENT,
  Role.INSTRUCTOR,
  Role.ADMIN,
]);

router.use(authenticate);

// Instructor Routes

// POST /api/live-classes
router.post(
  "/",
  instructorOrAdmin,
  validate(schemas.createLiveClass),
  createliveClass
);

// GET /api/live-classes/instructor
router.get(
  "/instructor",
  instructorOrAdmin,
  getinstructorLiveClasses
);

// PATCH /api/live-classes/:id
router.patch(
  "/:id",
  instructorOrAdmin,
  validate(schemas.liveClassId, 'params'),
  validate(schemas.updateLiveClass),
  updateliveClass
);

// PATCH /api/live-classes/:id/start
router.patch(
  "/:id/start",
  instructorOrAdmin,
  validate(schemas.liveClassId, "params"),
  startliveClass
);

// PATCH /api/live-classes/:id/end
router.patch(
  "/:id/end",
  instructorOrAdmin,
  validate(schemas.liveClassId, "params"),
  endliveClass
);

// PATCH /api/live-classes/:id/cancel
router.patch(
  "/:id/cancel",
  instructorOrAdmin,
  validate(schemas.liveClassId, "params"),
  cancelliveClass
);

// 🎓 Student Routes

// GET /api/live-classes/student - Get live classes (excluding cancelled)
router.get(
  "/student",
  studentOrAdmin,
  getstudentLiveClasses
);

// GET /api/live-classes/student/all - Get ALL live classes (including cancelled, categorized)  // ADD THIS ROUTE
router.get(
  "/student/all",
  studentOrAdmin,
  getAllStudentLiveClassesController  // Make sure this controller exists
);

// GET /api/live-classes/student/upcoming - Get upcoming classes only
router.get(
  "/student/upcoming",
  studentOrAdmin,
  getUpcomingStudentLiveClassesController
);

// GET /api/live-classes/student/current - Get currently live classes only
router.get(
  "/student/current",
  studentOrAdmin,
  getCurrentStudentLiveClassesController
);

// GET /api/live-classes/student/stats - Get statistics
router.get(
  "/student/stats",
  studentOrAdmin,
  getStudentLiveClassesWithStatsController
);

// POST /api/live-classes/:id/join
router.post(
  "/:id/join",
  studentOrAdmin,
  validate(schemas.liveClassId, "params"),
  joinliveClass
);

// Shared Routes

// GET /api/live-classes/:id
router.get(
  "/:id",
  validate(schemas.liveClassId, "params"),
  getliveClassById
);

// GET /api/live-classes/course/:courseId
router.get(
  "/course/:courseId",
  validate(schemas.courseId, 'params'),
  getcourseLiveClasses
);

export default router;