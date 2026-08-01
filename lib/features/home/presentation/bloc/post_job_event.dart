import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class PostJobEvent extends Equatable {
  const PostJobEvent();

  @override
  List<Object?> get props => [];
}

class PostJobFormChanged extends PostJobEvent {
  final String? jobName;
  final String? jobDescription;
  final String? jobLink;
  final String? perJobAmount;
  final String? totalJobLimit;

  const PostJobFormChanged({
    this.jobName,
    this.jobDescription,
    this.jobLink,
    this.perJobAmount,
    this.totalJobLimit,
  });

  @override
  List<Object?> get props => [
    jobName,
    jobDescription,
    jobLink,
    perJobAmount,
    totalJobLimit,
  ];
}

class PostJobImagePicked extends PostJobEvent {
  final File? image;
  const PostJobImagePicked(this.image);

  @override
  List<Object?> get props => [image];
}

class PostJobSubmitted extends PostJobEvent {
  const PostJobSubmitted();
}
