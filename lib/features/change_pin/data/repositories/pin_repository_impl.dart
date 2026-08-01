import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_earn/core/network/network_info.dart';
import 'package:global_earn/features/change_pin/domain/repositories/pin_repository.dart';
import 'dart:developer' as dev;

class PinRepositoryImpl implements PinRepository {
  final FirebaseFirestore firestore;
  final NetworkInfo networkInfo;

  PinRepositoryImpl({required this.firestore, required this.networkInfo});

  @override
  Future<String?> getPinStatus(String uid) async {
    final doc = await firestore.collection('users').doc(uid).get();
    return doc.data()?['pin'] as String?;
  }

  @override
  Future<void> setPin(String uid, String newPin) async {
    if (!await networkInfo.isConnected) throw 'ইন্টারনেট সংযোগ নেই';

    await firestore.collection('users').doc(uid).update({'pin': newPin});
    dev.log('✅ [PIN] Pin set successfully for uid: $uid');
  }

  @override
  Future<void> changePin(String uid, String currentPin, String newPin) async {
    if (!await networkInfo.isConnected) throw 'ইন্টারনেট সংযোগ নেই';

    final doc = await firestore.collection('users').doc(uid).get();
    final storedPin = doc.data()?['pin'] as String?;

    if (storedPin != currentPin) {
      dev.log('❌ [PIN] Wrong current pin');
      throw 'বর্তমান পিন ভুল';
    }

    await firestore.collection('users').doc(uid).update({'pin': newPin});
    dev.log('✅ [PIN] Pin updated successfully for uid: $uid');
  }
}
