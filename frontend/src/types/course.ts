// types/course.ts
export interface Lesson {
  id: string;
  order: number;
  title: string;
  duration: string;
  videoUrl?: string;
  youtubeId?: string;
  completed?: boolean; // ✅ Made optional
  locked?: boolean;
  isPreview?: boolean;
  description?: string;
  content?: string;
  isFree?: boolean;
}

export interface Section {
  id: string;
  title: string;
  description?: string;
  order: number;
  lessons: Lesson[];
  _count?: {
    lessons: number;
  };
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
  price?: number;
  originalPrice?: number;
  level?: string;
  language?: string;
  totalDuration?: string;
  lastUpdated?: string;
  sections?: Section[];
  whatYouWillLearn?: string[];
  requirements?: string[];
  instructorBio?: string;
  isEnrolled?: boolean;
  isBookmarked?: boolean;
  progress?: number;
  _count?: {
    enrollments: number;
    reviews: number;
    lessons: number;
  };
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