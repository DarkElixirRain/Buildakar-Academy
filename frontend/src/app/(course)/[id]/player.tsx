// app/(course)/[id]/player.tsx
import React, { useState, useRef } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  SafeAreaView,
  StatusBar,
  Dimensions,
} from 'react-native';
import { router, useLocalSearchParams } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { Video, ResizeMode } from 'expo-av';
import Slider from '@react-native-community/slider';

const { width, height } = Dimensions.get('window');

export default function VideoPlayerScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const videoRef = useRef<Video>(null);
  const [status, setStatus] = useState<any>({});
  const [isPlaying, setIsPlaying] = useState(false);
  const [progress, setProgress] = useState(0);

  const handlePlayPause = async () => {
    if (videoRef.current) {
      if (isPlaying) {
        await videoRef.current.pauseAsync();
      } else {
        await videoRef.current.playAsync();
      }
      setIsPlaying(!isPlaying);
    }
  };

  const handleSliderChange = async (value: number) => {
    if (videoRef.current && status.durationMillis) {
      const position = value * status.durationMillis;
      await videoRef.current.setPositionAsync(position);
      setProgress(value);
    }
  };

  return (
    <SafeAreaView className="flex-1 bg-black">
      <StatusBar hidden />
      
      {/* Header */}
      <View className="absolute top-0 left-0 right-0 z-10 px-4 pt-4">
        <TouchableOpacity
          onPress={() => router.back()}
          className="w-10 h-10 rounded-full bg-black/50 items-center justify-center"
        >
          <Ionicons name="chevron-down" size={24} color="white" />
        </TouchableOpacity>
      </View>

      {/* Video Player */}
      <Video
        ref={videoRef}
        source={{ uri: 'https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4' }}
        style={{ width: width, height: height }}
        resizeMode={ResizeMode.CONTAIN}
        isLooping={false}
        onPlaybackStatusUpdate={(status) => {
          setStatus(status);
          if (status.isLoaded && status.durationMillis) {
            setProgress(status.positionMillis / status.durationMillis);
          }
        }}
      />

      {/* Controls Overlay */}
      <View className="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/80 to-transparent p-6">
        {/* Progress Bar */}
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

        {/* Controls */}
        <View className="flex-row items-center justify-center space-x-8">
          <TouchableOpacity onPress={() => console.log('Rewind 10s')}>
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
          
          <TouchableOpacity onPress={() => console.log('Forward 10s')}>
            <Ionicons name="play-forward" size={28} color="white" />
          </TouchableOpacity>
        </View>
      </View>
    </SafeAreaView>
  );
}

function formatTime(millis: number): string {
  if (!millis) return '0:00';
  const totalSeconds = Math.floor(millis / 1000);
  const minutes = Math.floor(totalSeconds / 60);
  const seconds = totalSeconds % 60;
  return `${minutes}:${seconds.toString().padStart(2, '0')}`;
}