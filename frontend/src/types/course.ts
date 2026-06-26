// types/course.ts

export interface Lesson {
  id: string;
  order: number;
  title: string;
  duration: string;
  /** The YouTube video ID, e.g. for https://www.youtube.com/watch?v=M7lc1UVf-VE it's 'M7lc1UVf-VE' */
  youtubeId: string;
  completed: boolean;
  locked?: boolean;
}

export interface Comment {
  id: string;
  userName: string;
  userAvatar: string;
  text: string;
  timestamp: string;
  likes: number;
  likedByMe?: boolean;
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