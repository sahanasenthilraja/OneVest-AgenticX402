import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/security_service.dart';
import 'login_screen.dart';
import '../services/app_lock_service.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ONEVEST THEME
  // ============================================================

  static const Color background = Color(0xFF020B1D);
  static const Color surface = Color(0xFF0A1428);

  static const Color border = Color(0xFF243B60);

  static const Color teal = Color(0xFF14C8B0);
  static const Color tealDark = Color(0xFF0C8F82);

  static const Color white = Color(0xFFF5F8FC);
  static const Color muted = Color(0xFF91A0B8);

  static const Color green = Color(0xFF45E38A);
  static const Color red = Color(0xFFFF5A64);
  static const Color orange = Color(0xFFFFB52E);
  static const Color purple = Color(0xFFA86BFF);

  Map<String, dynamic>? userData;

  bool isLoading = true;
  bool isLoggingOut = false;

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
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  // ============================================================
  // LOAD USER
  // ============================================================

  Future<void> loadUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
        });

        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      if (!mounted) return;

      setState(() {
        userData = doc.data();
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: red,
          content: Text(
            "Unable to load profile",
            style: mono(13, color: white, weight: FontWeight.bold),
          ),
        ),
      );
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: border),
          ),
          title: Text("LOG OUT?", style: heading(14, color: white)),
          content: Text(
            "Are you sure you want to log out of OneVest?",
            style: mono(14, color: muted, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(
                "CANCEL",
                style: mono(12, color: muted, weight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: red,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                "LOG OUT",
                style: mono(12, color: Colors.white, weight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) return;

    setState(() {
      isLoggingOut = true;
    });

    try {
      // Stop the automatic session-lock timer.
      AppLockService.stop();

      // Remove the locally stored Transaction PIN.
      await SecurityService.clearPin(
        FirebaseAuth.instance.currentUser!.uid,
      );

      // Sign the user out of Firebase.
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      // Remove all previous screens so the user
      // cannot navigate back into the authenticated app.
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoggingOut = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: red,
          content: Text(
            "Logout failed. Please try again.",
            style: mono(13, color: white, weight: FontWeight.bold),
          ),
        ),
      );
    }
  }

  // ============================================================
  // TRANSACTION PIN
  // ============================================================

  Future<void> _setupTransactionPin() async {
    final pinController = TextEditingController();
    final confirmController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: border),
          ),
          title: Text("SET TRANSACTION PIN", style: heading(14, color: white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Create a 4-digit PIN to authorize AI Agent payments.",
                style: mono(12, color: muted, height: 1.5),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: pinController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                style: mono(16, color: white),
                decoration: InputDecoration(
                  labelText: "Transaction PIN",
                  labelStyle: mono(11, color: muted),
                  counterStyle: mono(10, color: muted),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: border),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: teal),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: confirmController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                style: mono(16, color: white),
                decoration: InputDecoration(
                  labelText: "Confirm PIN",
                  labelStyle: mono(11, color: muted),
                  counterStyle: mono(10, color: muted),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: border),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: teal),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(
                "CANCEL",
                style: mono(11, color: muted, weight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final pin = pinController.text.trim();
                final confirm = confirmController.text.trim();

                if (!RegExp(r'^\d{4}$').hasMatch(pin)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: red,
                      content: Text(
                        "PIN must contain exactly 4 digits.",
                        style: mono(12, color: white),
                      ),
                    ),
                  );
                  return;
                }

                if (pin != confirm) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: red,
                      content: Text(
                        "PINs do not match.",
                        style: mono(12, color: white),
                      ),
                    ),
                  );
                  return;
                }

                await SecurityService.savePin(
  FirebaseAuth.instance.currentUser!.uid,
  pin,
);

                if (!dialogContext.mounted) return;

                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: teal,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                "SAVE PIN",
                style: mono(11, color: Colors.black, weight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    pinController.dispose();
    confirmController.dispose();

    if (result == true && mounted) {
      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: tealDark,
          content: Text(
            "Transaction PIN secured successfully.",
            style: mono(12, color: white, weight: FontWeight.bold),
          ),
        ),
      );
    }
  }
  // ============================================================
  // KYC INFORMATION
  // ============================================================

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: teal.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                  border: Border.all(color: teal.withValues(alpha: 0.25)),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(color: teal, strokeWidth: 3),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "LOADING PROFILE",
                style: mono(
                  12,
                  color: muted,
                  weight: FontWeight.bold,
                  spacing: 1,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final name = userData?["name"]?.toString().trim().isNotEmpty == true
        ? userData!["name"].toString()
        : "User";

    final email = userData?["email"]?.toString() ?? "";
    final phone = userData?["phone"]?.toString() ?? "";

    final riskProfile = userData?["riskProfile"]?.toString().isNotEmpty == true
        ? userData!["riskProfile"].toString()
        : "Not Set";

    final kycStatus = userData?["kycStatus"]?.toString().isNotEmpty == true
        ? userData!["kycStatus"].toString()
        : "Not Verified";

    final initials = _getInitials(name);
    return Scaffold(
      backgroundColor: background,

      // ============================================================
      // APP BAR
      // ============================================================
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: white, size: 28),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: Text("Profile", style: heading(16, color: white)),
      ),

      // ============================================================
      // BODY
      // ============================================================
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          final bool desktop = width >= 1100;
          final bool tablet = width >= 700;

          final double horizontalPadding = desktop
              ? 70
              : tablet
              ? 40
              : 18;

          return RefreshIndicator(
            color: teal,
            backgroundColor: surface,
            onRefresh: loadUser,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                20,
                horizontalPadding,
                50,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1150),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ==================================================
                      // PROFILE HERO
                      // ==================================================
                      _profileHero(
                        name: name,
                        email: email,
                        initials: initials,
                      ),

                      const SizedBox(height: 22),

                      // ==================================================
                      // PROFILE INFORMATION
                      // ==================================================
                      _sectionTitle(
                        icon: Icons.person_outline_rounded,
                        title: "Personal Information",
                        subtitle: "Your account details",
                        color: teal,
                      ),

                      const SizedBox(height: 15),

                      if (desktop)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _infoCard(
                                icon: Icons.email_outlined,
                                title: "EMAIL ADDRESS",
                                value: email.isEmpty ? "Not provided" : email,
                                color: teal,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: _infoCard(
                                icon: Icons.phone_outlined,
                                title: "PHONE NUMBER",
                                value: phone.isEmpty ? "Not provided" : phone,
                                color: purple,
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            _infoCard(
                              icon: Icons.email_outlined,
                              title: "EMAIL ADDRESS",
                              value: email.isEmpty ? "Not provided" : email,
                              color: teal,
                            ),
                            const SizedBox(height: 15),
                            _infoCard(
                              icon: Icons.phone_outlined,
                              title: "PHONE NUMBER",
                              value: phone.isEmpty ? "Not provided" : phone,
                              color: purple,
                            ),
                          ],
                        ),

                      const SizedBox(height: 22),

                      // ==================================================
                      // INVESTOR PROFILE
                      // ==================================================
                      _sectionTitle(
                        icon: Icons.insights_rounded,
                        title: "Investor Profile",
                        subtitle: "Your investment preferences",
                        color: orange,
                      ),

                      const SizedBox(height: 15),

                      _riskCard(riskProfile),

                      const SizedBox(height: 22),

                      // ==================================================
                      // SECURITY
                      // ==================================================
                      _sectionTitle(
                        icon: Icons.security_rounded,
                        title: "Security",
                        subtitle: "Protect AI Agent transactions",
                        color: teal,
                      ),

                      const SizedBox(height: 15),

                      FutureBuilder<bool>(
  future: SecurityService.hasPin(
    FirebaseAuth.instance.currentUser!.uid,
  ),
                        builder: (context, snapshot) {
                          final pinConfigured = snapshot.data ?? false;

                          return _actionCard(
                            icon: Icons.lock_outline_rounded,
                            title: "Transaction PIN",
                            subtitle: pinConfigured
                                ? "PIN is configured for AI Agent payments"
                                : "Set a PIN to authorize AI Agent payments",
                            color: teal,
                            onTap: _setupTransactionPin,
                          );
                        },
                      ),
                      const SizedBox(height: 22),

                      // ==================================================
                      // KYC / IDENTITY VERIFICATION
                      // ==================================================
                      _sectionTitle(
                        icon: Icons.badge_outlined,
                        title: "Identity Verification",
                        subtitle: "KYC status for financial services",
                        color: orange,
                      ),

                      const SizedBox(height: 15),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: orange.withValues(alpha: 0.09),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.verified_user_outlined,
                                    color: orange,
                                    size: 25,
                                  ),
                                ),

                                const SizedBox(width: 15),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "KYC STATUS",
                                        style: mono(
                                          10,
                                          color: muted,
                                          weight: FontWeight.bold,
                                          spacing: 0.8,
                                        ),
                                      ),

                                      const SizedBox(height: 6),

                                      Text(
                                        kycStatus,
                                        style: mono(
                                          17,
                                          color:
                                              kycStatus.toLowerCase() ==
                                                  "verified"
                                              ? green
                                              : orange,
                                          weight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Icon(
                                  kycStatus.toLowerCase() == "verified"
                                      ? Icons.check_circle_rounded
                                      : Icons.pending_outlined,
                                  color: kycStatus.toLowerCase() == "verified"
                                      ? green
                                      : orange,
                                  size: 25,
                                ),
                              ],
                            ),

                            const SizedBox(height: 18),

                            Text(
                              kycStatus.toLowerCase() == "verified"
                                  ? "Identity verification has been completed."
                                  : "Identity verification is required before regulated investment services.",
                              style: mono(11, color: muted, height: 1.5),
                            ),

                            const SizedBox(height: 15),

                            _actionCard(
                              icon: Icons.arrow_forward_rounded,
                              title: "Start KYC",
                              subtitle:
                                  "Continue with an authorised KYC provider",
                              color: orange,
                              onTap: () => _showKycInformationDialog(context),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 22),

                      // ==================================================
                      // ACCOUNT ACTIONS
                      // ==================================================
                      _sectionTitle(
                        icon: Icons.tune_rounded,
                        title: "Account",
                        subtitle: "Manage your OneVest experience",
                        color: purple,
                      ),

                      const SizedBox(height: 15),

                      _actionCard(
                        icon: Icons.settings_rounded,
                        title: "Settings",
                        subtitle: "Manage your account preferences",
                        color: teal,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SettingsScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 12),

                      _actionCard(
                        icon: Icons.logout_rounded,
                        title: "Logout",
                        subtitle: "Sign out from your OneVest account",
                        color: red,
                        isLoading: isLoggingOut,
                        onTap: isLoggingOut ? null : logout,
                      ),

                      const SizedBox(height: 30),

                      // ==================================================
                      // FOOTER
                      // ==================================================
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: teal.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(13),
                                border: Border.all(
                                  color: teal.withValues(alpha: 0.15),
                                ),
                              ),
                              child: const Icon(
                                Icons.account_balance_wallet_rounded,
                                color: teal,
                                size: 22,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "ONEVEST",
                              style: heading(11, color: teal, spacing: 1.2),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              "Smart investing. One portfolio.",
                              style: mono(11, color: muted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // PROFILE HERO
  // ============================================================

  Widget _profileHero({
    required String name,
    required String email,
    required String initials,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF102B47), Color(0xFF0B172C)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: teal.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          // AVATAR
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [teal, tealDark]),
              boxShadow: [
                BoxShadow(
                  color: teal.withValues(alpha: 0.20),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                initials,
                style: mono(26, color: Colors.black, weight: FontWeight.w900),
              ),
            ),
          ),

          const SizedBox(width: 22),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "WELCOME BACK",
                  style: mono(
                    11,
                    color: teal,
                    weight: FontWeight.bold,
                    spacing: 1.5,
                  ),
                ),

                const SizedBox(height: 9),

                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: mono(25, color: white, weight: FontWeight.w900),
                ),

                const SizedBox(height: 8),

                if (email.isNotEmpty)
                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: mono(13, color: muted),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 15),

          // ACTIVE STATUS
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
            decoration: BoxDecoration(
              color: green.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: green.withValues(alpha: 0.20)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.circle, color: green, size: 8),
                const SizedBox(width: 7),
                Text(
                  "ACTIVE",
                  style: mono(10, color: green, weight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle({
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
            border: Border.all(color: color.withValues(alpha: 0.18)),
          ),
          child: Icon(icon, color: color, size: 23),
        ),

        const SizedBox(width: 13),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: mono(16, color: white, weight: FontWeight.w900),
              ),
              const SizedBox(height: 5),
              Text(subtitle, style: mono(12, color: muted)),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // INFORMATION CARD
  // ============================================================

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 23),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: mono(
                      10,
                      color: muted,
                      weight: FontWeight.bold,
                      spacing: 0.8,
                    ),
                  ),

                  const SizedBox(height: 7),

                  Text(
                    value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: mono(15, color: white, weight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // RISK CARD
  // ============================================================

  Widget _riskCard(String riskProfile) {
    final risk = riskProfile.toLowerCase();

    Color color = orange;
    IconData icon = Icons.balance_rounded;

    if (risk.contains("low") || risk.contains("conservative")) {
      color = green;
      icon = Icons.shield_outlined;
    } else if (risk.contains("high") || risk.contains("aggressive")) {
      color = red;
      icon = Icons.warning_amber_rounded;
    } else if (risk.contains("moderate")) {
      color = orange;
      icon = Icons.balance_rounded;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 29),
          ),

          const SizedBox(width: 17),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "RISK PROFILE",
                  style: mono(
                    10,
                    color: muted,
                    weight: FontWeight.bold,
                    spacing: 1,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  riskProfile,
                  style: mono(22, color: color, weight: FontWeight.w900),
                ),

                const SizedBox(height: 5),

                Text(
                  "Your investment risk preference",
                  style: mono(12, color: muted),
                ),
              ],
            ),
          ),

          Icon(
            Icons.verified_rounded,
            color: color.withValues(alpha: 0.7),
            size: 25,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACTION CARD
  // ============================================================

  Widget _actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return MouseRegion(
      cursor: onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          hoverColor: color.withValues(alpha: 0.035),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(19),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: onTap != null ? border : color.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: isLoading
                      ? Padding(
                          padding: const EdgeInsets.all(14),
                          child: CircularProgressIndicator(
                            color: color,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Icon(icon, color: color, size: 24),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: mono(15, color: white, weight: FontWeight.bold),
                      ),

                      const SizedBox(height: 5),

                      Text(subtitle, style: mono(11, color: muted)),
                    ],
                  ),
                ),

                Icon(
                  Icons.chevron_right_rounded,
                  color: color.withValues(alpha: 0.75),
                  size: 26,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // INITIALS
  // ============================================================

  String _getInitials(String name) {
    final cleanName = name.trim();

    if (cleanName.isEmpty) {
      return "U";
    }

    final parts = cleanName.split(RegExp(r'\s+'));

    if (parts.length == 1) {
      final word = parts.first;

      if (word.length >= 2) {
        return word.substring(0, 2).toUpperCase();
      }

      return word.substring(0, 1).toUpperCase();
    }

    return "${parts.first[0]}${parts.last[0]}".toUpperCase();
  }
}

Future<void> _showKycInformationDialog(BuildContext context) async {
  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: const Color(0xFF0A1428),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF243B60)),
        ),
        title: const Text(
          "KYC VERIFICATION",
          style: TextStyle(
            color: Color(0xFFF5F8FC),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.verified_user_outlined,
              color: Color(0xFFFFB52E),
              size: 42,
            ),
            SizedBox(height: 15),
            Text(
              "Identity verification is not completed yet.",
              style: TextStyle(
                color: Color(0xFFF5F8FC),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              "OneVest should use an authorised KYC provider "
              "for PAN, Aadhaar/e-KYC and identity verification. "
              "This prototype does not store or display fake "
              "government identification details.",
              style: TextStyle(
                color: Color(0xFF91A0B8),
                fontSize: 11,
                height: 1.6,
              ),
            ),
            SizedBox(height: 15),
            Text(
              "KYC STATUS: NOT VERIFIED",
              style: TextStyle(
                color: Color(0xFFFFB52E),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF14C8B0),
              foregroundColor: Colors.black,
            ),
            child: const Text("CLOSE"),
          ),
        ],
      );
    },
  );
}
