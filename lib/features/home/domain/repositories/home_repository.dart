import 'dart:io';
import '../../data/models/micro_job_model.dart';

abstract class HomeRepository {
  Future<void> postMicroJob(MicroJobModel job);
  Future<String> uploadJobImage(File image, String uid);
  Future<double> getUserBalance();
  Future<List<MicroJobModel>> getAvailableJobs();

  /// Real-time stream of active jobs, ordered newest-first.
  Stream<List<MicroJobModel>> watchAvailableJobs();
}
