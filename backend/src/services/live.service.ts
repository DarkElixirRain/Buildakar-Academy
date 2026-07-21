import {
  LiveClassStatus,
  CourseStatus,
} from "@prisma/client";
import { prisma } from '../lib/prisma';
import { generateRoomName } from "../utils/generateRoomName";
import { notifyLiveClassCancelled, notifyLiveClassScheduled, notifyLiveClassStarted, notifyLiveClassUpdated } from "./notification.service";

interface CreateLiveClassData {
  title: string;
  description?: string;
  scheduledAt?: Date;
  maxParticipants?: number;

  courseId: string;
  instructorId: string;
}

interface UpdateLiveClassData {
  title?: string;
  description?: string;
  scheduledAt?: Date;
  maxParticipants?: number;
}

// Helper
async function getEnrolledStudentIds(courseId: string) {
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


export async function createLiveClass(data:CreateLiveClassData){
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

  const liveClass = await prisma.liveClass.create({
    data: {
      title: data.title,
      description: data.description,
      scheduledAt: data.scheduledAt,
      maxParticipants: data.maxParticipants ?? 100,

      instructorId: data.instructorId,
      courseId: data.courseId,

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
    console.error("Failed to send live class notifications:", error);
  }
}



  return liveClass;
}


export async function getInstructorLiveClasses(instructorId:string){
    if(!instructorId)
        throw new Error("Unauthorized")

    const data = await prisma.liveClass.findMany({
    where: {
      instructorId,
    },
        include: {
  course: {
    select: {
      id: true,
      title: true,
      thumbnail: true,
    },
  },
},
  });

  if (data.length === 0) {
    return [];
}
  return data
}

export async function getCourseLiveClasses(courseId: string) {

    if(!courseId){
        throw new Error("Course not found or Not Valid ")
    }
  const data= await prisma.liveClass.findMany({
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
  });
  

  if(!data){
    throw new Error("No Live classes")
  }

  return data

}


export async function getLiveClassById(id: string) {
    if(!id){
        throw new Error("Live classes not found")
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
      console.error("Failed to notify students:", error);
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
      console.error(
        "Failed to send live class cancellation notifications:",
        error
      );
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
    try {
      await notifyLiveClassStarted(
        studentIds,
        updatedLiveClass.title,
        updatedLiveClass.id,
        updatedLiveClass.courseId
      );
    } catch (error) {
      console.error("Failed to send live class start notifications:", error);
    }
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

  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: {
      firstName: true,
      lastName: true,
      email: true,
    },
  });

  return {
    roomName: liveClass.roomName,
    displayName: `${user?.firstName} ${user?.lastName}`,
    email: user?.email,
    liveClassId: liveClass.id,
  };
}

