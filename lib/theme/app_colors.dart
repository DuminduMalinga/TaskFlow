import 'package:flutter/material.dart';

/// The app's colours for one brightness. Read them with `context.colors`.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.accent,
    required this.onAccent,
    required this.accentTint,
    required this.background,
    required this.card,
    required this.text,
    required this.muted,
    required this.border,
    required this.progressTrack,
    required this.completed,
    required this.danger,
    required this.dangerTint,
    required this.hero,
    required this.field,
  });

  static const light = AppColors(
    accent: Color(0xFFF4B618),
    onAccent: Color(0xFF17140F),
    accentTint: Color(0x33F4B618),
    background: Color(0xFFF5F0E4),
    card: Color(0xFFFFFFFF),
    text: Color(0xFF1E1A13),
    muted: Color(0xFF7C735F),
    border: Color(0x1417140F),
    progressTrack: Color(0xFFE6DCC4),
    completed: Color(0xFF7C735F),
    danger: Color(0xFFD9562F),
    dangerTint: Color(0x24F07B5C),
    hero: Color(0xFF17140F),
    field: Color(0xFFF7F2E7),
  );

  static const dark = AppColors(
    accent: Color(0xFFF4B618),
    onAccent: Color(0xFF17140F),
    accentTint: Color(0x29F4B618),
    background: Color(0xFF17140F),
    card: Color(0xFF25221C),
    text: Color(0xFFF7F0E0),
    muted: Color(0xFFA89F8B),
    border: Color(0x14FFFFFF),
    progressTrack: Color(0xFF3A352B),
    completed: Color(0xFFA89F8B),
    danger: Color(0xFFF07B5C),
    dangerTint: Color(0x29F07B5C),
    hero: Color(0xFF25221C),
    field: Color(0xFF1E1B16),
  );

  /// Primary accent, and the text/icon colour that sits on top of it.
  final Color accent;
  final Color onAccent;
  final Color accentTint;
  final Color background;
  final Color card;

  /// Primary text.
  final Color text;

  /// Secondary text.
  final Color muted;
  final Color border;
  final Color progressTrack;
  final Color completed;
  final Color danger;
  final Color dangerTint;

  /// Background of the daily progress card, which is dark in both themes.
  final Color hero;

  /// Fill of text fields and other inset controls.
  final Color field;

  /// The amber that floods every screen header, and the ink used on it.
  /// Identical in both themes so the brand reads the same everywhere.
  static const header = Color(0xFFF4B618);
  static const onHeader = Color(0xFF17140F);

  @override
  AppColors copyWith({
    Color? accent,
    Color? onAccent,
    Color? accentTint,
    Color? background,
    Color? card,
    Color? text,
    Color? muted,
    Color? border,
    Color? progressTrack,
    Color? completed,
    Color? danger,
    Color? dangerTint,
    Color? hero,
    Color? field,
  }) {
    return AppColors(
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      accentTint: accentTint ?? this.accentTint,
      background: background ?? this.background,
      card: card ?? this.card,
      text: text ?? this.text,
      muted: muted ?? this.muted,
      border: border ?? this.border,
      progressTrack: progressTrack ?? this.progressTrack,
      completed: completed ?? this.completed,
      danger: danger ?? this.danger,
      dangerTint: dangerTint ?? this.dangerTint,
      hero: hero ?? this.hero,
      field: field ?? this.field,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      accent: mix(accent, other.accent),
      onAccent: mix(onAccent, other.onAccent),
      accentTint: mix(accentTint, other.accentTint),
      background: mix(background, other.background),
      card: mix(card, other.card),
      text: mix(text, other.text),
      muted: mix(muted, other.muted),
      border: mix(border, other.border),
      progressTrack: mix(progressTrack, other.progressTrack),
      completed: mix(completed, other.completed),
      danger: mix(danger, other.danger),
      dangerTint: mix(dangerTint, other.dangerTint),
      hero: mix(hero, other.hero),
      field: mix(field, other.field),
    );
  }
}

extension AppColorsContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
