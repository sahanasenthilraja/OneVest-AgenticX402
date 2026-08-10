import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool investmentTips = true;
  bool challengeReminders = true;
  bool personalizedInsights = true;
  bool darkMode = true;

  String aiPersonality = "Friendly";
  String riskPreference = "Moderate";
  String currency = "INR (₹)";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020B1D),

      appBar: AppBar(
        backgroundColor: const Color(0xFF020B1D),
        elevation: 0,
        title: const Text(
          "Settings",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
        children: [
          _sectionTitle("ACCOUNT"),

          _settingsCard(
            children: [
              _settingsTile(
                icon: Icons.person_outline,
                title: "Profile",
                subtitle: "Manage your personal information",
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Profile settings"),
                    ),
                  );
                },
              ),
              _divider(),
              _settingsTile(
                icon: Icons.lock_outline,
                title: "Change Password",
                subtitle: "Update your account password",
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Change password"),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          _sectionTitle("AI EXPERIENCE"),

          _settingsCard(
            children: [
              _settingsTile(
                icon: Icons.auto_awesome,
                title: "AI Personality",
                subtitle: aiPersonality,
                onTap: _showAiPersonalityDialog,
              ),
              _divider(),
              _switchTile(
                icon: Icons.psychology_outlined,
                title: "Personalized Insights",
                subtitle: "Get AI-powered portfolio insights",
                value: personalizedInsights,
                onChanged: (value) {
                  setState(() {
                    personalizedInsights = value;
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          _sectionTitle("NOTIFICATIONS"),

          _settingsCard(
            children: [
              _switchTile(
                icon: Icons.trending_up,
                title: "Investment Tips",
                subtitle: "Receive useful investment insights",
                value: investmentTips,
                onChanged: (value) {
                  setState(() {
                    investmentTips = value;
                  });
                },
              ),
              _divider(),
              _switchTile(
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
            ],
          ),

          const SizedBox(height: 24),

          _sectionTitle("INVESTMENT PREFERENCES"),

          _settingsCard(
            children: [
              _settingsTile(
                icon: Icons.shield_outlined,
                title: "Risk Preference",
                subtitle: riskPreference,
                onTap: _showRiskPreferenceDialog,
              ),
              _divider(),
              _settingsTile(
                icon: Icons.currency_rupee,
                title: "Default Currency",
                subtitle: currency,
                onTap: _showCurrencyDialog,
              ),
            ],
          ),

          const SizedBox(height: 24),

          _sectionTitle("APPEARANCE"),

          _settingsCard(
            children: [
              _switchTile(
                icon: Icons.dark_mode_outlined,
                title: "Dark Mode",
                subtitle: "Use the OneVest dark theme",
                value: darkMode,
                onChanged: (value) {
                  setState(() {
                    darkMode = value;
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          _sectionTitle("PRIVACY & SECURITY"),

          _settingsCard(
            children: [
              _settingsTile(
                icon: Icons.security_outlined,
                title: "Privacy & Data",
                subtitle: "Manage your data and privacy",
                onTap: () {
                  _showInfoDialog(
                    "Privacy & Data",
                    "Your OneVest account and investment data are securely stored using Firebase.",
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 30),

          Center(
            child: Column(
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.tealAccent.withValues(alpha: 0.7),
                  size: 30,
                ),
                const SizedBox(height: 8),
                const Text(
                  "OneVest",
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Version 1.0.0",
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 6,
        bottom: 10,
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.tealAccent,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _settingsCard({
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF101D32),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.teal.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: Colors.tealAccent,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
          ),
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.white38,
      ),
      onTap: onTap,
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.teal.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: Colors.tealAccent,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
          ),
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: Colors.tealAccent,
        activeTrackColor: Colors.teal.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      indent: 74,
      color: Colors.white.withValues(alpha: 0.06),
    );
  }

  void _showAiPersonalityDialog() {
    const options = [
      "Friendly",
      "Professional",
      "Brutally Honest",
      "Motivational",
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF101D32),
          title: const Text(
            "AI Personality",
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((option) {
              return RadioListTile<String>(
                title: Text(
                  option,
                  style: const TextStyle(color: Colors.white),
                ),
                value: option,
                groupValue: aiPersonality,
                activeColor: Colors.tealAccent,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      aiPersonality = value;
                    });
                    Navigator.pop(context);
                  }
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showRiskPreferenceDialog() {
    const options = [
      "Conservative",
      "Moderate",
      "Aggressive",
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF101D32),
          title: const Text(
            "Risk Preference",
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((option) {
              return RadioListTile<String>(
                title: Text(
                  option,
                  style: const TextStyle(color: Colors.white),
                ),
                value: option,
                groupValue: riskPreference,
                activeColor: Colors.tealAccent,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      riskPreference = value;
                    });
                    Navigator.pop(context);
                  }
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showCurrencyDialog() {
    const options = [
      "INR (₹)",
      "USD (\$)",
      "EUR (€)",
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF101D32),
          title: const Text(
            "Default Currency",
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((option) {
              return RadioListTile<String>(
                title: Text(
                  option,
                  style: const TextStyle(color: Colors.white),
                ),
                value: option,
                groupValue: currency,
                activeColor: Colors.tealAccent,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      currency = value;
                    });
                    Navigator.pop(context);
                  }
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showInfoDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF101D32),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "OK",
                style: TextStyle(
                  color: Colors.tealAccent,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}