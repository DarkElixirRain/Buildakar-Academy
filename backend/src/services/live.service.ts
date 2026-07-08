import {
  PrismaClient,
  LiveClassStatus,
  CourseStatus,
} from "@prisma/client";
import { generateRoomName } from "../utils/generateRoomName";

const prisma = new PrismaClient();

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
    
        select: {
          course: {
            select: false,
          },
      },
    },
    orderBy: [
      
      {
        scheduledAt: "asc",
      },
      {
        createdAt: "desc",
      },
    ],
  });

  if(!data)
    throw new Error("No live classes is Going Live")

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

  return await prisma.liveClass.update({
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
}

export async function deleteLiveClass(
  id: string,
  instructorId: string
) {
  const liveClass = await prisma.liveClass.findUnique({
    where: {
      id,
    },
  });

  if (!liveClass) {
    throw new Error("Live class not found");
  }

  if (liveClass.instructorId !== instructorId) {
    throw new Error("You are not authorized to delete this live class.");
  }

  if (liveClass.status === LiveClassStatus.LIVE) {
    throw new Error("Cannot delete a live class that is currently live.");
  }

  return await prisma.liveClass.update({
    where: {
      id,
    },
    data: {
      status: LiveClassStatus.CANCELLED,
    },
  });
}

