import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../constants/colors.dart';

/// Full-screen video preview player.
///
/// Requires the `video_player` package:
///   flutter pub add video_player
///
/// If you'd rather not add the dependency yet, you can replace the body of
/// `_VideoPlayerBodyState.build` with a static Image + play icon mock.
class CustomVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String title;
  final double topInset;
  final VoidCallback onBack;

  const CustomVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.title,
    required this.topInset,
    required this.onBack,
  });

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  VideoPlayerController? _controller;
  bool _controlsVisible = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      await controller.initialize();
      controller.play();
      setState(() => _controller = controller);
    } catch (_) {
      setState(() => _hasError = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    final c = _controller;
    if (c == null) return;
    setState(() {
      c.value.isPlaying ? c.pause() : c.play();
    });
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
                    ? AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio,
                        child: VideoPlayer(_controller!),
                      )
                    : const CircularProgressIndicator(color: Colors.white),
          ),
          Positioned.fill(
            child: GestureDetector(
              onTap: () => setState(() => _controlsVisible = !_controlsVisible),
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
            // center play/pause
            if (_controller != null && _controller!.value.isInitialized)
              Center(
                child: _CircleIconButton(
                  size: 56,
                  icon: _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  onTap: _togglePlayPause,
                ),
              ),
            // bottom progress bar
            if (_controller != null && _controller!.value.isInitialized)
              Positioned(
                left: 12,
                right: 12,
                bottom: 24,
                child: VideoProgressIndicator(
                  _controller!,
                  allowScrubbing: true,
                  colors: VideoProgressColors(
                    playedColor: AppColors.getPrimaryColor(Theme.of(context).brightness),
                    bufferedColor: Colors.white30,
                    backgroundColor: Colors.white12,
                  ),
                ),
              ),
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