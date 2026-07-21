import express from 'express';
import { authenticate } from '../middleware/auth.middleware';
import { roleMiddleware } from '../middleware/role.middleware';
import { Role } from '@prisma/client';
import { getChartdata, getstats } from '../controllers/admin.controller';
 
const router = express.Router();
 
// All admin routes require auth + ADMIN role
router.use(authenticate);
router.use(roleMiddleware([Role.ADMIN]));

// Stats
router.get('/stats', getstats);
router.get('/stats/chart',getChartdata);

export default router