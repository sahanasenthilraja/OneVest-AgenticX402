import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/auth_service.dart';
import 'dashboard_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final AuthService authService = AuthService();

  bool hidePassword = true;
  bool isLoading = false;

  late AnimationController _floatingController;
  late AnimationController _entryController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  // ==========================================================
  // LOGIN
  // ==========================================================

  Future<void> login() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please enter email and password",
          ),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    String? error = await authService.login(
      email: emailController.text,
      password: passwordController.text,
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (error == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
        ),
      );
    }
  }

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void initState() {
    super.initState();

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<double>(
      begin: 20,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: Curves.easeOutCubic,
      ),
    );

    _entryController.forward();
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    _floatingController.dispose();
    _entryController.dispose();

    super.dispose();
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020B1D),

      body: _PixelCursor(
        child: Stack(
          children: [
            // ==================================================
            // BACKGROUND
            // ==================================================

            const Positioned.fill(
              child: _PixelBackground(),
            ),

            // ==================================================
            // MAIN CONTENT
            // ==================================================

            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 40,
                  ),
                  child: AnimatedBuilder(
                    animation: _entryController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeAnimation.value,
                        child: Transform.translate(
                          offset: Offset(
                            0,
                            _slideAnimation.value,
                          ),
                          child: child,
                        ),
                      );
                    },
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 520,
                      ),
                      child: Column(
                        children: [
                          // ==================================================
                          // ONEVEST LOGO
                          // ==================================================

                          _animatedLogo(),

                          const SizedBox(height: 34),

                          // ==================================================
                          // WELCOME BACK
                          // ==================================================

                          Text(
                            "Welcome Back",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.pressStart2p(
                              color: Colors.white,
                              fontSize: 25,
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 14),

                          // ==================================================
                          // SUBTITLE
                          // ==================================================

                          Text(
                            "Invest smarter. Build wealth with confidence.",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.spaceMono(
                              color: const Color(0xFFB7BED3),
                              fontSize: 14,
                              height: 1.6,
                            ),
                          ),

                          const SizedBox(height: 38),

                          // ==================================================
                          // EMAIL
                          // ==================================================

                          _pixelTextField(
                            controller: emailController,
                            hintText: "Email",
                            prefixIcon:
                                Icons.alternate_email_rounded,
                          ),

                          const SizedBox(height: 18),

                          // ==================================================
                          // PASSWORD
                          // ==================================================

                          _pixelTextField(
                            controller: passwordController,
                            hintText: "Password",
                            prefixIcon:
                                Icons.lock_outline_rounded,
                            obscureText: hidePassword,
                            suffixIcon: IconButton(
                              mouseCursor:
                                  SystemMouseCursors.none,
                              icon: Icon(
                                hidePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color:
                                    const Color(0xFFB7BED3),
                                size: 21,
                              ),
                              onPressed: () {
                                setState(() {
                                  hidePassword =
                                      !hidePassword;
                                });
                              },
                            ),
                          ),

                          const SizedBox(height: 30),

                          // ==================================================
                          // SIGN IN BUTTON
                          // ==================================================

                          _signInButton(),

                          const SizedBox(height: 18),

                          // ==================================================
                          // FORGOT PASSWORD
                          // ==================================================

                          MouseRegion(
                            cursor:
                                SystemMouseCursors.none,
                            child: TextButton(
                              onPressed: () {
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Forgot Password feature coming soon!",
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                "Forgot Password?",
                                style:
                                    GoogleFonts.pressStart2p(
                                  color:
                                      const Color(0xFF14C8B0),
                                  fontSize: 8,
                                ),
                              ),
                            ),
                          ),

                          // ==================================================
                          // CREATE ACCOUNT
                          // ==================================================

                          MouseRegion(
                            cursor:
                                SystemMouseCursors.none,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const SignupScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                "Create Account",
                                style:
                                    GoogleFonts.pressStart2p(
                                  color:
                                      const Color(0xFF14C8B0),
                                  fontSize: 9,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 22),

                          // ==================================================
                          // STATUS
                          // ==================================================

                          _animatedStatus(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // ANIMATED ONEVEST LOGO
  // ==========================================================

  Widget _animatedLogo() {
    return AnimatedBuilder(
      animation: _floatingController,
      builder: (context, child) {
        final movement =
            math.sin(
              _floatingController.value *
                  math.pi *
                  2,
            ) *
            3;

        return Transform.translate(
          offset: Offset(
            0,
            movement,
          ),
          child: child,
        );
      },
      child: Image.asset(
        "assets/images/onevest_logo.png",
        height: 115,
        fit: BoxFit.contain,
      ),
    );
  }

  // ==========================================================
  // EMAIL / PASSWORD FIELD
  // ==========================================================

  Widget _pixelTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return MouseRegion(
      // Hide normal mouse cursor.
      cursor: SystemMouseCursors.none,
      opaque: false,

      child: Container(
        decoration: BoxDecoration(
          // Professional dark-blue field.
          color: const Color(0xFF111F36),

          // Rounded corners only.
          borderRadius: BorderRadius.circular(14),

          // Very subtle border.
          border: Border.all(
            color: const Color(0xFF263A56),
            width: 1,
          ),
        ),

        child: TextField(
          controller: controller,
          obscureText: obscureText,

          // ==================================================
          // MOUSE CURSOR
          // ==================================================

          // Hide the normal I-beam mouse pointer.
          // Our pixel cursor will remain visible.
          mouseCursor: SystemMouseCursors.none,

          // ==================================================
          // TYPING CARET
          // ==================================================

          // KEEP THIS VISIBLE.
          // This is the blinking teal line that appears
          // when the user clicks inside the field.
          cursorColor: const Color(0xFF14C8B0),

          cursorWidth: 2.0,

          cursorRadius:
              const Radius.circular(1),

          cursorHeight: 22,

          // ==================================================
          // TEXT
          // ==================================================

          style: GoogleFonts.spaceMono(
            color: Colors.white,
            fontSize: 14,
          ),

          // ==================================================
          // FIELD DECORATION
          // ==================================================

          decoration: InputDecoration(
            hintText: hintText,

            hintStyle: GoogleFonts.spaceMono(
              color: const Color(0xFF8A96AA),
              fontSize: 14,
            ),

            prefixIcon: Icon(
              prefixIcon,
              color: const Color(0xFF8290A8),
              size: 21,
            ),

            suffixIcon: suffixIcon,

            filled: false,

            border: InputBorder.none,

            enabledBorder:
                InputBorder.none,

            focusedBorder:
                InputBorder.none,

            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 19,
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // SIGN IN BUTTON
  // ==========================================================

  Widget _signInButton() {
    return _AnimatedSignInButton(
      isLoading: isLoading,
      onPressed:
          isLoading ? null : login,
    );
  }

  // ==========================================================
  // SMALL STATUS
  // ==========================================================

  Widget _animatedStatus() {
    return AnimatedBuilder(
      animation: _floatingController,
      builder: (context, child) {
        final opacity =
            0.45 +
            (
                  math.sin(
                    _floatingController.value *
                        math.pi *
                        2,
                  ) +
                  1
                ) *
                0.20;

        return Opacity(
          opacity: opacity,
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Container(
                width: 5,
                height: 5,
                color:
                    const Color(0xFF14C8B0),
              ),

              const SizedBox(width: 8),

              Text(
                "ONEVEST",
                style:
                    GoogleFonts.pressStart2p(
                  color:
                      const Color(0xFF6D7890),
                  fontSize: 6,
                ),
              ),

              const SizedBox(width: 8),

              Container(
                width: 5,
                height: 5,
                color:
                    const Color(0xFF8B5CF6),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ==========================================================
// ANIMATED SIGN IN BUTTON
// ==========================================================

class _AnimatedSignInButton
    extends StatefulWidget {
  final bool isLoading;
  final VoidCallback? onPressed;

  const _AnimatedSignInButton({
    required this.isLoading,
    required this.onPressed,
  });

  @override
  State<_AnimatedSignInButton>
      createState() =>
          _AnimatedSignInButtonState();
}

class _AnimatedSignInButtonState
    extends State<_AnimatedSignInButton> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      // Keep browser cursor hidden.
      cursor: SystemMouseCursors.none,

      onEnter: (_) {
        if (!widget.isLoading) {
          setState(() {
            hovering = true;
          });
        }
      },

      onExit: (_) {
        setState(() {
          hovering = false;
        });
      },

      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 160),

        transform:
            Matrix4.translationValues(
          0,
          hovering && !widget.isLoading
              ? -3
              : 0,
          0,
        ),

        decoration: BoxDecoration(
          boxShadow: hovering
              ? [
                  BoxShadow(
                    color:
                        const Color(0xFF14C8B0)
                            .withValues(
                      alpha: 0.30,
                    ),
                    blurRadius: 18,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),

        child: SizedBox(
          width: double.infinity,
          height: 58,

          child: ElevatedButton(
            onPressed:
                widget.onPressed,

            style:
                ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(0xFF14C8B0),

              foregroundColor:
                  Colors.white,

              disabledBackgroundColor:
                  const Color(0xFF0C766C),

              elevation: 0,

              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(14),
              ),
            ),

            child: widget.isLoading
                ? const SizedBox(
                    width: 21,
                    height: 21,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    "Sign In",
                    style:
                        GoogleFonts.pressStart2p(
                      fontSize: 11,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// ==========================================================
// PIXEL BACKGROUND
// ==========================================================

class _PixelBackground
    extends StatefulWidget {
  const _PixelBackground();

  @override
  State<_PixelBackground>
      createState() =>
          _PixelBackgroundState();
}

class _PixelBackgroundState
    extends State<_PixelBackground>
    with
        SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(
      vsync: this,
      duration:
          const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: controller,
        builder: (
          context,
          child,
        ) {
          return CustomPaint(
            painter:
                _PixelParticlePainter(
              controller.value,
            ),
          );
        },
      ),
    );
  }
}

// ==========================================================
// PIXEL PARTICLES
// ==========================================================

class _PixelParticlePainter
    extends CustomPainter {
  final double animation;

  _PixelParticlePainter(
    this.animation,
  );

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final random =
        math.Random(42);

    for (int i = 0; i < 35; i++) {
      final x =
          random.nextDouble() *
              size.width;

      final baseY =
          random.nextDouble() *
              size.height;

      final movement =
          math.sin(
                animation *
                        math.pi *
                        2 +
                    i,
              ) *
              8;

      final y =
          baseY + movement;

      final pixelSize =
          i % 3 == 0 ? 3.0 : 2.0;

      final opacity =
          0.05 +
          random.nextDouble() * 0.12;

      final color = i % 2 == 0
          ? const Color(0xFF14C8B0)
          : const Color(0xFF8B5CF6);

      final paint = Paint()
        ..color = color.withValues(
          alpha: opacity,
        );

      canvas.drawRect(
        Rect.fromLTWH(
          x,
          y,
          pixelSize,
          pixelSize,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant
        _PixelParticlePainter
            oldDelegate,
  ) {
    return oldDelegate.animation !=
        animation;
  }
}

// ==========================================================
// CUSTOM PIXEL CURSOR
// ==========================================================

class _PixelCursor
    extends StatefulWidget {
  final Widget child;

  const _PixelCursor({
    required this.child,
  });

  @override
  State<_PixelCursor> createState() =>
      _PixelCursorState();
}

class _PixelCursorState
    extends State<_PixelCursor> {
  Offset mousePosition =
      Offset.zero;

  bool isInside = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      // Hide browser cursor.
      cursor: SystemMouseCursors.none,

      opaque: false,

      onEnter: (event) {
        setState(() {
          isInside = true;
          mousePosition =
              event.position;
        });
      },

      onHover: (event) {
        setState(() {
          mousePosition =
              event.position;
        });
      },

      onExit: (_) {
        setState(() {
          isInside = false;
        });
      },

      child: Stack(
        children: [
          widget.child,

          if (isInside)
            Positioned(
              left: mousePosition.dx,
              top: mousePosition.dy,

              child: IgnorePointer(
                child: MouseRegion(
                  cursor:
                      SystemMouseCursors.none,

                  opaque: false,

                  child: Transform.translate(
                    offset:
                        const Offset(2, 2),

                    child:
                        const _PixelArrowCursor(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ==========================================================
// PIXEL ARROW
// ==========================================================

class _PixelArrowCursor
    extends StatelessWidget {
  const _PixelArrowCursor();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size:
          const Size(28, 32),

      painter:
          const _PixelArrowPainter(),
    );
  }
}

// ==========================================================
// PIXEL ARROW PAINTER
// ==========================================================

class _PixelArrowPainter
    extends CustomPainter {
  const _PixelArrowPainter();

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    // ======================================================
    // DARK OUTLINE
    // ======================================================

    final outlinePaint =
        Paint()
          ..color =
              const Color(0xFF020B1D);

    final outlinePath =
        Path();

    outlinePath.moveTo(2, 1);
    outlinePath.lineTo(2, 27);
    outlinePath.lineTo(9, 22);
    outlinePath.lineTo(15, 31);
    outlinePath.lineTo(21, 27);
    outlinePath.lineTo(16, 19);
    outlinePath.lineTo(25, 18);
    outlinePath.close();

    canvas.drawPath(
      outlinePath,
      outlinePaint,
    );

    // ======================================================
    // WHITE PIXEL ARROW
    // ======================================================

    final cursorPaint =
        Paint()
          ..color =
              Colors.white;

    final cursorPath =
        Path();

    cursorPath.moveTo(5, 4);
    cursorPath.lineTo(5, 23);
    cursorPath.lineTo(11, 19);
    cursorPath.lineTo(16, 27);
    cursorPath.lineTo(19, 25);
    cursorPath.lineTo(14, 17);
    cursorPath.lineTo(22, 16);
    cursorPath.close();

    canvas.drawPath(
      cursorPath,
      cursorPaint,
    );

    // ======================================================
    // TEAL PIXEL ACCENT
    // ======================================================

    final accentPaint =
        Paint()
          ..color =
              const Color(0xFF14C8B0);

    canvas.drawRect(
      const Rect.fromLTWH(
        7,
        7,
        3,
        3,
      ),
      accentPaint,
    );

    canvas.drawRect(
      const Rect.fromLTWH(
        7,
        11,
        3,
        3,
      ),
      accentPaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant
        _PixelArrowPainter
            oldDelegate,
  ) {
    return false;
  }
}