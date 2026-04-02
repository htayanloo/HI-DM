import 'package:flutter/material.dart';

enum AppLayout { compact, medium, expanded }

class ResponsiveHome extends StatelessWidget {
  final Widget sidebar;
  final Widget content;
  final Widget? bottomBar;
  final bool sidebarVisible;

  const ResponsiveHome({
    super.key,
    required this.sidebar,
    required this.content,
    this.bottomBar,
    this.sidebarVisible = true,
  });

  static AppLayout layoutFor(double width) {
    if (width < 600) return AppLayout.compact;
    if (width < 900) return AppLayout.medium;
    return AppLayout.expanded;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = layoutFor(constraints.maxWidth);

        switch (layout) {
          case AppLayout.compact:
            // Mobile: bottom nav, no sidebar
            return Column(
              children: [
                Expanded(child: content),
                ?bottomBar,
              ],
            );

          case AppLayout.medium:
            // Tablet: collapsible narrow sidebar
            return Row(
              children: [
                if (sidebarVisible)
                  SizedBox(
                    width: 56,
                    child: sidebar,
                  ),
                if (sidebarVisible) const VerticalDivider(width: 1),
                Expanded(child: content),
              ],
            );

          case AppLayout.expanded:
            // Desktop: full sidebar
            return Row(
              children: [
                if (sidebarVisible)
                  SizedBox(
                    width: 200,
                    child: sidebar,
                  ),
                if (sidebarVisible) const VerticalDivider(width: 1),
                Expanded(child: content),
              ],
            );
        }
      },
    );
  }
}
