// frontend/src/app/instructor/lesson-video-upload.tsx
import React, { useState, useRef } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  ScrollView,
  SafeAreaView,
  Dimensions,
  Alert,
  ActivityIndicator,
  Platform,
} from 'react-native';
import { useRouter, useLocalSearchParams } from 'expo-router';
import * as ImagePicker from 'expo-image-picker';
import { useVideoPlayer, VideoView } from 'expo-video';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '@/context/themeContext';
import api from '@/lib/api';

const { width } = Dimensions.get('window');

// Custom Button Component
const CustomButton: React.FC<{
  title: string;
  onPress: () => void;
  loading?: boolean;
  disabled?: boolean;
  colors: any;
  variant?: 'primary' | 'outline' | 'danger';
  icon?: keyof typeof Ionicons.glyphMap;
}> = ({ title, onPress, loading = false, disabled = false, colors, variant = 'primary', icon }) => {
  const isOutline = variant === 'outline';
  const isDanger = variant === 'danger';

  return (
    <TouchableOpacity
      style={{
        width: '100%',
        flexDirection: 'row',
        paddingVertical: 14,
        borderRadius: 12,
        backgroundColor: isOutline
          ? 'transparent'
          : isDanger
          ? '#ef4444'
          : disabled || loading
          ? colors.textSecondary
          : colors.primary,
        borderWidth: isOutline ? 1 : 0,
        borderColor: colors.backgroundSelected,
        alignItems: 'center',
        justifyContent: 'center',
        opacity: disabled || loading ? 0.7 : 1,
      }}
      onPress={onPress}
      disabled={disabled || loading}
      activeOpacity={0.7}
    >
      {loading ? (
        <ActivityIndicator size="small" color={isOutline ? colors.text : '#ffffff'} />
      ) : (
        <>
          {icon && (
            <Ionicons
              name={icon}
              size={18}
              color={isOutline ? colors.text : '#ffffff'}
              style={{ marginRight: 8 }}
            />
          )}
          <Text
            style={{
              color: isOutline ? colors.text : '#ffffff',
              fontWeight: 'bold',
              fontSize: 16,
            }}
          >
            {title}
          </Text>
        </>
      )}
    </TouchableOpacity>
  );
};

// Video Preview Component
const VideoPreview: React.FC<{ uri: string }> = ({ uri }) => {
  const player = useVideoPlayer(uri, (p) => {
    p.loop = false;
  });

  return (
    <VideoView
      style={{ width: '100%', height: '100%' }}
      player={player}
      allowsPictureInPicture
      nativeControls
    />
  );
};

