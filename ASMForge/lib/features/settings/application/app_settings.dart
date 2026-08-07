enum AssistanceLevel { guided, standard, expert }

class AppSettings {
  final bool animationsEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final double textScale;
  final bool highContrast;
  final AssistanceLevel assistanceLevel;

  const AppSettings({
    this.animationsEnabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.textScale = 1.0,
    this.highContrast = false,
    this.assistanceLevel = AssistanceLevel.standard,
  });

  AppSettings copyWith({
    bool? animationsEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    double? textScale,
    bool? highContrast,
    AssistanceLevel? assistanceLevel,
  }) {
    return AppSettings(
      animationsEnabled: animationsEnabled ?? this.animationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      textScale: textScale ?? this.textScale,
      highContrast: highContrast ?? this.highContrast,
      assistanceLevel: assistanceLevel ?? this.assistanceLevel,
    );
  }

  Map<String, dynamic> toJson() => {
        'animationsEnabled': animationsEnabled,
        'soundEnabled': soundEnabled,
        'vibrationEnabled': vibrationEnabled,
        'textScale': textScale,
        'highContrast': highContrast,
        'assistanceLevel': assistanceLevel.name,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        animationsEnabled: json['animationsEnabled'] as bool? ?? true,
        soundEnabled: json['soundEnabled'] as bool? ?? true,
        vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
        textScale: (json['textScale'] as num?)?.toDouble() ?? 1.0,
        highContrast: json['highContrast'] as bool? ?? false,
        assistanceLevel: AssistanceLevel.values.firstWhere(
          (e) => e.name == json['assistanceLevel'],
          orElse: () => AssistanceLevel.standard,
        ),
      );
}
