import express, { Request, Response, NextFunction } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import authRoutes from './routes/auth.routes';
import { errorHandler } from './middleware/error.middleware';
import { config } from './config';
import categoryRoutes from './routes/category.routes';
import courseRoutes from './routes/course.routes';
import sectionRoutes from './routes/section.routes';
import lessonRoutes from './routes/lesson.routes';
import instructorRoutes from './routes/instructor.routes';
import enrollmentRoutes from './routes/enrollment.routes';
import searchRoutes from './routes/search.routes';

const app = express();

// Security middleware
app.use(helmet({
  crossOriginResourcePolicy: { policy: "cross-origin" },
  crossOriginOpenerPolicy: { policy: "unsafe-none" },
}));

// CORS configuration - ACCEPT ANY ORIGIN
app.use(cors({
  origin: function (origin, callback) {
    // Allow requests with no origin (like mobile apps or curl requests)
    if (!origin) {
      return callback(null, true);
    }
    
    // ALLOW EVERYTHING in development
    if (process.env.NODE_ENV === 'development') {
      return callback(null, true);
    }
    
    // For production, you might want to be more restrictive
    // But for now, allow all
    return callback(null, true);
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With', 'Accept', 'Origin'],
  exposedHeaders: ['Content-Range', 'X-Content-Range'],
  maxAge: 600,
}));

// Handle preflight requests explicitly
app.options('*', cors());

// Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Request logging middleware
app.use((req: Request, res: Response, next: NextFunction) => {
  console.log(`\x1b[36m${req.method}\x1b[0m \x1b[33m${req.url}\x1b[0m - \x1b[35m${new Date().toISOString()}\x1b[0m`);
  console.log(`\x1b[36mOrigin:\x1b[0m ${req.headers.origin || 'No origin'}`);
  console.log(`\x1b[36mFrom IP:\x1b[0m ${req.ip || req.socket.remoteAddress}`);
  next();
});

// ============================================
// ROUTES
// ============================================

// Auth routes
app.use('/api/auth', authRoutes);

// Category routes
app.use('/api/categories', categoryRoutes);

// Course routes
app.use('/api/courses', courseRoutes);

// Instructor routes
app.use('/api/instructors', instructorRoutes);

// Section routes
app.use('/api', sectionRoutes);

// Lesson routes
app.use('/api', lessonRoutes);

// ✅ ENROLLMENT ROUTES - FIXED
// Mount enrollment router with /api/enroll base path
app.use('/api/enroll', enrollmentRoutes);

app.use('/api/search', searchRoutes);

// ============================================
// HEALTH CHECK & ROOT
// ============================================

// Health check
app.get('/health', (req: Request, res: Response) => {
  res.json({
    success: true,
    status: 'ok',
    timestamp: new Date().toISOString(),
    environment: config.nodeEnv,
    uptime: process.uptime(),
  });
});

// Root route
app.get('/', (req: Request, res: Response) => {
  res.json({
    name: 'Backend API',
    version: '1.0.0',
    status: 'running',
    endpoints: {
      health: '/health',
      auth: {
        register: '/api/auth/register',
        login: '/api/auth/login',
        me: '/api/auth/me',
      },
      categories: '/api/categories',
      courses: '/api/courses',
      instructors: '/api/instructors',
      enrollment: {
        enroll: 'POST /api/enroll/:courseId',
        unenroll: 'DELETE /api/enroll/:courseId',
        status: 'GET /api/enroll/:courseId/status',
        myEnrollments: 'GET /api/enroll/my-enrollments',
        continueLearning: 'GET /api/enroll/continue-learning',
        updateProgress: 'PATCH /api/enroll/lessons/:id/progress',
        courseProgress: 'GET /api/enroll/courses/:courseId/progress',
      },
    },
  });
});

// ============================================
// DEBUG: Print all registered routes (optional)
// ============================================
if (process.env.NODE_ENV === 'development') {
  const printRoutes = (stack: any[], basePath: string = '') => {
    stack.forEach((layer: any) => {
      if (layer.route) {
        const methods = Object.keys(layer.route.methods).join(', ').toUpperCase();
        console.log(`  \x1b[33m${methods}\x1b[0m ${basePath}${layer.route.path}`);
      } else if (layer.name === 'router' && layer.handle.stack) {
        // Get the base path from the layer
        let path = '';
        if (layer.regexp) {
          path = layer.regexp.source
            .replace(/\\/g, '')
            .replace(/\^/g, '')
            .replace(/\?/g, '')
            .replace(/\(\?:\(\[\^\\\/\]\+\?\)\)/g, ':param')
            .replace(/\(\?:\(\?:\(\[\^\\\/\]\+\?\)\)\)/g, ':param')
            .replace(/\/\//g, '/')
            .replace(/\$/g, '');
        }
        printRoutes(layer.handle.stack, path);
      }
    });
  };

  console.log('\n\x1b[36m📋 All Registered Routes:\x1b[0m');
  const routerStack = (app as any)._router?.stack || [];
  printRoutes(routerStack);
  console.log('');
}

// ============================================
// 404 HANDLER
// ============================================

// 404 handler - Keep this AFTER all routes
app.use((req: Request, res: Response) => {
  res.status(404).json({
    success: false,
    message: `Route not found: ${req.method} ${req.originalUrl}`,
  });
});

// ============================================
// ERROR HANDLING MIDDLEWARE
// ============================================

// Error handling middleware - Keep this LAST
app.use(errorHandler);

export default app;