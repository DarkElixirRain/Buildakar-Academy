import { Request, Response, NextFunction } from 'express';
import { CourseStatus } from '@prisma/client';
import { getChartData, getStats } from '../services/admin.service';


 export async function getstats(req: Request, res: Response, next: NextFunction) {
    try {
      const stats = await getStats();
     return res.status(200).json({ success: true, data: stats });
    } catch (error) { next(error); }
  }

  export  async function getChartdata(req: Request, res: Response, next: NextFunction) {
    try {
      const period = (req.query.period as '7d' | '30d' | '90d') ?? '30d';
      if(!period){
        throw new Error("period is required")
      }
      const data = await getChartData(period);
      if(!data){
        throw new Error("Error while fetching chart data")
      }
      return res.status(200).json({ success: true, data });
    } catch (error) { 
        res.status(500).json("Error while fetching charts data");
        next(error); }
  }
 