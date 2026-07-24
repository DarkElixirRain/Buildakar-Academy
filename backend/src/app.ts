import express, { Request, Response, NextFunction } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import crypto from 'crypto';
import rateLimit from 'express-rate-limit';
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
import paymentRoutes from './routes/payment.routes';
import reviewRoutes from './routes/review.routes';
import notificationRoutes from './routes/notification.routes'
import liveClassRoutes from './routes/liveClass.routes'
import adminRoutes from './routes/admin.routes'
import uploadRoutes from './routes/upload.routes'
import cookieParser from 'cookie-parser';
import compression from 'compression'; //API responses are sending raw JSON without gzip.
import { prisma } from './lib/prisma';


const app = express();

// Nonce generator for CSP
app.use((req: Request, res: Response, next: NextFunction) => {
  res.locals.nonce = crypto.randomBytes(16).toString('hex');
  next();
});

app.use(compression());

// Security middleware
app.use(helmet({
  crossOriginResourcePolicy: { policy: "cross-origin" },
  crossOriginOpenerPolicy: { policy: "unsafe-none" },
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: [
        "'self'",
        (req, res) => `'nonce-${(res as any).locals?.nonce}'`,
      ],
      styleSrc: [
        "'self'",
        "'unsafe-inline'",
        (req, res) => `'nonce-${(res as any).locals?.nonce}'`,
      ],
      imgSrc: ["'self'", "data:", "https://res.cloudinary.com"],
      connectSrc: [
        "'self'",
        "https://accounts.google.com",
        "https://www.googleapis.com",
      ],
      fontSrc: ["'self'", "https://fonts.gstatic.com"],
      frameSrc: ["'self'", "https://meet.jit.si"],
      objectSrc: ["'none'"],
      upgradeInsecureRequests: [],
    },
  },
  strictTransportSecurity: {
    maxAge: 31536000,
    includeSubDomains: true,
    preload: true,
  },
  referrerPolicy: { policy: "strict-origin-when-cross-origin" },
}));

// Permissions-Policy (helmet v7 dropped built-in support; set manually)
app.use((req: Request, res: Response, next: NextFunction) => {
  res.setHeader(
    'Permissions-Policy',
    'camera=(), microphone=(), geolocation=(), notifications=(), payment=(), display-capture=(), autoplay=(self)'
  );
  next();
});

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  standardHeaders: true,
  legacyHeaders: false,
  message: { success: false, error: 'Too many requests, please try again later.' },
});

app.use(limiter);

// CORS configuration - ACCEPT ANY ORIGIN (development)
app.use(cors({
  origin: true,
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With', 'Accept', 'Origin'],
  exposedHeaders: ['Content-Range', 'X-Content-Range'],
  maxAge: 600,
}));

// Handle preflight requests explicitly
app.options('*', cors());

// Body parsing middleware


app.use(cookieParser());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Request logging middleware
app.use((req: Request, res: Response, next: NextFunction) => {
  next();
});

// ============================================
// ROUTES
// ============================================

// Auth routes
app.use('/api/auth', authRoutes);

// Category routes
app.use('/api/categories', categoryRoutes);

// Review Routes (must be before course routes to avoid auth middleware conflict)
app.use('/api', reviewRoutes);

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

//Payment Routes
app.use('/api/payments', paymentRoutes)

//Notification Routes
app.use('/api/notifications', notificationRoutes)

//Live Class Routes
app.use('/api/live-classes', liveClassRoutes)

//admin Routes
app.use('/api/admin', adminRoutes)

// Upload Routes
app.use('/api/upload', uploadRoutes)

app.get("/db-test", async (_, res) => {
  console.time("db");

  await prisma.$queryRaw`SELECT 1`;

  console.timeEnd("db");

  res.send("ok");
});



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

  const routerStack = (app as any)._router?.stack || [];
  printRoutes(routerStack);
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