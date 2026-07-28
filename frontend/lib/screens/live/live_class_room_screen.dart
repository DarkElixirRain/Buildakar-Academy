import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import '../../constants/colors.dart';
import '../../providers/live_class_provider.dart';
import '../../services/jitsi_service.dart';
import '../../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class LiveClassRoomScreen extends StatefulWidget {
  final Map<String, dynamic> liveClass;
  final Map<String, dynamic> roomData;
  final String userName;
  final String? userEmail;
  final String? userAvatarUrl;

  const LiveClassRoomScreen({
    Key? key,
    required this.liveClass,
    required this.roomData,
    this.userName = 'Student',
    this.userEmail,
    this.userAvatarUrl,
  }) : super(key: key);

  @override
  State<LiveClassRoomScreen> createState() => _LiveClassRoomScreenState();
}

enum _RoomState { connecting, inMeeting, ended, error }

class _LiveClassRoomScreenState extends State<LiveClassRoomScreen> {
  _RoomState _state = _RoomState.connecting;
  String? _errorMessage;
  int _participantCount = 0;
  bool _isLeaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _connect());
  }

  void _onConferenceJoined(String url) {
    if (!mounted) return;
    setState(() => _state = _RoomState.inMeeting);
  }

  void _onConferenceTerminated(String url, Object? error) {
    JitsiService.markLeft();
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _state = _RoomState.error;
        _errorMessage = error.toString();
      });
    } else {
      setState(() => _state = _RoomState.ended);
      _isLeaving = true;
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) Navigator.of(context).pop();
      });
    }
  }

  void _onParticipantJoined(String? email, String? name, String? role, String? participantId) {
    if (!mounted) return;
    setState(() => _participantCount++);
  }

  void _onParticipantLeft(String? participantId) {
    if (!mounted) return;
    setState(() {
      if (_participantCount > 0) _participantCount--;
    });
  }

Future<void> _connect() async {
  final room = widget.roomData['room']?.toString() ??
      widget.roomData['roomName']?.toString() ??
      widget.roomData['jitsiRoomName']?.toString();
  final serverUrl = widget.roomData['serverUrl']?.toString();
  final token = widget.roomData['token']?.toString();
  final title = widget.liveClass['title']?.toString() ?? 'Live Class';

  debugPrint('[LiveClassRoom] _connect: room=$room title=$title serverUrl=$serverUrl tokenPresent=${token != null && token.isNotEmpty}');

  if (room == null || room.isEmpty) {
    debugPrint('[LiveClassRoom] ERROR: room name is null or empty. roomData keys: ${widget.roomData.keys}');
    setState(() {
      _state = _RoomState.error;
      _errorMessage = 'This class does not have a meeting room configured.';
    });
    return;
  }

  final listener = JitsiMeetEventListener(
    conferenceJoined: (url) {
      debugPrint('[LiveClassRoom] ✅ conferenceJoined: $url');
      _onConferenceJoined(url);
    },
    conferenceTerminated: (url, error) {
      debugPrint('[LiveClassRoom] 🔴 conferenceTerminated: url=$url error=$error');
      _onConferenceTerminated(url, error);
    },
    readyToClose: () {
      debugPrint('[LiveClassRoom] 📴 readyToClose');
    },
    participantJoined: (email, name, role, participantId) {
      debugPrint('[LiveClassRoom] 👤 participantJoined: $name ($participantId)');
      _onParticipantJoined(email, name, role, participantId);
    },
    participantLeft: (participantId) {
      debugPrint('[LiveClassRoom] 👋 participantLeft: $participantId');
      _onParticipantLeft(participantId);
    },
  );

  try {
    debugPrint('[LiveClassRoom] ⏳ Calling JitsiService.joinMeeting...');
    await JitsiService.joinMeeting(
      room: room,
      displayName: widget.userName,
      email: widget.userEmail,
      avatarUrl: widget.userAvatarUrl,
      subject: title,
      serverUrl: serverUrl,
      token: token,
      listener: listener,
    ).timeout(const Duration(seconds: 20));
    debugPrint('[LiveClassRoom] ✅ JitsiService.joinMeeting completed');
    if (mounted) {
      setState(() => _state = _RoomState.inMeeting);
    }
  } on TimeoutException {
    debugPrint('[LiveClassRoom] ⚠️ JitsiService.joinMeeting timed out after 20s');
    if (!mounted) return;
    setState(() {
      _state = _RoomState.error;
      _errorMessage = 'Connection timed out. Please check your connection and try again.';
    });
  } catch (e) {
    debugPrint('[LiveClassRoom] ❌ Exception from JitsiService.joinMeeting: $e');
    if (!mounted) return;
    setState(() {
      _state = _RoomState.error;
      _errorMessage = 'Could not connect to the class. Please check your connection and try again.';
    });
  }
}
  Future<void> _retry() async {
    setState(() {
      _state = _RoomState.connecting;
      _errorMessage = null;
    });
    await _connect();
  }

  Future<void> _leaveRoom() async {
    if (_isLeaving) return;
    _isLeaving = true;

    await JitsiService.hangUp();
    JitsiService.markLeft();

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _switchCamera() async {
    await JitsiService.switchCamera();
  }

  Future<void> _endClass() async {
    // Show confirmation dialog
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('End Class'),
        content: const Text('Are you sure you want to end this class for everyone?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('End Class'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // End the class using the LiveClassProvider
    if (!mounted) return;
    try {
      final liveClassId = widget.liveClass['id']?.toString();
      if (liveClassId == null || liveClassId.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to end class: Invalid class ID'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final provider = Provider.of<LiveClassProvider>(context, listen: false);
      final success = await provider.endLiveClass(liveClassId);

      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.errorMessage.isNotEmpty
                  ? provider.errorMessage
                  : 'Failed to end class'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else if (mounted) {
        // Successfully ended the class, show success message and leave
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Class ended successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // Leave the room after ending the class
        if (mounted) {
          await _leaveRoom();
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error ending class: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _toggleAudio(bool mute) async {
    await JitsiService.toggleAudio(mute);
  }

  Future<void> _toggleVideo(bool mute) async {
    await JitsiService.toggleVideo(mute);
  }

  @override
  void dispose() {
    JitsiService.markLeft();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.liveClass['title']?.toString() ?? 'Live Class';

    return PopScope(
      canPop: _state != _RoomState.inMeeting,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (_state == _RoomState.inMeeting) {
          await _leaveRoom();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.getBackgroundColor(Theme.of(context).brightness),
        body: SafeArea(
          child: _buildBody(title),
        ),
      ),
    );
  }

  Widget _buildBody(String title) {
    switch (_state) {
      case _RoomState.connecting:
        return _ConnectingView(title: title);
      case _RoomState.inMeeting:
        final bool isInstructor = widget.liveClass['instructorId']?.toString() ==
            Provider.of<AuthProvider>(context, listen: false).user?.id;

        return _InMeetingBackdrop(
          title: title,
          participantCount: _participantCount,
          onLeave: _leaveRoom,
          onEnd: isInstructor ? _endClass : null,
          isInstructor: isInstructor,
          onAudioToggle: (mute) => _toggleAudio(mute),
          onVideoToggle: (mute) => _toggleVideo(mute),
          onCameraToggle: _switchCamera,
        );
      case _RoomState.ended:
        return const _EndedView();
      case _RoomState.error:
        return _ErrorView(
          message: _errorMessage ?? 'Something went wrong.',
          onRetry: _retry,
          onClose: () => Navigator.of(context).pop(),
        );
    }
  }
}

// ---------------------------------------------------------------------------
// States
// ---------------------------------------------------------------------------

class _ConnectingView extends StatelessWidget {
  final String title;
  const _ConnectingView({required this.title});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.getErrorColor(brightness),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'LIVE',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.getTextColor(brightness),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.getTextColor(brightness),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.getTextColor(brightness),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Connecting to class…',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.getTextSecondaryColor(brightness),
            ),
          ),
        ],
      ),
    );
  }
}

