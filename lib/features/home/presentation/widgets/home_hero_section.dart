import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomeHeroSection extends StatelessWidget {
  const HomeHeroSection({super.key});

  static const double _bannerHeight = 185.0;
  static const double _borderRadius = 15.0;
  static const String _defaultPlaceholderAsset = 'assets/images/top_header_image.png';

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(_borderRadius));

    return Container(
      width: double.infinity,
      height: _bannerHeight,
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('app_config')
              .doc('home_banner')
              .snapshots(),
          builder: (context, snapshot) {
            // ── Fallback State (Loading / Error / Missing Document) ──────────
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildPlaceholder();
            }

            if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
              return _buildPlaceholder();
            }

            final data = snapshot.data!.data() as Map<String, dynamic>?;
            final List<String> images = _extractImageUrls(data);

            // ── Condition 1 (Empty Array / No Images) ────────────────────────
            if (images.isEmpty) {
              return _buildPlaceholder();
            }

            // ── Condition 2 (Single Image -> Static, No Slider) ──────────────
            if (images.length == 1) {
              return _buildSingleImage(images.first, radius);
            }

            // ── Condition 3 (Multiple Images -> Carousel Slider) ─────────────
            return _buildCarousel(images, radius);
          },
        ),
      ),
    );
  }

  /// ─── Extract Image URLs with fallbacks for multiple data formats ───────────
  List<String> _extractImageUrls(Map<String, dynamic>? data) {
    if (data == null) return [];

    final rawImages = data['images'] ?? data['banners'] ?? data['imageUrl'] ?? data['image'];

    if (rawImages is List) {
      return rawImages
          .map((e) => e.toString().trim())
          .where((url) => url.isNotEmpty && (url.startsWith('http://') || url.startsWith('https://')))
          .toList();
    } else if (rawImages is String && rawImages.trim().isNotEmpty) {
      final trimmed = rawImages.trim();
      if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
        return [trimmed];
      }
    }
    return [];
  }

  /// ─── Fallback Local Asset Placeholder ─────────────────────────────────────
  Widget _buildPlaceholder() {
    return Image.asset(
      _defaultPlaceholderAsset,
      fit: BoxFit.cover,
      width: double.infinity,
      height: _bannerHeight,
      errorBuilder: (context, error, stackTrace) => Container(
        width: double.infinity,
        height: _bannerHeight,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1205), Color(0xFF3D2B00)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }

  /// ─── Single Network Image ─────────────────────────────────────────────────
  Widget _buildSingleImage(String imageUrl, BorderRadius radius) {
    return ClipRRect(
      borderRadius: radius,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: _bannerHeight,
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) {
          debugPrint('Error loading home banner image ($url): $error');
          return _buildPlaceholder();
        },
      ),
    );
  }

  /// ─── Multi-Image Auto-Play Carousel Slider ────────────────────────────────
  Widget _buildCarousel(List<String> images, BorderRadius radius) {
    return CarouselSlider.builder(
      itemCount: images.length,
      options: CarouselOptions(
        height: _bannerHeight,
        viewportFraction: 1.0, // Full width matching original design
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 4),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
        enableInfiniteScroll: true,
        enlargeCenterPage: false,
        padEnds: false,
      ),
      itemBuilder: (context, index, realIndex) {
        final imageUrl = images[index];
        return ClipRRect(
          borderRadius: radius,
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: _bannerHeight,
            placeholder: (context, url) => _buildPlaceholder(),
            errorWidget: (context, url, error) {
              debugPrint('Error loading home banner image ($url): $error');
              return _buildPlaceholder();
            },
          ),
        );
      },
    );
  }
}
