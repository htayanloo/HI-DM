import 'package:flutter/material.dart';

class StatusColors {
  final BuildContext context;
  late final bool _isDark;

  StatusColors(this.context) {
    _isDark = Theme.of(context).brightness == Brightness.dark;
  }

  Color forStatus(String status) {
    return switch (status) {
      'downloading' => _isDark ? const Color(0xFF64FFDA) : const Color(0xFF00897B),
      'completed' => _isDark ? const Color(0xFF69F0AE) : const Color(0xFF2E7D32),
      'paused' => _isDark ? const Color(0xFFFFD54F) : const Color(0xFFF9A825),
      'error' => _isDark ? const Color(0xFFEF5350) : const Color(0xFFC62828),
      'queued' => _isDark ? const Color(0xFF90A4AE) : const Color(0xFF546E7A),
      'connecting' => _isDark ? const Color(0xFF42A5F5) : const Color(0xFF1565C0),
      'assembling' || 'merging' => _isDark ? const Color(0xFFAB47BC) : const Color(0xFF7B1FA2),
      _ => Colors.grey,
    };
  }

  Color get progressBackground =>
      _isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06);

  Color get activeGlow =>
      _isDark ? const Color(0xFF64FFDA).withValues(alpha: 0.15) : const Color(0xFF00897B).withValues(alpha: 0.08);
}
