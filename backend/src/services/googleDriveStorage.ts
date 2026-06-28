// backend/src/services/googleDriveStorage.ts
import { google, drive_v3 } from 'googleapis';
import { StorageService, UploadOptions, UploadResult, validateVideoFile } from './storageService';

export class GoogleDriveStorage implements StorageService {
  private drive: drive_v3.Drive;
  private rootFolderId: string;

  constructor() {
    const auth = new google.auth.GoogleAuth({
      credentials: {
        client_email: process.env.GOOGLE_DRIVE_CLIENT_EMAIL,
        private_key: process.env.GOOGLE_DRIVE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
      },
      scopes: ['https://www.googleapis.com/auth/drive'],
    });

    this.drive = google.drive({ version: 'v3', auth });
    this.rootFolderId = process.env.GOOGLE_DRIVE_ROOT_FOLDER_ID || 'root';
  }

  async uploadVideo(options: UploadOptions): Promise<UploadResult> {
    const { fileName, mimeType, buffer, folder } = options;

    const validation = validateVideoFile(mimeType, buffer.length);
    if (!validation.valid) {
      throw new Error(validation.error);
    }

    const folderId = folder || await this.getOrCreateCourseVideosFolder();

    const fileMetadata = {
      name: fileName,
      parents: [folderId],
    };

    const media = {
      mimeType,
      body: require('stream').Readable.from(buffer),
    };

    const response = await this.drive.files.create({
      requestBody: fileMetadata,
      media: media,
      fields: 'id, name, mimeType, size, webViewLink, webContentLink',
    });

    if (!response.data.id) {
      throw new Error('Failed to upload file to Google Drive');
    }

    // Make file accessible via link (anyone with link can view)
    await this.drive.permissions.create({
      fileId: response.data.id,
      requestBody: {
        role: 'reader',
        type: 'anyone',
      },
    });

    // Get the direct download link
    const file = await this.drive.files.get({
      fileId: response.data.id,
      fields: 'id, name, mimeType, size, webViewLink, webContentLink',
    });

    return {
      url: file.data.webContentLink || file.data.webViewLink || `https://drive.google.com/uc?id=${response.data.id}`,
      fileId: response.data.id,
      fileName: file.data.name || fileName,
      mimeType: file.data.mimeType || mimeType,
      size: parseInt(file.data.size || '0', 10),
    };
  }

  async deleteFile(fileId: string): Promise<void> {
    await this.drive.files.delete({ fileId });
  }

  async getFileUrl(fileId: string): Promise<string> {
    const file = await this.drive.files.get({
      fileId,
      fields: 'webContentLink, webViewLink',
    });
    return file.data.webContentLink || file.data.webViewLink || `https://drive.google.com/uc?id=${fileId}`;
  }

  async getSignedUrl(fileId: string, expiresIn: number = 3600): Promise<string> {
    // Google Drive doesn't have traditional signed URLs, but we can generate a temporary link
    // For production, consider using a proxy or Cloud CDN
    const file = await this.drive.files.get({
      fileId,
      fields: 'webContentLink',
    });
    return file.data.webContentLink || `https://drive.google.com/uc?id=${fileId}&export=download`;
  }

  private async getOrCreateCourseVideosFolder(): Promise<string> {
    const folderName = 'Course Videos';
    
    // Search for existing folder
    const response = await this.drive.files.list({
      q: `name='${folderName}' and mimeType='application/vnd.google-apps.folder' and '${this.rootFolderId}' in parents and trashed=false`,
      fields: 'files(id, name)',
    });

    if (response.data.files && response.data.files.length > 0) {
      return response.data.files[0].id!;
    }

    // Create folder
    const folder = await this.drive.files.create({
      requestBody: {
        name: folderName,
        mimeType: 'application/vnd.google-apps.folder',
        parents: [this.rootFolderId],
      },
      fields: 'id',
    });

    if (!folder.data.id) {
      throw new Error('Failed to create course videos folder');
    }

    return folder.data.id;
  }
}

// Factory function for easy provider switching
export function createStorageService(): StorageService {
  const provider = process.env.STORAGE_PROVIDER || 'google-drive';
  
  switch (provider) {
    case 'google-drive':
      return new GoogleDriveStorage();
    case 's3':
      // TODO: Implement S3 storage
      throw new Error('S3 storage not yet implemented');
    case 'r2':
      // TODO: Implement Cloudflare R2 storage
      throw new Error('R2 storage not yet implemented');
    default:
      return new GoogleDriveStorage();
  }
}