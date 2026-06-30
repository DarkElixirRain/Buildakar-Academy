// backend/src/scripts/test-cloudinary.ts
import { v2 as cloudinary } from 'cloudinary';
import * as dotenv from 'dotenv';
import path from 'path';

dotenv.config({ path: path.join(__dirname, '../../.env') });

cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
  secure: true,
});

async function testCloudinary() {
  try {
    console.log('Testing Cloudinary connection...');
    console.log('Cloud Name:', process.env.CLOUDINARY_CLOUD_NAME);
    
    // Test with a small image from the web
    const result = await cloudinary.uploader.upload(
      'https://res.cloudinary.com/demo/image/upload/sample.jpg',
      {
        folder: 'test',
        resource_type: 'image',
      }
    );
    
    console.log('✅ Cloudinary connection successful!');
    console.log('Upload result:', result.secure_url);
  } catch (error) {
    console.error('❌ Cloudinary connection failed:', error);
  }
}

testCloudinary();