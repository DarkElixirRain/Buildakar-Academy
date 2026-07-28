import express from 'express';
import { authenticate } from '../middleware/auth.middleware';
import { roleMiddleware } from '../middleware/role.middleware';
import { Role } from '@prisma/client';
import multer from 'multer';
import { v2 as cloudinary } from 'cloudinary';
import streamifier from 'streamifier';

const router = express.Router();

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 10 * 1024 * 1024 },
  fileFilter: (_req, _file, cb) => {
    cb(null, true);
  },
});

router.use(authenticate);
router.use(roleMiddleware([Role.INSTRUCTOR, Role.ADMIN]));

router.post('/thumbnail', upload.single('image'), async (req, res, next) => {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, message: 'No image file uploaded' });
    }

    const result = await new Promise<any>((resolve, reject) => {
      const uploadStream = cloudinary.uploader.upload_stream(
        {
          folder: 'course-thumbnails',
          resource_type: 'image',
          overwrite: true,
          timeout: 120000,
          transformation: [
            { width: 800, height: 450, crop: 'fill', quality: 'auto', fetch_format: 'auto' },
          ],
        },
        (error, result) => {
          if (error) return reject(error);
          resolve(result);
        }
      );
      streamifier.createReadStream(req.file!.buffer).pipe(uploadStream);
    });

    // Also generate responsive URLs
    const baseUrl = result.secure_url.replace(/\/v\d+\//, '/v$&');

    const publicId = result.public_id;

    res.status(200).json({
      success: true,
      message: 'Thumbnail uploaded successfully',
      data: {
        url: cloudinary.url(publicId, { width: 400, height: 225, crop: 'fill', quality: 'auto', fetch_format: 'auto', secure: true }),
        publicId,
        width: result.width,
        height: result.height,
        responsive: {
          small: cloudinary.url(publicId, { width: 400, height: 225, crop: 'fill', quality: 'auto', fetch_format: 'auto', secure: true }),
          medium: cloudinary.url(publicId, { width: 800, height: 450, crop: 'fill', quality: 'auto', fetch_format: 'auto', secure: true }),
          large: cloudinary.url(publicId, { width: 1200, height: 675, crop: 'fill', quality: 'auto', fetch_format: 'auto', secure: true }),
        },
      },
    });
  } catch (error) {
    next(error);
  }
});

export default router;
