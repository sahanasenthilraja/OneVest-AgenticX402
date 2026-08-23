import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FinancialTwinScreen extends StatelessWidget {
  const FinancialTwinScreen({super.key});

  // ============================================================
  // ONEVEST THEME
  // ============================================================

  static const Color background = Color(0xFF020B1D);
  static const Color panel = Color(0xFF101A31);
  static const Color panel2 = Color(0xFF14223B);

  static const Color teal = Color(0xFF10D8C3);
  static const Color tealDark = Color(0xFF0B3946);

  static const Color green = Color(0xFF48D36B);
  static const Color orange = Color(0xFFFFB340);
  static const Color purple = Color(0xFF9875FF);
  static const Color blue = Color(0xFF5C8CFF);

  static const Color white = Color(0xFFF4F7FF);
  static const Color muted = Color(0xFF91A4C3);
  static const Color border = Color(0xFF294269);

  @override
  Widget build(BuildContext context) {
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
                        40,
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.stretch,
                        children: [
                          _buildHero(),

                          const SizedBox(height: 22),

                          _buildProfileOverview(),

                          const SizedBox(height: 22),

                          _buildMetricsGrid(),

                          const SizedBox(height: 22),

                          _buildStrengthsAndImprovements(),

                          const SizedBox(height: 22),

                          _buildPrediction(),

                          const SizedBox(height: 22),

                          _buildTwinSummary(),
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
        padding: const EdgeInsets.symmetric(horizontal: 14),
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
                Icons.person_rounded,
                color: teal,
                size: 25,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                'FINANCIAL TWIN',
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
          color: teal.withValues(alpha: 0.45),
        ),
      ),
      child: LayoutBuilder(
        builder: (
          BuildContext context,
          BoxConstraints constraints,
        ) {
          final bool small = constraints.maxWidth < 650;

          final Widget avatar = Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: tealDark,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: teal.withValues(alpha: 0.5),
              ),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: teal,
              size: 52,
            ),
          );

          final Widget text = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ONEVEST AI // FINANCIAL TWIN',
                style: GoogleFonts.pressStart2p(
                  color: teal,
                  fontSize: 7,
                ),
              ),

              const SizedBox(height: 15),

              Text(
                'MEET YOUR\nFINANCIAL TWIN.',
                style: GoogleFonts.pressStart2p(
                  color: white,
                  fontSize: small ? 13 : 17,
                  height: 1.7,
                ),
              ),

              const SizedBox(height: 13),

              Text(
                'A snapshot of your investing personality, habits and portfolio health.',
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
                avatar,
                const SizedBox(height: 20),
                text,
              ],
            );
          }

          return Row(
            children: [
              avatar,
              const SizedBox(width: 25),
              Expanded(child: text),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // PROFILE OVERVIEW
  // ============================================================

  Widget _buildProfileOverview() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: tealDark,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.rocket_launch_rounded,
              color: teal,
              size: 29,
            ),
          ),

          const SizedBox(width: 17),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'GROWTH BUILDER',
                  style: GoogleFonts.pressStart2p(
                    color: teal,
                    fontSize: 8,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'You are building wealth with a long-term mindset.',
                  style: GoogleFonts.pressStart2p(
                    color: white,
                    fontSize: 7,
                    height: 1.8,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: green.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: green.withValues(alpha: 0.35),
              ),
            ),
            child: Text(
              'STRONG',
              style: GoogleFonts.pressStart2p(
                color: green,
                fontSize: 5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // METRICS
  // ============================================================

  Widget _buildMetricsGrid() {
    final List<Widget> cards = [
      _metricCard(
        title: 'FINANCIAL AGE',
        value: '22 YEARS',
        icon: Icons.cake_rounded,
        color: orange,
      ),
      _metricCard(
        title: 'PORTFOLIO HEALTH',
        value: '91 / 100',
        icon: Icons.favorite_rounded,
        color: green,
      ),
      _metricCard(
        title: 'RISK APPETITE',
        value: 'MEDIUM',
        icon: Icons.speed_rounded,
        color: blue,
      ),
      _metricCard(
        title: 'INVESTMENT IQ',
        value: '87 / 100',
        icon: Icons.psychology_rounded,
        color: purple,
      ),
    ];

    return LayoutBuilder(
      builder: (
        BuildContext context,
        BoxConstraints constraints,
      ) {
        final bool small = constraints.maxWidth < 700;

        if (small) {
          return Column(
            children: [
              cards[0],
              const SizedBox(height: 14),
              cards[1],
              const SizedBox(height: 14),
              cards[2],
              const SizedBox(height: 14),
              cards[3],
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: cards[0]),
            const SizedBox(width: 14),
            Expanded(child: cards[1]),
            const SizedBox(width: 14),
            Expanded(child: cards[2]),
            const SizedBox(width: 14),
            Expanded(child: cards[3]),
          ],
        );
      },
    );
  }

  Widget _metricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: color.withValues(alpha: 0.30),
                  ),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 22,
                ),
              ),

              const Spacer(),

              Icon(
                Icons.arrow_outward_rounded,
                color: muted,
                size: 17,
              ),
            ],
          ),

          const SizedBox(height: 17),

          Text(
            title,
            style: GoogleFonts.pressStart2p(
              color: muted,
              fontSize: 5,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            value,
            style: GoogleFonts.pressStart2p(
              color: white,
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STRENGTHS + IMPROVEMENTS
  // ============================================================

  Widget _buildStrengthsAndImprovements() {
    return LayoutBuilder(
      builder: (
        BuildContext context,
        BoxConstraints constraints,
      ) {
        final Widget strengths = _buildListCard(
          title: 'YOUR STRENGTHS',
          subtitle: 'What your twin likes about you',
          icon: Icons.check_circle_rounded,
          color: green,
          items: const [
            'Diversified Portfolio',
            'Consistent Investor',
            'Strong Long-term Potential',
            'Good Investment Discipline',
          ],
        );

        final Widget improvements = _buildListCard(
          title: 'NEEDS ATTENTION',
          subtitle: 'Where your twin sees room to grow',
          icon: Icons.warning_amber_rounded,
          color: orange,
          items: const [
            'Increase Gold Allocation',
            'Build an Emergency Fund',
            'Reduce Crypto Exposure',
            'Review Asset Allocation',
          ],
        );

        if (constraints.maxWidth < 700) {
          return Column(
            children: [
              strengths,
              const SizedBox(height: 16),
              improvements,
            ],
          );
        }

        return Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Expanded(child: strengths),
            const SizedBox(width: 16),
            Expanded(child: improvements),
          ],
        );
      },
    );
  }

  Widget _buildListCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required List<String> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 47,
                height: 47,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 25,
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
                      style: GoogleFonts.pressStart2p(
                        color: color,
                        fontSize: 7,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      subtitle,
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

          const SizedBox(height: 20),

          ...items.map(
            (String item) {
              return Padding(
                padding:
                    const EdgeInsets.only(bottom: 13),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Icon(
                      icon,
                      color: color,
                      size: 18,
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        item,
                        style:
                            GoogleFonts.pressStart2p(
                          color: white,
                          fontSize: 6,
                          height: 1.7,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // AI PREDICTION
  // ============================================================

  Widget _buildPrediction() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF103C48),
            Color(0xFF0B2637),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: teal.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: teal.withValues(alpha: 0.10),
              shape: BoxShape.circle,
              border: Border.all(
                color: teal.withValues(alpha: 0.35),
              ),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: teal,
              size: 29,
            ),
          ),

          const SizedBox(height: 18),

          Text(
            'AI FUTURE SNAPSHOT',
            style: GoogleFonts.pressStart2p(
              color: teal,
              fontSize: 8,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'YOUR NEXT CHAPTER LOOKS PROMISING.',
            textAlign: TextAlign.center,
            style: GoogleFonts.pressStart2p(
              color: white,
              fontSize: 9,
              height: 1.8,
            ),
          ),

          const SizedBox(height: 15),

          Text(
            'If you continue investing consistently, '
            'your portfolio could potentially double '
            'within 5–7 years.',
            textAlign: TextAlign.center,
            style: GoogleFonts.pressStart2p(
              color: muted,
              fontSize: 6,
              height: 2.0,
            ),
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 11,
            ),
            decoration: BoxDecoration(
              color: background.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: teal.withValues(alpha: 0.25),
              ),
            ),
            child: Text(
              'CONSISTENCY > TIMING',
              style: GoogleFonts.pressStart2p(
                color: teal,
                fontSize: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FINAL SUMMARY
  // ============================================================

  Widget _buildTwinSummary() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: panel2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: border,
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: muted,
            size: 21,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              'Your Financial Twin is an AI-generated snapshot '
              'based on your investment behaviour and portfolio '
              'patterns. It is intended for educational purposes '
              'and should not be treated as financial advice.',
              style: GoogleFonts.pressStart2p(
                color: muted,
                fontSize: 5,
                height: 2.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