class _InMeetingBackdrop extends StatelessWidget {
  final String title;
  final int participantCount;
  final VoidCallback onLeave;
  final VoidCallback? onEnd;
  final bool isInstructor;
  final Function(bool) onAudioToggle;
  final Function(bool) onVideoToggle;
  final VoidCallback? onCameraToggle;

  const _InMeetingBackdrop({
    required this.title,
    required this.participantCount,
    required this.onLeave,
    this.onEnd,
    this.isInstructor = false,
    required this.onAudioToggle,
    required this.onVideoToggle,
    this.onCameraToggle,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final textColor = AppColors.getTextColor(brightness);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.videocam_rounded,
            color: textColor.withValues(alpha: 0.24),
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.inter(
              color: textColor.withValues(alpha: 0.38),
              fontWeight: FontWeight.w600,
            ),
          ),
          if (participantCount > 0) ...[
            const SizedBox(height: 8),
            Text(
              '$participantCount participant${
                  participantCount > 1 ? 's' : ''
              }',
              style: GoogleFonts.inter(
                color: textColor.withValues(alpha: 0.24),
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Audio mute/unmute button
              Tooltip(
                message: 'Mute microphone',
                child: IconButton(
                  icon: Icon(
                    Icons.mic_none,
                    color: textColor.withValues(alpha: 0.24),
                    size: 28,
                  ),
                  onPressed: () => onAudioToggle(true),
                ),
              ),
              const SizedBox(width: 16),
              // Video on/off button
              Tooltip(
                message: 'Turn off video',
                child: IconButton(
                  icon: Icon(
                    Icons.videocam,
                    color: textColor.withValues(alpha: 0.24),
                    size: 28,
                  ),
                  onPressed: () => onVideoToggle(true),
                ),
              ),
              const SizedBox(width: 16),
              // Switch camera button
              if (onCameraToggle != null) ...[
                Tooltip(
                  message: 'Switch camera',
                  child: IconButton(
                    icon: Icon(
                      Icons.cameraswitch,
                      color: textColor.withValues(alpha: 0.24),
                      size: 28,
                    ),
                    onPressed: () => onCameraToggle!(),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 32),
          if (isInstructor && onEnd != null) ...[
            // Instructor sees "End Class" button
            ElevatedButton.icon(
              onPressed: onEnd,
              icon:
                  const Icon(Icons.stop_circle, color: Colors.white, size: 20),
              label: Text(
                'End Class',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          ElevatedButton.icon(
            onPressed: onLeave,
            icon:
                Icon(Icons.call_end, color: textColor, size: 20),
            label: Text(
              'Leave Class',
              style: GoogleFonts.inter(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.getErrorColor(brightness),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EndedView extends StatelessWidget {
  const _EndedView();

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final textColor = AppColors.getTextColor(brightness);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.call_end_rounded,
            color: AppColors.getErrorColor(brightness),
            size: 40,
          ),
          const SizedBox(height: 16),
          Text(
            'You left the class',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'The meeting has ended',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: textColor.withValues(alpha: 0.54),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onClose;

  const _ErrorView({
    required this.message,
    required this.onRetry,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final textColor = AppColors.getTextColor(brightness);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: AppColors.getErrorColor(brightness),
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: textColor.withValues(alpha: 0.70),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton(
                  onPressed: onClose,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: textColor.withValues(alpha: 0.24)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: GoogleFonts.inter(color: textColor),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.getPrimaryColor(brightness),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Retry',
                    style: GoogleFonts.inter(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}