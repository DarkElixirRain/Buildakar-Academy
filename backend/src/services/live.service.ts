// backend/src/services/live.service.ts

import {
  LiveClassStatus,
  CourseStatus,
} from "@prisma/client";
import { prisma } from '../lib/prisma';
import { generateRoomName } from "../utils/generateRoomName";
import { notifyLiveClassCancelled, notifyLiveClassScheduled, notifyLiveClassStarted, notifyLiveClassUpdated } from "./notification.service";
import fs from 'fs';
import jwt from 'jsonwebtoken';

interface CreateLiveClassData {
  title: string;
  description?: string;
  scheduledAt?: Date;
  maxParticipants?: number;
  courseId?: string;
  instructorId: string;
}

interface UpdateLiveClassData {
  title?: string;
  description?: string;
  scheduledAt?: Date;
  maxParticipants?: number;
}

// Helper
async function getEnrolledStudentIds(courseId: string | undefined | null) {
  if (!courseId) return [];
  const students = await prisma.enrollment.findMany({
    where: {
      courseId,
    },
    select: {
      userId: true,
    },
  });

  return students.map(student => student.userId);
}

export async function createLiveClass(data: CreateLiveClassData) {
  if (data.courseId) {
    const course = await prisma.course.findUnique({
      where: {
        id: data.courseId,
      },
    });

    if (!course) {
      throw new Error("Course not found");
    }

    if (course.instructorId !== data.instructorId) {
      throw new Error("You are not authorized to create a live class for this course.");
    }
    if (
      course.status !== CourseStatus.PUBLISHED ||
      !course.isPublished
    ) {
      throw new Error("Only published courses can have live classes.");
    }
  }

  const liveClass = await prisma.liveClass.create({
    data: {
      title: data.title,
      description: data.description,
      scheduledAt: data.scheduledAt,
      maxParticipants: data.maxParticipants ?? 100,
      instructorId: data.instructorId,
      ...(data.courseId ? { courseId: data.courseId } : {}),
      roomName: generateRoomName(data.courseId),
      status: LiveClassStatus.SCHEDULED,
    },
    include: {
      instructor: {
        select: {
          id: true,
          firstName: true,
          lastName: true,
          email: true,
          photo: true,
        },
      },
      course: {
        select: {
          id: true,
          title: true,
          thumbnail: true,
        },
      },
    },
  });

  const studentIds = await getEnrolledStudentIds(liveClass.courseId);

  if (studentIds.length > 0) {
    try {
      await notifyLiveClassScheduled(
        studentIds,
        liveClass.title,
        liveClass.id,
        liveClass.courseId,
        liveClass.scheduledAt
      );
    } catch (error) {
      }
  }

  return liveClass;
}

export async function getInstructorLiveClasses(instructorId: string, page = 1, limit = 20) {
  if (!instructorId)
    throw new Error("Unauthorized");

  const [data, total] = await Promise.all([
    prisma.liveClass.findMany({
      where: {
        instructorId,
      },
      include: {
        instructor: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            photo: true,
            email: true,
          },
        },
        course: {
          select: {
            id: true,
            title: true,
            thumbnail: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
      skip: (page - 1) * limit,
      take: limit,
    }),
    prisma.liveClass.count({ where: { instructorId } }),
  ]);

  if (data.length === 0) {
    return { data: [], pagination: { page, limit, total: 0, totalPages: 0, hasMore: false } };
  }
  return {
    data,
    pagination: {
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit),
      hasMore: page * limit < total,
    },
  };
}

export async function getCourseLiveClasses(courseId: string, page = 1, limit = 20) {
  if (!courseId) {
    throw new Error("Course not found or Not Valid");
  }
  const [data, total] = await Promise.all([
    prisma.liveClass.findMany({
      where: {
        courseId,
        status: {
          not: LiveClassStatus.CANCELLED,
        },
      },
      include: {
        instructor: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            photo: true,
          },
        },
      },
      orderBy: {
        scheduledAt: "asc",
      },
      skip: (page - 1) * limit,
      take: limit,
    }),
    prisma.liveClass.count({
      where: {
        courseId,
        status: { not: LiveClassStatus.CANCELLED },
      },
    }),
  ]);

  return {
    data,
    pagination: {
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit),
      hasMore: page * limit < total,
    },
  };
}

