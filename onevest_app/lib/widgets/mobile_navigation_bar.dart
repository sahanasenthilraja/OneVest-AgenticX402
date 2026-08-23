import 'package:flutter/material.dart';

class MobileNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const MobileNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const Color background = Color(0xFF02001F);
  static const Color teal = Color(0xFF14C8B0);
  static const Color muted = Color(0xFF8995AD);
  static const Color border = Color(0xFF1C2945);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 72,
        decoration: const BoxDecoration(
          color: background,
          border: Border(
            top: BorderSide(
              color: border,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            _navItem(
              index: 0,
              icon: Icons.home_rounded,
              label: 'Home',
            ),
            _navItem(
              index: 1,
              icon: Icons.account_balance_wallet_rounded,
              label: 'Portfolio',
            ),
            _navItem(
              index: 2,
              icon: Icons.smart_toy_rounded,
              label: 'AI Agent',
            ),
            _navItem(
              index: 3,
              icon: Icons.auto_awesome_rounded,
              label: 'AI',
            ),
            _navItem(
              index: 4,
              icon: Icons.person_rounded,
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final bool selected = currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: selected
                    ? teal.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 21,
                color: selected ? teal : muted,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 8,
                fontWeight:
                    selected ? FontWeight.bold : FontWeight.normal,
                color: selected ? teal : muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
