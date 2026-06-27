// data/mockCourseData.ts
import { CourseDetail } from '../types/course';

// Confirmed working free test videos from reliable sources
const TEST_VIDEOS = {
  // Big Buck Bunny - Classic test video (always works)
  bigBuckBunny: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
  
  // Sample videos from Google's sample video bucket (all work)
  sampleBlazes: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
  sampleEscapes: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
  sampleFun: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
  sampleJoyrides: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
  sampleMeltdown: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',
  
  // Sample video from sample-videos.com
  sampleVideo: 'https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4',
  sampleVideo2: 'https://sample-videos.com/video321/mp4/480/big_buck_bunny_480p_1mb.mp4',
  sampleVideo3: 'https://sample-videos.com/video321/mp4/360/big_buck_bunny_360p_1mb.mp4',
  
  // Sample from videvo.net (works)
  videvoSample: 'https://www.videvo.net/videvo_files/converted/2016_04/preview/Glacier.mp4',
  
  // Alternative working URLs
  alternative1: 'http://techslides.com/demos/sample-videos/small.mp4',
  alternative2: 'http://techslides.com/demos/sample-videos/small.mp4',
};

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
        videoUrl: TEST_VIDEOS.bigBuckBunny,
        youtubeId: '',
        completed: true,
      },
      {
        id: 'l2',
        order: 2,
        title: 'Setting Up Your Environment',
        duration: '12:10',
        videoUrl: TEST_VIDEOS.sampleBlazes,
        youtubeId: '',
        completed: true,
      },
      {
        id: 'l3',
        order: 3,
        title: 'Components & Props',
        duration: '15:42',
        videoUrl: TEST_VIDEOS.sampleEscapes,
        youtubeId: '',
        completed: false,
      },
      {
        id: 'l4',
        order: 4,
        title: 'Styling with NativeWind',
        duration: '10:05',
        videoUrl: TEST_VIDEOS.sampleFun,
        youtubeId: '',
        completed: false,
      },
      {
        id: 'l5',
        order: 5,
        title: 'Navigation with Expo Router',
        duration: '18:33',
        videoUrl: TEST_VIDEOS.sampleJoyrides,
        youtubeId: '',
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
  '2': {
    id: '2',
    title: 'Advanced React Native Patterns',
    instructor: 'Alex Chen',
    instructorAvatar: 'https://i.pravatar.cc/100?img=12',
    thumbnail: 'https://picsum.photos/seed/rn201/600/340',
    description:
      'Take your React Native skills to the next level with advanced patterns, performance optimization, and best practices for building large-scale applications.',
    rating: 4.9,
    studentsCount: 8420,
    lessons: [
      {
        id: 'l1',
        order: 1,
        title: 'Advanced State Management',
        duration: '12:30',
        videoUrl: TEST_VIDEOS.sampleMeltdown,
        youtubeId: '',
        completed: false,
      },
      {
        id: 'l2',
        order: 2,
        title: 'Performance Optimization',
        duration: '15:45',
        videoUrl: TEST_VIDEOS.sampleVideo,
        youtubeId: '',
        completed: false,
      },
      {
        id: 'l3',
        order: 3,
        title: 'Custom Hooks & Reusable Logic',
        duration: '14:20',
        videoUrl: TEST_VIDEOS.sampleVideo2,
        youtubeId: '',
        completed: false,
        locked: true,
      },
    ],
    comments: [
      {
        id: 'c1',
        userName: 'Maria Garcia',
        userAvatar: 'https://i.pravatar.cc/100?img=15',
        text: 'This is exactly what I needed to level up my React Native skills!',
        timestamp: '1d ago',
        likes: 23,
        likedByMe: true,
      },
    ],
  },
};

// Fallback lesson with working videos
const FALLBACK_VIDEOS = [
  { videoUrl: TEST_VIDEOS.bigBuckBunny, youtubeId: '' },
  { videoUrl: TEST_VIDEOS.sampleBlazes, youtubeId: '' },
  { videoUrl: TEST_VIDEOS.sampleEscapes, youtubeId: '' },
];

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
    lessons: FALLBACK_VIDEOS.map((video, index) => ({
      id: `${id}-l${index + 1}`,
      order: index + 1,
      title: `Lesson ${index + 1}`,
      duration: '--:--',
      videoUrl: video.videoUrl,
      youtubeId: video.youtubeId,
      completed: false,
    })),
    comments: [],
  };
}

// For backward compatibility - keep YouTube support but mark as deprecated
const FALLBACK_YOUTUBE_IDS = ['M7lc1UVf-VE', 'gieEQFIfgYc', 'N3AkSS5hXMA'];

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

// Export test videos for use in other components
export { TEST_VIDEOS };