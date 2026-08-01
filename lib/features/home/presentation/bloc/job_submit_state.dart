import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:global_earn/features/home/data/models/micro_job_model.dart';

abstract class JobSubmitState extends Equatable {
  const JobSubmitState();
  @override
  List<Object?> get props => [];
}

class JobSubmitInitial extends JobSubmitState {
  const JobSubmitInitial();
}

class JobSubmitLoading extends JobSubmitState {
  const JobSubmitLoading();
}

class JobDetailLoaded extends JobSubmitState {
  final MicroJobModel job;
  final List<File?> proofImages;

  const JobDetailLoaded({required this.job, required this.proofImages});

  JobDetailLoaded copyWith({MicroJobModel? job, List<File?>? proofImages}) {
    return JobDetailLoaded(
      job: job ?? this.job,
      proofImages: proofImages ?? this.proofImages,
    );
  }

  @override
  List<Object?> get props => [job, ...proofImages.map((e) => e?.path)];
}

class JobSubmitSuccess extends JobSubmitState {
  const JobSubmitSuccess();
}

class JobAlreadySubmitted extends JobSubmitState {
  const JobAlreadySubmitted();
}

class JobSlotsFull extends JobSubmitState {
  const JobSlotsFull();
}

class JobSubmitError extends JobSubmitState {
  final String message;
  const JobSubmitError(this.message);
  @override
  List<Object?> get props => [message];
}
