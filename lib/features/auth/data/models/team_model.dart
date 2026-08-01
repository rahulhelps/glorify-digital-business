class TeamModel {
  final num level1;
  final num level1Business;
  final num level2;
  final num level2Business;
  final num level3;
  final num level3Business;
  final num level4;
  final num level4Business;
  final num level5;
  final num level5Business;
  final num level6;
  final num level6Business;
  final num level7;
  final num level7Business;
  final num level8;
  final num level8Business;
  final num level9;
  final num level9Business;
  final num level10;
  final num level10Business;

  TeamModel({
    required this.level1,
    required this.level1Business,
    required this.level2,
    required this.level2Business,
    required this.level3,
    required this.level3Business,
    required this.level4,
    required this.level4Business,
    required this.level5,
    required this.level5Business,
    required this.level6,
    required this.level6Business,
    required this.level7,
    required this.level7Business,
    required this.level8,
    required this.level8Business,
    required this.level9,
    required this.level9Business,
    required this.level10,
    required this.level10Business,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      level1: json['level1'] as int? ?? 0,
      level1Business: json['level1Business'] as int? ?? 0,
      level2: json['level2'] as int? ?? 0,
      level2Business: json['level2Business'] as int? ?? 0,
      level3: json['level3'] as int? ?? 0,
      level3Business: json['level3Business'] as int? ?? 0,
      level4: json['level4'] as int? ?? 0,
      level4Business: json['level4Business'] as int? ?? 0,
      level5: json['level5'] as int? ?? 0,
      level5Business: json['level5Business'] as int? ?? 0,
      level6: json['level6'] as int? ?? 0,
      level6Business: json['level6Business'] as int? ?? 0,
      level7: json['level7'] as int? ?? 0,
      level7Business: json['level7Business'] as int? ?? 0,
      level8: json['level8'] as int? ?? 0,
      level8Business: json['level8Business'] as int? ?? 0,
      level9: json['level9'] as int? ?? 0,
      level9Business: json['level9Business'] as int? ?? 0,
      level10: json['level10'] as int? ?? 0,
      level10Business: json['level10Business'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level1': level1,
      'level1Business': level1Business,
      'level2': level2,
      'level2Business': level2Business,
      'level3': level3,
      'level3Business': level3Business,
      'level4': level4,
      'level4Business': level4Business,
      'level5': level5,
      'level5Business': level5Business,
      'level6': level6,
      'level6Business': level6Business,
      'level7': level7,
      'level7Business': level7Business,
      'level8': level8,
      'level8Business': level8Business,
      'level9': level9,
      'level9Business': level9Business,
      'level10': level10,
      'level10Business': level10Business,
    };
  }
}
