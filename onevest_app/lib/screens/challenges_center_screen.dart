import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChallengeCenterScreen extends StatefulWidget {
  const ChallengeCenterScreen({super.key});

  @override
  State<ChallengeCenterScreen> createState() =>
      _ChallengeCenterScreenState();
}

class _ChallengeCenterScreenState
    extends State<ChallengeCenterScreen> {
  // ============================================================
  // ONEVEST THEME
  // ============================================================

  static const Color background = Color(0xFF020B1D);
  static const Color panel = Color(0xFF0E1830);
  static const Color border = Color(0xFF263A56);

  static const Color teal = Color(0xFF14C8B0);
  static const Color tealDark = Color(0xFF0C3942);

  static const Color white = Color(0xFFF5F8FC);
  static const Color muted = Color(0xFF91A0B8);

  static const Color green = Color(0xFF45E38A);
  static const Color orange = Color(0xFFFFB52E);
  static const Color purple = Color(0xFFA86BFF);

  // ============================================================
  // CHALLENGE STATE
  // ============================================================

  bool challenge1 = true;
  bool challenge2 = false;
  bool challenge3 = false;

  int get currentXP {
    int xp = 640;

    if (challenge2) {
      xp += 120;
    }

    if (challenge3) {
      xp += 150;
    }

    return xp > 1000 ? 1000 : xp;
  }

  // ============================================================
  // FONT HELPERS
  // ============================================================

  TextStyle heading(
    double size, {
    Color color = white,
  }) {
    return GoogleFonts.pressStart2p(
      fontSize: size,
      color: color,
      fontWeight: FontWeight.w700,
    );
  }

  TextStyle mono(
    double size, {
    Color color = white,
    FontWeight weight = FontWeight.normal,
  }) {
    return GoogleFonts.spaceMono(
      fontSize: size,
      color: color,
      fontWeight: weight,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final double progress = currentXP / 1000;

    return Scaffold(
      backgroundColor: background,

      // ========================================================
      // APP BAR
      // ========================================================

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
          'CHALLENGE CENTER',
          style: heading(
            12,
            color: white,
          ),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool desktop = constraints.maxWidth >= 800;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: desktop ? 60 : 20,
              vertical: 20,
            ),

            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 1050,
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    // ==================================================
                    // PAGE LABEL
                    // ==================================================

                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),

                      decoration: BoxDecoration(
                        color: teal.withValues(
                          alpha: 0.10,
                        ),
                        borderRadius:
                            BorderRadius.circular(8),
                        border: Border.all(
                          color: teal.withValues(
                            alpha: 0.30,
                          ),
                        ),
                      ),

                      child: Text(
                        'REWARDS // PROGRESS',
                        style: mono(
                          9,
                          color: teal,
                          weight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ==================================================
                    // TITLE
                    // ==================================================

                    Text(
                      'Challenge Center',
                      style: heading(
                        desktop ? 18 : 15,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Complete missions, earn XP and build better investing habits.',
                      style: mono(
                        10,
                        color: muted,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ==================================================
                    // LEVEL CARD
                    // ==================================================

                    _buildLevelCard(progress),

                    const SizedBox(height: 24),

                    // ==================================================
                    // CHALLENGES
                    // ==================================================

                    _sectionHeader(
                      'TODAY\'S CHALLENGES',
                      'Complete missions to earn XP',
                      Icons.flag_rounded,
                    ),

                    const SizedBox(height: 18),

                    _buildChallenge(
                      title: 'Add an Investment',
                      subtitle:
                          'Add your first investment to the portfolio',
                      xp: 100,
                      completed: challenge1,
                      icon: Icons.add_chart_rounded,
                      accent: teal,
                      onChanged: (value) {
                        setState(() {
                          challenge1 = value;
                        });
                      },
                    ),

                    const SizedBox(height: 12),

                    _buildChallenge(
                      title: 'Invest ₹500 through SIP',
                      subtitle:
                          'Build a consistent monthly investment habit',
                      xp: 120,
                      completed: challenge2,
                      icon: Icons.autorenew_rounded,
                      accent: purple,
                      onChanged: (value) {
                        setState(() {
                          challenge2 = value;
                        });
                      },
                    ),

                    const SizedBox(height: 12),

                    _buildChallenge(
                      title: 'Diversify into 4 Assets',
                      subtitle:
                          'Spread your investments across asset classes',
                      xp: 150,
                      completed: challenge3,
                      icon: Icons.pie_chart_rounded,
                      accent: orange,
                      onChanged: (value) {
                        setState(() {
                          challenge3 = value;
                        });
                      },
                    ),

                    const SizedBox(height: 30),

                    // ==================================================
                    // ACHIEVEMENTS
                    // ==================================================

                    _sectionHeader(
                      'ACHIEVEMENTS',
                      'Milestones unlocked through your journey',
                      Icons.emoji_events_rounded,
                    ),

                    const SizedBox(height: 18),

                    Wrap(
                      spacing: 14,
                      runSpacing: 14,
                      children: const [
                        _BadgeCard(
                          emoji: '🥉',
                          title: 'BEGINNER',
                          subtitle: 'First investment',
                          unlocked: true,
                          accent: orange,
                        ),
                        _BadgeCard(
                          emoji: '🥈',
                          title: 'DIVERSIFIED',
                          subtitle: 'Multiple assets',
                          unlocked: true,
                          accent: purple,
                        ),
                        _BadgeCard(
                          emoji: '🥇',
                          title: 'SIP CHAMPION',
                          subtitle: 'Consistent investor',
                          unlocked: true,
                          accent: teal,
                        ),
                        _BadgeCard(
                          emoji: '💎',
                          title: 'WEALTH BUILDER',
                          subtitle: 'Long-term investor',
                          unlocked: false,
                          accent: teal,
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // ==================================================
                    // STREAK
                    // ==================================================

                    _buildStreakCard(),

                    const SizedBox(height: 24),

                    // ==================================================
                    // MOTIVATION
                    // ==================================================

                    _buildMotivationCard(),

                    const SizedBox(height: 30),
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
  // LEVEL CARD
  // ============================================================

  Widget _buildLevelCard(double progress) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),

      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.20,
            ),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,

                decoration: BoxDecoration(
                  color: tealDark,
                  borderRadius:
                      BorderRadius.circular(15),
                  border: Border.all(
                    color: teal.withValues(
                      alpha: 0.35,
                    ),
                  ),
                ),

                child: const Icon(
                  Icons.military_tech_rounded,
                  color: teal,
                  size: 28,
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LEVEL 4 INVESTOR',
                      style: heading(
                        11,
                        color: white,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      '⭐ ⭐ ⭐ ⭐',
                      style: mono(
                        11,
                        color: orange,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                '$currentXP XP',
                style: mono(
                  13,
                  color: teal,
                  weight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'XP PROGRESS',
                style: mono(
                  9,
                  color: muted,
                  weight: FontWeight.bold,
                ),
              ),

              Text(
                '$currentXP / 1000 XP',
                style: mono(
                  9,
                  color: teal,
                  weight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          ClipRRect(
            borderRadius:
                BorderRadius.circular(20),

            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor:
                  Colors.white.withValues(
                alpha: 0.08,
              ),
              color: teal,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            '${1000 - currentXP} XP remaining to Level 5',
            style: mono(
              9,
              color: muted,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION HEADER
  // ============================================================

  Widget _sectionHeader(
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Container(
          width: 42,
          height: 42,

          decoration: BoxDecoration(
            color: teal.withValues(
              alpha: 0.10,
            ),
            borderRadius:
                BorderRadius.circular(12),
            border: Border.all(
              color: teal.withValues(
                alpha: 0.20,
              ),
            ),
          ),

          child: Icon(
            icon,
            color: teal,
            size: 21,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Text(
                title,
                style: heading(
                  10,
                  color: white,
                ),
              ),

              const SizedBox(height: 7),

              Text(
                subtitle,
                style: mono(
                  9,
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
  // CHALLENGE CARD
  // ============================================================

  Widget _buildChallenge({
    required String title,
    required String subtitle,
    required int xp,
    required bool completed,
    required IconData icon,
    required Color accent,
    required ValueChanged<bool> onChanged,
  }) {
    return AnimatedContainer(
      duration:
          const Duration(milliseconds: 250),

      width: double.infinity,

      padding:
          const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: completed
            ? accent.withValues(
                alpha: 0.08,
              )
            : panel,

        borderRadius:
            BorderRadius.circular(18),

        border: Border.all(
          color: completed
              ? accent.withValues(
                  alpha: 0.45,
                )
              : border,
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,

            decoration: BoxDecoration(
              color: accent.withValues(
                alpha: 0.10,
              ),
              borderRadius:
                  BorderRadius.circular(13),
            ),

            child: Icon(
              icon,
              color: accent,
              size: 22,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  style: mono(
                    11,
                    color: white,
                    weight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  subtitle,
                  style: mono(
                    8,
                    color: muted,
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),

                  decoration: BoxDecoration(
                    color: accent.withValues(
                      alpha: 0.10,
                    ),
                    borderRadius:
                        BorderRadius.circular(6),
                  ),

                  child: Text(
                    '+$xp XP',
                    style: mono(
                      8,
                      color: accent,
                      weight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          Checkbox(
            value: completed,

            onChanged: (value) {
              onChanged(
                value ?? false,
              );
            },

            activeColor: accent,
            checkColor: background,

            side: BorderSide(
              color: muted.withValues(
                alpha: 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STREAK CARD
  // ============================================================

  Widget _buildStreakCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        color: panel,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: border,
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,

            decoration: BoxDecoration(
              color: orange.withValues(
                alpha: 0.10,
              ),
              borderRadius:
                  BorderRadius.circular(15),
            ),

            child: const Icon(
              Icons.local_fire_department_rounded,
              color: orange,
              size: 28,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  'WEEKLY STREAK',
                  style: heading(10),
                ),

                const SizedBox(height: 8),

                Text(
                  '7 DAYS',
                  style: mono(
                    14,
                    color: orange,
                    weight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'Keep investing consistently 🔥',
                  style: mono(
                    8,
                    color: muted,
                  ),
                ),
              ],
            ),
          ),

          Row(
            children: List.generate(
              7,
              (index) {
                return Padding(
                  padding:
                      const EdgeInsets.only(
                    left: 5,
                  ),
                  child: Icon(
                    Icons
                        .local_fire_department_rounded,
                    size: 18,
                    color: index < 7
                        ? orange
                        : muted,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MOTIVATION CARD
  // ============================================================

  Widget _buildMotivationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        color: tealDark.withValues(
          alpha: 0.75,
        ),
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: teal.withValues(
            alpha: 0.30,
          ),
        ),
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Container(
            width: 44,
            height: 44,

            decoration: BoxDecoration(
              color: teal.withValues(
                alpha: 0.10,
              ),
              borderRadius:
                  BorderRadius.circular(12),
            ),

            child: const Icon(
              Icons.lightbulb_outline_rounded,
              color: teal,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  'ONEVEST TIP',
                  style: mono(
                    8,
                    color: teal,
                    weight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Small consistent investments can build powerful long-term habits.',
                  style: mono(
                    10,
                    color: white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// BADGE CARD
// ================================================================

class _BadgeCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final bool unlocked;
  final Color accent;

  const _BadgeCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.unlocked,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      padding:
          const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: unlocked
            ? const Color(0xFF0E1830)
            : const Color(0xFF0A1428),

        borderRadius:
            BorderRadius.circular(18),

        border: Border.all(
          color: unlocked
              ? accent.withValues(
                  alpha: 0.35,
                )
              : const Color(
                  0xFF1A2942,
                ),
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

            children: [
              Text(
                emoji,
                style: const TextStyle(
                  fontSize: 30,
                ),
              ),

              if (unlocked)
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 4,
                  ),

                  decoration: BoxDecoration(
                    color: const Color(
                      0xFF45E38A,
                    ).withValues(
                      alpha: 0.10,
                    ),
                    borderRadius:
                        BorderRadius.circular(6),
                  ),

                  child: Text(
                    'UNLOCKED',
                    style: GoogleFonts.spaceMono(
                      color: const Color(
                        0xFF45E38A,
                      ),
                      fontSize: 6,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                )
              else
                const Icon(
                  Icons.lock_outline_rounded,
                  color: Color(0xFF526078),
                  size: 18,
                ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            title,
            style: GoogleFonts.pressStart2p(
              color: unlocked
                  ? Colors.white
                  : const Color(0xFF65728A),
              fontSize: 8,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            subtitle,
            style: GoogleFonts.spaceMono(
              color: unlocked
                  ? const Color(0xFF91A0B8)
                  : const Color(0xFF526078),
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }
}