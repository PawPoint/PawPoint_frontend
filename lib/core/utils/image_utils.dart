import 'dart:convert';
import 'package:flutter/material.dart';

/// A utility to handle profile images from various sources:
/// 1. Network URLs (http/https)
/// 2. Base64 Data URIs (data:image/...)
/// 3. Asset paths (fallback or explicit)
class ImageUtils {
  static ImageProvider? getProfileImage(String? photoUrl) {
    if (photoUrl == null || photoUrl.isEmpty) return null;

    if (photoUrl.startsWith('http')) {
      return NetworkImage(photoUrl);
    }

    if (photoUrl.startsWith('data:image')) {
      try {
        final base64String = photoUrl.split(',').last;
        return MemoryImage(base64Decode(base64String));
      } catch (e) {
        debugPrint('Error decoding base64 image: $e');
        return null;
      }
    }

    // If it doesn't look like a URL or Data URI, assume it might be an asset path
    // but typically we'd handle assets separately if we know they are assets.
    return null;
  }

  static Widget buildProfileImage(
    String? photoUrl, {
    double radius = 28,
    IconData fallbackIcon = Icons.person,
    double fallbackIconSize = 22,
    Color? fallbackColor,
    BoxFit fit = BoxFit.cover,
  }) {
    final imageProvider = getProfileImage(photoUrl);
    
    if (imageProvider != null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: const Color(0xFFE8E8E8),
        backgroundImage: imageProvider,
      );
    }

    // If photoUrl is an asset path (not URL/Base64)
    if (photoUrl != null && photoUrl.isNotEmpty && !photoUrl.startsWith('http') && !photoUrl.startsWith('data:image')) {
       return CircleAvatar(
        radius: radius,
        backgroundColor: const Color(0xFFE8E8E8),
        backgroundImage: AssetImage(photoUrl),
        onBackgroundImageError: (_, __) {},
        child: null, // If asset fails, it will show the background color or we could handle error better
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFE8E8E8),
      child: Icon(
        fallbackIcon,
        size: fallbackIconSize,
        color: fallbackColor ?? Colors.grey,
      ),
    );
  }
}