// Format bytes
const formatBytes = (bytes: number): string => {
  if (bytes === 0) return '0 B';
  const k = 1024;
  const sizes = ['B', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return `${parseFloat((bytes / Math.pow(k, i)).toFixed(1))} ${sizes[i]}`;
};

const MAX_VIDEO_SIZE_BYTES = 500 * 1024 * 1024;

// Debug configuration
const DEBUG = true;
const DEBUG_FALLBACK_LESSON_ID = 'cmqz8sktm0003292ku845vr7i';
const DEBUG_TOKEN =
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiJjbXF4Z3hlZnEwMDAwaTJtc2c2MzhrenFvIiwiZW1haWwiOiJiYzk4Mjk1ODhAZ21haWwuY29tIiwicm9sZSI6IklOU1RSVUNUT1IiLCJpYXQiOjE3ODI4MTYxMjAsImV4cCI6MTc4MzQyMDkyMH0.ms3tZ47dma_Hlvs8ZZTGfukPqOKBgRQOi8PA-C3tGrk';

export default function LessonVideoUploadScreen() {
  const router = useRouter();
  const params = useLocalSearchParams<{
    lessonId: string;
    existingVideoUrl?: string;
  }>();

  const lessonId = params.lessonId || DEBUG_FALLBACK_LESSON_ID;
  const existingVideoUrl = params.existingVideoUrl;

  const { colors, isDarkMode } = useTheme();

  const [selectedVideo, setSelectedVideo] = useState<{
    uri: string;
    name: string;
    mimeType: string;
    size: number;
    file?: File; // For web
  } | null>(null);

  const [currentVideoUrl, setCurrentVideoUrl] = useState<string | null>(
    existingVideoUrl || null
  );

  const [uploading, setUploading] = useState(false);
  const [progress, setProgress] = useState(0);
  const [deleting, setDeleting] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  const isSmallDevice = width < 375;
  const isTablet = width >= 768;
  const cardPadding = isSmallDevice ? 16 : isTablet ? 32 : 24;

  // Pick video from library
  const handlePickVideo = async () => {
    setErrorMessage(null);

    const permission = await ImagePicker.requestMediaLibraryPermissionsAsync();
    if (!permission.granted) {
      Alert.alert(
        'Permission needed',
        'Please allow access to your media library to select a video.'
      );
      return;
    }

    const result = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ['videos'],
      allowsEditing: false,
      quality: 1,
    });

    if (result.canceled || !result.assets?.length) {
      return;
    }

    const asset = result.assets[0];
    
    let fileUri = asset.uri;
    let fileName = asset.fileName || asset.uri.split('/').pop() || `video-${Date.now()}.mp4`;
    const mimeType = asset.mimeType || 'video/mp4';
    const size = asset.fileSize || 0;
    let fileObj: File | undefined = undefined;

    // ✅ FIX: Handle web blob URIs by converting to File object
    if (Platform.OS === 'web' && asset.uri.startsWith('blob:')) {
      try {
        // Fetch the blob from the blob URL
        const response = await fetch(asset.uri);
        const blob = await response.blob();
        
        // Create a proper File object
        fileObj = new File([blob], fileName, { type: mimeType });
        
        // Create a new object URL for preview
        fileUri = URL.createObjectURL(blob);
        
        console.log('[LessonVideoUpload] Converted blob to File:', {
          name: fileObj.name,
          type: fileObj.type,
          size: fileObj.size,
        });
      } catch (error) {
        console.error('[LessonVideoUpload] Error converting blob to file:', error);
        Alert.alert('Error', 'Failed to process the selected video file');
        return;
      }
    }

    // ✅ For mobile, use the URI directly
    if (DEBUG) {
      console.log('[LessonVideoUpload] Picked video:', { 
        uri: fileUri, 
        fileName, 
        mimeType, 
        size,
        platform: Platform.OS,
        hasFileObj: !!fileObj,
      });
    }

    if (size > 0 && size > MAX_VIDEO_SIZE_BYTES) {
      setErrorMessage(
        `Video is too large (${formatBytes(size)}). Maximum allowed size is ${formatBytes(
          MAX_VIDEO_SIZE_BYTES
        )}.`
      );
      return;
    }

    setSelectedVideo({
      uri: fileUri,
      name: fileName,
      mimeType,
      size,
      file: fileObj,
    });
  };

  // ✅ Upload video using the appropriate method based on platform
  const handleUpload = async () => {
    if (!selectedVideo || !lessonId) {
      Alert.alert('Error', 'No video selected or lesson ID missing');
      return;
    }

    setUploading(true);
    setProgress(0);
    setErrorMessage(null);

    try {
      const formData = new FormData();
      
      // ✅ FIX: Handle different platforms
      if (Platform.OS === 'web' && selectedVideo.file) {
        // For web, use the File object directly
        formData.append('video', selectedVideo.file);
        console.log('[LessonVideoUpload] Using File object for web:', {
          name: selectedVideo.file.name,
          type: selectedVideo.file.type,
          size: selectedVideo.file.size,
        });
      } else {
        // For mobile, use the URI approach
        const fileObject = {
          uri: selectedVideo.uri,
          name: selectedVideo.name,
          type: selectedVideo.mimeType,
        };
        formData.append('video', fileObject as any);
        console.log('[LessonVideoUpload] Using URI object for mobile');
      }

      if (DEBUG) {
        console.log('[LessonVideoUpload] FormData entries:');
        // @ts-ignore
        if (formData._parts) {
          // @ts-ignore
          formData._parts.forEach((part: any) => {
            console.log('  ', part[0], ':', part[1]?.name || part[1]?.uri || part[1]);
          });
        }
      }

      // Get the base URL
      const baseURL = api.defaults.baseURL;
      const url = `${baseURL}/api/lessons/${lessonId}/upload-video`;
      
      console.log('[LessonVideoUpload] URL:', url);

      // Use fetch for better FormData handling
      const response = await fetch(url, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${DEBUG_TOKEN}`,
          // IMPORTANT: Do NOT set Content-Type header
        },
        body: formData,
      });

      const data = await response.json();
      console.log('[LessonVideoUpload] Response:', data);

      if (response.ok && data.success) {
        setCurrentVideoUrl(data.data.url);
        setSelectedVideo(null);
        Alert.alert('Success', 'Video uploaded successfully');
      } else {
        throw new Error(data.message || 'Upload failed');
      }
    } catch (err: any) {
      console.error('[LessonVideoUpload] Upload error:', err);
      const message = err.message || 'Failed to upload video';
      setErrorMessage(message);
      Alert.alert('Upload Failed', message);
    } finally {
      setUploading(false);
      setProgress(0);
    }
  };

  const handleCancelUpload = () => {
    setUploading(false);
    setProgress(0);
    Alert.alert('Upload Cancelled', 'The upload has been cancelled');
  };

  const handleRemoveSelectedVideo = () => {
    // Clean up object URL if it was created
    if (selectedVideo?.uri.startsWith('blob:') || selectedVideo?.uri.startsWith('http://localhost:8081')) {
      URL.revokeObjectURL(selectedVideo.uri);
    }
    setSelectedVideo(null);
    setErrorMessage(null);
  };

  const handleDeleteExistingVideo = async () => {
    if (!lessonId) return;

    Alert.alert('Delete Video', 'Are you sure you want to delete this lesson video?', [
      { text: 'Cancel', style: 'cancel' },
      {
        text: 'Delete',
        style: 'destructive',
        onPress: async () => {
          setDeleting(true);
          setErrorMessage(null);
          try {
            const baseURL = api.defaults.baseURL;
            const url = `${baseURL}/api/lessons/${lessonId}/video`;
            
            const response = await fetch(url, {
              method: 'DELETE',
              headers: {
                'Authorization': `Bearer ${DEBUG_TOKEN}`,
              },
            });

            const data = await response.json();
            
            if (response.ok && data.success) {
              setCurrentVideoUrl(null);
              Alert.alert('Success', 'Video deleted successfully');
            } else {
              throw new Error(data.message || 'Failed to delete video');
            }
          } catch (err: any) {
            console.error('[LessonVideoUpload] Delete error:', err);
            const message = err.message || 'Failed to delete video';
            setErrorMessage(message);
            Alert.alert('Delete Failed', message);
          } finally {
            setDeleting(false);
          }
        },
      },
    ]);
  };

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: colors.background }}>
      <ScrollView
        showsVerticalScrollIndicator={false}
        contentContainerStyle={{
          flexGrow: 1,
          paddingVertical: isSmallDevice ? 16 : 32,
        }}
      >
        <View style={{ width: '100%', paddingHorizontal: 16 }}>
          <View style={{ width: '100%', maxWidth: 480, marginHorizontal: 'auto' }}>
            {/* Header */}
            <View style={{ flexDirection: 'row', alignItems: 'center', marginBottom: 24 }}>
              <TouchableOpacity onPress={() => router.back()} style={{ marginRight: 12 }}>
                <Ionicons name="arrow-back" size={24} color={colors.text} />
              </TouchableOpacity>
              <View>
                <Text style={{ fontWeight: 'bold', color: colors.text, fontSize: isSmallDevice ? 20 : 24 }}>
                  Lesson Video
                </Text>
                <Text style={{ color: colors.textSecondary, fontSize: 13, marginTop: 2 }}>
                  Upload or replace the video for this lesson
                </Text>
              </View>
            </View>

            {/* Debug Banner */}
            {DEBUG && (
              <View
                style={{
                  backgroundColor: isDarkMode ? 'rgba(234, 179, 8, 0.15)' : '#fef9c3',
                  borderWidth: 1,
                  borderColor: isDarkMode ? 'rgba(234, 179, 8, 0.3)' : '#fde047',
                  borderRadius: 10,
                  padding: 10,
                  marginBottom: 16,
                }}
              >
                <Text style={{ fontSize: 12, color: colors.text }}>
                  DEBUG · lessonId: {lessonId} · Platform: {Platform.OS}
                </Text>
                <Text style={{ fontSize: 11, color: colors.textSecondary, marginTop: 4 }}>
                  API URL: {api.defaults.baseURL}
                </Text>
                <Text style={{ fontSize: 11, color: colors.textSecondary, marginTop: 4 }}>
                  Has File Object: {selectedVideo?.file ? 'Yes' : 'No'}
                </Text>
              </View>
            )}

            {/* Main Card */}
            <View
              style={{
                width: '100%',
                backgroundColor: colors.backgroundElement,
                borderRadius: 24,
                borderWidth: 1,
                borderColor: colors.backgroundSelected,
                padding: cardPadding,
                boxShadow: isDarkMode
                  ? '0px 2px 4px rgba(0, 0, 0, 0.2)'
                  : '0px 2px 4px rgba(15, 23, 42, 0.05)',
                elevation: 4,
              }}
            >
              {errorMessage && (
                <View
                  style={{
                    backgroundColor: isDarkMode ? 'rgba(239, 68, 68, 0.15)' : '#fef2f2',
                    borderWidth: 1,
                    borderColor: isDarkMode ? 'rgba(239, 68, 68, 0.3)' : '#fecaca',
                    borderRadius: 12,
                    padding: 12,
                    marginBottom: 16,
                  }}
                >
                  <Text style={{ color: '#ef4444', fontSize: 14, textAlign: 'center', fontWeight: '500' }}>
                    {errorMessage}
                  </Text>
                </View>
              )}

              {/* Existing video preview */}
              {currentVideoUrl && !selectedVideo && (
                <View style={{ marginBottom: 20 }}>
                  <Text style={{ fontSize: 14, fontWeight: '600', color: colors.text, marginBottom: 8 }}>
                    Current Video
                  </Text>
                  <View
                    style={{
                      width: '100%',
                      aspectRatio: 16 / 9,
                      borderRadius: 12,
                      overflow: 'hidden',
                      backgroundColor: '#000',
                    }}
                  >
                    <VideoPreview uri={currentVideoUrl} />
                  </View>

                  <View style={{ marginTop: 12 }}>
                    <CustomButton
                      title={deleting ? 'Deleting...' : 'Remove Video'}
                      onPress={handleDeleteExistingVideo}
                      loading={deleting}
                      colors={colors}
                      variant="danger"
                      icon="trash-outline"
                    />
                  </View>
                </View>
              )}

              {/* No video + no selection yet */}
              {!currentVideoUrl && !selectedVideo && (
                <TouchableOpacity
                  onPress={handlePickVideo}
                  activeOpacity={0.7}
                  style={{
                    width: '100%',
                    aspectRatio: 16 / 9,
                    borderRadius: 12,
                    borderWidth: 2,
                    borderColor: colors.backgroundSelected,
                    borderStyle: 'dashed',
                    alignItems: 'center',
                    justifyContent: 'center',
                    marginBottom: 16,
                  }}
                >
                  <Ionicons name="cloud-upload-outline" size={36} color={colors.textSecondary} />
                  <Text style={{ color: colors.textSecondary, marginTop: 8, fontSize: 14, fontWeight: '500' }}>
                    Tap to select a video
                  </Text>
                  <Text style={{ color: colors.textSecondary, marginTop: 2, fontSize: 12 }}>
                    Max size {formatBytes(MAX_VIDEO_SIZE_BYTES)}
                  </Text>
                </TouchableOpacity>
              )}

              {/* Selected video, ready to upload */}
              {selectedVideo && (
                <View style={{ marginBottom: 16 }}>
                  <Text style={{ fontSize: 14, fontWeight: '600', color: colors.text, marginBottom: 8 }}>
                    Selected Video
                  </Text>

                  <View
                    style={{
                      width: '100%',
                      aspectRatio: 16 / 9,
                      borderRadius: 12,
                      overflow: 'hidden',
                      backgroundColor: '#000',
                      marginBottom: 12,
                    }}
                  >
                    <VideoPreview uri={selectedVideo.uri} />
                  </View>

                  <View
                    style={{
                      flexDirection: 'row',
                      alignItems: 'center',
                      justifyContent: 'space-between',
                      backgroundColor: colors.background,
                      borderRadius: 10,
                      paddingHorizontal: 12,
                      paddingVertical: 10,
                      marginBottom: 16,
                    }}
                  >
                    <View style={{ flex: 1, marginRight: 8 }}>
                      <Text style={{ color: colors.text, fontSize: 13, fontWeight: '500' }} numberOfLines={1}>
                        {selectedVideo.name}
                      </Text>
                      {selectedVideo.size > 0 && (
                        <Text style={{ color: colors.textSecondary, fontSize: 12, marginTop: 2 }}>
                          {formatBytes(selectedVideo.size)}
                        </Text>
                      )}
                      {selectedVideo.file && (
                        <Text style={{ color: colors.primary, fontSize: 11, marginTop: 2 }}>
                          ✓ File object ready for upload
                        </Text>
                      )}
                    </View>
                    {!uploading && (
                      <TouchableOpacity onPress={handleRemoveSelectedVideo}>
                        <Ionicons name="close-circle" size={22} color={colors.textSecondary} />
                      </TouchableOpacity>
                    )}
                  </View>

                  {/* Progress bar */}
                  {uploading && (
                    <View style={{ marginBottom: 16 }}>
                      <View
                        style={{
                          width: '100%',
                          height: 8,
                          borderRadius: 4,
                          backgroundColor: colors.backgroundSelected,
                          overflow: 'hidden',
                        }}
                      >
                        <View
                          style={{
                            width: `${progress}%`,
                            height: '100%',
                            backgroundColor: colors.primary,
                          }}
                        />
                      </View>
                      <View style={{ flexDirection: 'row', justifyContent: 'space-between', marginTop: 6 }}>
                        <Text style={{ color: colors.textSecondary, fontSize: 12 }}>
                          Uploading... {progress}%
                        </Text>
                        <TouchableOpacity onPress={handleCancelUpload}>
                          <Text style={{ color: '#ef4444', fontSize: 12, fontWeight: '600' }}>Cancel</Text>
                        </TouchableOpacity>
                      </View>
                    </View>
                  )}

                  <CustomButton
                    title={uploading ? `Uploading ${progress}%` : 'Upload Video'}
                    onPress={handleUpload}
                    loading={uploading}
                    colors={colors}
                    icon="cloud-upload-outline"
                  />
                </View>
              )}

              {/* Replace existing / pick new when one already exists */}
              {currentVideoUrl && !selectedVideo && (
                <CustomButton
                  title="Replace Video"
                  onPress={handlePickVideo}
                  colors={colors}
                  variant="outline"
                  icon="swap-horizontal-outline"
                />
              )}
            </View>
          </View>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}