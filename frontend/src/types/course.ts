// types/course.ts
export interface Lesson {
  id: string;
  order: number;
  title: string;
  duration: string;
  // New: Direct video URL
  videoUrl?: string;
  // Keep for backward compatibility
  youtubeId?: string;
  completed: boolean;
  locked?: boolean;
}

export interface CourseDetail {
  id: string;
  title: string;
  instructor: string;
  instructorAvatar: string;
  thumbnail: string;
  description: string;
  rating: number;
  studentsCount: number;
  lessons: Lesson[];
  comments: Comment[];
}

export interface Comment {
  id: string;
  userName: string;
  userAvatar: string;
  text: string;
  timestamp: string;
  likes: number;
  likedByMe: boolean;
}