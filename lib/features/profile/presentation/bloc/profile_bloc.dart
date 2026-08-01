import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_earn/features/profile/domain/repositories/profile_repository.dart';
import 'package:global_earn/features/user/presentation/bloc/user_bloc.dart';
import 'package:global_earn/features/user/presentation/bloc/user_event.dart';
import 'profile_event.dart';
import 'profile_state.dart';
import 'dart:developer' as dev;

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository repository;
  final UserBloc userBloc;

  ProfileBloc({required this.repository, required this.userBloc})
    : super(ProfileInitial()) {
    on<LoadProfile>((event, emit) {
      dev.log('🔥 [Profile] Loading user data...');
      emit(ProfileLoaded());
    });

    on<UpdateProfile>((event, emit) async {
      if (event.name.isEmpty) {
        emit(ProfileError('নাম দিন'));
        return;
      }
      if (event.phone.length < 11) {
        emit(ProfileError('সঠিক মোবাইল নম্বর দিন'));
        return;
      }
      if (event.dateOfBirth == null) {
        emit(ProfileError('অনুগ্রহ করে জন্ম তারিখ নির্বাচন করুন'));
        return;
      }

      emit(ProfileUpdating());
      try {
        dev.log('🔥 [Profile] Updating profile...');
        await repository.updateProfile(
          uid: event.uid,
          name: event.name,
          phone: event.phone,
          bio: event.bio,
          dateOfBirth: event.dateOfBirth,
        );

        // Refresh UserBloc with fresh data
        final freshUser = await repository.getUser(event.uid);
        userBloc.add(UserLoadedEvent(freshUser));

        dev.log('✅ [Profile] Profile updated successfully');
        emit(ProfileSuccess('প্রোফাইল আপডেট হয়েছে'));
        emit(ProfileLoaded());
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    });

    on<UpdateProfilePhoto>((event, emit) async {
      emit(ProfileUpdating());
      try {
        await repository.uploadProfilePhoto(
          uid: event.uid,
          imageFile: event.imageFile,
        );

        // Refresh UserBloc with fresh data
        final freshUser = await repository.getUser(event.uid);
        userBloc.add(UserLoadedEvent(freshUser));

        emit(ProfileSuccess('প্রোফাইল ফটো আপডেট হয়েছে'));
        emit(ProfileLoaded());
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    });
  }
}
