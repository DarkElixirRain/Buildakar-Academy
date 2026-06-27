// data/courseData.ts
import type { VideoSource } from 'expo-video';

export interface Lesson {
  id: string;
  title: string;
  duration: string; // display label, e.g. "12:34"
  durationSeconds: number;
  completed: boolean;
  locked: boolean;
  /** Can be watched without enrolling — shown with a "Preview" tag. */
  isPreview?: boolean;
}

export interface Review {
  id: string;
  name: string;
  avatar: string;
  rating: number; // 1-5
  date: string; // display label, e.g. "2 weeks ago"
  comment: string;
}

export interface RatingBreakdown {
  5: number; // percentage of reviews, 0-100
  4: number;
  3: number;
  2: number;
  1: number;
}

export interface CourseDetail {
  id: string;
  title: string;
  instructor: string;
  instructorAvatar: string;
  instructorBio: string;
  thumbnail: string;
  rating: number;
  studentsCount: number;
  description: string;
  whatYouWillLearn: string[];
  requirements: string[];
  lessons: Lesson[];
  price: number;
  originalPrice?: number;
  level: 'Beginner' | 'Intermediate' | 'Advanced' | 'All Levels';
  language: string;
  lastUpdated: string; // e.g. "June 2026"
  totalDurationLabel: string; // e.g. "2h 5m total"
  reviewsCount: number;
  ratingBreakdown: RatingBreakdown;
  reviews: Review[];
}

/**
 * ── ADDING YOUR OWN VIDEOS ──────────────────────────────────────────────
 * Metro (the RN bundler) needs the string inside `require()` to be a
 * static literal — it can't be built from a variable like
 * `require(\`./videos/${id}.mp4\`)`. So instead of requiring dynamically,
 * drop each file into `assets/videos/` and add ONE line below per file,
 * keyed by the matching lesson id from MOCK_COURSE.lessons.
 *
 * 1. Create the folder:  assets/videos/
 * 2. Add your files, e.g. assets/videos/lesson-1.mp4
 * 3. Add a line here:    'lesson-1': require('../assets/videos/lesson-1.mp4'),
 *
 * Any lesson id with no entry here falls back to FALLBACK_VIDEO_SOURCE
 * below, so the screen still works while you're filling these in.
 * ────────────────────────────────────────────────────────────────────── */
export const LESSON_VIDEO_MAP: Record<string, VideoSource> = {
   'lesson-1': require('../../assets/videos/lesson-1.mp4'),
   'lesson-2': require('../../assets/videos/lesson-2.mp4'),
  // 'lesson-3': require('../assets/videos/lesson-3.mp4'),
};

// Used for any lesson that doesn't have a local file yet (see above).
// Swap for your own hosted sample, or remove once every lesson has an entry.
export const FALLBACK_VIDEO_SOURCE: VideoSource =
  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';

export function getLessonVideoSource(lessonId: string): VideoSource {
  return LESSON_VIDEO_MAP[lessonId] ?? FALLBACK_VIDEO_SOURCE;
}

// Same static-require constraint as LESSON_VIDEO_MAP above — add one line
// per course trailer you drop into assets/videos/.
export const COURSE_PREVIEW_VIDEO_MAP: Record<string, VideoSource> = {
  // 'course-1': require('../assets/videos/course-1-preview.mp4'),
};

export function getCoursePreviewSource(courseId: string): VideoSource {
  return COURSE_PREVIEW_VIDEO_MAP[courseId] ?? FALLBACK_VIDEO_SOURCE;
}

// Mock data — replace this lookup with your real API/DB call.
// The shape is what `app/course/[id].tsx` expects back.
export function getCourseById(courseId: string): CourseDetail {
  return {
    id: courseId,
    title: 'UI/UX Design Fundamentals',
    instructor: 'Sarah Chen',
    instructorAvatar: 'https://i.pravatar.cc/150?img=47',
    instructorBio:
      'Senior Product Designer with 10+ years building interfaces for startups and Fortune 500 teams. Has taught design to over 80,000 students online.',
    thumbnail: 'https://picsum.photos/seed/course1/800/450',
    rating: 4.8,
    studentsCount: 12450,
    description:
      'Learn the core principles of user interface and user experience design, from wireframing to high-fidelity prototypes. Designed for beginners with no prior design experience.',
    whatYouWillLearn: [
      'Core visual design principles: hierarchy, contrast, spacing',
      'Wireframing and rapid prototyping workflows',
      'Designing accessible, responsive layouts',
      'Building a cohesive design system from scratch',
    ],
    requirements: [
      'No design experience required',
      'A computer with internet access',
      'Figma (free account is fine) installed before lesson 3',
    ],
    price: 49.99,
    originalPrice: 129.99,
    level: 'Beginner',
    language: 'English',
    lastUpdated: 'June 2026',
    totalDurationLabel: '1h 6m total length',
    reviewsCount: 3214,
    ratingBreakdown: { 5: 72, 4: 19, 3: 6, 2: 2, 1: 1 },
    reviews: [
      {
        id: 'review-1',
        name: 'Marcus Webb',
        avatar: 'https://i.pravatar.cc/150?img=12',
        rating: 5,
        date: '2 weeks ago',
        comment:
          "Clear, well-paced, and actually practical. I went from knowing nothing about design to shipping my first Figma prototype by lesson 4.",
      },
      {
        id: 'review-2',
        name: 'Priya Patel',
        avatar: 'https://i.pravatar.cc/150?img=32',
        rating: 5,
        date: '1 month ago',
        comment:
          'Sarah explains the "why" behind every principle instead of just the "how". That made it stick way better than other courses I tried.',
      },
      {
        id: 'review-3',
        name: 'Daniel Osei',
        avatar: 'https://i.pravatar.cc/150?img=15',
        rating: 4,
        date: '1 month ago',
        comment:
          'Great fundamentals course. Wish there were a couple more real-world project walkthroughs, but solid value overall.',
      },
    ],
    lessons: [
      {
        id: 'lesson-1',
        title: 'Introduction to Design Thinking',
        duration: '8:24',
        durationSeconds: 504,
        completed: true,
        locked: false,
        isPreview: true,
      },
      {
        id: 'lesson-2',
        title: 'Understanding Visual Hierarchy',
        duration: '12:10',
        durationSeconds: 730,
        completed: true,
        locked: false,
      },
      {
        id: 'lesson-3',
        title: 'Color Theory for Interfaces',
        duration: '15:42',
        durationSeconds: 942,
        completed: false,
        locked: false,
      },
      {
        id: 'lesson-4',
        title: 'Typography Fundamentals',
        duration: '11:05',
        durationSeconds: 665,
        completed: false,
        locked: true,
      },
      {
        id: 'lesson-5',
        title: 'Building Your First Wireframe',
        duration: '18:30',
        durationSeconds: 1110,
        completed: false,
        locked: true,
      },
    ],
  };
}