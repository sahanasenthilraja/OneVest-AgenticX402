import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AICoachScreen extends StatefulWidget {
  const AICoachScreen({super.key});

  @override
  State<AICoachScreen> createState() => _AICoachScreenState();
}

class _AICoachScreenState extends State<AICoachScreen> {
  // ============================================================
  // ONEVEST COLORS
  // ============================================================

  static const Color background = Color(0xFF020B1D);
  static const Color panel = Color(0xFF101A31);
  static const Color panel2 = Color(0xFF14223B);

  static const Color teal = Color(0xFF10D8C3);
  static const Color tealDark = Color(0xFF0B3946);

  static const Color green = Color(0xFF48D36B);
  static const Color orange = Color(0xFFFFB340);
  static const Color purple = Color(0xFF9875FF);

  static const Color white = Color(0xFFF4F7FF);
  static const Color muted = Color(0xFF91A4C3);
  static const Color border = Color(0xFF294269);

  // ============================================================
  // MISSION STATE
  // ============================================================

  bool portfolioReviewed = false;
  bool sipInvested = false;
  bool articleRead = false;

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final int completedMissions = [
      portfolioReviewed,
      sipInvested,
      articleRead,
    ].where((bool value) => value).length;

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

                          _buildCoachStatus(),

                          const SizedBox(height: 22),

                          _buildAdviceCard(),

                          const SizedBox(height: 22),

                          _buildMissionCard(
                            completedMissions,
                          ),

                          const SizedBox(height: 22),

                          _buildQuoteCard(),

                          const SizedBox(height: 22),

                          _buildCoachFooter(),
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
                Icons.smart_toy_rounded,
                color: teal,
                size: 25,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                'AI INVESTMENT COACH',
                style: GoogleFonts.pressStart2p(
                  color: white,
                  fontSize: 9,
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
                      color: green,
                      shape: BoxShape.circle,
                    ),
                  ),

                  const SizedBox(width: 7),

                  Text(
                    'COACH ONLINE',
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
              Icons.smart_toy_rounded,
              color: teal,
              size: 52,
            ),
          );

          final Widget text = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ONEVEST AI // COACH MODE',
                style: GoogleFonts.pressStart2p(
                  color: teal,
                  fontSize: 7,
                ),
              ),

              const SizedBox(height: 15),

              Text(
                'COACH ARIA.\nYOUR MONEY MENTOR.',
                style: GoogleFonts.pressStart2p(
                  color: white,
                  fontSize: small ? 12 : 16,
                  height: 1.75,
                ),
              ),

              const SizedBox(height: 14),

              Text(
                'Personal guidance, daily missions and smarter investing habits — one step at a time.',
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
  // COACH STATUS
  // ============================================================

  Widget _buildCoachStatus() {
    return Container(
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: teal.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.psychology_rounded,
              color: teal,
              size: 28,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'COACH ARIA',
                  style: GoogleFonts.pressStart2p(
                    color: white,
                    fontSize: 8,
                  ),
                ),

                const SizedBox(height: 9),

                Text(
                  'Monitoring your investing habits',
                  style: GoogleFonts.pressStart2p(
                    color: muted,
                    fontSize: 6,
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
                color: green.withValues(alpha: 0.30),
              ),
            ),
            child: Text(
              'ACTIVE',
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
  // TODAY'S ADVICE
  // ============================================================

  Widget _buildAdviceCard() {
    return Container(
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: teal.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: teal.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.tips_and_updates_rounded,
                  color: teal,
                  size: 25,
                ),
              ),

              const SizedBox(width: 14),

              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    "TODAY'S ADVICE",
                    style: GoogleFonts.pressStart2p(
                      color: teal,
                      fontSize: 7,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Small moves. Better habits.',
                    style: GoogleFonts.pressStart2p(
                      color: muted,
                      fontSize: 5,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 22),

          _adviceRow(
            icon: Icons.check_circle_rounded,
            text: 'Continue your monthly SIP.',
          ),

          _adviceRow(
            icon: Icons.check_circle_rounded,
            text: 'Increase Gold allocation by 5%.',
          ),

          _adviceRow(
            icon: Icons.check_circle_rounded,
            text: 'Avoid panic selling during volatility.',
          ),
        ],
      ),
    );
  }

  Widget _adviceRow({
    required IconData icon,
    required String text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: panel2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: border,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: green,
            size: 21,
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Text(
              text,
              style: GoogleFonts.pressStart2p(
                color: white,
                fontSize: 6,
                height: 1.7,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TODAY'S MISSION
  // ============================================================

  Widget _buildMissionCard(
    int completedMissions,
  ) {
    final double progress =
        completedMissions / 3;

    return Container(
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: orange.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: orange.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.flag_rounded,
                  color: orange,
                  size: 25,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      "TODAY'S MISSION",
                      style: GoogleFonts.pressStart2p(
                        color: orange,
                        fontSize: 7,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      '$completedMissions / 3 COMPLETED',
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

          const SizedBox(height: 18),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: border,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(
                orange,
              ),
            ),
          ),

          const SizedBox(height: 20),

          _missionTile(
            title: 'Review your portfolio',
            completed: portfolioReviewed,
            onChanged: (bool value) {
              setState(() {
                portfolioReviewed = value;
              });
            },
          ),

          _missionTile(
            title: 'Invest ₹500 through SIP',
            completed: sipInvested,
            onChanged: (bool value) {
              setState(() {
                sipInvested = value;
              });
            },
          ),

          _missionTile(
            title: 'Read one finance article',
            completed: articleRead,
            onChanged: (bool value) {
              setState(() {
                articleRead = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _missionTile({
    required String title,
    required bool completed,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: completed
            ? green.withValues(alpha: 0.08)
            : panel2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: completed
              ? green.withValues(alpha: 0.35)
              : border,
        ),
      ),
      child: CheckboxListTile(
        value: completed,
        onChanged: (bool? value) {
          onChanged(value ?? false);
        },
        activeColor: green,
        checkColor: background,
        controlAffinity:
            ListTileControlAffinity.leading,
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 10,
        ),
        title: Text(
          title,
          style: GoogleFonts.pressStart2p(
            color: completed ? green : white,
            fontSize: 6,
            height: 1.7,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // QUOTE
  // ============================================================

  Widget _buildQuoteCard() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF211B3B),
            Color(0xFF131B34),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: purple.withValues(alpha: 0.40),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: purple.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.format_quote_rounded,
              color: purple,
              size: 29,
            ),
          ),

          const SizedBox(height: 18),

          Text(
            'QUOTE OF THE DAY',
            style: GoogleFonts.pressStart2p(
              color: purple,
              fontSize: 7,
            ),
          ),

          const SizedBox(height: 18),

          Text(
            '"The stock market is a device for transferring money from the impatient to the patient."',
            textAlign: TextAlign.center,
            style: GoogleFonts.pressStart2p(
              color: white,
              fontSize: 7,
              height: 2.0,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            '— WARREN BUFFETT',
            style: GoogleFonts.pressStart2p(
              color: muted,
              fontSize: 5,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FOOTER
  // ============================================================

  Widget _buildCoachFooter() {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: panel2,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: border,
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            color: teal,
            size: 20,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              'Coach Aria provides AI-generated educational '
              'guidance. Always verify information before '
              'making financial decisions.',
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