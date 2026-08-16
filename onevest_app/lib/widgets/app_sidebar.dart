import 'package:flutter/material.dart';

import '../screens/dashboard_screen.dart';
import '../screens/portfolio_screen.dart';
import '../screens/ai_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/portfolio_analytics_screen.dart';

/// Which screen the sidebar currently represents, so it can
/// highlight the right icon and avoid re-navigating to itself.
enum SidebarItem { home, portfolio, ai, profile, analytics }

/// Persistent left-hand navigation rail.
///
/// Drop this into any screen's Scaffold like:
///
/// ```dart
/// body: Row(
///   children: [
///     const AppSidebar(current: SidebarItem.portfolio),
///     Expanded(child: <existing screen body>),
///   ],
/// ),
/// ```
///
/// Adjust the import paths above if your screens/ folder is
/// located somewhere other than ../screens/ relative to this file.
class AppSidebar extends StatelessWidget {
  final SidebarItem current;

  const AppSidebar({super.key, required this.current});

  void _navigate(BuildContext context, SidebarItem item) {
    if (item == current) return;

    Widget screen;
    switch (item) {
      case SidebarItem.home:
        screen = const DashboardScreen();
        break;
      case SidebarItem.portfolio:
        screen = const PortfolioScreen();
        break;
      case SidebarItem.ai:
        screen = const AiScreen();
        break;
      case SidebarItem.profile:
        screen = const ProfileScreen();
        break;
      case SidebarItem.analytics:
        screen = const PortfolioAnalyticsScreen();
        break;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 78,
      color: const Color(0xFF0A1220),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          _SidebarButton(
            icon: Icons.home_rounded,
            label: "Home",
            active: current == SidebarItem.home,
            onTap: () => _navigate(context, SidebarItem.home),
          ),
          const SizedBox(height: 14),
          _SidebarButton(
            icon: Icons.account_balance_wallet_rounded,
            label: "Portfolio",
            active: current == SidebarItem.portfolio,
            onTap: () => _navigate(context, SidebarItem.portfolio),
          ),
          const SizedBox(height: 14),
          _SidebarButton(
            icon: Icons.smart_toy_rounded,
            label: "AI",
            active: current == SidebarItem.ai,
            onTap: () => _navigate(context, SidebarItem.ai),
          ),
          const SizedBox(height: 14),
          _SidebarButton(
            icon: Icons.person_rounded,
            label: "Profile",
            active: current == SidebarItem.profile,
            onTap: () => _navigate(context, SidebarItem.profile),
          ),
          const Spacer(),
          _SidebarButton(
            icon: Icons.bar_chart_rounded,
            label: "Analytics",
            active: current == SidebarItem.analytics,
            onTap: () => _navigate(context, SidebarItem.analytics),
          ),
        ],
      ),
    );
  }
}

class _SidebarButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _SidebarButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  State<_SidebarButton> createState() => _SidebarButtonState();
}

class _SidebarButtonState extends State<_SidebarButton> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: SizedBox(
          width: 48,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.centerLeft,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: widget.active
                      ? const Color(0xFF14C8B0)
                      : (hovering
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.transparent),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Icon(
                  widget.icon,
                  size: 22,
                  color: widget.active
                      ? const Color(0xFF04140F)
                      : (hovering ? Colors.white : const Color(0xFF6D7890)),
                ),
              ),

              // Hover tooltip, positioned just to the right of the rail.
              if (hovering && !widget.active)
                Positioned(
                  left: 56,
                  child: IgnorePointer(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black38,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        widget.label,
                        style: const TextStyle(
                          color: Color(0xFF0A1220),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}