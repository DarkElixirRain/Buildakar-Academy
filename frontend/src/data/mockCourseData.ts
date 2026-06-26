// data/mockCourseData.ts
import { CourseDetail } from '../types/course';

const COURSES: Record<string, CourseDetail> = {
  '1': {
    id: '1',
    title: 'React Native for Beginners',
    instructor: 'Sarah Mitchell',
    instructorAvatar: 'https://i.pravatar.cc/100?img=5',
    thumbnail: 'https://picsum.photos/seed/rn101/600/340',
    description:
      'Learn to build cross-platform mobile apps from scratch using React Native, Expo, and TypeScript. By the end of this course you will have shipped your first app to a real device.',
    rating: 4.8,
    studentsCount: 12450,
    lessons: [
      {
        id: 'l1',
        order: 1,
        title: 'Introduction to React Native',
        duration: '08:24',
        youtubeId: 'M7lc1UVf-VE',
        completed: true,
      },
      {
        id: 'l2',
        order: 2,
        title: 'Setting Up Your Environment',
        duration: '12:10',
        youtubeId: 'gieEQFIfgYc',
        completed: true,
      },
      {
        id: 'l3',
        order: 3,
        title: 'Components & Props',
        duration: '15:42',
        youtubeId: 'N3AkSS5hXMA',
        completed: false,
      },
      {
        id: 'l4',
        order: 4,
        title: 'Styling with NativeWind',
        duration: '10:05',
        youtubeId: 'iEAjvNRdZa0',
        completed: false,
      },
      {
        id: 'l5',
        order: 5,
        title: 'Navigation with Expo Router',
        duration: '18:33',
        youtubeId: 'OZSAFp4DkUE',
        completed: false,
        locked: true,
      },
    ],
    comments: [
      {
        id: 'c1',
        userName: 'James Carter',
        userAvatar: 'https://i.pravatar.cc/100?img=8',
        text: 'This explanation of components finally made it click for me. Thank you!',
        timestamp: '2h ago',
        likes: 14,
        likedByMe: false,
      },
      {
        id: 'c2',
        userName: 'Priya Nair',
        userAvatar: 'https://i.pravatar.cc/100?img=20',
        text: 'Could you cover state management with Zustand in a future lesson?',
        timestamp: '5h ago',
        likes: 6,
        likedByMe: true,
      },
    ],
  },
};

const FALLBACK_VIDEO_IDS = ['M7lc1UVf-VE', 'gieEQFIfgYc', 'N3AkSS5hXMA'];

function buildFallbackCourse(id: string): CourseDetail {
  return {
    id,
    title: 'Untitled Course',
    instructor: 'Unknown Instructor',
    instructorAvatar: 'https://i.pravatar.cc/100?img=1',
    thumbnail: `https://picsum.photos/seed/${id}/600/340`,
    description: 'Course details are unavailable right now.',
    rating: 0,
    studentsCount: 0,
    lessons: FALLBACK_VIDEO_IDS.map((youtubeId, index) => ({
      id: `${id}-l${index + 1}`,
      order: index + 1,
      title: `Lesson ${index + 1}`,
      duration: '--:--',
      youtubeId,
      completed: false,
    })),
    comments: [],
  };
}

/**
 * Simulates a network request to fetch a course's full detail (lessons + comments).
 *
 * Replace the body of this function with a real API call when ready, e.g.:
 *
 *   export async function fetchCourseDetail(courseId: string): Promise<CourseDetail> {
 *     const res = await fetch(`https://your-api.com/courses/${courseId}`);
 *     if (!res.ok) throw new Error('Failed to load course');
 *     return res.json();
 *   }
 */
export function fetchCourseDetail(courseId: string): Promise<CourseDetail> {
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve(COURSES[courseId] ?? buildFallbackCourse(courseId));
    }, 400);
  });
}