import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

/// Custom title bar with HI-DM branding — replaces system titlebar.
class CustomTitleBar extends StatelessWidget {
  final Widget? trailing;

  const CustomTitleBar({super.key, this.trailing});

  static const double height = 42;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = Platform.isWindows || Platform.isMacOS || Platform.isLinux;

    return GestureDetector(
      onPanStart: isDesktop ? (_) => windowManager.startDragging() : null,
      onDoubleTap: isDesktop ? () async {
        if (await windowManager.isMaximized()) {
          await windowManager.unmaximize();
        } else {
          await windowManager.maximize();
        }
      } : null,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: Row(
          children: [
            // macOS traffic lights spacing
            if (Platform.isMacOS) const SizedBox(width: 72),

            // Logo + Title
            Padding(
              padding: EdgeInsets.only(left: Platform.isMacOS ? 0 : 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // HI-DM Logo from asset
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.asset(
                      'assets/icons/hi-dm-logo.png',
                      width: 28,
                      height: 28,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // HI-DM text
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                    ).createShader(bounds),
                    child: const Text(
                      'HI-DM',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: Colors.white, // Required for ShaderMask
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Download Manager',
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Trailing content (optional — for extra buttons)
            if (trailing != null) trailing!,

            // Window controls (Windows/Linux only)
            if (Platform.isWindows || Platform.isLinux) ...[
              _WindowButton(
                icon: Icons.minimize_rounded,
                onPressed: () => windowManager.minimize(),
                hoverColor: theme.colorScheme.surfaceContainerHighest,
              ),
              _WindowButton(
                icon: Icons.crop_square_rounded,
                onPressed: () async {
                  if (await windowManager.isMaximized()) {
                    await windowManager.unmaximize();
                  } else {
                    await windowManager.maximize();
                  }
                },
                hoverColor: theme.colorScheme.surfaceContainerHighest,
              ),
              _WindowButton(
                icon: Icons.close_rounded,
                onPressed: () => windowManager.close(),
                hoverColor: const Color(0xFFE53935),
                hoverIconColor: Colors.white,
              ),
            ],

            if (Platform.isMacOS) const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

class _WindowButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color hoverColor;
  final Color? hoverIconColor;

  const _WindowButton({
    required this.icon,
    required this.onPressed,
    required this.hoverColor,
    this.hoverIconColor,
  });

  @override
  State<_WindowButton> createState() => _WindowButtonState();
}

class _WindowButtonState extends State<_WindowButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 46,
          height: CustomTitleBar.height,
          color: _isHovered ? widget.hoverColor : Colors.transparent,
          child: Icon(
            widget.icon,
            size: 16,
            color: _isHovered
                ? (widget.hoverIconColor ?? theme.colorScheme.onSurface)
                : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}
