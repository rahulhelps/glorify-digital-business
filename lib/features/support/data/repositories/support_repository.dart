import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_earn/features/support/data/models/support_agent_model.dart';
import 'package:global_earn/features/support/data/models/support_settings_model.dart';

abstract class SupportRepository {
  Future<SupportSettingsModel> getActiveSupportAgents();
}

class SupportRepositoryImpl implements SupportRepository {
  final FirebaseFirestore _firestore;

  SupportRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<SupportSettingsModel> getActiveSupportAgents() async {
    try {
      final doc = await _firestore.collection('app_config').doc('support_settings').get();

      if (!doc.exists) {
        return const SupportSettingsModel(
          headerTitle: 'Glorify Digital Business সাপোর্ট সেন্টার',
          headerSubtitle: '',
          agents: [],
        );
      }

      final data = doc.data();
      if (data == null) {
        return const SupportSettingsModel(
          headerTitle: 'Glorify Digital Business সাপোর্ট সেন্টার',
          headerSubtitle: '',
          agents: [],
        );
      }

      final rawAgents = data['agents'];
      final List<SupportAgentModel> agents = [];

      if (rawAgents != null) {
        if (rawAgents is Map<String, dynamic> || rawAgents is Map) {
          final agentMap = Map<String, dynamic>.from(rawAgents as Map);

          if (agentMap.containsKey('name') || agentMap.containsKey('role')) {
            // Case 1: Single agent map
            final agent = SupportAgentModel.fromMap(agentMap, 'agent_0');
            if (agent.isActive) agents.add(agent);
          } else {
            // Case 2: Nested map
            int i = 0;
            for (var value in agentMap.values) {
              if (value is Map) {
                final agent = SupportAgentModel.fromMap(Map<String, dynamic>.from(value), 'agent_$i');
                if (agent.isActive) agents.add(agent);
                i++;
              }
            }
          }
        } else if (rawAgents is List) {
          // Case 3: List of maps
          for (var i = 0; i < rawAgents.length; i++) {
            if (rawAgents[i] is Map) {
              final agent = SupportAgentModel.fromMap(Map<String, dynamic>.from(rawAgents[i] as Map), 'agent_$i');
              if (agent.isActive) agents.add(agent);
            }
          }
        }
      }

      return SupportSettingsModel(
        headerTitle: data['header_title']?.toString() ?? 'Glorify Digital Business সাপোর্ট সেন্টার',
        headerSubtitle: data['header_subtitle']?.toString() ?? '',
        agents: agents,
      );
    } catch (e) {
      throw Exception('Failed to fetch support agents: $e');
    }
  }
}
