import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RoastScreen extends StatefulWidget {
  const RoastScreen({super.key});

  @override
  State<RoastScreen> createState() => _RoastScreenState();
}

class _RoastScreenState extends State<RoastScreen> {
  // ============================================================
  // ONEVEST COLORS
  // ============================================================

  static const Color background = Color(0xFF020B1D);
  static const Color panel = Color(0xFF101A31);
  static const Color panelLight = Color(0xFF162440);

  static const Color teal = Color(0xFF10D8C3);
  static const Color tealDark = Color(0xFF0B3946);

  static const Color orange = Color(0xFFFFB340);

  static const Color white = Color(0xFFF4F7FF);
  static const Color muted = Color(0xFF91A4C3);

  static const Color border = Color(0xFF294269);

  // ============================================================
  // ROAST DATA
  // ============================================================

  final List<Map<String, String>> roasts = [
    {
      'emoji': '😂',
      'roast':
          'Your portfolio has more Crypto than common sense.\nMaybe let Mutual Funds join the conversation.',
      'advice':
          'Reduce Crypto exposure and consider increasing diversified investments for better portfolio stability.',
      'tag': 'SPICY',
    },
    {
      'emoji': '🤣',
      'roast':
          'You invested ₹500 in Gold.\nInflation probably did not even notice.',
      'advice':
          'Review your Gold allocation and make sure it has a meaningful role in your overall diversification strategy.',
      'tag': 'MEDIUM',
    },
    {
      'emoji': '😅',
      'roast':
          'Your SIP consistency deserves an award.\nYour future self is already smiling.',
      'advice':
          'Keep your SIP going and review your goals periodically instead of trying to perfectly time the market.',
      'tag': 'WHOLESOME',
    },
    {
      'emoji': '🔥',
      'roast':
          'Calling this diversified is like calling one pizza topping a buffet.',
      'advice':
          'Consider spreading your investments across different asset classes and sectors to reduce concentration risk.',
      'tag': 'BRUTAL',
    },
    {
      'emoji': '😎',
      'roast':
          'I came prepared to destroy this portfolio...\nBut there is almost nothing to roast.\nNice portfolio!',
      'advice':
          'Keep reviewing your allocation periodically and rebalance when your portfolio moves away from your target mix.',
      'tag': 'IMPRESSED',
    },
  ];

  int roastIndex = 0;

  // ============================================================
  // NEXT ROAST
  // ============================================================

