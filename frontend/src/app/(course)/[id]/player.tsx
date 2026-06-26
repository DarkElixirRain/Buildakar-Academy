// app/(course)/[id]/player.tsx
import React, { useState, useRef, useEffect } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  SafeAreaView,
  StatusBar,
  Dimensions,
  Linking,
  Alert,
  ActivityIndicator,
  Platform,
} from 'react-native';
import { router, useLocalSearchParams } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { Video, ResizeMode } from 'expo-av';
import Slider from '@react-native-community/slider';
import  WebView  from 'react-native-webview';

const { width, height } = Dimensions.get('window');

// Helper function to extract YouTube video ID
const extractYouTubeVideoId = (url: string): string | null => {
  if (!url) return null;
  
  const match = url.match(/youtu\.be\/([^\?&]+)/);
  if (match) return match[1];
  
  const match2 = url.match(/youtube\.com\/watch\?v=([^&]+)/);
  if (match2) return match2[1];
  
  const match3 = url.match(/youtube\.com\/embed\/([^\?&]+)/);
  if (match3) return match3[1];
  
  const match4 = url.match(/youtube\.com\/shorts\/([^\?&]+)/);
  if (match4) return match4[1];
  
  return null;
};

const isYouTubeUrl = (url: string): boolean => {
  if (!url) return false;
  return url.includes('youtube.com') || url.includes('youtu.be');
};

