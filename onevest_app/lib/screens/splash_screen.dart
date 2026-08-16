import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  static const Color background = Color(0xFF020B1D);
  static const Color panel = Color(0xFF101A31);
  static const Color teal = Color(0xFF10D8C3);
  static const Color white = Color(0xFFF4F7FF);
  static const Color muted = Color(0xFF91A4C3);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.75,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _controller.forward();

    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          // =====================================================
          // BACKGROUND GLOW
          // =====================================================

          Positioned(
            top: -120,
            left: -100,
            child: _glowCircle(
              size: 300,
              color: teal.withValues(alpha: 0.08),
            ),
          ),

          Positioned(
            bottom: -150,
            right: -100,
            child: _glowCircle(
              size: 350,
              color: teal.withValues(alpha: 0.05),
            ),
          ),

          // =====================================================
          // MAIN CONTENT
          // =====================================================

          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // =================================================
                    // LOGO
                    // =================================================

                    Container(
                      width: 150,
                      height: 150,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: panel,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: teal.withValues(alpha: 0.55),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: teal.withValues(alpha: 0.12),
                            blurRadius: 35,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/images/onevest_logo.png',
                          fit: BoxFit.contain,
                          errorBuilder: (
                            context,
                            error,
                            stackTrace,
                          ) {
                            return const Icon(
                              Icons.account_balance_wallet_rounded,
                              color: teal,
                              size: 70,
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // =================================================
                    // ONEVEST TITLE
                    // =================================================

                    Text(
                      'ONEVEST',
                      style: GoogleFonts.pressStart2p(
                        color: white,
                        fontSize: 24,
                        letterSpacing: 1.5,
                      ),
                    ),

                    const SizedBox(height: 15),

                    // =================================================
                    // TAGLINE
                    // =================================================

                    Text(
                      'INVEST SMART. GROW TOGETHER.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.pressStart2p(
                        color: teal,
                        fontSize: 7,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 45),

                    // =================================================
                    // LOADING INDICATOR
                    // =================================================

                    SizedBox(
                      width: 180,
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              minHeight: 4,
                              backgroundColor:
                                  const Color(0xFF1B2943),
                              valueColor:
                                  const AlwaysStoppedAnimation<Color>(
                                teal,
                              ),
                            ),
                          ),

                          const SizedBox(height: 15),

                          Text(
                            'INITIALIZING YOUR FINANCIAL HUB...',
                            style: GoogleFonts.pressStart2p(
                              color: muted,
                              fontSize: 5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // =====================================================
          // BOTTOM VERSION
          // =====================================================

          Positioned(
            bottom: 28,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'ONEVEST AI  •  SMARTER MONEY. SMARTER FUTURE.',
                textAlign: TextAlign.center,
                style: GoogleFonts.pressStart2p(
                  color: muted.withValues(alpha: 0.65),
                  fontSize: 4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // GLOW CIRCLE
  // ============================================================

  Widget _glowCircle({
    required double size,
    required Color color,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}