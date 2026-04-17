import 'package:flutter/material.dart';
import 'package:azager/core/constants/app_colors.dart';

class ImageViewerScreen extends StatefulWidget {
  final List<String> imageAssets;
  final int initialIndex;

  const ImageViewerScreen({
    super.key,
    required this.imageAssets,
    required this.initialIndex,
  });

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  late final PageController _controller;
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full-screen page view
          PageView.builder(
            controller: _controller,
            itemCount: widget.imageAssets.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (_, i) => InteractiveViewer(
              minScale: 0.8,
              maxScale: 4.0,
              child: _buildViewerImage(widget.imageAssets[i]),
            ),
          ),

          // Close button
          Positioned(
            top: 52,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
          ),

          // Counter
          Positioned(
            top: 56,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '${_current + 1} / ${widget.imageAssets.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Dot indicators
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.imageAssets.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _current == i ? 20 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: _current == i ? AppColors.primary : Colors.white38,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewerImage(String image) {
    if (image.startsWith('http')) {
      return Image.network(
        image,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _fallback(image),
      );
    }
    return Image.asset(
      image,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => _fallback(image),
    );
  }

  Widget _fallback(String image) {
    return Container(
      color: const Color(0xFF1A1A1A),
      child: Center(
        child: Text(
          image.isNotEmpty
              ? image.split('/').last.split('.')[0].toUpperCase()[0]
              : '?',
          style: const TextStyle(
            fontSize: 80,
            fontWeight: FontWeight.w800,
            color: Colors.white24,
          ),
        ),
      ),
    );
  }
}