// NEW: Get all live classes for a student
export async function getStudentLiveClasses(studentId: string) {
  if (!studentId) {
    throw new Error("Student ID is required");
  }

  // First, get all courses the student is enrolled in
  const enrollments = await prisma.enrollment.findMany({
    where: {
      userId: studentId,
    },
    select: {
      courseId: true,
    },
  });

  const courseIds = enrollments.map(enrollment => enrollment.courseId);

  // Get live classes for enrolled courses + course-less public classes
  const liveClasses = await prisma.liveClass.findMany({
    where: {
      OR: [
        ...(courseIds.length > 0 ? [{ courseId: { in: courseIds } }] : []),
        { courseId: null },
      ],
      status: {
        not: LiveClassStatus.CANCELLED,
      },
    },
    include: {
      instructor: {
        select: {
          id: true,
          firstName: true,
          lastName: true,
          photo: true,
          email: true,
        },
      },
      course: {
        select: {
          id: true,
          title: true,
          thumbnail: true,
          description: true,
        },
      },
    },
    orderBy: {
      scheduledAt: "asc",
    },
  });

  // Add additional metadata for each live class
  const now = new Date();
  const liveClassesWithMetadata = liveClasses.map(liveClass => ({
    ...liveClass,
    isJoinable: liveClass.status === LiveClassStatus.LIVE,
    isUpcoming: liveClass.status === LiveClassStatus.SCHEDULED && 
                liveClass.scheduledAt && 
                new Date(liveClass.scheduledAt) > now,
    isPast: liveClass.status === LiveClassStatus.ENDED || 
            (liveClass.status === LiveClassStatus.SCHEDULED && 
             liveClass.scheduledAt && 
             new Date(liveClass.scheduledAt) <= now),
  }));

  return liveClassesWithMetadata;
}

// NEW: Get upcoming live classes for a student
export async function getUpcomingStudentLiveClasses(studentId: string) {
  if (!studentId) {
    throw new Error("Student ID is required");
  }

  const enrollments = await prisma.enrollment.findMany({
    where: {
      userId: studentId,
    },
    select: {
      courseId: true,
    },
  });

  const courseIds = enrollments.map(enrollment => enrollment.courseId);

  return await prisma.liveClass.findMany({
    where: {
      OR: [
        ...(courseIds.length > 0 ? [{ courseId: { in: courseIds } }] : []),
        { courseId: null },
      ],
      status: {
        in: [LiveClassStatus.SCHEDULED, LiveClassStatus.LIVE],
      },
      scheduledAt: {
        gte: new Date(),
      },
    },
    include: {
      instructor: {
        select: {
          id: true,
          firstName: true,
          lastName: true,
          photo: true,
          email: true,
        },
      },
      course: {
        select: {
          id: true,
          title: true,
          thumbnail: true,
          description: true,
        },
      },
    },
    orderBy: {
      scheduledAt: "asc",
    },
  });
}

// NEW: Get currently live classes for a student
export async function getCurrentStudentLiveClasses(studentId: string) {
  if (!studentId) {
    throw new Error("Student ID is required");
  }

  const enrollments = await prisma.enrollment.findMany({
    where: {
      userId: studentId,
    },
    select: {
      courseId: true,
    },
  });

  const courseIds = enrollments.map(enrollment => enrollment.courseId);

  return await prisma.liveClass.findMany({
    where: {
      OR: [
        ...(courseIds.length > 0 ? [{ courseId: { in: courseIds } }] : []),
        { courseId: null },
      ],
      status: LiveClassStatus.LIVE,
    },
    include: {
      instructor: {
        select: {
          id: true,
          firstName: true,
          lastName: true,
          photo: true,
          email: true,
        },
      },
      course: {
        select: {
          id: true,
          title: true,
          thumbnail: true,
          description: true,
        },
      },
    },
    orderBy: {
      startedAt: "asc",
    },
  });
}

