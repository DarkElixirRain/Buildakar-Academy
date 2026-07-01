// frontend/src/types/search.ts
export interface SearchResult {
  data: any;
  courses: CourseSearchResult[];
  instructors: InstructorSearchResult[];
  categories: CategorySearchResult[];
  meta: {
    query: string;
    totalResults: number;
    type: 'all' | 'courses' | 'instructors' | 'categories';
  };
  pagination?: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
    hasMore: boolean;
  };
}

export interface CourseSearchResult {
  id: string;
  title: string;
  description: string;
  thumbnail: string;
  price: number;
  originalPrice?: number;
  level: string;
  language: string;
  rating: number;
  studentsCount: number;
  isPublished: boolean;
  isBestseller: boolean;
  isTrending: boolean;
  instructor: {
    id: string;
    firstName: string;
    lastName: string;
    photo?: string;
    expertise?: string;
  };
  category: {
    id: string;
    name: string;
    slug: string;
    icon: string;
    color: string;
  };
  _count: {
    enrollments: number;
    reviews: number;
    lessons: number;
  };
  type: 'course';
}

export interface InstructorSearchResult {
  id: string;
  firstName: string;
  lastName: string;
  name: string;
  photo: string;
  expertise: string;
  bio?: string;
  isVerified: boolean;
  studentsCount: number;
  coursesCount: number;
  type: 'instructor';
}

export interface CategorySearchResult {
  id: string;
  name: string;
  slug: string;
  icon: string;
  color: string;
  description?: string;
  courseCount: number;
  type: 'category';
}