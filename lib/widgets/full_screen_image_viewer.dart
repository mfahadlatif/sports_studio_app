import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FullScreenImageViewer extends StatelessWidget {
  final List<String> images;
  final int initialIndex;

  const FullScreenImageViewer({
    super.key,
    required this.images,
    this.initialIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final PageController pageController = PageController(initialPage: initialIndex);
    final RxInt currentIndex = initialIndex.obs;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GestureDetector(
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity! > 800) {
                Get.back();
              }
            },
            child: PageView.builder(
              controller: pageController,
              itemCount: images.length,
              onPageChanged: (index) => currentIndex.value = index,
              itemBuilder: (context, index) {
                final path = images[index];
                final isUrl = path.startsWith('http') || path.startsWith('https');

                return InteractiveViewer(
                  child: Center(
                    child: isUrl 
                      ? CachedNetworkImage(
                          imageUrl: path,
                          fit: BoxFit.contain,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(color: Colors.white),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.broken_image, color: Colors.white, size: 50),
                        )
                      : Image.file(
                          File(path),
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => 
                              const Icon(Icons.broken_image, color: Colors.white, size: 50),
                        ),
                  ),
                );
              },
            ),
          ),
          
          // Close button
          Positioned(
            top: 50,
            right: 20,
            child: CircleAvatar(
              backgroundColor: Colors.black.withValues(alpha: 0.5),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Get.back(),
              ),
            ),
          ),
          
          // Indicator
          if (images.length > 1)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Obx(() => Text(
                  "${currentIndex.value + 1} / ${images.length}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                )),
              ),
            ),
        ],
      ),
    );
  }
}
