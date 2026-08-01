import 'dart:io';
import 'package:flutter/foundation.dart';

@immutable
abstract class ProfileEvent {}

class LoadProfile extends ProfileEvent {}

class UpdateProfile extends ProfileEvent {
  final String uid;
  final String name;
  final String phone;
  final String? bio;
  final DateTime? dateOfBirth;

  UpdateProfile({
    required this.uid,
    required this.name,
    required this.phone,
    this.bio,
    this.dateOfBirth,
  });
}

class UpdateProfilePhoto extends ProfileEvent {
  final String uid;
  final File imageFile;

  UpdateProfilePhoto({required this.uid, required this.imageFile});
}
