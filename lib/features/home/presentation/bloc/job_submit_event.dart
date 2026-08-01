import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class JobSubmitEvent extends Equatable {
  const JobSubmitEvent();
  @override
  List<Object?> get props => [];
}

/// Load job details when the screen opens.
class LoadJobDetail extends JobSubmitEvent {
  final String jobId;
  const LoadJobDetail(this.jobId);
  @override
  List<Object?> get props => [jobId];
}

/// User picked a proof image from gallery/camera.
class ProofImagePicked extends JobSubmitEvent {
  final int index;
  final File image;
  const ProofImagePicked(this.index, this.image);
  @override
  List<Object?> get props => [index, image.path];
}

class ProofImageRemoved extends JobSubmitEvent {
  final int index;
  const ProofImageRemoved(this.index);
  @override
  List<Object?> get props => [index];
}

/// User tapped Submit.
class SubmitJob extends JobSubmitEvent {
  final String proofText;
  const SubmitJob({this.proofText = ''});
  @override
  List<Object?> get props => [proofText];
}
