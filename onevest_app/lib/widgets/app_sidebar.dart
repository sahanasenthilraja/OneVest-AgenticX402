import 'package:flutter/material.dart';
import 'package:onevest_app/screens/user_profile_screen.dart';

enum SidebarItem { home, portfolio, ai, profile, analytics }

class AppSidebar extends StatelessWidget {
  final SidebarItem selected;
  final Function(SidebarItem) onSelected;

  const AppSidebar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: const Color(0xFF020B1D),
      child: Column(
        children: [
          const SizedBox(height: 40),

          _item(
            context,
            SidebarItem.home,
            Icons.dashboard_outlined,
            "Dashboard",
          ),

          _item(
            context,
            SidebarItem.portfolio,
            Icons.account_balance_wallet_outlined,
            "Portfolio",
          ),

          _item(context, SidebarItem.ai, Icons.smart_toy_outlined, "AI Agent"),

          _item(context, SidebarItem.profile, Icons.person_outline, "Profile"),

          _item(
            context,
            SidebarItem.analytics,
            Icons.analytics_outlined,
            "Analytics",
          ),
        ],
      ),
    );
  }

  Widget _item(
    BuildContext context,
    SidebarItem item,
    IconData icon,
    String title,
  ) {
    final bool active = selected == item;

    return ListTile(
      leading: Icon(
        icon,
        color: active ? const Color(0xFF14C8B0) : Colors.white70,
      ),

      title: Text(
        title,
        style: TextStyle(
          color: active ? const Color(0xFF14C8B0) : Colors.white70,
          fontWeight: FontWeight.w600,
        ),
      ),

      onTap: () {
        if (item == SidebarItem.profile) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          );
        } else {
          onSelected(item);
        }
      },
    );
  }
}
