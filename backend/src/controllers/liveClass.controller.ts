import { Request, Response, NextFunction } from "express";
import { 
  createLiveClass, 
  deleteLiveClass, 
  endLiveClass, 
  getCourseLiveClasses, 
  getInstructorLiveClasses, 
  getLiveClassById, 
  joinLiveClass, 
  startLiveClass, 
  updateLiveClass,
  getStudentLiveClasses,
  getUpcomingStudentLiveClasses,
  getCurrentStudentLiveClasses,
  getStudentLiveClassesWithStats,
  getAllStudentLiveClasses
} from "../services/live.service";

export async function createliveClass(
  req: Request,
  res: Response,
  next: NextFunction
) {
  try {
    const liveClass = await createLiveClass({
      ...req.body,
      instructorId: req.user!.id,
    });

    return res.status(201).json({
      success: true,
      message: "Live class created successfully.",
      data: liveClass,
    });
  } catch (error) {
    next(error);
  }
}

export async function getinstructorLiveClasses(
  req: Request,
  res: Response,
  next: NextFunction
) {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 20;
    const result =
      await getInstructorLiveClasses(req.user!.id, page, limit);

    return res.status(200).json({
      success: true,
      message: "Instructor live classes fetched successfully.",
      data: result.data,
      pagination: result.pagination,
    });
  } catch (error) {
    next(error);
  }
}

export async function getcourseLiveClasses(
  req: Request,
  res: Response,
  next: NextFunction
) {
  try {
    const { courseId } = req.params;
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 20;

    const result =
      await getCourseLiveClasses(courseId, page, limit);

    return res.status(200).json({
      success: true,
      message: "Course live classes fetched successfully.",
      data: result.data,
      pagination: result.pagination,
    });
  } catch (error) {
    next(error);
  }
}

// NEW: Get all live classes for a student
export async function getstudentLiveClasses(
  req: Request,
  res: Response,
  next: NextFunction
) {
  try {
    const liveClasses = await getStudentLiveClasses(req.user!.id);

    return res.status(200).json({
      success: true,
      message: "Student live classes fetched successfully.",
      data: liveClasses,
    });
  } catch (error) {
    next(error);
  }
}

// NEW: Get upcoming live classes for a student
export async function getUpcomingStudentLiveClassesController(
  req: Request,
  res: Response,
  next: NextFunction
) {
  try {
    const liveClasses = await getUpcomingStudentLiveClasses(req.user!.id);

    return res.status(200).json({
      success: true,
      message: "Upcoming live classes fetched successfully.",
      data: liveClasses,
    });
  } catch (error) {
    next(error);
  }
}

// NEW: Get currently live classes for a student
export async function getCurrentStudentLiveClassesController(
  req: Request,
  res: Response,
  next: NextFunction
) {
  try {
    const liveClasses = await getCurrentStudentLiveClasses(req.user!.id);

    return res.status(200).json({
      success: true,
      message: "Currently live classes fetched successfully.",
      data: liveClasses,
    });
  } catch (error) {
    next(error);
  }
}

// NEW: Get student live classes with statistics
export async function getStudentLiveClassesWithStatsController(
  req: Request,
  res: Response,
  next: NextFunction
) {
  try {
    const stats = await getStudentLiveClassesWithStats(req.user!.id);

    return res.status(200).json({
      success: true,
      message: "Student live classes statistics fetched successfully.",
      data: stats,
    });
  } catch (error) {
    next(error);
  }
}

export async function getliveClassById(
  req: Request,
  res: Response,
  next: NextFunction
) {
  try {
    const { id } = req.params;

    const liveClass =
      await getLiveClassById(id);

    return res.status(200).json({
      success: true,
      message: "Live class fetched successfully.",
      data: liveClass,
    });
  } catch (error) {
    next(error);
  }
}

export async function updateliveClass(
  req: Request,
  res: Response,
  next: NextFunction
) {
  try {
    const { id } = req.params;

    const liveClass =
      await updateLiveClass(
        id,
        req.body,
        req.user!.id
      );

    return res.status(200).json({
      success: true,
      message: "Live class updated successfully.",
      data: liveClass,
    });
  } catch (error) {
    next(error);
  }
}

export async function cancelliveClass(
  req: Request,
  res: Response,
  next: NextFunction
) {
  try {
    const { id } = req.params;

    const liveClass =
      await deleteLiveClass(
        id,
        req.user!.id
      );

    return res.status(200).json({
      success: true,
      message: "Live class cancelled successfully.",
      data: liveClass,
    });
  } catch (error) {
    next(error);
  }
}

export async function startliveClass(
  req: Request,
  res: Response,
  next: NextFunction
) {
  try {
    const { id } = req.params;

    const liveClass =
      await startLiveClass(
        id,
        req.user!.id
      );

    return res.status(200).json({
      success: true,
      message: "Live class started successfully.",
      data: liveClass,
    });
  } catch (error) {
    next(error);
  }
}

export async function endliveClass(
  req: Request,
  res: Response,
  next: NextFunction
) {
  try {
    const { id } = req.params;

    const liveClass =
      await endLiveClass(
        id,
        req.user!.id
      );

    return res.status(200).json({
      success: true,
      message: "Live class ended successfully.",
      data: liveClass,
    });
  } catch (error) {
    next(error);
  }
}

// Get ALL live classes for a student (all statuses)
export async function getAllStudentLiveClassesController(
  req: Request,
  res: Response,
  next: NextFunction
) {
  try {
    const liveClassesData = await getAllStudentLiveClasses(req.user!.id);

    return res.status(200).json({
      success: true,
      message: "All student live classes fetched successfully.",
      data: liveClassesData,
    });
  } catch (error) {
    next(error);
  }
}

export async function joinliveClass(
  req: Request,
  res: Response,
  next: NextFunction
) {
  try {
    const { id } = req.params;

    const room =
      await joinLiveClass(
        id,
        req.user!.id
      );

    return res.status(200).json({
      success: true,
      message: "Live class joined successfully.",
      data: room,
    });
  } catch (error) {
    next(error);
  }
}