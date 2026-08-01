import 'package:equatable/equatable.dart';

class SupportAgentModel extends Equatable {
  final String id;
  final String name;
  final String role;
  final String avatarUrl;
  final String facebookUrl;
  final String whatsappNumber;
  final String telegramUsername;
  final String phoneNumber;
  final bool isActive;

  const SupportAgentModel({
    required this.id,
    required this.name,
    required this.role,
    required this.avatarUrl,
    required this.facebookUrl,
    required this.whatsappNumber,
    required this.telegramUsername,
    required this.phoneNumber,
    required this.isActive,
  });

  factory SupportAgentModel.fromMap(Map<String, dynamic> map, [String docId = '']) {
    return SupportAgentModel(
      id: docId,
      name: map['name']?.toString() ?? 'Support Agent',
      role: map['role']?.toString() ?? 'Support Agent',
      avatarUrl: map['avatar_url']?.toString() ?? '',
      facebookUrl: map['facebook_url']?.toString() ?? '',
      whatsappNumber: map['whatsapp_number']?.toString() ?? '',
      telegramUsername: map['telegram_username']?.toString() ?? '',
      phoneNumber: map['phone_number']?.toString() ?? '',
      isActive: map['is_active'] == true || map['is_active'] == 'true',
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        role,
        avatarUrl,
        facebookUrl,
        whatsappNumber,
        telegramUsername,
        phoneNumber,
        isActive,
      ];
}
