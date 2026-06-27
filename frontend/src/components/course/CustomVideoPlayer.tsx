// components/course/CustomVideoPlayer.tsx
//
// Custom video player for course lessons, built on `expo-video`.
//
// Setup (one-time):
//   npx expo install expo-video
//
// expo-video needs a development build — it will not run inside the plain
// Expo Go app. Run `npx expo run:ios` / `npx expo run:android`, or create an
// EAS dev build, then this screen will work normally.
//
import React, { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import {
  ActivityIndicator,
  GestureResponderEvent,
  PanResponder,
  Pressable,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
} from 'react-native';
import { useEvent, useEventListener } from 'expo';
import { useVideoPlayer, VideoView, type VideoSource } from 'expo-video';
import { Ionicons } from '@expo/vector-icons';

const PLAYBACK_SPEEDS = [0.5, 0.75, 1, 1.25, 1.5, 1.75, 2];

function formatTime(totalSeconds: number): string {
  if (!Number.isFinite(totalSeconds) || totalSeconds < 0) return '0:00';
  const mins = Math.floor(totalSeconds / 60);
  const secs = Math.floor(totalSeconds % 60);
  return `${mins}:${secs.toString().padStart(2, '0')}`;
}

interface CustomVideoPlayerProps {
  source: VideoSource;
  title?: string;
  /** Resume playback at this position (seconds) once the video is ready. */
  startPosition?: number;
  onBack?: () => void;
  /** Fires roughly every 0.5s while playing — wire this to save progress. */
  onProgress?: (currentTime: number, duration: number) => void;
  onEnd?: () => void;
  /** Safe-area top inset, so the back button clears the status bar/notch. */
  topInset?: number;
}

export const CustomVideoPlayer: React.FC<CustomVideoPlayerProps> = ({
  source,
  title,
  startPosition = 0,
  onBack,
  onProgress,
  onEnd,
  topInset = 0,
}) => {
  const videoViewRef = useRef<any>(null);
  const appliedStartPosition = useRef(false);

  const player = useVideoPlayer(source, (p) => {
    p.loop = false;
    p.timeUpdateEventInterval = 0.5;
    p.play();
  });

  const { status } = useEvent(player, 'statusChange', { status: player.status });
  const { isPlaying } = useEvent(player, 'playingChange', { isPlaying: player.playing });

  const [currentTime, setCurrentTime] = useState(0);
  const [duration, setDuration] = useState(0);
  const [muted, setMuted] = useState(false);
  const [speedIndex, setSpeedIndex] = useState(2); // 1x
  const [isFullscreen, setIsFullscreen] = useState(false);
  const [controlsVisible, setControlsVisible] = useState(true);
  const [barWidth, setBarWidth] = useState(0);
  const [isScrubbing, setIsScrubbing] = useState(false);
  const [scrubPercent, setScrubPercent] = useState(0);

  const hideTimerRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const scheduleHide = useCallback(() => {
    if (hideTimerRef.current) clearTimeout(hideTimerRef.current);
    hideTimerRef.current = setTimeout(() => setControlsVisible(false), 3000);
  }, []);

  useEffect(() => {
    if (isPlaying) {
      scheduleHide();
    } else if (hideTimerRef.current) {
      clearTimeout(hideTimerRef.current);
    }
    return () => {
      if (hideTimerRef.current) clearTimeout(hideTimerRef.current);
    };
  }, [isPlaying, scheduleHide]);

  // Jump to the saved position once the video has metadata to seek into.
  useEffect(() => {
    if (!appliedStartPosition.current && status === 'readyToPlay' && startPosition > 0) {
      player.currentTime = startPosition;
      appliedStartPosition.current = true;
    }
  }, [status, startPosition, player]);

  useEventListener(player, 'timeUpdate', (payload) => {
    setCurrentTime(payload.currentTime);
    if (player.duration && Number.isFinite(player.duration)) {
      setDuration(player.duration);
    }
    onProgress?.(payload.currentTime, player.duration ?? 0);
  });

  useEventListener(player, 'playToEnd', () => {
    onEnd?.();
  });

  const toggleControls = useCallback(() => {
    setControlsVisible((visible) => {
      const next = !visible;
      if (next && player.playing) scheduleHide();
      return next;
    });
  }, [player, scheduleHide]);

  const handlePlayPause = useCallback(() => {
    if (player.playing) {
      player.pause();
      if (hideTimerRef.current) clearTimeout(hideTimerRef.current);
      setControlsVisible(true);
    } else {
      player.play();
      scheduleHide();
    }
  }, [player, scheduleHide]);

  const skip = useCallback(
    (seconds: number) => {
      player.seekBy(seconds);
      setControlsVisible(true);
      if (player.playing) scheduleHide();
    },
    [player, scheduleHide]
  );

  const cycleSpeed = useCallback(() => {
    setSpeedIndex((idx) => {
      const next = (idx + 1) % PLAYBACK_SPEEDS.length;
      player.playbackRate = PLAYBACK_SPEEDS[next];
      return next;
    });
  }, [player]);

  const toggleMute = useCallback(() => {
    setMuted((m) => {
      player.muted = !m;
      return !m;
    });
  }, [player]);

  const toggleFullscreen = useCallback(async () => {
    if (isFullscreen) {
      await videoViewRef.current?.exitFullscreen?.();
    } else {
      await videoViewRef.current?.enterFullscreen?.();
    }
  }, [isFullscreen]);

  const clampPercent = useCallback(
    (x: number) => (barWidth > 0 ? Math.min(Math.max(x / barWidth, 0), 1) : 0),
    [barWidth]
  );

  const panResponder = useMemo(
    () =>
      PanResponder.create({
        onStartShouldSetPanResponder: () => true,
        onMoveShouldSetPanResponder: () => true,
        onPanResponderGrant: (evt: GestureResponderEvent) => {
          if (hideTimerRef.current) clearTimeout(hideTimerRef.current);
          setIsScrubbing(true);
          setScrubPercent(clampPercent(evt.nativeEvent.locationX));
        },
        onPanResponderMove: (evt: GestureResponderEvent) => {
          setScrubPercent(clampPercent(evt.nativeEvent.locationX));
        },
        onPanResponderRelease: (evt: GestureResponderEvent) => {
          const pct = clampPercent(evt.nativeEvent.locationX);
          if (duration > 0) player.currentTime = pct * duration;
          setIsScrubbing(false);
          if (player.playing) scheduleHide();
        },
      }),
    [clampPercent, duration, player, scheduleHide]
  );

  const displayPercent = isScrubbing ? scrubPercent : duration > 0 ? currentTime / duration : 0;

  return (
    <Pressable style={styles.container} onPress={toggleControls}>
      <VideoView
        ref={videoViewRef}
        player={player}
        style={StyleSheet.absoluteFill}
        contentFit="contain"
        nativeControls={false}
        onFullscreenEnter={() => setIsFullscreen(true)}
        onFullscreenExit={() => setIsFullscreen(false)}
      />

      {status === 'loading' && (
        <View style={styles.centerOverlay} pointerEvents="none">
          <ActivityIndicator color="#FFFFFF" size="large" />
        </View>
      )}

      {status === 'error' && (
        <View style={styles.centerOverlay}>
          <Ionicons name="alert-circle-outline" size={36} color="#FFFFFF" />
          <Text style={styles.errorText}>Couldn't load this video</Text>
        </View>
      )}

      {controlsVisible && status !== 'error' && (
        <View style={styles.overlay} pointerEvents="box-none">
          <View style={[styles.topBar, { paddingTop: 8 + topInset }]}>
            {onBack && (
              <TouchableOpacity onPress={onBack} style={styles.iconButton} hitSlop={12}>
                <Ionicons name="chevron-back" size={24} color="#FFFFFF" />
              </TouchableOpacity>
            )}
            <Text style={styles.topBarTitle} numberOfLines={1}>
              {title}
            </Text>
            <TouchableOpacity onPress={cycleSpeed} style={styles.speedButton} hitSlop={12}>
              <Text style={styles.speedButtonText}>{PLAYBACK_SPEEDS[speedIndex]}x</Text>
            </TouchableOpacity>
          </View>

          <View style={styles.centerControls}>
            <TouchableOpacity onPress={() => skip(-10)} style={styles.iconButton} hitSlop={12}>
              <Ionicons name="play-back" size={26} color="#FFFFFF" />
            </TouchableOpacity>
            <TouchableOpacity onPress={handlePlayPause} style={styles.playButton} hitSlop={12}>
              <Ionicons name={isPlaying ? 'pause' : 'play'} size={28} color="#0F172A" />
            </TouchableOpacity>
            <TouchableOpacity onPress={() => skip(10)} style={styles.iconButton} hitSlop={12}>
              <Ionicons name="play-forward" size={26} color="#FFFFFF" />
            </TouchableOpacity>
          </View>

          <View style={styles.bottomBar}>
            <Text style={styles.timeText}>{formatTime(currentTime)}</Text>
            <View
              style={styles.seekTrack}
              onLayout={(e) => setBarWidth(e.nativeEvent.layout.width)}
              {...panResponder.panHandlers}
            >
              <View style={styles.seekTrackBg} />
              <View style={[styles.seekTrackFill, { width: `${displayPercent * 100}%` }]} />
              <View style={[styles.seekThumb, { left: `${displayPercent * 100}%` }]} />
            </View>
            <Text style={styles.timeText}>{formatTime(duration)}</Text>
            <TouchableOpacity onPress={toggleMute} style={styles.iconButton} hitSlop={12}>
              <Ionicons name={muted ? 'volume-mute' : 'volume-high'} size={18} color="#FFFFFF" />
            </TouchableOpacity>
            <TouchableOpacity onPress={toggleFullscreen} style={styles.iconButton} hitSlop={12}>
              <Ionicons name={isFullscreen ? 'contract' : 'expand'} size={18} color="#FFFFFF" />
            </TouchableOpacity>
          </View>
        </View>
      )}
    </Pressable>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#000000',
    overflow: 'hidden',
  },
  centerOverlay: {
    ...StyleSheet.absoluteFill,
    alignItems: 'center',
    justifyContent: 'center',
    gap: 8,
  },
  errorText: {
    color: '#FFFFFF',
    fontSize: 13,
    fontWeight: '500',
  },
  overlay: {
    ...StyleSheet.absoluteFill,
    justifyContent: 'space-between',
  },
  topBar: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 8,
    paddingTop: 8,
    backgroundColor: 'rgba(15,23,42,0.45)',
  },
  topBarTitle: {
    flex: 1,
    color: '#FFFFFF',
    fontSize: 14,
    fontWeight: '600',
    marginHorizontal: 4,
  },
  speedButton: {
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: 999,
    backgroundColor: 'rgba(255,255,255,0.2)',
  },
  speedButtonText: {
    color: '#FFFFFF',
    fontSize: 12,
    fontWeight: '700',
  },
  iconButton: {
    padding: 8,
  },
  centerControls: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 36,
  },
  playButton: {
    width: 56,
    height: 56,
    borderRadius: 28,
    backgroundColor: '#FFFFFF',
    alignItems: 'center',
    justifyContent: 'center',
  },
  bottomBar: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 10,
    paddingVertical: 8,
    gap: 6,
    backgroundColor: 'rgba(15,23,42,0.45)',
  },
  timeText: {
    color: '#FFFFFF',
    fontSize: 11,
    fontWeight: '500',
    width: 36,
    textAlign: 'center',
  },
  seekTrack: {
    flex: 1,
    height: 24,
    justifyContent: 'center',
  },
  seekTrackBg: {
    height: 3,
    borderRadius: 2,
    backgroundColor: 'rgba(255,255,255,0.3)',
  },
  seekTrackFill: {
    position: 'absolute',
    height: 3,
    borderRadius: 2,
    backgroundColor: '#2563EB',
  },
  seekThumb: {
    position: 'absolute',
    width: 12,
    height: 12,
    borderRadius: 6,
    backgroundColor: '#FFFFFF',
    marginLeft: -6,
  },
});