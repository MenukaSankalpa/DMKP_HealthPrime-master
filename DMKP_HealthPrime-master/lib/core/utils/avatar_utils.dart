import 'package:flutter/material.dart';

class AvatarUtils {
  static const Map<String, IconData> avatars = {
    '1': Icons.face,
    '2': Icons.face_2,
    '3': Icons.face_3,
    '4': Icons.face_4,
    '5': Icons.face_5,
    '6': Icons.face_6,
    '7': Icons.sentiment_satisfied_alt,
    '8': Icons.pets,
    '9': Icons.bolt,
    '10': Icons.star,
    '11': Icons.favorite,
    '12': Icons.music_note,
    '13': Icons.sports_soccer,
    '14': Icons.directions_bike,
    '15': Icons.rocket_launch,
    '16': Icons.local_fire_department,
  };

  static IconData getIcon(String? id) {
    if (id == null || !avatars.containsKey(id)) {
      return Icons.person;
    }
    return avatars[id]!;
  }
}