// NEW: Get student live classes with statistics
export async function getStudentLiveClassesWithStats(studentId: string) {
  if (!studentId) {
    throw new Error("Student ID is required");
  }

  const enrollments = await prisma.enrollment.findMany({
    where: {
      userId: studentId,
    },
    select: {
      courseId: true,
    },
  });

  const courseIds = enrollments.map(enrollment => enrollment.courseId);

  const liveClasses = await prisma.liveClass.findMany({
    where: {
      OR: [
        ...(courseIds.length > 0 ? [{ courseId: { in: courseIds } }] : []),
        { courseId: null },
      ],
    },
    include: {
      instructor: {
        select: {
          id: true,
          firstName: true,
          lastName: true,
          photo: true,
          email: true,
        },
      },
      course: {
        select: {
          id: true,
          title: true,
          thumbnail: true,
          description: true,
        },
      },
    },
    orderBy: {
      scheduledAt: "asc",
    },
  });

  const now = new Date();
  
  return {
    total: liveClasses.length,
    upcoming: liveClasses.filter(
      c => c.status === LiveClassStatus.SCHEDULED && 
           c.scheduledAt && 
           new Date(c.scheduledAt) > now
    ).length,
    live: liveClasses.filter(c => c.status === LiveClassStatus.LIVE).length,
    ended: liveClasses.filter(c => c.status === LiveClassStatus.ENDED).length,
    cancelled: liveClasses.filter(c => c.status === LiveClassStatus.CANCELLED).length,
    classes: liveClasses.map(liveClass => ({
      ...liveClass,
      isJoinable: liveClass.status === LiveClassStatus.LIVE,
      isUpcoming: liveClass.status === LiveClassStatus.SCHEDULED && 
                  liveClass.scheduledAt && 
                  new Date(liveClass.scheduledAt) > now,
      isPast: liveClass.status === LiveClassStatus.ENDED || 
              (liveClass.status === LiveClassStatus.SCHEDULED && 
               liveClass.scheduledAt && 
               new Date(liveClass.scheduledAt) <= now),
    })),
  };
}

export async function getLiveClassById(id: string) {
  if (!id) {
    throw new Error("Live classes not found");
  }
  const liveClass = await prisma.liveClass.findUnique({
    where: {
      id,
    },
    include: {
      instructor: {
        select: {
          id: true,
          firstName: true,
          lastName: true,
          photo: true,
          email: true,
        },
      },
      course: {
        select: {
          id: true,
          title: true,
          thumbnail: true,
        },
      },
    },
  });

  if (!liveClass) {
    throw new Error("Live class not found");
  }

  return liveClass;
}

export async function updateLiveClass(
  id: string,
  data: UpdateLiveClassData,
  instructorId: string
) {
  const liveClass = await prisma.liveClass.findUnique({
    where: { id },
  });

  if (!liveClass) {
    throw new Error("Live class not found");
  }

  if (liveClass.instructorId !== instructorId) {
    throw new Error("You are not authorized to update this live class.");
  }

  if (
    liveClass.status === LiveClassStatus.LIVE ||
    liveClass.status === LiveClassStatus.ENDED
  ) {
    throw new Error("This live class can no longer be edited.");
  }

  const updatedLiveClass = await prisma.liveClass.update({
    where: { id },
    data,
    include: {
      instructor: {
        select: {
          id: true,
          firstName: true,
          lastName: true,
          photo: true,
        },
      },
      course: {
        select: {
          id: true,
          title: true,
          thumbnail: true,
        },
      },
    },
  });

  const studentIds = await getEnrolledStudentIds(updatedLiveClass.courseId);

  if (studentIds.length > 0) {
    try {
      await notifyLiveClassUpdated(
        studentIds,
        updatedLiveClass.title,
        updatedLiveClass.id,
        updatedLiveClass.courseId
      );
    } catch (error) {
      }
  }

  return updatedLiveClass;
}

export async function deleteLiveClass(
  id: string,
  instructorId: string
) {
  const liveClass = await prisma.liveClass.findUnique({
    where: { id },
  });

  if (!liveClass) {
    throw new Error("Live class not found");
  }

  if (liveClass.instructorId !== instructorId) {
    throw new Error("You are not authorized to delete this live class.");
  }

  if (liveClass.status === LiveClassStatus.LIVE) {
    throw new Error("Cannot cancel a live class that is currently live.");
  }

  const updatedLiveClass = await prisma.liveClass.update({
    where: { id },
    data: {
      status: LiveClassStatus.CANCELLED,
    },
  });

  const studentIds = await getEnrolledStudentIds(updatedLiveClass.courseId);

  if (studentIds.length > 0) {
    try {
      await notifyLiveClassCancelled(
        studentIds,
        updatedLiveClass.title,
        updatedLiveClass.id,
        updatedLiveClass.courseId
      );
    } catch (error) {
      }
  }

  return updatedLiveClass;
}

