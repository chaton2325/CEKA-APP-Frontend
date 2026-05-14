import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String url;
  final bool autoPlay;
  final bool looping;
  final bool isList;

  const VideoPlayerWidget({
    super.key,
    required this.url,
    this.autoPlay = true,
    this.looping = false,
    this.isList = false,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isChecking = true;
  String _finalUrl = '';

  @override
  void initState() {
    super.initState();
    _checkAndInitialize();
  }

  Future<void> _checkAndInitialize() async {
    if (widget.url.startsWith('http')) {
      _finalUrl = widget.url;
    } else {
      final baseUrl = AppConstants.baseUrl.endsWith('/') 
          ? AppConstants.baseUrl.substring(0, AppConstants.baseUrl.length - 1) 
          : AppConstants.baseUrl;
      final mediaUrl = widget.url.startsWith('/') ? widget.url : '/${widget.url}';
      _finalUrl = '$baseUrl$mediaUrl';
    }
    
    _finalUrl = Uri.encodeFull(_finalUrl);

    try {
      // Diagnostic check: verify if the server responds
      final response = await http.head(Uri.parse(_finalUrl)).timeout(const Duration(seconds: 5));
      debugPrint('Diagnostic: HTTP HEAD returned ${response.statusCode} for $_finalUrl');
      
      if (response.statusCode != 200) {
        throw 'Le serveur a renvoyé une erreur ${response.statusCode}';
      }

      if (mounted) setState(() => _isChecking = false);
      _initializePlayer();
    } catch (e) {
      debugPrint('Diagnostic error: $e');
      if (mounted) {
        setState(() {
          _isChecking = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _initializePlayer() async {
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(_finalUrl),
      httpHeaders: {'Connection': 'keep-alive'},
    );

    try {
      await _videoPlayerController.initialize();
      
      if (!mounted) return;

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: widget.autoPlay,
        looping: widget.looping,
        aspectRatio: _videoPlayerController.value.aspectRatio,
        placeholder: Container(color: Colors.black),
        autoInitialize: true,
        allowedScreenSleep: false,
        errorBuilder: (context, errorMessage) {
          return _buildErrorWidget(errorMessage);
        },
      );
      setState(() {});
    } catch (e) {
      debugPrint('VideoPlayer error: $e');
      if (mounted) setState(() => _hasError = true);
    }
  }

  Future<void> _openExternally() async {
    final uri = Uri.parse(_finalUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(
              'Erreur: $error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _openExternally,
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: const Text('Ouvrir avec le lecteur système'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white24,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return Container(
        height: 200,
        color: Colors.black,
        child: const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
      );
    }

    if (_hasError) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        child: _buildErrorWidget('Réseau ou format non supporté'),
      );
    }

    if (_chewieController != null && _chewieController!.videoPlayerController.value.isInitialized) {
      return Container(
        constraints: BoxConstraints(maxHeight: widget.isList ? 300 : double.infinity),
        child: AspectRatio(
          aspectRatio: _videoPlayerController.value.aspectRatio,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.isList ? 12 : 0),
            child: Chewie(controller: _chewieController!),
          ),
        ),
      );
    }

    return Container(
      height: 200,
      color: Colors.black,
      child: const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
    );
  }
}
