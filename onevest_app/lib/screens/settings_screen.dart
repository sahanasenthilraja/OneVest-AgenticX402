import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;
  bool challengeReminders = true;
  bool personalizedInsights = true;
  bool darkMode = true;

  String aiPersonality = "Friendly";
  String riskPreference = "Moderate";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020B1D),

      appBar: AppBar(
        backgroundColor: const Color(0xFF020B1D),
        elevation: 0,

        title: const Text(
          "Settings",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),

        children: [
          // =====================================================
          // ACCOUNT
          // =====================================================
          settingsSectionTitle("Account", Icons.person_outline),

          settingsTile(
            icon: Icons.person_outline,
            title: "Profile",
            subtitle: "Manage your personal information",
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Profile settings coming soon")),
              );
            },
          ),

          settingsTile(
            icon: Icons.lock_outline,
            title: "Change Password",
            subtitle: "Update your account password",
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Password settings coming soon")),
              );
            },
          ),

          const SizedBox(height: 20),

          // =====================================================
          // AI PREFERENCES
          // =====================================================
          settingsSectionTitle("AI Preferences", Icons.auto_awesome),

          settingsTile(
            icon: Icons.psychology_outlined,
            title: "AI Personality",
            subtitle: aiPersonality,
            onTap: () => showAiPersonalityDialog(),
          ),

          settingsSwitchTile(
            icon: Icons.insights_outlined,
            title: "Personalized Insights",
            subtitle: "Receive AI-powered portfolio insights",
            value: personalizedInsights,
            onChanged: (value) {
              setState(() {
                personalizedInsights = value;
              });
            },
          ),

          const SizedBox(height: 20),

          // =====================================================
          // NOTIFICATIONS
          // =====================================================
          settingsSectionTitle("Notifications", Icons.notifications_none),

          settingsSwitchTile(
            icon: Icons.notifications_active_outlined,
            title: "Investment Tips",
            subtitle: "Receive daily investment tips",
            value: notificationsEnabled,
            onChanged: (value) {
              setState(() {
                notificationsEnabled = value;
              });
            },
          ),

          settingsSwitchTile(
            icon: Icons.emoji_events_outlined,
            title: "Challenge Reminders",
            subtitle: "Get reminders about your challenges",
            value: challengeReminders,
            onChanged: (value) {
              setState(() {
                challengeReminders = value;
              });
            },
          ),

          const SizedBox(height: 20),

          // =====================================================
          // INVESTMENT PREFERENCES
          // =====================================================
          settingsSectionTitle(
            "Investment Preferences",
            Icons.account_balance_wallet_outlined,
          ),

          settingsTile(
            icon: Icons.shield_outlined,
            title: "Risk Preference",
            subtitle: riskPreference,
            onTap: () => showRiskDialog(),
          ),

          settingsTile(
            icon: Icons.currency_rupee,
            title: "Default Currency",
            subtitle: "Indian Rupee (₹)",
            onTap: () {},
          ),

          const SizedBox(height: 20),

          // =====================================================
          // APPEARANCE
          // =====================================================
          settingsSectionTitle("Appearance", Icons.palette_outlined),

          settingsSwitchTile(
            icon: Icons.dark_mode_outlined,
            title: "Dark Mode",
            subtitle: "Use OneVest dark theme",
            value: darkMode,
            onChanged: (value) {
              setState(() {
                darkMode = value;
              });
            },
          ),

          const SizedBox(height: 20),

          // =====================================================
          // PRIVACY & SECURITY
          // =====================================================
          settingsSectionTitle("Privacy & Security", Icons.security_outlined),

          settingsTile(
            icon: Icons.privacy_tip_outlined,
            title: "Privacy & Data",
            subtitle: "Manage your data and privacy",
            onTap: () {
              showPrivacyDialog();
            },
          ),

          settingsTile(
            icon: Icons.logout,
            title: "Logout",
            subtitle: "Sign out of your OneVest account",
            iconColor: Colors.redAccent,
            onTap: () {
              showLogoutDialog();
            },
          ),

          const SizedBox(height: 20),

          // =====================================================
          // DISCLAIMER
          // =====================================================
          settingsSectionTitle("Important", Icons.info_outline),

          Container(
            padding: const EdgeInsets.all(16),

            decoration: BoxDecoration(
              color: const Color(0xFF13243D),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),

            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.amber,
                  size: 25,
                ),

                SizedBox(width: 12),

                Expanded(
                  child: Text(
                    "OneVest provides financial education and "
                    "general investment information. It does not "
                    "provide personalized financial advice or "
                    "guarantee investment returns.",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // =====================================================
          // APP VERSION
          // =====================================================
          const Center(
            child: Column(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: Colors.tealAccent,
                  size: 30,
                ),

                SizedBox(height: 8),

                Text(
                  "OneVest",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  "Version 1.0.0",
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // SECTION TITLE
  // ===========================================================

  Widget settingsSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 10),

      child: Row(
        children: [
          Icon(icon, color: Colors.tealAccent, size: 20),

          const SizedBox(width: 8),

          Text(
            title,
            style: const TextStyle(
              color: Colors.tealAccent,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // NORMAL SETTINGS TILE
  // ===========================================================

  Widget settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color iconColor = Colors.white70,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),

      decoration: BoxDecoration(
        color: const Color(0xFF1A2B45),
        borderRadius: BorderRadius.circular(15),
      ),

      child: ListTile(
        onTap: onTap,

        leading: Icon(icon, color: iconColor),

        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),

        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),

        trailing: const Icon(Icons.chevron_right, color: Colors.white38),
      ),
    );
  }

  // ===========================================================
  // SWITCH SETTINGS TILE
  // ===========================================================

  Widget settingsSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),

      decoration: BoxDecoration(
        color: const Color(0xFF1A2B45),
        borderRadius: BorderRadius.circular(15),
      ),

      child: SwitchListTile(
        value: value,
        onChanged: onChanged,

        activeThumbColor: Colors.tealAccent,
        activeTrackColor: Colors.teal.withOpacity(0.5),

        secondary: Icon(icon, color: Colors.white70),

        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),

        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ),
    );
  }

  // ===========================================================
  // AI PERSONALITY DIALOG
  // ===========================================================

  void showAiPersonalityDialog() {
    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A2B45),

          title: const Text(
            "AI Personality",
            style: TextStyle(color: Colors.white),
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              aiPersonalityOption("Professional"),
              aiPersonalityOption("Friendly"),
              aiPersonalityOption("Motivational"),
              aiPersonalityOption("Brutally Honest"),
            ],
          ),
        );
      },
    );
  }

  Widget aiPersonalityOption(String personality) {
    return RadioListTile<String>(
      value: personality,
      groupValue: aiPersonality,

      activeColor: Colors.tealAccent,

      title: Text(personality, style: const TextStyle(color: Colors.white)),

      onChanged: (value) {
        if (value == null) return;

        setState(() {
          aiPersonality = value;
        });

        Navigator.pop(context);
      },
    );
  }

  // ===========================================================
  // RISK PREFERENCE DIALOG
  // ===========================================================

  void showRiskDialog() {
    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A2B45),

          title: const Text(
            "Risk Preference",
            style: TextStyle(color: Colors.white),
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              riskOption("Conservative"),
              riskOption("Moderate"),
              riskOption("Aggressive"),
            ],
          ),
        );
      },
    );
  }

  Widget riskOption(String risk) {
    return RadioListTile<String>(
      value: risk,
      groupValue: riskPreference,

      activeColor: Colors.tealAccent,

      title: Text(risk, style: const TextStyle(color: Colors.white)),

      onChanged: (value) {
        if (value == null) return;

        setState(() {
          riskPreference = value;
        });

        Navigator.pop(context);
      },
    );
  }

  // ===========================================================
  // PRIVACY DIALOG
  // ===========================================================

  void showPrivacyDialog() {
    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A2B45),

          title: const Text(
            "Privacy & Data",
            style: TextStyle(color: Colors.white),
          ),

          content: const Text(
            "Your investment information is stored securely "
            "and is used to provide portfolio analytics and "
            "personalized OneVest features.",
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),

              child: const Text(
                "Close",
                style: TextStyle(color: Colors.tealAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================
  // LOGOUT DIALOG
  // ===========================================================

  void showLogoutDialog() {
    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A2B45),

          title: const Text("Logout", style: TextStyle(color: Colors.white)),

          content: const Text(
            "Are you sure you want to logout?",
            style: TextStyle(color: Colors.white70),
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),

              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.white54),
              ),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),

              onPressed: () {
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Logout functionality will be connected next.",
                    ),
                  ),
                );
              },

              child: const Text("Logout"),
            ),
          ],
        );
      },
    );
  }
}
