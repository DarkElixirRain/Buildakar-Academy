// store/settingsStore.ts
//
// Persisted app preferences shown on the Settings screen. Kept separate
// from themeStore so theme changes (which touch NativeWind directly) don't
// get bundled with plain data toggles.

import { create } from "zustand";
import { persist, createJSONStorage } from "zustand/middleware";
import AsyncStorage from "@react-native-async-storage/async-storage";

export type VideoQuality = "auto" | "data-saver" | "high" | "hd";
export type PlaybackSpeed = "0.5" | "0.75" | "1" | "1.25" | "1.5" | "1.75" | "2";

interface SettingsState {
  // Notifications
  pushNotifications: boolean;
  emailNotifications: boolean;
  courseReminders: boolean;

  // Learning / playback
  autoplayNextLesson: boolean;
  downloadOverWifiOnly: boolean;
  videoQuality: VideoQuality;
  playbackSpeed: PlaybackSpeed;
  subtitleLanguage: string;

  // Localization
  appLanguage: string;

  // Setters
  togglePushNotifications: () => void;
  toggleEmailNotifications: () => void;
  toggleCourseReminders: () => void;
  toggleAutoplayNextLesson: () => void;
  toggleDownloadOverWifiOnly: () => void;
  setVideoQuality: (quality: VideoQuality) => void;
  setPlaybackSpeed: (speed: PlaybackSpeed) => void;
  setSubtitleLanguage: (language: string) => void;
  setAppLanguage: (language: string) => void;
}

export const useSettingsStore = create<SettingsState>()(
  persist(
    (set) => ({
      pushNotifications: true,
      emailNotifications: true,
      courseReminders: true,

      autoplayNextLesson: true,
      downloadOverWifiOnly: true,
      videoQuality: "auto",
      playbackSpeed: "1",
      subtitleLanguage: "English",

      appLanguage: "English",

      togglePushNotifications: () =>
        set((s) => ({ pushNotifications: !s.pushNotifications })),
      toggleEmailNotifications: () =>
        set((s) => ({ emailNotifications: !s.emailNotifications })),
      toggleCourseReminders: () =>
        set((s) => ({ courseReminders: !s.courseReminders })),
      toggleAutoplayNextLesson: () =>
        set((s) => ({ autoplayNextLesson: !s.autoplayNextLesson })),
      toggleDownloadOverWifiOnly: () =>
        set((s) => ({ downloadOverWifiOnly: !s.downloadOverWifiOnly })),
      setVideoQuality: (videoQuality) => set({ videoQuality }),
      setPlaybackSpeed: (playbackSpeed) => set({ playbackSpeed }),
      setSubtitleLanguage: (subtitleLanguage) => set({ subtitleLanguage }),
      setAppLanguage: (appLanguage) => set({ appLanguage }),
    }),
    {
      name: "settings-storage",
      storage: createJSONStorage(() => AsyncStorage),
    }
  )
);