  void nextRoast() {
    if (roasts.isEmpty) {
      return;
    }

    setState(() {
      roastIndex = (roastIndex + 1) % roasts.length;
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final Map<String, String> current = roasts[roastIndex];

    final String emoji = current['emoji'] ?? '🔥';

    final String roast = current['roast'] ??
        'Your portfolio is currently too mysterious to roast.';

    final String advice = current['advice'] ??
        'Review your portfolio allocation and investment goals.';

    final String tag = current['tag'] ?? 'ROAST';

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),

            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 1100,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        24,
                        10,
                        24,
                        35,
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.stretch,
                        children: [
                          _buildHero(),

                          const SizedBox(height: 22),

                          _buildRoastCard(
                            emoji: emoji,
                            roast: roast,
                            tag: tag,
                          ),

                          const SizedBox(height: 18),

                          _buildAdviceCard(
                            advice: advice,
                          ),

                          const SizedBox(height: 22),

                          _buildRoastButton(),

                          const SizedBox(height: 16),

                          _buildDisclaimer(),
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

  // ============================================================
  // TOP BAR
  // ============================================================

  Widget _buildTopBar(BuildContext context) {
    return SizedBox(
      height: 68,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: white,
                size: 30,
              ),
            ),

            const SizedBox(width: 5),

            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: tealDark,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: teal.withValues(alpha: 0.45),
                ),
              ),
              child: const Icon(
                Icons.local_fire_department_rounded,
                color: orange,
                size: 25,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                'AI ROAST MODE',
                style: GoogleFonts.pressStart2p(
                  color: white,
                  fontSize: 10,
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 11,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: tealDark,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: teal.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
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
                    'AI ONLINE',
                    style: GoogleFonts.pressStart2p(
                      color: teal,
                      fontSize: 5,
                    ),
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
  // HERO
  // ============================================================

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF162D47),
            Color(0xFF0D1830),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: orange.withValues(alpha: 0.45),
        ),
      ),
      child: LayoutBuilder(
        builder: (
          BuildContext context,
          BoxConstraints constraints,
        ) {
          final bool small = constraints.maxWidth < 650;

          final Widget fireIcon = Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: orange.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: orange.withValues(alpha: 0.45),
              ),
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              color: orange,
              size: 46,
            ),
          );

          final Widget text = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ONEVEST AI // ROAST ENGINE',
                style: GoogleFonts.pressStart2p(
                  color: orange,
                  fontSize: 7,
                ),
              ),

              const SizedBox(height: 15),

              Text(
                'YOUR PORTFOLIO.\nNO MERCY.',
                style: GoogleFonts.pressStart2p(
                  color: white,
                  fontSize: small ? 13 : 17,
                  height: 1.7,
                ),
              ),

              const SizedBox(height: 13),

              Text(
                'AI-powered portfolio observations with a little extra fire.',
                style: GoogleFonts.pressStart2p(
                  color: muted,
                  fontSize: 7,
                  height: 1.8,
                ),
              ),
            ],
          );

          if (small) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                fireIcon,

                const SizedBox(height: 20),

                text,
              ],
            );
          }

          return Row(
            children: [
              fireIcon,

              const SizedBox(width: 25),

              Expanded(
                child: text,
              ),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // ROAST CARD
  // ============================================================

  Widget _buildRoastCard({
    required String emoji,
    required String roast,
    required String tag,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        28,
        24,
        28,
        28,
      ),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: orange.withValues(alpha: 0.45),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // HEADER
          Row(
            children: [
              Text(
                'ROAST OF THE DAY',
                style: GoogleFonts.pressStart2p(
                  color: muted,
                  fontSize: 7,
                ),
              ),

              const Spacer(),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: orange.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: orange.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  tag,
                  style: GoogleFonts.pressStart2p(
                    color: orange,
                    fontSize: 5,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // FIRE ICON
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: orange.withValues(alpha: 0.09),
              shape: BoxShape.circle,
              border: Border.all(
                color: orange.withValues(alpha: 0.35),
              ),
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              color: orange,
              size: 42,
            ),
          ),

          const SizedBox(height: 25),

          // ==================================================
          // ROAST EMOJI
          // ==================================================

          Text(
            emoji,
            style: const TextStyle(
              fontSize: 34,
            ),
          ),

          const SizedBox(height: 17),

          // ==================================================
          // ROAST TEXT
          // SAME ONEVEST PIXEL FONT
          // ==================================================

          Text(
            roast,
            textAlign: TextAlign.center,
            softWrap: true,
            style: GoogleFonts.pressStart2p(
              color: white,
              fontSize: 8,
              height: 2.0,
            ),
          ),

          const SizedBox(height: 4),
        ],
      ),
    );
  }

  // ============================================================
  // AI ADVICE
  // ============================================================

  Widget _buildAdviceCard({
    required String advice,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: tealDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: teal.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: teal.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.lightbulb_outline_rounded,
              color: teal,
              size: 29,
            ),
          ),

          const SizedBox(width: 17),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'OKAY, NOW THE USEFUL PART',
                  style: GoogleFonts.pressStart2p(
                    color: teal,
                    fontSize: 7,
                  ),
                ),

                const SizedBox(height: 15),

                // BIGGER ADVICE FONT
                Text(
                  advice,
                  softWrap: true,
                  style: GoogleFonts.pressStart2p(
                    color: white,
                    fontSize: 7,
                    height: 2.0,
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
  // ROAST AGAIN BUTTON
  // ============================================================

  Widget _buildRoastButton() {
    return SizedBox(
      width: double.infinity,
      height: 62,
      child: ElevatedButton(
        onPressed: nextRoast,
        style: ElevatedButton.styleFrom(
          backgroundColor: orange,
          foregroundColor: background,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.refresh_rounded,
              size: 23,
            ),

            const SizedBox(width: 12),

            Text(
              'ROAST ME AGAIN',
              style: GoogleFonts.pressStart2p(
                color: background,
                fontSize: 7,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DISCLAIMER
  // ============================================================

  Widget _buildDisclaimer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: panelLight,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: muted,
            size: 19,
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Text(
              'AI roasts are for entertainment and educational purposes. '
              'Do not make investment decisions based on a roast alone.',
              softWrap: true,
              style: GoogleFonts.pressStart2p(
                color: muted,
                fontSize: 6,
                height: 1.9,
              ),
            ),
          ),
        ],
      ),
    );
  }
}