export default function VideoPlayerScreen() {
  const { id, videoUrl: urlParam } = useLocalSearchParams<{ id: string; videoUrl?: string }>();
  const videoRef = useRef<Video>(null);
  const webViewRef = useRef<WebView>(null);
  const [status, setStatus] = useState<any>({});
  const [isPlaying, setIsPlaying] = useState(false);
  const [progress, setProgress] = useState(0);
  const [videoUrl, setVideoUrl] = useState<string>('');
  const [isYouTube, setIsYouTube] = useState(false);
  const [videoId, setVideoId] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const [webViewError, setWebViewError] = useState(false);

  useEffect(() => {
    const url = urlParam || 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';
    setVideoUrl(url);
    
    if (isYouTubeUrl(url)) {
      const id = extractYouTubeVideoId(url);
      if (id) {
        setIsYouTube(true);
        setVideoId(id);
      } else {
        setIsYouTube(false);
        setVideoUrl('https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4');
      }
    } else {
      setIsYouTube(false);
      setVideoUrl(url);
    }
  }, [urlParam]);

  const handlePlayPause = async () => {
    if (videoRef.current && !isYouTube) {
      if (isPlaying) {
        await videoRef.current.pauseAsync();
      } else {
        await videoRef.current.playAsync();
      }
      setIsPlaying(!isPlaying);
    }
  };

  const handleSliderChange = async (value: number) => {
    if (videoRef.current && status.durationMillis && !isYouTube) {
      const position = value * status.durationMillis;
      await videoRef.current.setPositionAsync(position);
      setProgress(value);
    }
  };

  const formatTime = (millis: number): string => {
    if (!millis) return '0:00';
    const totalSeconds = Math.floor(millis / 1000);
    const minutes = Math.floor(totalSeconds / 60);
    const seconds = totalSeconds % 60;
    return `${minutes}:${seconds.toString().padStart(2, '0')}`;
  };

  const openYouTube = () => {
    if (!videoId) return;
    const url = `https://www.youtube.com/watch?v=${videoId}`;
    Linking.openURL(url).catch(() => {
      Alert.alert('Error', 'Unable to open YouTube app');
    });
  };

  // YouTube Player with WebView - Optimized for both platforms
  const YouTubePlayer = () => {
    if (!videoId) return null;

    if (webViewError) {
      return (
        <View className="flex-1 items-center justify-center bg-black p-6">
          <Ionicons name="logo-youtube" size={60} color="#FF0000" />
          <Text className="text-white text-lg font-bold mt-4 text-center">
            YouTube Video
          </Text>
          <Text className="text-gray-400 text-sm mt-2 text-center">
            Tap below to open in YouTube app
          </Text>
          <TouchableOpacity
            className="mt-6 bg-[#FF0000] px-6 py-3 rounded-full"
            onPress={openYouTube}
          >
            <Text className="text-white font-bold">Open in YouTube</Text>
          </TouchableOpacity>
        </View>
      );
    }

    // Use different embed URLs for different platforms
    const embedUrl = Platform.select({
      ios: `https://www.youtube.com/embed/${videoId}?playsinline=1&autoplay=1&rel=0&controls=1&modestbranding=1&iv_load_policy=3&enablejsapi=0`,
      android: `https://www.youtube.com/embed/${videoId}?playsinline=1&autoplay=1&rel=0&controls=1&modestbranding=1&iv_load_policy=3`,
      default: `https://www.youtube.com/embed/${videoId}?playsinline=1&autoplay=1&rel=0&controls=1&modestbranding=1&iv_load_policy=3`,
    });

    // User agent for better compatibility
    const userAgent = Platform.select({
      ios: 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1',
      android: 'Mozilla/5.0 (Linux; Android 11) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36',
      default: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
    });

    return (
      <View className="flex-1 bg-black">
        <WebView
  ref={webViewRef}
  source={{ uri: embedUrl }}
  javaScriptEnabled
  domStorageEnabled
  allowsFullscreenVideo
  mediaPlaybackRequiresUserAction={false}
  onError={(e: { nativeEvent: any; }) => {
    console.log("WebView error:", e.nativeEvent);
    setWebViewError(true);
  }}
/>
        {loading && (
          <View className="absolute inset-0 items-center justify-center bg-black">
            <ActivityIndicator size="large" color="#FF0000" />
            <Text className="text-white text-sm mt-4">Loading video...</Text>
          </View>
        )}
        <TouchableOpacity
          className="absolute bottom-10 left-0 right-0 mx-4 bg-white/10 backdrop-blur-sm py-3 rounded-xl"
          onPress={openYouTube}
        >
          <Text className="text-white text-center font-semibold">
            Open in YouTube App
          </Text>
        </TouchableOpacity>
      </View>
    );
  };

  // YouTube Video
  if (isYouTube && videoId) {
    return (
      <SafeAreaView className="flex-1 bg-black">
        <StatusBar hidden />
        
        <View className="absolute top-0 left-0 right-0 z-10 px-4 pt-4">
          <TouchableOpacity
            onPress={() => router.back()}
            className="w-10 h-10 rounded-full bg-black/50 items-center justify-center"
          >
            <Ionicons name="chevron-down" size={24} color="white" />
          </TouchableOpacity>
        </View>

        <YouTubePlayer />
      </SafeAreaView>
    );
  }

  // Direct Video URL
  return (
    <SafeAreaView className="flex-1 bg-black">
      <StatusBar hidden />
      
      <View className="absolute top-0 left-0 right-0 z-10 px-4 pt-4">
        <TouchableOpacity
          onPress={() => router.back()}
          className="w-10 h-10 rounded-full bg-black/50 items-center justify-center"
        >
          <Ionicons name="chevron-down" size={24} color="white" />
        </TouchableOpacity>
      </View>

      <Video
        ref={videoRef}
        source={{ uri: videoUrl }}
        style={{ width: width, height: height }}
        resizeMode={ResizeMode.CONTAIN}
        isLooping={false}
        shouldPlay={true}
        onPlaybackStatusUpdate={(status) => {
          setStatus(status);
          if (status.isLoaded && status.durationMillis) {
            setProgress(status.positionMillis / status.durationMillis);
          }
        }}
      />

      <View className="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/80 to-transparent p-6">
        <View className="mb-4">
          <Slider
            value={progress}
            onValueChange={handleSliderChange}
            minimumValue={0}
            maximumValue={1}
            minimumTrackTintColor="#2563EB"
            maximumTrackTintColor="rgba(255,255,255,0.3)"
            thumbTintColor="#2563EB"
            style={{ height: 40 }}
          />
          <View className="flex-row justify-between">
            <Text className="text-white text-xs">
              {formatTime(status.positionMillis)}
            </Text>
            <Text className="text-white text-xs">
              {formatTime(status.durationMillis)}
            </Text>
          </View>
        </View>

        <View className="flex-row items-center justify-center space-x-8">
          <TouchableOpacity 
            onPress={() => {
              if (videoRef.current && status.positionMillis) {
                const newPosition = Math.max(0, status.positionMillis - 10000);
                videoRef.current.setPositionAsync(newPosition);
              }
            }}
          >
            <Ionicons name="play-back" size={28} color="white" />
          </TouchableOpacity>
          
          <TouchableOpacity
            className="w-16 h-16 rounded-full bg-[#2563EB] items-center justify-center"
            onPress={handlePlayPause}
          >
            <Ionicons
              name={isPlaying ? 'pause' : 'play'}
              size={32}
              color="white"
            />
          </TouchableOpacity>
          
          <TouchableOpacity 
            onPress={() => {
              if (videoRef.current && status.positionMillis && status.durationMillis) {
                const newPosition = Math.min(status.durationMillis, status.positionMillis + 10000);
                videoRef.current.setPositionAsync(newPosition);
              }
            }}
          >
            <Ionicons name="play-forward" size={28} color="white" />
          </TouchableOpacity>
        </View>
      </View>
    </SafeAreaView>
  );
}