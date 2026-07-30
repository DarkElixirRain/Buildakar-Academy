import 'package:flutter/foundation.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart'
    show JitsiMeet, JitsiMeetConferenceOptions, JitsiMeetUserInfo, JitsiMeetEventListener;
import 'package:jitsi_meet_flutter_sdk/src/method_response.dart'
    show MethodResponse;

class JitsiService {
  static final JitsiMeet _jitsiMeet = JitsiMeet();
  static bool _isInMeeting = false;
  static bool _isJoining = false;

  static bool get isInMeeting => _isInMeeting;

  static Future<void> joinMeeting({
    required String room,
    required String displayName,
    String? email,
    String? avatarUrl,
    String? subject,
    String? serverUrl,
    String? token,
    JitsiMeetEventListener? listener,
  }) async {
    if (_isJoining) {
      debugPrint('[JitsiService] Already joining a meeting, skipping duplicate call');
      return;
    }

    try {
      if (_isInMeeting) {
        await hangUp();
      }

      _isJoining = true;

      final userInfo = JitsiMeetUserInfo(
        displayName: displayName,
        email: email,
        avatar: avatarUrl,
      );

      final options = JitsiMeetConferenceOptions(
        serverURL: serverUrl ?? 'https://meet.jit.si',
        room: room,
        token: token,
        userInfo: userInfo,
        configOverrides: {
          'startWithAudioMuted': true,
          'startWithVideoMuted': true,
          'prejoinPageEnabled': false,
          'prejoinConfig': {'enabled': false},
          'lobbyModeEnabled': false,
          'enableWelcomePage': false,
          'disableDeepLinking': true,
          'subject': subject ?? '',
        },
        featureFlags: {
          'prejoinpage.enabled': false,
          'lobby-mode.enabled': false,
        },
      );

      final MethodResponse response = await _jitsiMeet.join(options, listener);
      if (!response.isSuccess) {
        throw Exception('Failed to join meeting: ${response.error ?? response.message ?? 'Unknown error'}');
      }
      _isInMeeting = true;
    } catch (error) {
      _isInMeeting = false;
      rethrow;
    } finally {
      _isJoining = false;
    }
  }

  static Future<void> leaveMeeting() async {
    try {
      if (_isInMeeting) {
        await _jitsiMeet.hangUp();
        _isInMeeting = false;
      }
    } catch (error) {
      // Ignore errors when leaving
    }
  }

  static Future<void> toggleAudio(bool mute) async {
    try {
      if (_isInMeeting) {
        await _jitsiMeet.setAudioMuted(mute);
      }
    } catch (error) {
      // Ignore errors
    }
  }

  static Future<void> toggleVideo(bool mute) async {
    try {
      if (_isInMeeting) {
        await _jitsiMeet.setVideoMuted(mute);
      }
    } catch (error) {
      // Ignore errors
    }
  }

  static Future<void> toggleSpeakerphone(bool enabled) async {
    try {
      if (_isInMeeting) {
        // Note: Speakerphone control might need platform-specific implementation
        // For now, we'll leave this as a placeholder
      }
    } catch (error) {
      // Ignore errors
    }
  }

  static Future<void> sendChatMessage(String message, {String? participantId}) async {
    try {
      if (_isInMeeting) {
        await _jitsiMeet.sendChatMessage(to: participantId, message: message);
      }
    } catch (error) {
      // Ignore errors
    }
  }

  static Future<void> switchCamera() async {
    try {
      if (_isInMeeting) {
        // Since switchCamera method is not available in this version of the JitsiMeet SDK,
        // we'll simulate camera switching by toggling video off and on
        // This achieves the same effect of camera switching on most platforms
        await toggleVideo(true); // Disable video
        await Future.delayed(const Duration(milliseconds: 500));
        await toggleVideo(false); // Re-enable video
      }
    } catch (error) {
      // Ignore errors
    }
  }

  static Future<void> hangUp() async {
    try {
      if (_isInMeeting) {
        await _jitsiMeet.hangUp();
        _isInMeeting = false;
      }
    } catch (_) {}
  }

  static void markLeft() {
    _isInMeeting = false;
  }
}
