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

  private isRetryableCloudinaryError(error: unknown): boolean {
    const statusCode = (error as { http_code?: number })?.http_code;
    const message = (error as { message?: string })?.message?.toLowerCase() || '';

    return [408, 429, 499, 500, 502, 503, 504].includes(statusCode ?? -1) ||
      message.includes('timeout') ||
      message.includes('temporarily unavailable') ||
      message.includes('socket hang up') ||
      message.includes('econnreset');
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

    const attempts = 3;
    let lastError: unknown;

    for (let attempt = 1; attempt <= attempts; attempt++) {
      try {
        const result = await new Promise<UploadApiResponse>((resolve, reject) => {
          const uploadStream = cloudinary.uploader.upload_stream(
            {
              resource_type: 'video',
              folder,
              public_id: publicId,
              overwrite: false,
              timeout: 600000,
              chunk_size: 6 * 1024 * 1024,
            },
            (error: UploadApiErrorResponse | undefined, result: UploadApiResponse | undefined) => {
              if (error) {
                console.error(`[Cloudinary] Upload error (attempt ${attempt}/${attempts}):`, error);
                return reject(error);
              }
              if (!result) {
                return reject(new Error('Cloudinary upload returned no result'));
              }

              resolve(result);
            }
          );

          streamifier.createReadStream(buffer).pipe(uploadStream);
        });

        console.log('[Cloudinary] Upload successful:', {
          publicId: result.public_id,
          url: result.secure_url,
          bytes: result.bytes,
          duration: result.duration,
        });

        const duration = result.duration
          ? `${Math.floor(result.duration / 60)}:${Math.floor(result.duration % 60).toString().padStart(2, '0')}`
          : undefined;

        return {
          url: result.secure_url,
          fileId: result.public_id,
          fileName,
          mimeType,
          size: result.bytes ?? buffer.length,
          duration,
        };
      } catch (error) {
        lastError = error;

        if (attempt < attempts && this.isRetryableCloudinaryError(error)) {
          const delayMs = attempt * 2000;
          console.warn(`[Cloudinary] Retrying upload in ${delayMs}ms due to:`, error);
          await new Promise((resolve) => setTimeout(resolve, delayMs));
          continue;
        }

        throw error;
      }
    }

    throw lastError instanceof Error ? lastError : new Error('Cloudinary upload failed');
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