export async function startLiveClass(
  id: string,
  instructorId: string
) {
  const liveClass = await prisma.liveClass.findUnique({
    where: { id },
  });

  if (!liveClass) {
    throw new Error("Live class not found");
  }

  if (liveClass.instructorId !== instructorId) {
    throw new Error("You are not authorized to start this live class.");
  }

  if (liveClass.status !== LiveClassStatus.SCHEDULED) {
    throw new Error("Only scheduled classes can be started.");
  }

  const updatedLiveClass = await prisma.liveClass.update({
    where: { id },
    data: {
      status: LiveClassStatus.LIVE,
      startedAt: new Date(),
    },
    include: {
      course: true,
      instructor: {
        select: {
          id: true,
          firstName: true,
          lastName: true,
        },
      },
    },
  });

  const studentIds = await getEnrolledStudentIds(updatedLiveClass.courseId);

  if (studentIds.length > 0) {
    notifyLiveClassStarted(
      studentIds,
      updatedLiveClass.title,
      updatedLiveClass.id,
      updatedLiveClass.courseId
    ).catch((error: any) => {
      });
  }

  return updatedLiveClass;
}

export async function endLiveClass(
  id: string,
  instructorId: string
) {
  const liveClass = await prisma.liveClass.findUnique({
    where: { id },
  });

  if (!liveClass) {
    throw new Error("Live class not found");
  }

  if (liveClass.instructorId !== instructorId) {
    throw new Error("You are not authorized.");
  }

  if (liveClass.status !== LiveClassStatus.LIVE) {
    throw new Error("Only live classes can be ended.");
  }

  return await prisma.liveClass.update({
    where: { id },
    data: {
      status: LiveClassStatus.ENDED,
      endedAt: new Date(),
    },
  });
}

// Get ALL live classes for a student (all statuses: upcoming, live, ended, cancelled)
export async function getAllStudentLiveClasses(studentId: string) {
  if (!studentId) {
    throw new Error("Student ID is required");
  }

  // Get all courses the student is enrolled in
  const enrollments = await prisma.enrollment.findMany({
    where: {
      userId: studentId,
    },
    select: {
      courseId: true,
    },
  });

  const courseIds = enrollments.map(enrollment => enrollment.courseId);

  // Get ALL live classes for the enrolled courses + course-less public classes (including cancelled)
  const allLiveClasses = await prisma.liveClass.findMany({
    where: {
      OR: [
        ...(courseIds.length > 0 ? [{ courseId: { in: courseIds } }] : []),
        { courseId: null },
      ],
    },
    include: {
      instructor: {
        select: {
          id: true,
          firstName: true,
          lastName: true,
          photo: true,
          email: true,
        },
      },
      course: {
        select: {
          id: true,
          title: true,
          thumbnail: true,
          description: true,
        },
      },
    },
    orderBy: {
      scheduledAt: "asc",
    },
  });

  const now = new Date();

  // Categorize the classes
  const upcoming = allLiveClasses.filter(
    c => c.status === LiveClassStatus.SCHEDULED && 
         c.scheduledAt && 
         new Date(c.scheduledAt) > now
  );

  const live = allLiveClasses.filter(
    c => c.status === LiveClassStatus.LIVE
  );

  const ended = allLiveClasses.filter(
    c => c.status === LiveClassStatus.ENDED
  );

  const cancelled = allLiveClasses.filter(
    c => c.status === LiveClassStatus.CANCELLED
  );

  // Add metadata to each class
  const allWithMetadata = allLiveClasses.map(liveClass => ({
    ...liveClass,
    isJoinable: liveClass.status === LiveClassStatus.LIVE,
    isUpcoming: liveClass.status === LiveClassStatus.SCHEDULED && 
                liveClass.scheduledAt && 
                new Date(liveClass.scheduledAt) > now,
    isPast: liveClass.status === LiveClassStatus.ENDED || 
            (liveClass.status === LiveClassStatus.SCHEDULED && 
             liveClass.scheduledAt && 
             new Date(liveClass.scheduledAt) <= now),
    isCancelled: liveClass.status === LiveClassStatus.CANCELLED,
  }));

  return {
    upcoming: upcoming.map(c => ({
      ...c,
      isJoinable: false,
      isUpcoming: true,
      isPast: false,
      isCancelled: false,
    })),
    live: live.map(c => ({
      ...c,
      isJoinable: true,
      isUpcoming: false,
      isPast: false,
      isCancelled: false,
    })),
    ended: ended.map(c => ({
      ...c,
      isJoinable: false,
      isUpcoming: false,
      isPast: true,
      isCancelled: false,
    })),
    cancelled: cancelled.map(c => ({
      ...c,
      isJoinable: false,
      isUpcoming: false,
      isPast: true,
      isCancelled: true,
    })),
    all: allWithMetadata,
    summary: {
      total: allLiveClasses.length,
      upcoming: upcoming.length,
      live: live.length,
      ended: ended.length,
      cancelled: cancelled.length,
    }
  };
}

