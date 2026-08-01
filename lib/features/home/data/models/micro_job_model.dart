import 'package:cloud_firestore/cloud_firestore.dart';

class MicroJobModel {
  final String id;
  final String userId; // stored as 'userId' or 'postedBy'
  final String posterName;
  final String jobName;
  final String jobDescription;
  final String jobLink;
  final double perJobAmount;
  final int totalJobLimit;
  final int completedCount;
  final String? featureImage; // stored as 'featureImage' or 'imageUrl'
  final String status;
  final DateTime createdAt;

  MicroJobModel({
    required this.id,
    required this.userId,
    required this.posterName,
    required this.jobName,
    required this.jobDescription,
    required this.jobLink,
    required this.perJobAmount,
    required this.totalJobLimit,
    this.completedCount = 0,
    this.featureImage,
    this.status = 'active',
    required this.createdAt,
  });

  /// Available slots = totalJobLimit - completedCount
  int get availableSlots =>
      (totalJobLimit - completedCount).clamp(0, totalJobLimit);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'postedBy': userId,
      'posterName': posterName,
      'jobName': jobName,
      'jobDescription': jobDescription,
      'jobLink': jobLink,
      'perJobAmount': perJobAmount,
      'totalJobLimit': totalJobLimit,
      'completedCount': completedCount,
      'featureImage': featureImage,
      'imageUrl': featureImage, // write both so queries on either work
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory MicroJobModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    // Safely parse createdAt — never hard-cast
    DateTime parsedDate;
    final rawDate = map['createdAt'];
    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    // Support both field name conventions
    final image = (map['featureImage'] as String?)?.isNotEmpty == true
        ? map['featureImage'] as String
        : (map['imageUrl'] as String?)?.isNotEmpty == true
        ? map['imageUrl'] as String
        : null;

    return MicroJobModel(
      id: docId ?? map['id'] ?? '',
      userId: map['userId'] ?? map['postedBy'] ?? '',
      posterName: map['posterName'] ?? '',
      jobName: map['jobName'] ?? '',
      jobDescription: map['jobDescription'] ?? '',
      jobLink: map['jobLink'] ?? '',
      perJobAmount: (map['perJobAmount'] ?? 0.0).toDouble(),
      totalJobLimit: (map['totalJobLimit'] ?? 0) as int,
      completedCount: (map['completedCount'] ?? map['filledSlots'] ?? 0) as int,
      featureImage: image,
      status: map['status'] ?? 'active',
      createdAt: parsedDate,
    );
  }
}
