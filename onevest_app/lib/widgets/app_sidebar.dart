import 'package:flutter/material.dart';

import '../screens/dashboard_screen.dart';
import '../screens/portfolio_screen.dart';
import '../screens/ai_agent_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/portfolio_analytics_screen.dart';

enum SidebarItem {
  home,
  portfolio,
  ai,
  profile,
  analytics,
}

class AppSidebar extends StatelessWidget {
  final SidebarItem current;

  const AppSidebar({
    super.key,
    required this.current,
  });

  void _navigate(
    BuildContext context,
    SidebarItem item,
  ) {
    if (item == current) return;

    switch (item) {
      case SidebarItem.home:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const DashboardScreen(),
          ),
        );
        break;

      case SidebarItem.portfolio:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const PortfolioScreen(),
          ),
        );
        break;

      case SidebarItem.ai:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const AiAgentScreen(),
          ),
        );
        break;

      case SidebarItem.profile:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const ProfileScreen(),
          ),
        );
        break;

      case SidebarItem.analytics:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const PortfolioAnalyticsScreen(),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 78,
      color: const Color(0xFF0A1220),
      padding: const EdgeInsets.symmetric(
        vertical: 20,
      ),
      child: Column(
        children: [
          _SidebarButton(
            icon: Icons.home_rounded,
            label: 'Home',
            active: current == SidebarItem.home,
            onTap: () {
              _navigate(
                context,
                SidebarItem.home,
              );
            },
          ),

          const SizedBox(height: 14),

          _SidebarButton(
            icon: Icons.account_balance_wallet_rounded,
            label: 'Portfolio',
            active: current == SidebarItem.portfolio,
            onTap: () {
              _navigate(
                context,
                SidebarItem.portfolio,
              );
            },
          ),

          const SizedBox(height: 14),

          _SidebarButton(
            icon: Icons.smart_toy_rounded,
            label: 'AI Agent',
            active: current == SidebarItem.ai,
            onTap: () {
              _navigate(
                context,
                SidebarItem.ai,
              );
            },
          ),

          const SizedBox(height: 14),

          _SidebarButton(
            icon: Icons.person_rounded,
            label: 'Profile',
            active: current == SidebarItem.profile,
            onTap: () {
              _navigate(
                context,
                SidebarItem.profile,
              );
            },
          ),

          const Spacer(),

          _SidebarButton(
            icon: Icons.bar_chart_rounded,
            label: 'Analytics',
            active: current == SidebarItem.analytics,
            onTap: () {
              _navigate(
                context,
                SidebarItem.analytics,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SidebarButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      preferBelow: false,
      waitDuration: const Duration(
        milliseconds: 300,
      ),
      child: SizedBox(
        width: 48,
        height: 48,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: AnimatedContainer(
              duration: const Duration(
                milliseconds: 150,
              ),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: active
                    ? const Color(0xFF14C8B0)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: 22,
                color: active
                    ? const Color(0xFF04140F)
                    : const Color(0xFF6D7890),
              ),
            ),
          ),
        ),
      ),
    );
  }
}