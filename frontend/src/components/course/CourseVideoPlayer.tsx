// components/course/CourseVideoPlayer.web.tsx
//
// Web-only override. Metro/webpack automatically picks this file instead of
// CourseVideoPlayer.tsx when bundling for the browser (Expo web), because of
// the ".web.tsx" suffix — no import changes needed anywhere else.
//
// react-native-youtube-iframe's bridge page expects window.ReactNativeWebView,
// which only exists inside a real native WebView, so it crashes on web with
// "Cannot read properties of undefined (reading 'postMessage')". This file
// sidesteps that entirely by talking to the real YouTube IFrame Player API
// that ships for browsers.

import React, { useEffect, useRef, useState } from 'react';
import { View, ActivityIndicator, useWindowDimensions } from 'react-native';

interface CourseVideoPlayerProps {
  youtubeId: string;
  onEnd?: () => void;
}

declare global {
  interface Window {
    YT?: any;
    onYouTubeIframeAPIReady?: () => void;
  }
}

let apiPromise: Promise<void> | null = null;

function loadYouTubeApi(): Promise<void> {
  if (typeof window === 'undefined') return Promise.resolve();
  if (window.YT && window.YT.Player) return Promise.resolve();
  if (apiPromise) return apiPromise;

  apiPromise = new Promise((resolve) => {
    const previousCallback = window.onYouTubeIframeAPIReady;
    window.onYouTubeIframeAPIReady = () => {
      previousCallback?.();
      resolve();
    };

    const script = document.createElement('script');
    script.src = 'https://www.youtube.com/iframe_api';
    document.head.appendChild(script);
  });

  return apiPromise;
}

export const CourseVideoPlayer: React.FC<CourseVideoPlayerProps> = ({
  youtubeId,
  onEnd,
}) => {
  const { width } = useWindowDimensions();
  const videoHeight = (width * 9) / 16;

  // nativeID renders as a real DOM id on web (react-native-web), which the
  // YouTube API needs to mount the iframe into.
  const containerId = useRef(
    `yt-player-${Math.random().toString(36).slice(2)}`
  ).current;
  const playerRef = useRef<any>(null);
  const onEndRef = useRef(onEnd);
  onEndRef.current = onEnd;

  const [loading, setLoading] = useState(true);

  // Create the player once on mount.
  useEffect(() => {
    let cancelled = false;

    loadYouTubeApi().then(() => {
      if (cancelled) return;

      playerRef.current = new window.YT.Player(containerId, {
        videoId: youtubeId,
        width: '100%',
        height: '100%',
        playerVars: {
          rel: 0,
          modestbranding: 1,
          playsinline: 1,
        },
        events: {
          onReady: () => setLoading(false),
          onStateChange: (event: any) => {
            // 0 === YT.PlayerState.ENDED
            if (event.data === 0) {
              onEndRef.current?.();
            }
          },
        },
      });
    });

    return () => {
      cancelled = true;
      playerRef.current?.destroy?.();
      playerRef.current = null;
    };
    // Player is created once; lesson changes are handled by loadVideoById below.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // When the lesson changes, load the new video into the existing player
  // rather than tearing down and recreating it.
  useEffect(() => {
    if (playerRef.current?.loadVideoById) {
      setLoading(true);
      playerRef.current.loadVideoById(youtubeId);
    }
  }, [youtubeId]);

  return (
    <View style={{ width, height: videoHeight, backgroundColor: '#000000' }}>
      {loading && (
        <View
          style={{
            position: 'absolute',
            width: '100%',
            height: '100%',
            justifyContent: 'center',
            alignItems: 'center',
            zIndex: 1,
          }}
        >
          <ActivityIndicator color="#FFFFFF" size="large" />
        </View>
      )}
      <View nativeID={containerId} style={{ width: '100%', height: '100%' }} />
    </View>
  );
};