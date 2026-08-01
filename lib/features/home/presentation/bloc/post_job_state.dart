import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class PostJobState extends Equatable {
  final String jobName;
  final String jobDescription;
  final String jobLink;
  final String perJobAmount;
  final String totalJobLimit;
  final File? image;

  const PostJobState({
    this.jobName = '',
    this.jobDescription = '',
    this.jobLink = '',
    this.perJobAmount = '',
    this.totalJobLimit = '',
    this.image,
  });

  bool get isFormValid =>
      jobName.isNotEmpty &&
      jobDescription.isNotEmpty &&
      jobLink.isNotEmpty &&
      perJobAmount.isNotEmpty &&
      totalJobLimit.isNotEmpty &&
      image != null;

  @override
  List<Object?> get props => [
    jobName,
    jobDescription,
    jobLink,
    perJobAmount,
    totalJobLimit,
    image,
  ];
}

class PostJobInitial extends PostJobState {
  const PostJobInitial() : super();
}

class PostJobFormUpdated extends PostJobState {
  const PostJobFormUpdated({
    super.jobName,
    super.jobDescription,
    super.jobLink,
    super.perJobAmount,
    super.totalJobLimit,
    super.image,
  });
}

class PostJobLoading extends PostJobState {
  final double? uploadProgress;
  const PostJobLoading({
    super.jobName,
    super.jobDescription,
    super.jobLink,
    super.perJobAmount,
    super.totalJobLimit,
    super.image,
    this.uploadProgress,
  });

  @override
  List<Object?> get props => [...super.props, uploadProgress];
}

class PostJobSuccess extends PostJobState {
  const PostJobSuccess() : super();
}

class PostJobFailure extends PostJobState {
  final String message;
  const PostJobFailure(
    this.message, {
    super.jobName,
    super.jobDescription,
    super.jobLink,
    super.perJobAmount,
    super.totalJobLimit,
    super.image,
  });

  @override
  List<Object?> get props => [...super.props, message];
}
