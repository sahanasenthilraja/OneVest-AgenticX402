import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/auth_service.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final AuthService authService = AuthService();

  // ============================================================
  // STATE
  // ============================================================

  bool hidePassword = true;
  bool hideConfirmPassword = true;
  bool isLoading = false;

  String riskProfile = 'Medium';

  // ============================================================
  // ONEVEST COLORS
  // ============================================================

  static const Color bg = Color(0xFF020B1D);
  static const Color panel = Color(0xFF101A31);
  static const Color panel2 = Color(0xFF12213B);

  static const Color teal = Color(0xFF10D8C3);
  static const Color tealDark = Color(0xFF0B3946);

  static const Color white = Color(0xFFF4F7FF);
  static const Color muted = Color(0xFF8EA0BE);
  static const Color border = Color(0xFF294269);

  // ============================================================
  // FONT STYLES
  // ============================================================

  TextStyle get pixelTitle => GoogleFonts.pressStart2p(
        color: white,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      );

  TextStyle get pixelSmall => GoogleFonts.pressStart2p(
        color: muted,
        fontSize: 8,
        fontWeight: FontWeight.w400,
      );

  TextStyle get pixelTeal => GoogleFonts.pressStart2p(
        color: teal,
        fontSize: 9,
        fontWeight: FontWeight.w500,
      );

  TextStyle get bodyText => GoogleFonts.spaceGrotesk(
        color: white,
        fontSize: 15,
      );

  TextStyle get bodyMuted => GoogleFonts.spaceGrotesk(
        color: muted,
        fontSize: 14,
      );

  // ============================================================
  // SIGN UP
  // ============================================================

  Future<void> signUp() async {
    FocusScope.of(context).unfocus();

    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      _showMessage('Please fill all fields.');
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      _showMessage('Passwords do not match.');
      return;
    }

    if (passwordController.text.length < 6) {
      _showMessage('Password must contain at least 6 characters.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    String? error;

    try {
      error = await authService.signUp(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        riskProfile: riskProfile,
        password: passwordController.text,
      );
    } catch (e) {
      error = e.toString();
    }

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (error == null) {
      _showMessage('Account created successfully.');

      await Future.delayed(
        const Duration(milliseconds: 700),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
    } else {
      _showMessage(error);
    }
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: panel2,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(
              color: border,
            ),
          ),
          content: Text(
            message,
            style: bodyText,
          ),
        ),
      );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration fieldDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.spaceGrotesk(
        color: muted,
        fontSize: 15,
      ),
      prefixIcon: Icon(
        icon,
        color: teal,
        size: 21,
      ),
      filled: true,
      fillColor: const Color(0xFF0D1830),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: border,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: teal,
          width: 1.4,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Colors.redAccent,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Colors.redAccent,
        ),
      ),
    );
  }

  // ============================================================
  // INPUT FIELD
  // ============================================================

  Widget buildField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: pixelSmall,
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: GoogleFonts.spaceGrotesk(
            color: white,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          cursorColor: teal,
          decoration: fieldDecoration(
            hint: hint,
            icon: icon,
          ).copyWith(
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TOP BAR
  // ============================================================

  Widget buildTopBar() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
      ),
      decoration: const BoxDecoration(
        color: bg,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: white,
              size: 21,
            ),
          ),

          const SizedBox(width: 6),

          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: tealDark,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: teal,
              ),
            ),
            child: const Icon(
              Icons.person_add_alt_1_rounded,
              color: teal,
              size: 21,
            ),
          ),

          const SizedBox(width: 14),

          Text(
            'CREATE ACCOUNT',
            style: pixelTitle,
          ),

          const Spacer(),

          // ONLINE STATUS
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF092A27),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: teal.withValues(alpha: 0.45),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: teal,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  'ONLINE',
                  style: pixelSmall.copyWith(
                    color: teal,
                    fontSize: 7,
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
  // HERO
  // ============================================================

  Widget buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 28,
      ),
      decoration: BoxDecoration(
        color: panel2,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: teal.withValues(alpha: 0.65),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // LOGO
          Container(
            width: 110,
            height: 110,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: teal.withValues(alpha: 0.7),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/onevest_logo.png',
                fit: BoxFit.contain,
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'WELCOME TO ONEVEST',
            style: pixelTeal,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 18),

          Text(
            'CREATE YOUR\nONEVEST ACCOUNT',
            textAlign: TextAlign.center,
            style: GoogleFonts.pressStart2p(
              color: white,
              fontSize: 17,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            'Start building your smarter financial future.',
            textAlign: TextAlign.center,
            style: bodyMuted.copyWith(
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DETAILS CARD
  // ============================================================

  Widget buildDetailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YOUR DETAILS',
            style: GoogleFonts.pressStart2p(
              color: teal,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'Tell OneVest a little about yourself.',
            style: bodyMuted,
          ),

          const SizedBox(height: 30),

          // NAME
          buildField(
            label: 'Full Name',
            hint: 'Enter your full name',
            icon: Icons.person_outline_rounded,
            controller: nameController,
          ),

          const SizedBox(height: 22),

          // EMAIL
          buildField(
            label: 'Email',
            hint: 'Enter your email',
            icon: Icons.email_outlined,
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
          ),

          const SizedBox(height: 22),

          // PHONE
          buildField(
            label: 'Phone Number',
            hint: 'Enter your phone number',
            icon: Icons.phone_outlined,
            controller: phoneController,
            keyboardType: TextInputType.phone,
          ),

          const SizedBox(height: 22),

          // RISK PROFILE
          Text(
            'RISK PROFILE',
            style: pixelSmall,
          ),

          const SizedBox(height: 10),

          DropdownButtonFormField<String>(
            initialValue: riskProfile,
            dropdownColor: panel2,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: muted,
            ),
            style: GoogleFonts.spaceGrotesk(
              color: white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            decoration: fieldDecoration(
              hint: 'Select risk profile',
              icon: Icons.show_chart_rounded,
            ),
            items: const [
              DropdownMenuItem(
                value: 'Low',
                child: Text('Low'),
              ),
              DropdownMenuItem(
                value: 'Medium',
                child: Text('Medium'),
              ),
              DropdownMenuItem(
                value: 'High',
                child: Text('High'),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                riskProfile = value;
              });
            },
          ),

          const SizedBox(height: 22),

          // PASSWORD
          buildField(
            label: 'Password',
            hint: 'Create a password',
            icon: Icons.lock_outline_rounded,
            controller: passwordController,
            obscureText: hidePassword,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  hidePassword = !hidePassword;
                });
              },
              icon: Icon(
                hidePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: muted,
              ),
            ),
          ),

          const SizedBox(height: 22),

          // CONFIRM PASSWORD
          buildField(
            label: 'Confirm Password',
            hint: 'Re-enter your password',
            icon: Icons.lock_reset_outlined,
            controller: confirmPasswordController,
            obscureText: hideConfirmPassword,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  hideConfirmPassword = !hideConfirmPassword;
                });
              },
              icon: Icon(
                hideConfirmPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: muted,
              ),
            ),
          ),

          const SizedBox(height: 30),

          // CREATE ACCOUNT
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              onPressed: isLoading ? null : signUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: teal,
                disabledBackgroundColor:
                    teal.withValues(alpha: 0.4),
                foregroundColor: bg,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: bg,
                      ),
                    )
                  : Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Text(
                          'CREATE ACCOUNT',
                          style: GoogleFonts.pressStart2p(
                            color: bg,
                            fontSize: 9,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: bg,
                        ),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 24),

          // LOGIN
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                );
              },
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Already have an account?  ',
                      style: bodyMuted.copyWith(
                        fontSize: 13,
                      ),
                    ),
                    TextSpan(
                      text: 'LOGIN',
                      style: GoogleFonts.pressStart2p(
                        color: teal,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECURITY CARD
  // ============================================================

  Widget buildSecurityNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF082B35),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: teal.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: tealDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.security_rounded,
              color: teal,
              size: 21,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'ONEVEST SECURITY',
                  style: pixelSmall.copyWith(
                    color: teal,
                    fontSize: 8,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Your account information is protected.',
                  style: bodyMuted.copyWith(
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

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,

      body: SafeArea(
        child: Column(
          children: [
            // TOP HEADER
            buildTopBar(),

            const Divider(
              height: 1,
              color: Color(0xFF16243D),
            ),

            // PAGE
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final bool desktop =
                      constraints.maxWidth >= 850;

                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal:
                          desktop ? 40 : 16,
                      vertical: 24,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 820,
                        ),
                        child: Column(
                          children: [
                            buildHero(),

                            const SizedBox(height: 26),

                            buildDetailsCard(),

                            const SizedBox(height: 18),

                            buildSecurityNote(),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }
}
