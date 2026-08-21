import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class HlsPlayer extends StatefulWidget {
  const HlsPlayer({required this.url, super.key});

  final String url;

  @override
  State<HlsPlayer> createState() => _HlsPlayerState();
}

class _HlsPlayerState extends State<HlsPlayer> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void didUpdateWidget(covariant HlsPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) _initialize();
  }

  Future<void> _initialize() async {
    await _disposeControllers();
    if (!mounted) return;
    setState(() => _error = null);
    final videoController =
        VideoPlayerController.networkUrl(Uri.parse(widget.url));
    try {
      await videoController.initialize();
      if (!mounted) {
        await videoController.dispose();
        return;
      }
      final chewieController = ChewieController(
        videoPlayerController: videoController,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControlsOnInitialize: true,
        placeholder: const ColoredBox(color: Colors.black),
        errorBuilder: (_, message) =>
            Center(child: Text(message, textAlign: TextAlign.center)),
      );
      setState(() {
        _videoController = videoController;
        _chewieController = chewieController;
      });
    } catch (_) {
      await videoController.dispose();
      if (mounted) {
        setState(() =>
            _error = 'تعذر تشغيل مصدر HLS. تحقق من حالة البث أو أعد المحاولة.');
      }
    }
  }

  Future<void> _disposeControllers() async {
    _chewieController?.dispose();
    _chewieController = null;
    await _videoController?.dispose();
    _videoController = null;
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return _PlayerMessage(message: _error!, onRetry: _initialize);
    }
    if (_chewieController == null ||
        !(_videoController?.value.isInitialized ?? false)) {
      return const AspectRatio(
        aspectRatio: 16 / 9,
        child: ColoredBox(
          color: Colors.black,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    return AspectRatio(
        aspectRatio: _videoController!.value.aspectRatio,
        child: Chewie(controller: _chewieController!));
  }
}

class _PlayerMessage extends StatelessWidget {
  const _PlayerMessage({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ColoredBox(
        color: Colors.black,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: Colors.white70, size: 36),
                const SizedBox(height: 10),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('إعادة المحاولة')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
