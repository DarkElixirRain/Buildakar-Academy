import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class CustomVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String title;
  final double topInset;
  final VoidCallback onBack;
  final VoidCallback? onNextLesson;
  final VoidCallback? onPreviousLesson;
  final bool hasNextLesson;
  final bool hasPreviousLesson;

  const CustomVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.title,
    required this.topInset,
    required this.onBack,
    this.onNextLesson,
    this.onPreviousLesson,
    this.hasNextLesson = false,
    this.hasPreviousLesson = false,
  });

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  VideoPlayerController? _controller;
  bool _controlsVisible = true;
  bool _hasError = false;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _lockLandscape();
    _init();
    _showControls();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controller?.removeListener(_onControllerUpdate);
    _controller?.dispose();
    _restorePortrait();
    super.dispose();
  }

  void _lockLandscape() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _restorePortrait() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  void _showControls() {
    setState(() => _controlsVisible = true);
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _controller != null && _controller!.value.isPlaying) {
        setState(() => _controlsVisible = false);
      }
    });
  }

  void _toggleControls() {
    if (_controlsVisible) {
      setState(() => _controlsVisible = false);
      _hideTimer?.cancel();
    } else {
      _showControls();
    }
  }

  Future<void> _init() async {
    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      await controller.initialize();
      controller.play();
      controller.addListener(_onControllerUpdate);
      setState(() => _controller = controller);
    } catch (_) {
      setState(() => _hasError = true);
    }
  }

  void _onControllerUpdate() {
    if (!mounted) return;
    if (_controller != null && _controller!.value.isPlaying && !_controlsVisible) {
      _hideTimer?.cancel();
      _hideTimer = Timer(const Duration(seconds: 4), () {
        if (mounted && _controller!.value.isPlaying) {
          setState(() => _controlsVisible = false);
        }
      });
    }
  }

  void _togglePlayPause() {
    final c = _controller;
    if (c == null) return;
    setState(() {
      c.value.isPlaying ? c.pause() : c.play();
    });
    _showControls();
  }

  void _seekBy(int seconds) {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    final pos = c.value.position.inMilliseconds + (seconds * 1000);
    final clamped = pos.clamp(0, c.value.duration.inMilliseconds);
    c.seekTo(Duration(milliseconds: clamped));
    _showControls();
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          Center(
            child: _hasError
                ? const Text(
                    'Unable to load preview video',
                    style: TextStyle(color: Colors.white70),
                  )
                : _controller != null && _controller!.value.isInitialized
                    ? _controller!.value.size.width > 0
                        ? Center(
                            child: VideoPlayer(_controller!),
                          )
                        : const CircularProgressIndicator(color: Colors.white)
                    : const CircularProgressIndicator(color: Colors.white),
          ),
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleControls,
              behavior: HitTestBehavior.translucent,
            ),
          ),
          if (_controlsVisible) ...[
            // top bar
            Positioned(
              top: widget.topInset + 8,
              left: 12,
              right: 12,
              child: Row(
                children: [
                  _CircleIconButton(icon: Icons.arrow_back, onTap: widget.onBack),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            // gradient top
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.center,
                      colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent],
                    ),
                  ),
                ),
              ),
            ),
            // gradient bottom
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 140,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (_controller != null && _controller!.value.isInitialized) ...[
              // center play/pause (large, only show when paused)
              if (!_controller!.value.isPlaying)
                Center(
                  child: GestureDetector(
                    onTap: _togglePlayPause,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.play_arrow, color: Colors.white, size: 40),
                    ),
                  ),
                ),
              // bottom controls bar
              Positioned(
                left: 0,
                right: 0,
                bottom: 16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // progress bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: VideoProgressIndicator(
                        _controller!,
                        allowScrubbing: true,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        colors: VideoProgressColors(
                          playedColor: Colors.blueAccent,
                          bufferedColor: Colors.white30,
                          backgroundColor: Colors.white12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // controls row: time - seek back - play/pause - seek forward - time - next
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text(
                            _formatDuration(_controller!.value.position),
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                          const Spacer(),
                          // previous lesson
                          if (widget.hasPreviousLesson)
                            _ControlButton(
                              icon: Icons.skip_previous_rounded,
                              onTap: () => widget.onPreviousLesson?.call(),
                            ),
                          const SizedBox(width: 4),
                          // backward 10s
                          _ControlButton(
                            icon: Icons.replay_10_rounded,
                            onTap: () => _seekBy(-10),
                          ),
                          const SizedBox(width: 4),
                          // play/pause
                          _ControlButton(
                            icon: _controller!.value.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            size: 44,
                            iconSize: 26,
                            onTap: _togglePlayPause,
                          ),
                          const SizedBox(width: 4),
                          // forward 10s
                          _ControlButton(
                            icon: Icons.forward_10_rounded,
                            onTap: () => _seekBy(10),
                          ),
                          const SizedBox(width: 4),
                          // next lesson
                          if (widget.hasNextLesson)
                            _ControlButton(
                              icon: Icons.skip_next_rounded,
                              onTap: () => widget.onNextLesson?.call(),
                            ),
                          const Spacer(),
                          Text(
                            _formatDuration(_controller!.value.duration),
                            style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;

  const _CircleIconButton({required this.icon, required this.onTap, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: size * 0.5),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final double iconSize;

  const _ControlButton({
    required this.icon,
    required this.onTap,
    this.size = 36,
    this.iconSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: iconSize),
      ),
    );
  }
}
