import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() =>
      _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState
    extends State<PrivacySecurityScreen> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color background = Color(0xFF020B1D);
  static const Color panel = Color(0xFF0A1428);
  static const Color panelLight = Color(0xFF10203A);
  static const Color fieldColor = Color(0xFF142542);
  static const Color border = Color(0xFF263B5C);

  static const Color teal = Color(0xFF14C8B0);
  static const Color green = Color(0xFF45E38A);
  static const Color orange = Color(0xFFFFB52E);
  static const Color purple = Color(0xFFA86BFF);
  static const Color red = Color(0xFFFF5A64);

  static const Color white = Color(0xFFF5F8FC);
  static const Color muted = Color(0xFF91A0B8);

  // ============================================================
  // SETTINGS
  // ============================================================

  bool biometricEnabled = false;
  bool loginAlertsEnabled = true;
  bool transactionAlertsEnabled = true;
  bool personalizedDataEnabled = true;

  // ============================================================
  // TEXT STYLES
  // ============================================================

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

  TextStyle pixel(
    double size, {
    Color color = white,
  }) {
    return GoogleFonts.pressStart2p(
      fontSize: size,
      color: color,
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
        scrolledUnderElevation: 0,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: white,
            size: 20,
          ),
        ),

        title: Text(
          "Privacy & Security",
          style: pixel(13),
        ),
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool desktop =
              constraints.maxWidth >= 900;

          final double horizontalPadding =
              desktop ? 60 : 20;

          return SingleChildScrollView(
            physics:
                const BouncingScrollPhysics(),

            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              18,
              horizontalPadding,
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
                    _header(),

                    const SizedBox(height: 30),

                    // ==================================================
                    // SECURITY
                    // ==================================================

                    _sectionHeader(
                      icon: Icons.security_rounded,
                      title: "Account Security",
                      subtitle:
                          "Protect your OneVest account",
                      color: green,
                    ),

                    const SizedBox(height: 14),

                    _card(
                      children: [
                        _switchTile(
                          icon:
                              Icons.fingerprint_rounded,
                          title:
                              "Biometric Login",
                          subtitle:
                              "Use device biometrics for faster sign-in",
                          color: purple,
                          value:
                              biometricEnabled,
                          onChanged: (value) {
                            setState(() {
                              biometricEnabled =
                                  value;
                            });

                            _showMessage(
                              value
                                  ? "Biometric login enabled"
                                  : "Biometric login disabled",
                              success: true,
                            );
                          },
                        ),

                        _divider(),

                        _switchTile(
                          icon:
                              Icons.login_rounded,
                          title:
                              "Login Alerts",
                          subtitle:
                              "Get notified when your account is accessed",
                          color: teal,
                          value:
                              loginAlertsEnabled,
                          onChanged: (value) {
                            setState(() {
                              loginAlertsEnabled =
                                  value;
                            });
                          },
                        ),

                        _divider(),

                        _infoTile(
                          icon:
                              Icons.password_rounded,
                          title:
                              "Password Security",
                          subtitle:
                              "Your password is securely managed through Firebase Authentication.",
                          color: green,
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // ==================================================
                    // TRANSACTION SECURITY
                    // ==================================================

                    _sectionHeader(
                      icon:
                          Icons.account_balance_wallet_outlined,
                      title:
                          "Transaction Security",
                      subtitle:
                          "Control alerts related to your investments",
                      color: orange,
                    ),

                    const SizedBox(height: 14),

                    _card(
                      children: [
                        _switchTile(
                          icon:
                              Icons.notifications_active_outlined,
                          title:
                              "Transaction Alerts",
                          subtitle:
                              "Receive notifications for important investment activity",
                          color: orange,
                          value:
                              transactionAlertsEnabled,
                          onChanged: (value) {
                            setState(() {
                              transactionAlertsEnabled =
                                  value;
                            });
                          },
                        ),

                        _divider(),

                        _infoTile(
                          icon:
                              Icons.verified_user_outlined,
                          title:
                              "Secure Transactions",
                          subtitle:
                              "OneVest uses secure authentication and protected data storage for your account.",
                          color: green,
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // ==================================================
                    // DATA & PRIVACY
                    // ==================================================

                    _sectionHeader(
                      icon:
                          Icons.privacy_tip_outlined,
                      title: "Data & Privacy",
                      subtitle:
                          "Control how your information is used",
                      color: teal,
                    ),

                    const SizedBox(height: 14),

                    _card(
                      children: [
                        _switchTile(
                          icon:
                              Icons.auto_awesome_rounded,
                          title:
                              "Personalized Data",
                          subtitle:
                              "Allow OneVest to use your portfolio preferences for personalized insights",
                          color: teal,
                          value:
                              personalizedDataEnabled,
                          onChanged: (value) {
                            setState(() {
                              personalizedDataEnabled =
                                  value;
                            });
                          },
                        ),

                        _divider(),

                        _infoTile(
                          icon:
                              Icons.cloud_outlined,
                          title:
                              "Cloud Data Storage",
                          subtitle:
                              "Your account and portfolio information is stored using Firebase services.",
                          color: purple,
                        ),

                        _divider(),

                        _infoTile(
                          icon:
                              Icons.visibility_outlined,
                          title:
                              "Data Visibility",
                          subtitle:
                              "Your portfolio information is intended to remain associated with your authenticated account.",
                          color: teal,
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // ==================================================
                    // PRIVACY INFORMATION
                    // ==================================================

                    _sectionHeader(
                      icon:
                          Icons.info_outline_rounded,
                      title:
                          "Privacy Information",
                      subtitle:
                          "Understand how OneVest handles your data",
                      color: purple,
                    ),

                    const SizedBox(height: 14),

                    _card(
                      children: [
                        _expandableTile(
                          icon:
                              Icons.storage_outlined,
                          title:
                              "What data is stored?",
                          color: purple,
                          content:
                              "OneVest may store account information, investment details, portfolio preferences and application settings required to provide the service.",
                        ),

                        _divider(),

                        _expandableTile(
                          icon:
                              Icons.manage_accounts_outlined,
                          title:
                              "Who can access my data?",
                          color: teal,
                          content:
                              "Your investment information is associated with your authenticated OneVest account. Access should be limited to authorized application functionality.",
                        ),

                        _divider(),

                        _expandableTile(
                          icon:
                              Icons.security_outlined,
                          title:
                              "How is my account protected?",
                          color: green,
                          content:
                              "OneVest uses Firebase Authentication and Firestore-based storage as part of its application architecture.",
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // ==================================================
                    // DANGER ZONE
                    // ==================================================

                    _sectionHeader(
                      icon:
                          Icons.warning_amber_rounded,
                      title: "Account Actions",
                      subtitle:
                          "Important account management options",
                      color: red,
                    ),

                    const SizedBox(height: 14),

                    _card(
                      children: [
                        _actionTile(
                          icon:
                              Icons.logout_rounded,
                          title:
                              "Sign Out",
                          subtitle:
                              "Sign out of your OneVest account",
                          color: red,
                          onTap: () {
                            _showMessage(
                              "Please use Logout from your Profile screen.",
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

      padding: const EdgeInsets.all(25),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF102B47),
            Color(0xFF081326),
          ],
        ),

        borderRadius:
            BorderRadius.circular(23),

        border: Border.all(
          color:
              green.withValues(alpha: 0.20),
        ),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(
              alpha: 0.20,
            ),
            blurRadius: 25,
            offset:
                const Offset(0, 10),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,

            decoration: BoxDecoration(
              color:
                  green.withValues(
                alpha: 0.09,
              ),
              borderRadius:
                  BorderRadius.circular(18),
              border: Border.all(
                color:
                    green.withValues(
                  alpha: 0.20,
                ),
              ),
            ),

            child: const Icon(
              Icons.shield_rounded,
              color: green,
              size: 32,
            ),
          ),

          const SizedBox(width: 18),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  "ONEVEST // SECURITY",
                  style: mono(
                    10,
                    color: green,
                    weight:
                        FontWeight.bold,
                    spacing: 1.4,
                  ),
                ),

                const SizedBox(height: 9),

                Text(
                  "Privacy & Security",
                  style: mono(
                    20,
                    color: white,
                    weight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 7),

                Text(
                  "Manage your privacy, security and account protection preferences.",
                  style: mono(
                    11,
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
            color:
                color.withValues(
              alpha: 0.09,
            ),
            borderRadius:
                BorderRadius.circular(14),
            border: Border.all(
              color:
                  color.withValues(
                alpha: 0.17,
              ),
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
                  weight:
                      FontWeight.w900,
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
  // CARD
  // ============================================================

  Widget _card({
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,

      decoration: BoxDecoration(
        color: panel,
        borderRadius:
            BorderRadius.circular(19),
        border: Border.all(
          color: border,
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(
              alpha: 0.12,
            ),
            blurRadius: 18,
            offset:
                const Offset(0, 7),
          ),
        ],
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
      padding:
          const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 17,
      ),

      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,

            decoration: BoxDecoration(
              color:
                  color.withValues(
                alpha: 0.09,
              ),
              borderRadius:
                  BorderRadius.circular(14),
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
                    weight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  subtitle,
                  maxLines: 3,
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

          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor:
                Colors.black,
            activeTrackColor:
                teal,
            inactiveThumbColor:
                muted,
            inactiveTrackColor:
                fieldColor,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFO TILE
  // ============================================================

  Widget _infoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 17,
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Container(
            width: 52,
            height: 52,

            decoration: BoxDecoration(
              color:
                  color.withValues(
                alpha: 0.09,
              ),
              borderRadius:
                  BorderRadius.circular(14),
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
  // EXPANDABLE TILE
  // ============================================================

  Widget _expandableTile({
    required IconData icon,
    required String title,
    required Color color,
    required String content,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),

      child: ExpansionTile(
        tilePadding:
            const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 5,
        ),

        childrenPadding:
            const EdgeInsets.fromLTRB(
          88,
          0,
          20,
          18,
        ),

        iconColor: color,
        collapsedIconColor: muted,

        leading: Container(
          width: 52,
          height: 52,

          decoration: BoxDecoration(
            color:
                color.withValues(
              alpha: 0.09,
            ),
            borderRadius:
                BorderRadius.circular(14),
          ),

          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),

        title: Text(
          title,
          style: mono(
            14,
            color: white,
            weight: FontWeight.bold,
          ),
        ),

        children: [
          Align(
            alignment:
                Alignment.centerLeft,
            child: Text(
              content,
              style: mono(
                11,
                color: muted,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACTION TILE
  // ============================================================

  Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor:
          SystemMouseCursors.click,

      child: Material(
        color: Colors.transparent,

        child: InkWell(
          onTap: onTap,

          hoverColor:
              color.withValues(
            alpha: 0.035,
          ),

          child: Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 17,
            ),

            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,

                  decoration: BoxDecoration(
                    color:
                        color.withValues(
                      alpha: 0.09,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      14,
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
                          color: color,
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
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons.chevron_right_rounded,
                  color:
                      color.withValues(
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
  // DIVIDER
  // ============================================================

  Widget _divider() {
    return Divider(
      height: 1,
      indent: 88,
      endIndent: 20,
      color:
          Colors.white.withValues(
        alpha: 0.055,
      ),
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message, {
    bool success = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        behavior:
            SnackBarBehavior.floating,
        backgroundColor:
            success ? green : panelLight,

        content: Row(
          children: [
            Icon(
              success
                  ? Icons.check_circle_outline
                  : Icons.info_outline,
              color: success
                  ? Colors.black
                  : teal,
              size: 20,
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                message,
                style: mono(
                  11,
                  color: success
                      ? Colors.black
                      : white,
                  weight:
                      FontWeight.bold,
                ),
              ),
            ),
          ],
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
              color:
                  teal.withValues(
                alpha: 0.08,
              ),
              borderRadius:
                  BorderRadius.circular(15),
              border: Border.all(
                color:
                    teal.withValues(
                  alpha: 0.15,
                ),
              ),
            ),

            child: const Icon(
              Icons.shield_rounded,
              color: teal,
              size: 25,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            "ONEVEST",
            style: pixel(
              11,
              color: teal,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            "Your portfolio. Your data. Your control.",
            textAlign: TextAlign.center,
            style: mono(
              10,
              color: muted,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            "Privacy & Security",
            style: mono(
              9,
              color:
                  muted.withValues(
                alpha: 0.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}