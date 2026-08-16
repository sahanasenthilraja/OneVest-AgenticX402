import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  static const Color background = Color(0xFF020B1D);
  static const Color surface = Color(0xFF0A1428);
  static const Color surface2 = Color(0xFF0F1D35);
  static const Color border = Color(0xFF243B60);

  static const Color teal = Color(0xFF14C8B0);
  static const Color green = Color(0xFF45E38A);
  static const Color purple = Color(0xFFA86BFF);

  static const Color white = Color(0xFFF5F8FC);
  static const Color muted = Color(0xFF91A0B8);

  TextStyle heading(
    double size, {
    Color color = white,
    FontWeight weight = FontWeight.w700,
  }) {
    return GoogleFonts.pressStart2p(
      fontSize: size,
      color: color,
      fontWeight: weight,
    );
  }

  TextStyle mono(
    double size, {
    Color color = white,
    FontWeight weight = FontWeight.normal,
    double? height,
  }) {
    return GoogleFonts.spaceMono(
      fontSize: size,
      color: color,
      fontWeight: weight,
      height: height,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,

        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: white,
            size: 28,
          ),
        ),

        title: Text(
          "Privacy & Security",
          style: heading(16),
        ),
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          final padding =
              constraints.maxWidth >= 1000
                  ? 70.0
                  : constraints.maxWidth >= 700
                      ? 40.0
                      : 18.0;

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              padding,
              18,
              padding,
              50,
            ),

            child: Center(
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(
                  maxWidth: 1050,
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    _hero(),

                    const SizedBox(height: 30),

                    _sectionTitle(
                      "SECURITY STATUS",
                      Icons.verified_user_outlined,
                      green,
                    ),

                    const SizedBox(height: 14),

                    _securityStatus(),

                    const SizedBox(height: 30),

                    _sectionTitle(
                      "SECURITY",
                      Icons.lock_outline_rounded,
                      purple,
                    ),

                    const SizedBox(height: 14),

                    _card(
                      children: [
                        _tile(
                          icon: Icons.password_rounded,
                          title: "Password Protection",
                          subtitle:
                              "Your account is protected with Firebase Authentication.",
                          color: purple,
                          trailing:
                              _badge("ACTIVE", green),
                        ),

                        _divider(),

                        _tile(
                          icon: Icons.phonelink_lock_outlined,
                          title: "Two-Factor Authentication",
                          subtitle:
                              "Add another layer of protection to your account.",
                          color: teal,
                          trailing:
                              _badge("AVAILABLE", teal),
                          onTap: () {
                            _showComingSoon(
                              context,
                              "Two-Factor Authentication",
                            );
                          },
                        ),

                        _divider(),

                        _tile(
                          icon: Icons.devices_rounded,
                          title: "Login Activity",
                          subtitle:
                              "Review devices and account access.",
                          color: green,
                          onTap: () {
                            _showComingSoon(
                              context,
                              "Login Activity",
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    _sectionTitle(
                      "PRIVACY",
                      Icons.privacy_tip_outlined,
                      teal,
                    ),

                    const SizedBox(height: 14),

                    _card(
                      children: [
                        _tile(
                          icon:
                              Icons.storage_rounded,
                          title: "Your Data",
                          subtitle:
                              "Your profile and investment information are stored securely.",
                          color: teal,
                          onTap: () {
                            _showDataInfo(context);
                          },
                        ),

                        _divider(),

                        _tile(
                          icon:
                              Icons.shield_outlined,
                          title: "Data Protection",
                          subtitle:
                              "OneVest uses authenticated access for your account data.",
                          color: green,
                          trailing:
                              _badge("PROTECTED", green),
                        ),

                        _divider(),

                        _tile(
                          icon:
                              Icons.visibility_off_outlined,
                          title: "Privacy Controls",
                          subtitle:
                              "Control how your personal information is handled.",
                          color: purple,
                          onTap: () {
                            _showComingSoon(
                              context,
                              "Privacy Controls",
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    _infoBanner(),

                    const SizedBox(height: 35),

                    Center(
                      child: Text(
                        "Your privacy matters at OneVest.",
                        style: mono(
                          11,
                          color: muted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _hero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF102B47),
            Color(0xFF0A1428),
          ],
        ),

        borderRadius:
            BorderRadius.circular(24),

        border: Border.all(
          color:
              green.withValues(alpha: 0.20),
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,

            decoration: BoxDecoration(
              color:
                  green.withValues(alpha: 0.10),
              borderRadius:
                  BorderRadius.circular(18),
            ),

            child: const Icon(
              Icons.security_rounded,
              color: green,
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
                  "PRIVACY & SECURITY",
                  style: mono(
                    11,
                    color: green,
                    weight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "Your data stays protected",
                  style: mono(
                    20,
                    color: white,
                    weight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 7),

                Text(
                  "Manage your account security and understand how OneVest protects your information.",
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

  Widget _sectionTitle(
    String title,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: 22,
        ),

        const SizedBox(width: 10),

        Text(
          title,
          style: mono(
            13,
            color: white,
            weight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _securityStatus() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: surface,
        borderRadius:
            BorderRadius.circular(18),

        border: Border.all(
          color:
              green.withValues(alpha: 0.28),
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,

            decoration: BoxDecoration(
              color:
                  green.withValues(alpha: 0.10),
              borderRadius:
                  BorderRadius.circular(15),
            ),

            child: const Icon(
              Icons.check_circle_outline_rounded,
              color: green,
              size: 29,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  "Account Security",
                  style: mono(
                    15,
                    color: white,
                    weight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "Your account is currently protected.",
                  style: mono(
                    11,
                    color: muted,
                  ),
                ),
              ],
            ),
          ),

          _badge("SECURE", green),
        ],
      ),
    );
  }

  Widget _card({
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius:
            BorderRadius.circular(19),

        border: Border.all(
          color: border,
        ),
      ),

      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(19),

        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return MouseRegion(
      cursor: onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,

      child: Material(
        color: Colors.transparent,

        child: InkWell(
          onTap: onTap,

          child: Padding(
            padding:
                const EdgeInsets.all(19),

            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,

                  decoration: BoxDecoration(
                    color:
                        color.withValues(alpha: 0.09),
                    borderRadius:
                        BorderRadius.circular(14),
                  ),

                  child: Icon(
                    icon,
                    color: color,
                    size: 25,
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
                          14,
                          color: white,
                          weight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        subtitle,
                        style: mono(
                          11,
                          color: muted,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),

                if (trailing != null)
                  trailing
                else if (onTap != null)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: color,
                    size: 27,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _badge(
    String text,
    Color color,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),

      decoration: BoxDecoration(
        color:
            color.withValues(alpha: 0.09),

        borderRadius:
            BorderRadius.circular(9),

        border: Border.all(
          color:
              color.withValues(alpha: 0.22),
        ),
      ),

      child: Text(
        text,
        style: mono(
          9,
          color: color,
          weight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      indent: 87,
      endIndent: 18,
      color:
          Colors.white.withValues(alpha: 0.055),
    );
  }

  Widget _infoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color:
            teal.withValues(alpha: 0.06),

        borderRadius:
            BorderRadius.circular(16),

        border: Border.all(
          color:
              teal.withValues(alpha: 0.16),
        ),
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: teal,
            size: 23,
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Text(
              "OneVest uses authenticated access to protect your account. Never share your password or authentication credentials with anyone.",
              style: mono(
                11,
                color: muted,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDataInfo(BuildContext context) {
    showDialog(
      context: context,

      builder: (_) {
        return AlertDialog(
          backgroundColor: surface,

          title: Text(
            "Your Data",
            style: mono(
              16,
              color: white,
              weight: FontWeight.bold,
            ),
          ),

          content: Text(
            "Your OneVest profile and investment information are stored using Firebase services and protected through authenticated account access.",
            style: mono(
              12,
              color: muted,
              height: 1.6,
            ),
          ),

          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context),

              child: Text(
                "CLOSE",
                style: mono(
                  11,
                  color: teal,
                  weight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showComingSoon(
    BuildContext context,
    String title,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          "$title will be available soon.",
          style: mono(
            11,
            color: Colors.white,
          ),
        ),
        backgroundColor: surface3,
        behavior:
            SnackBarBehavior.floating,
      ),
    );
  }
}