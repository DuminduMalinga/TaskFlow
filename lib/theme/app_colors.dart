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
  });

  static const light = AppColors(
    accent: Color(0xFF4F46E5),
    onAccent: Color(0xFFFFFFFF),
    accentTint: Color(0xFFEEF2FF),
    background: Color(0xFFF5F7FB),
    card: Color(0xFFFFFFFF),
    text: Color(0xFF172554),
    muted: Color(0xFF64748B),
    border: Color(0xFFE2E8F0),
    progressTrack: Color(0xFFC7D2FE),
    completed: Color(0xFF64748B),
    danger: Color(0xFFDC2626),
    dangerTint: Color(0xFFFEE2E2),
    hero: Color(0xFF172554),
  );

  static const dark = AppColors(
    accent: Color(0xFF818CF8),
    onAccent: Color(0xFF111827),
    accentTint: Color(0x29818CF8),
    background: Color(0xFF111827),
    card: Color(0xFF1F2937),
    text: Color(0xFFF9FAFB),
    muted: Color(0xFF9CA3AF),
    border: Color(0xFF374151),
    progressTrack: Color(0xFF374151),
    completed: Color(0xFF9CA3AF),
    danger: Color(0xFFF87171),
    dangerTint: Color(0x29F87171),
    hero: Color(0xFF1F2937),
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
    );
  }
}

extension AppColorsContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
