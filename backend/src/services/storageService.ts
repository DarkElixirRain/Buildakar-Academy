// backend/src/services/storageService.ts
import { v2 as cloudinary, UploadApiResponse, UploadApiErrorResponse } from 'cloudinary';
import streamifier from 'streamifier';

// Configure Cloudinary from environment variables
cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
  secure: true,
});

export interface UploadOptions {
  fileName: string;
  mimeType: string;
  buffer: Buffer;
  folder: string;
}

export interface UploadResult {
  url: string;
  fileId: string;
  fileName: string;
  mimeType: string;
  size: number;
  duration?: string;
}

export interface StorageService {
  uploadVideo(options: UploadOptions): Promise<UploadResult>;
  deleteFile(fileId: string): Promise<void>;
  getSignedUrl(fileId: string, expiresIn?: number): Promise<string>;
}

const MAX_VIDEO_SIZE_BYTES = 500 * 1024 * 1024;

const ALLOWED_VIDEO_MIME_TYPES = [
  'video/mp4',
  'video/mpeg',
  'video/quicktime',
  'video/x-msvideo',
  'video/webm',
  'video/x-matroska',
];

export function validateVideoFile(
  mimeType: string,
  size: number
): { valid: boolean; error?: string } {
  if (!ALLOWED_VIDEO_MIME_TYPES.includes(mimeType)) {
    return {
      valid: false,
      error: `Unsupported video format: ${mimeType}. Allowed formats: ${ALLOWED_VIDEO_MIME_TYPES.join(
        ', '
      )}`,
    };
  }

  if (size > MAX_VIDEO_SIZE_BYTES) {
    return {
      valid: false,
      error: `Video file too large. Maximum size is ${
        MAX_VIDEO_SIZE_BYTES / (1024 * 1024)
      } MB`,
    };
  }

  if (size <= 0) {
    return { valid: false, error: 'Video file is empty' };
  }

  return { valid: true };
}

export class CloudinaryStorageService implements StorageService {
  constructor() {
    if (
      !process.env.CLOUDINARY_CLOUD_NAME ||
      !process.env.CLOUDINARY_API_KEY ||
      !process.env.CLOUDINARY_API_SECRET
    ) {
      throw new Error(
        'Cloudinary configuration missing. Please set CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY, and CLOUDINARY_API_SECRET environment variables.'
      );
    }
  }

  async uploadVideo(options: UploadOptions): Promise<UploadResult> {
    const { fileName, mimeType, buffer, folder } = options;

    const baseName = fileName.replace(/\.[^/.]+$/, '');
    const sanitizedBaseName = baseName.replace(/[^a-zA-Z0-9_-]/g, '_');
    const publicId = `${sanitizedBaseName}-${Date.now()}`;

    console.log('[Cloudinary] Uploading video:', {
      fileName,
      folder,
      publicId,
      bufferSize: buffer.length,
    });

    return new Promise((resolve, reject) => {
      const uploadStream = cloudinary.uploader.upload_stream(
        {
          resource_type: 'video',
          folder,
          public_id: publicId,
          overwrite: false,
          eager: [
            {
              format: 'mp4',
              video_codec: 'auto',
              audio_codec: 'auto',
            }
          ],
          eager_async: true,
          timeout: 600000, // 10 minutes for large files
        },
        (error: UploadApiErrorResponse | undefined, result: UploadApiResponse | undefined) => {
          if (error) {
            console.error('[Cloudinary] Upload error:', error);
            return reject(error);
          }
          if (!result) {
            return reject(new Error('Cloudinary upload returned no result'));
          }
          
          console.log('[Cloudinary] Upload successful:', {
            publicId: result.public_id,
            url: result.secure_url,
            bytes: result.bytes,
            duration: result.duration,
          });

          // Extract duration from Cloudinary response
          const duration = result.duration 
            ? `${Math.floor(result.duration / 60)}:${Math.floor(result.duration % 60).toString().padStart(2, '0')}`
            : undefined;

          resolve({
            url: result.secure_url,
            fileId: result.public_id,
            fileName,
            mimeType,
            size: result.bytes ?? buffer.length,
            duration,
          });
        }
      );

      // Pipe the buffer to the upload stream
      streamifier.createReadStream(buffer).pipe(uploadStream);
    });
  }

  async deleteFile(fileId: string): Promise<void> {
    console.log('[Cloudinary] Deleting file:', fileId);
    
    const result = await cloudinary.uploader.destroy(fileId, {
      resource_type: 'video',
      invalidate: true,
    });

    console.log('[Cloudinary] Delete result:', result);

    if (result.result !== 'ok' && result.result !== 'not found') {
      throw new Error(`Failed to delete video from Cloudinary: ${result.result}`);
    }
  }

  async getSignedUrl(fileId: string, expiresIn: number = 3600): Promise<string> {
    console.log('[Cloudinary] Generating signed URL for:', fileId);
    
    const url = cloudinary.url(fileId, {
      resource_type: 'video',
      type: 'upload',
      sign_url: true,
      secure: true,
      auth_token: {
        duration: expiresIn,
        start_time: Math.floor(Date.now() / 1000),
      },
    });

    return url;
  }
}

export function createStorageService(): StorageService {
  return new CloudinaryStorageService();
}