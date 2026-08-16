import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'profile_screen.dart';
import 'privacy_security_screen.dart';
import 'about_onevest_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color background = Color(0xFF020B1D);
  static const Color surface = Color(0xFF0A1428);
  static const Color surface2 = Color(0xFF0F1D35);
  static const Color surface3 = Color(0xFF142542);
  static const Color border = Color(0xFF243B60);

  static const Color teal = Color(0xFF14C8B0);
  static const Color green = Color(0xFF45E38A);
  static const Color red = Color(0xFFFF5A64);
  static const Color orange = Color(0xFFFFB52E);
  static const Color purple = Color(0xFFA86BFF);

  static const Color white = Color(0xFFF5F8FC);
  static const Color muted = Color(0xFF91A0B8);

  // ============================================================
  // STATE
  // ============================================================

  bool investmentTips = true;
  bool challengeReminders = true;
  bool personalizedInsights = true;
  bool darkMode = true;

  String aiPersonality = "Friendly";
  String riskPreference = "Moderate";
  String currency = "INR (₹)";

  // ============================================================
  // FONT HELPERS
  // ============================================================

  TextStyle heading(
    double size, {
    Color color = white,
    FontWeight weight = FontWeight.w700,
    double? spacing,
  }) {
    return GoogleFonts.pressStart2p(
      fontSize: size,
      color: color,
      fontWeight: weight,
      letterSpacing: spacing,
    );
  }

  TextStyle mono(
    double size, {
    Color color = white,
    FontWeight weight = FontWeight.normal,
    double? spacing,
    double? height,
  }) {
    return GoogleFonts.spaceMono(
      fontSize: size,
      color: color,
      fontWeight: weight,
      letterSpacing: spacing,
      height: height,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: white,
            size: 28,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Settings",
          style: heading(16),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool desktop = constraints.maxWidth >= 1000;

          final double horizontalPadding = desktop
              ? 70
              : constraints.maxWidth >= 700
                  ? 40
                  : 18;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              18,
              horizontalPadding,
              50,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 1100,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header(),

                    const SizedBox(height: 30),

                    // ==================================================
                    // ACCOUNT
                    // ==================================================

                    _sectionHeader(
                      icon: Icons.person_outline_rounded,
                      title: "Account",
                      subtitle: "Manage your OneVest account",
                      color: teal,
                    ),

                    const SizedBox(height: 14),

                    _settingsCard(
                      children: [
                        _settingsTile(
                          icon: Icons.person_outline_rounded,
                          title: "Profile",
                          subtitle:
                              "View and manage your personal information",
                          color: teal,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProfileScreen(),
                              ),
                            );
                          },
                        ),

                        _divider(),

                        _settingsTile(
                          icon: Icons.lock_reset_rounded,
                          title: "Change Password",
                          subtitle:
                              "Update your account password securely",
                          color: purple,
                          onTap: _showChangePasswordDialog,
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // ==================================================
                    // AI EXPERIENCE
                    // ==================================================

                    _sectionHeader(
                      icon: Icons.auto_awesome_rounded,
                      title: "AI Experience",
                      subtitle:
                          "Customize how OneVest AI interacts with you",
                      color: purple,
                    ),

                    const SizedBox(height: 14),

                    _settingsCard(
                      children: [
                        _settingsTile(
                          icon: Icons.psychology_rounded,
                          title: "AI Personality",
                          subtitle: aiPersonality,
                          color: purple,
                          trailing: _valueBadge(
                            aiPersonality,
                            purple,
                          ),
                          onTap: _showAiPersonalityDialog,
                        ),

                        _divider(),

                        _switchTile(
                          icon: Icons.insights_rounded,
                          title: "Personalized Insights",
                          subtitle:
                              "Get AI-powered portfolio insights",
                          color: teal,
                          value: personalizedInsights,
                          onChanged: (value) {
                            setState(() {
                              personalizedInsights = value;
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // ==================================================
                    // NOTIFICATIONS
                    // ==================================================

                    _sectionHeader(
                      icon: Icons.notifications_none_rounded,
                      title: "Notifications",
                      subtitle:
                          "Choose what updates you want to receive",
                      color: orange,
                    ),

                    const SizedBox(height: 14),

                    _settingsCard(
                      children: [
                        _switchTile(
                          icon: Icons.trending_up_rounded,
                          title: "Investment Tips",
                          subtitle:
                              "Receive useful investment insights",
                          color: green,
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
                          subtitle:
                              "Get reminders about your challenges",
                          color: orange,
                          value: challengeReminders,
                          onChanged: (value) {
                            setState(() {
                              challengeReminders = value;
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // ==================================================
                    // INVESTMENT PREFERENCES
                    // ==================================================

                    _sectionHeader(
                      icon: Icons.account_balance_wallet_outlined,
                      title: "Investment Preferences",
                      subtitle:
                          "Set your investing preferences",
                      color: teal,
                    ),

                    const SizedBox(height: 14),

                    _settingsCard(
                      children: [
                        _settingsTile(
                          icon: Icons.shield_outlined,
                          title: "Risk Preference",
                          subtitle: riskPreference,
                          color: orange,
                          trailing: _valueBadge(
                            riskPreference,
                            orange,
                          ),
                          onTap: _showRiskPreferenceDialog,
                        ),

                        _divider(),

                        _settingsTile(
                          icon: Icons.currency_rupee_rounded,
                          title: "Default Currency",
                          subtitle: currency,
                          color: green,
                          trailing: _valueBadge(
                            currency,
                            green,
                          ),
                          onTap: _showCurrencyDialog,
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // ==================================================
                    // APPEARANCE
                    // ==================================================

                    _sectionHeader(
                      icon: Icons.palette_outlined,
                      title: "Appearance",
                      subtitle:
                          "Customize your OneVest experience",
                      color: purple,
                    ),

                    const SizedBox(height: 14),

                    _settingsCard(
                      children: [
                        _switchTile(
                          icon: Icons.dark_mode_outlined,
                          title: "Dark Mode",
                          subtitle: darkMode
                              ? "Dark theme is currently enabled"
                              : "Light theme selected",
                          color: purple,
                          value: darkMode,
                          onChanged: (value) {
                            setState(() {
                              darkMode = value;
                            });

                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              SnackBar(
                                backgroundColor: value
                                    ? surface3
                                    : Colors.white,
                                content: Text(
                                  value
                                      ? "Dark Mode enabled"
                                      : "Light Mode selected",
                                  style: TextStyle(
                                    color: value
                                        ? white
                                        : Colors.black,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // ==================================================
                    // PRIVACY & SECURITY
                    // ==================================================

                    _sectionHeader(
                      icon: Icons.security_outlined,
                      title: "Privacy & Security",
                      subtitle:
                          "Keep your account and data protected",
                      color: green,
                    ),

                    const SizedBox(height: 14),

                    _settingsCard(
                      children: [
                        _settingsTile(
                          icon: Icons.privacy_tip_outlined,
                          title: "Privacy & Data",
                          subtitle:
                              "Manage your data and privacy",
                          color: green,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const PrivacySecurityScreen(),
                              ),
                            );
                          },
                        ),

                        _divider(),

                        _settingsTile(
                          icon: Icons.info_outline_rounded,
                          title: "About OneVest",
                          subtitle:
                              "Learn more about OneVest",
                          color: teal,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const AboutOneVestScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 35),

                    _footer(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF102B47),
            Color(0xFF0A1428),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: teal.withValues(alpha: 0.20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.20),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: teal.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: teal.withValues(alpha: 0.22),
              ),
            ),
            child: const Icon(
              Icons.settings_rounded,
              color: teal,
              size: 31,
            ),
          ),

          const SizedBox(width: 18),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  "ONEVEST SETTINGS",
                  style: mono(
                    11,
                    color: teal,
                    weight: FontWeight.bold,
                    spacing: 1.4,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "Customize your experience",
                  style: mono(
                    20,
                    color: white,
                    weight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 7),

                Text(
                  "Manage your account, AI, notifications and investment preferences.",
                  style: mono(
                    12,
                    color: muted,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION HEADER
  // ============================================================

  Widget _sectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: color.withValues(alpha: 0.18),
            ),
          ),
          child: Icon(
            icon,
            color: color,
            size: 23,
          ),
        ),

        const SizedBox(width: 13),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: mono(
                  16,
                  color: white,
                  weight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                subtitle,
                style: mono(
                  11,
                  color: muted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SETTINGS CARD
  // ============================================================

  Widget _settingsCard({
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  // ============================================================
  // SETTINGS TILE
  // ============================================================

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          hoverColor: color.withValues(alpha: 0.035),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 17,
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.09),
                    borderRadius:
                        BorderRadius.circular(14),
                    border: Border.all(
                      color:
                          color.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: mono(
                          15,
                          color: white,
                          weight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,
                        style: mono(
                          11,
                          color: muted,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                trailing ??
                    Icon(
                      Icons.chevron_right_rounded,
                      color: color.withValues(
                        alpha: 0.75,
                      ),
                      size: 27,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SWITCH TILE
  // ============================================================

  Widget _switchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 17,
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: mono(
                    15,
                    color: white,
                    weight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: mono(
                    11,
                    color: muted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.black,
            activeTrackColor: teal,
            inactiveThumbColor: muted,
            inactiveTrackColor: surface3,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // VALUE BADGE
  // ============================================================

  Widget _valueBadge(
    String value,
    Color color,
  ) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 135,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: 0.18),
        ),
      ),
      child: Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: mono(
          10,
          color: color,
          weight: FontWeight.bold,
        ),
      ),
    );
  }

  // ============================================================
  // DIVIDER
  // ============================================================

  Widget _divider() {
    return Divider(
      height: 1,
      indent: 88,
      endIndent: 20,
      color: Colors.white.withValues(alpha: 0.055),
    );
  }

  // ============================================================
  // AI PERSONALITY
  // ============================================================

  void _showAiPersonalityDialog() {
    const options = [
      "Friendly",
      "Professional",
      "Brutally Honest",
      "Motivational",
    ];

    _selectionDialog(
      title: "AI Personality",
      icon: Icons.psychology_rounded,
      color: purple,
      options: options,
      selected: aiPersonality,
      onSelected: (value) {
        setState(() {
          aiPersonality = value;
        });
        Navigator.pop(context);
      },
    );
  }

  // ============================================================
  // RISK PREFERENCE
  // ============================================================

  void _showRiskPreferenceDialog() {
    const options = [
      "Conservative",
      "Moderate",
      "Aggressive",
    ];

    _selectionDialog(
      title: "Risk Preference",
      icon: Icons.shield_outlined,
      color: orange,
      options: options,
      selected: riskPreference,
      onSelected: (value) {
        setState(() {
          riskPreference = value;
        });
        Navigator.pop(context);
      },
    );
  }

  // ============================================================
  // CURRENCY
  // ============================================================

  void _showCurrencyDialog() {
    const options = [
      "INR (₹)",
      "USD (\$)",
      "EUR (€)",
    ];

    _selectionDialog(
      title: "Default Currency",
      icon: Icons.currency_rupee_rounded,
      color: green,
      options: options,
      selected: currency,
      onSelected: (value) {
        setState(() {
          currency = value;
        });
        Navigator.pop(context);
      },
    );
  }

  // ============================================================
  // SELECTION DIALOG
  // ============================================================

  void _selectionDialog({
    required String title,
    required IconData icon,
    required Color color,
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelected,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints:
                const BoxConstraints(maxWidth: 450),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: color.withValues(alpha: 0.20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color:
                            color.withValues(alpha: 0.09),
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 24,
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Text(
                        title,
                        style: mono(
                          16,
                          color: white,
                          weight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                ...options.map(
                  (option) {
                    final isSelected =
                        option == selected;

                    return Padding(
                      padding:
                          const EdgeInsets.only(
                        bottom: 9,
                      ),
                      child: InkWell(
                        borderRadius:
                            BorderRadius.circular(13),
                        onTap: () {
                          onSelected(option);
                          Navigator.pop(
                            dialogContext,
                          );
                        },
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? color.withValues(
                                    alpha: 0.10,
                                  )
                                : surface2,
                            borderRadius:
                                BorderRadius.circular(13),
                            border: Border.all(
                              color: isSelected
                                  ? color.withValues(
                                      alpha: 0.40,
                                    )
                                  : border,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? Icons
                                        .radio_button_checked_rounded
                                    : Icons
                                        .radio_button_off_rounded,
                                color: isSelected
                                    ? color
                                    : muted,
                                size: 22,
                              ),

                              const SizedBox(width: 13),

                              Text(
                                option,
                                style: mono(
                                  13,
                                  color: isSelected
                                      ? color
                                      : white,
                                  weight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 7),

                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(
                        dialogContext,
                      );
                    },
                    child: Text(
                      "CLOSE",
                      style: mono(
                        11,
                        color: muted,
                        weight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // CHANGE PASSWORD
  // ============================================================

  Future<void> _showChangePasswordDialog() async {
    final passwordController =
        TextEditingController();

    final confirmPasswordController =
        TextEditingController();

    bool obscurePassword = true;
    bool obscureConfirmPassword = true;
    bool isChanging = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                constraints:
                    const BoxConstraints(maxWidth: 480),
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius:
                      BorderRadius.circular(22),
                  border: Border.all(
                    color:
                        purple.withValues(alpha: 0.25),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: purple.withValues(
                                alpha: 0.10,
                              ),
                              borderRadius:
                                  BorderRadius.circular(
                                15,
                              ),
                            ),
                            child: const Icon(
                              Icons.lock_reset_rounded,
                              color: purple,
                              size: 28,
                            ),
                          ),

                          const SizedBox(width: 15),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Change Password",
                                  style: mono(
                                    16,
                                    color: white,
                                    weight:
                                        FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "Secure your OneVest account",
                                  style: mono(
                                    10,
                                    color: muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      Text(
                        "NEW PASSWORD",
                        style: mono(
                          10,
                          color: purple,
                          weight: FontWeight.bold,
                          spacing: 1,
                        ),
                      ),

                      const SizedBox(height: 8),

                      TextField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        style: const TextStyle(
                          color: white,
                          fontSize: 14,
                        ),
                        decoration:
                            _passwordDecoration(
                          "Enter new password",
                          Icons.lock_outline_rounded,
                          purple,
                          obscurePassword,
                          () {
                            setDialogState(() {
                              obscurePassword =
                                  !obscurePassword;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 18),

                      Text(
                        "CONFIRM PASSWORD",
                        style: mono(
                          10,
                          color: purple,
                          weight: FontWeight.bold,
                          spacing: 1,
                        ),
                      ),

                      const SizedBox(height: 8),

                      TextField(
                        controller:
                            confirmPasswordController,
                        obscureText:
                            obscureConfirmPassword,
                        style: const TextStyle(
                          color: white,
                          fontSize: 14,
                        ),
                        decoration:
                            _passwordDecoration(
                          "Confirm new password",
                          Icons.verified_user_outlined,
                          purple,
                          obscureConfirmPassword,
                          () {
                            setDialogState(() {
                              obscureConfirmPassword =
                                  !obscureConfirmPassword;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "Password must contain at least 6 characters.",
                        style: mono(
                          10,
                          color: muted,
                        ),
                      ),

                      const SizedBox(height: 25),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isChanging
                              ? null
                              : () async {
                                  final password =
                                      passwordController
                                          .text
                                          .trim();

                                  final confirm =
                                      confirmPasswordController
                                          .text
                                          .trim();

                                  if (password.isEmpty ||
                                      confirm.isEmpty) {
                                    _snack(
                                      "Please fill both password fields.",
                                    );
                                    return;
                                  }

                                  if (password.length <
                                      6) {
                                    _snack(
                                      "Password must contain at least 6 characters.",
                                    );
                                    return;
                                  }

                                  if (password !=
                                      confirm) {
                                    _snack(
                                      "Passwords do not match.",
                                    );
                                    return;
                                  }

                                  setDialogState(() {
                                    isChanging = true;
                                  });

                                  try {
                                    final user =
                                        FirebaseAuth
                                            .instance
                                            .currentUser;

                                    if (user == null) {
                                      throw Exception(
                                        "No logged-in user found.",
                                      );
                                    }

                                    await user
                                        .updatePassword(
                                      password,
                                    );

                                    if (!context.mounted) {
                                      return;
                                    }

                                    Navigator.pop(
                                      dialogContext,
                                    );

                                    _snack(
                                      "Password changed successfully!",
                                      success: true,
                                    );
                                  } on FirebaseAuthException catch (e) {
                                    setDialogState(() {
                                      isChanging = false;
                                    });

                                    String message;

                                    if (e.code ==
                                        'requires-recent-login') {
                                      message =
                                          "Please login again before changing your password.";
                                    } else if (e.code ==
                                        'weak-password') {
                                      message =
                                          "The password is too weak.";
                                    } else {
                                      message = e.message ??
                                          "Unable to change password.";
                                    }

                                    _snack(message);
                                  } catch (e) {
                                    setDialogState(() {
                                      isChanging = false;
                                    });

                                    _snack(
                                      "Error: $e",
                                    );
                                  }
                                },
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor: purple,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                          ),
                          child: isChanging
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  "CHANGE PASSWORD",
                                  style: mono(
                                    11,
                                    color: Colors.white,
                                    weight:
                                        FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: isChanging
                              ? null
                              : () {
                                  Navigator.pop(
                                    dialogContext,
                                  );
                                },
                          child: Text(
                            "CANCEL",
                            style: mono(
                              10,
                              color: muted,
                              weight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    passwordController.dispose();
    confirmPasswordController.dispose();
  }

  // ============================================================
  // PASSWORD DECORATION
  // ============================================================

  InputDecoration _passwordDecoration(
    String hint,
    IconData icon,
    Color color,
    bool obscure,
    VoidCallback toggle,
  ) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: muted,
      ),
      prefixIcon: Icon(
        icon,
        color: color,
      ),
      suffixIcon: IconButton(
        onPressed: toggle,
        icon: Icon(
          obscure
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          color: muted,
        ),
      ),
      filled: true,
      fillColor: surface2,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide:
            const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide:
            const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide(
          color: color,
          width: 1.5,
        ),
      ),
    );
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void _snack(
    String message, {
    bool success = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor:
            success ? green : surface3,
        content: Text(
          message,
          style: TextStyle(
            color:
                success ? Colors.black : white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FOOTER
  // ============================================================

  Widget _footer() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: teal.withValues(alpha: 0.08),
              borderRadius:
                  BorderRadius.circular(15),
              border: Border.all(
                color: teal.withValues(alpha: 0.15),
              ),
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: teal,
              size: 25,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            "ONEVEST",
            style: heading(
              11,
              color: teal,
              spacing: 1.2,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            "Smart investing. One portfolio.",
            style: mono(
              11,
              color: muted,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            "Version 1.0.0",
            style: mono(
              10,
              color: muted.withValues(
                alpha: 0.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}