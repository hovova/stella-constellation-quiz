import 'package:flutter/material.dart';

import '../models/avatar_option.dart';

const List<AvatarOption> avatarOptions = [
  AvatarOption(
    id: 'star',
    name: 'Star',
    fallbackIcon: Icons.star,
  ),
  AvatarOption(
    id: 'moon',
    name: 'Moon',
    fallbackIcon: Icons.dark_mode,
  ),
  AvatarOption(
    id: 'rocket',
    name: 'Rocket',
    fallbackIcon: Icons.rocket_launch,
  ),
  AvatarOption(
    id: 'planet',
    name: 'Planet',
    fallbackIcon: Icons.public,
  ),
  AvatarOption(
    id: 'trophy',
    name: 'Trophy',
    fallbackIcon: Icons.emoji_events,
  ),
  AvatarOption(
    id: 'premium',
    name: 'Premium',
    fallbackIcon: Icons.workspace_premium,
  ),
];

AvatarOption findAvatarById(String id) {
  return avatarOptions.firstWhere(
    (avatar) => avatar.id == id,
    orElse: () => avatarOptions.first,
  );
}