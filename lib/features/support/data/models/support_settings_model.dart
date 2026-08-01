import 'package:equatable/equatable.dart';
import 'package:global_earn/features/support/data/models/support_agent_model.dart';

class SupportSettingsModel extends Equatable {
  final String headerTitle;
  final String headerSubtitle;
  final List<SupportAgentModel> agents;

  const SupportSettingsModel({
    required this.headerTitle,
    required this.headerSubtitle,
    required this.agents,
  });

  @override
  List<Object?> get props => [headerTitle, headerSubtitle, agents];
}
