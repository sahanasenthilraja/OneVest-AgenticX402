import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Main entrance sequence (logo -> title -> tagline -> loader)
  late final AnimationController _entrance;

  // Continuous ambient motion (ring rotation, glow pulse, background drift)
  late final AnimationController _ambient;

  static const Color background = Color(0xFF020B1D);
  static const Color teal = Color(0xFF10D8C3);
  static const Color blue = Color(0xFF3E7BFA);
  static const Color white = Color(0xFFF4F7FF);
  static const Color muted = Color(0xFF91A4C3);

  @override
  void initState() {
    super.initState();

    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..forward();

    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    Timer(const Duration(milliseconds: 3400), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (_, anim, __) => const LoginScreen(),
          transitionsBuilder: (_, anim, __, child) {
            return FadeTransition(opacity: anim, child: child);
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _entrance.dispose();
    _ambient.dispose();
    super.dispose();
  }

  // Staggered interval helper — carves a sub-timeline out of _entrance
  Animation<double> _stagger(double start, double end, {Curve curve = Curves.easeOutCubic}) {
    return CurvedAnimation(
      parent: _entrance,
      curve: Interval(start, end, curve: curve),
    );
  }

  @override
  Widget build(BuildContext context) {
    final logoFade = _stagger(0.0, 0.45);
    final logoScale = _stagger(0.0, 0.55, curve: Curves.easeOutBack);
    final titleFade = _stagger(0.35, 0.65);
    final titleSlide = _stagger(0.35, 0.7);
    final taglineFade = _stagger(0.55, 0.8);
    final loaderFade = _stagger(0.7, 1.0);

    return Scaffold(
      backgroundColor: background,
      body: AnimatedBuilder(
        animation: Listenable.merge([_entrance, _ambient]),
        builder: (context, _) {
          final t = _ambient.value; // 0..1 looping

          return Stack(
            children: [
              // =====================================================
              // DRIFTING BACKGROUND GLOW (slow parallax breathing)
              // =====================================================
              Positioned(
                top: -140 + 20 * math.sin(t * 2 * math.pi),
                left: -100 + 15 * math.cos(t * 2 * math.pi),
                child: _glowCircle(
                  size: 320,
                  color: teal.withValues(alpha: 0.09),
                ),
              ),
              Positioned(
                bottom: -160 - 20 * math.sin(t * 2 * math.pi),
                right: -110 - 15 * math.cos(t * 2 * math.pi),
                child: _glowCircle(
                  size: 380,
                  color: blue.withValues(alpha: 0.07),
                ),
              ),

              // Rising growth-line streaks — faint echo of the logo's
              // chart bars, drifting upward very slowly
              Positioned.fill(
                child: CustomPaint(
                  painter: _GrowthLinesPainter(
                    progress: t,
                    colors: [teal, blue],
                  ),
                ),
              ),

              // Faint circuit-style dot grid for fintech texture
              Positioned.fill(
                child: CustomPaint(
                  painter: _DotGridPainter(color: white.withValues(alpha: 0.02)),
                ),
              ),

              // =====================================================
              // MAIN CONTENT
              // =====================================================
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // =================================================
                    // LOGO — plain, sits directly on the background,
                    // no glow, no ring, no panel
                    // =================================================
                    FadeTransition(
                      opacity: logoFade,
                      child: ScaleTransition(
                        scale: logoScale,
                        child: SizedBox(
                          width: 118,
                          height: 118,
                          child: Image.asset(
                            'assets/images/onevest_logo.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.account_balance_wallet_rounded,
                                color: teal,
                                size: 56,
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // =================================================
                    // ONEVEST TITLE — fades + rises into place
                    // =================================================
                    FadeTransition(
                      opacity: titleFade,
                      child: Transform.translate(
                        offset: Offset(0, 14 * (1 - titleSlide.value)),
                        child: ShaderMask(
                          shaderCallback: (rect) => const LinearGradient(
                            colors: [white, teal],
                          ).createShader(rect),
                          child: Text(
                            'ONEVEST',
                            style: GoogleFonts.pressStart2p(
                              color: white,
                              fontSize: 24,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // =================================================
                    // TAGLINE
                    // =================================================
                    FadeTransition(
                      opacity: taglineFade,
                      child: Text(
                        'INVEST SMART. GROW TOGETHER.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.pressStart2p(
                          color: teal,
                          fontSize: 7,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 45),

                    // =================================================
                    // LOADING INDICATOR — animated shimmer sweep
                    // =================================================
                    FadeTransition(
                      opacity: loaderFade,
                      child: SizedBox(
                        width: 180,
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: SizedBox(
                                height: 4,
                                child: Stack(
                                  children: [
                                    Container(color: const Color(0xFF1B2943)),
                                    Align(
                                      alignment: Alignment(
                                        -1 + 2 * ((t * 1.6) % 1.0),
                                        0,
                                      ),
                                      child: FractionallySizedBox(
                                        widthFactor: 0.35,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                teal.withValues(alpha: 0.0),
                                                teal,
                                                blue.withValues(alpha: 0.0),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
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
                    ),
                  ],
                ),
              ),

              // =====================================================
              // BOTTOM VERSION — the glow lives here now: a soft
              // pulsing blur sits behind the crisp text
              // =====================================================
              Positioned(
                bottom: 28,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: loaderFade,
                  child: Center(
                    child: _glowText(
                      'ONEVEST AI  •  SMARTER MONEY. SMARTER FUTURE.',
                      style: GoogleFonts.pressStart2p(
                        color: muted.withValues(alpha: 0.75),
                        fontSize: 4,
                      ),
                      glowColor: teal,
                      glowStrength: 0.35 + 0.25 * (0.5 + 0.5 * math.sin(t * 2 * math.pi)),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _glowCircle({required double size, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  // Layers a blurred, colored copy of the text behind the crisp text —
  // this is the one glow left on screen, and it lives on the bottom line
  Widget _glowText(
    String text, {
    required TextStyle style,
    required Color glowColor,
    required double glowStrength,
  }) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ImageFiltered(
          imageFilter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: style.copyWith(
              color: glowColor.withValues(alpha: glowStrength),
            ),
          ),
        ),
        Text(
          text,
          textAlign: TextAlign.center,
          style: style,
        ),
      ],
    );
  }
}

// ============================================================
// Faint upward-drifting growth lines — a quiet nod to the bar-chart
// mark in the logo, moving slowly so the background feels alive
// without competing with the foreground content
// ============================================================
class _GrowthLinesPainter extends CustomPainter {
  final double progress; // 0..1 looping
  final List<Color> colors;
  _GrowthLinesPainter({required this.progress, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(7); // fixed seed = stable layout across frames
    const lineCount = 5;

    for (int i = 0; i < lineCount; i++) {
      final baseX = size.width * (0.08 + i * 0.11) + rng.nextDouble() * 20;
      final drift = (progress + i * 0.17) % 1.0;
      final startY = size.height * (1.15 - drift * 1.3);
      final lineHeight = 70.0 + (i.isEven ? 30 : 0);
      final opacity = (0.05 * (1 - (drift - 0.5).abs() * 1.6)).clamp(0.0, 0.05);

      final paint = Paint()
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            colors[i.isEven ? 0 : 1].withValues(alpha: 0.0),
            colors[i.isEven ? 0 : 1].withValues(alpha: opacity),
          ],
        ).createShader(
          Rect.fromLTWH(baseX, startY - lineHeight, 2, lineHeight),
        );

      canvas.drawLine(
        Offset(baseX, startY),
        Offset(baseX, startY - lineHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GrowthLinesPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// ============================================================
// Faint dot grid background texture
// ============================================================
class _DotGridPainter extends CustomPainter {
  final Color color;
  _DotGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const spacing = 28.0;
    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), 1.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotGridPainter oldDelegate) => false;
}
