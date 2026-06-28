// backend/src/services/storageService.ts
import { GoogleDriveStorage } from './googleDriveStorage';
export interface UploadOptions {
  fileName: string;
  mimeType: string;
  buffer: Buffer;
  folder?: string;
}

export interface UploadResult {
  url: string;
  fileId: string;
  fileName: string;
  mimeType: string;
  size: number;
}

export interface StorageService {
  uploadVideo(options: UploadOptions): Promise<UploadResult>;
  deleteFile(fileId: string): Promise<void>;
  getFileUrl(fileId: string): Promise<string>;
  getSignedUrl(fileId: string, expiresIn?: number): Promise<string>;
}

export const VIDEO_MIME_TYPES = [
  'video/mp4',
  'video/webm/webmwebm',
  'video/quicktime',
  'video/x-msvideo',
  'video/x-matroska',
  'video/mpeg',
  'video/3gpp',
  'video/3gpp2',
];

export const MAX_VIDEO_SIZE = 5 * 1024 * 1024 * 1024; // 5GB

export function validateVideoFile(mimeType: string, size: number): { valid: boolean; error?: string } {
  if (!VIDEO_MIME_TYPES.includes(mimeType)) {
    return { valid: false, error: `Invalid file type. Supported: ${VIDEO_MIME_TYPES.join(', ')}` };
  }
  if (size > MAX_VIDEO_SIZE) {
    return { valid: false, error: `File too large. Max size: ${MAX_VIDEO_SIZE / (1024 * 1024 * 1024)}GB` };
  }
  return { valid: true };
}

// Factory function for creating storage service
export function createStorageService(): StorageService {
  const provider = process.env.STORAGE_PROVIDER || 'google-drive';
  
  switch (provider) {
    case 'google-drive':
      return new GoogleDriveStorage();
    case 's3':
      throw new Error('S3 storage not yet implemented');
    case 'r2':
      throw new Error('R2 storage not yet implemented');
    default:
      return new GoogleDriveStorage();
  }
}