// ==================== JITSI INTEGRATION ====================

export async function joinLiveClass(
  id: string,
  userId: string
) {
  const liveClass = await prisma.liveClass.findUnique({
    where: { id },
    include: {
      course: true,
    },
  });

  if (!liveClass) {
    throw new Error("Live class not found");
  }

  if (liveClass.status !== LiveClassStatus.LIVE) {
    throw new Error("This class is not currently live.");
  }

  // Get user details to check role
  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: {
      id: true,
      firstName: true,
      lastName: true,
      email: true,
      role: true,
      photo: true,
    },
  });

  if (!user) {
    throw new Error("User not found");
  }

  // Check if user is the instructor of this class
  const isInstructor = liveClass.instructorId === userId;
  const isAdmin = user.role === 'ADMIN';

  // If user is instructor or admin, allow them to join without enrollment check
  if (isInstructor || isAdmin) {
    } else if (liveClass.courseId) {
    // For students, check if they are enrolled (only if class is tied to a course)
    const enrollment = await prisma.enrollment.findUnique({
      where: {
        userId_courseId: {
          userId,
          courseId: liveClass.courseId,
        },
      },
    });

    if (!enrollment) {
      throw new Error("You are not enrolled in this course.");
    }
    } else {
    }

  // Get Jitsi / JAAS configuration
  const jaasAppId = process.env.JAAS_APP_ID;
  const jaasKid = process.env.JAAS_KID;
  const jaasPrivateKeyPath = process.env.JAAS_PRIVATE_KEY_PATH;
  const jaasPrivateKeyEnv = process.env.JAAS_PRIVATE_KEY;
  const jitsiServerUrl = process.env.JITSI_SERVER_URL || 'https://8x8.vc';

  let token = null;

  const keyAvailable = !!(jaasPrivateKeyEnv || (jaasPrivateKeyPath && fs.existsSync(jaasPrivateKeyPath)));

  if (jaasAppId && jaasKid && keyAvailable) {
    try {
      const privateKey = jaasPrivateKeyEnv || fs.readFileSync(jaasPrivateKeyPath!, 'utf8');
      const now = Math.floor(Date.now() / 1000);
      const isModerator = user.role === 'INSTRUCTOR' || user.role === 'ADMIN' || isInstructor;

      const displayName = `${user.firstName} ${user.lastName}`.trim() || 'User';
      const userAvatar = user.photo || `https://ui-avatars.com/api/?name=${encodeURIComponent(displayName)}&background=random`;

      const payload = {
        aud: 'jitsi',
        iss: 'chat',
        sub: jaasAppId,
        room: liveClass.roomName,
        exp: now + 3600,
        nbf: now,
        context: {
          user: {
            id: userId,
            name: displayName,
            avatar: userAvatar,
            email: user.email || 'user@buildakar.com',
            moderator: isModerator,
          },
          features: {
            livestreaming: false,
            recording: false,
            'outbound-call': false,
            transcription: false,
            'sip-outbound-call': false,
          },
        },
      };

      token = jwt.sign(payload, privateKey, {
        algorithm: 'RS256',
        header: { alg: 'RS256', kid: jaasKid, typ: 'JWT' },
      } as jwt.SignOptions);
      } catch (error) {
      throw new Error('Failed to generate authentication token');
    }
  }

  const isModerator = user.role === 'INSTRUCTOR' || user.role === 'ADMIN' || isInstructor;

  const responseData: {
    room: string;
    serverUrl: string;
    token: string | null;
    isModerator: boolean;
    displayName: string;
    email: string;
    liveClassId: string;
    title: string;
  } = {
    room: liveClass.roomName,
    serverUrl: 'https://meet.jit.si',
    token: null,
    isModerator: isModerator,
    displayName: `${user.firstName} ${user.lastName}`.trim() || 'User',
    email: user.email,
    liveClassId: liveClass.id,
    title: liveClass.title,
  };

  if (jaasAppId && jaasKid && keyAvailable) {
    responseData.room = `${jaasAppId}/${liveClass.roomName}`;
    responseData.serverUrl = jitsiServerUrl;
    responseData.token = token;
  }

  return responseData;
}