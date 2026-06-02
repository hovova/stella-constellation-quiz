import 'package:flutter/material.dart';

class AvatarOption {
  final String id;
  final String name;
  final IconData fallbackIcon;
  final String? imagePath;

  const AvatarOption({
    required this.id,
    required this.name,
    required this.fallbackIcon,
    this.imagePath,
  });
}