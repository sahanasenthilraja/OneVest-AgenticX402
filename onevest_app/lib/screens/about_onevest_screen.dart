import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutOneVestScreen extends StatelessWidget {
  const AboutOneVestScreen({super.key});

  static const Color background = Color(0xFF020B1D);
  static const Color surface = Color(0xFF0A1428);
  static const Color surface2 = Color(0xFF0F1D35);
  static const Color border = Color(0xFF243B60);

  static const Color teal = Color(0xFF14C8B0);
  static const Color green = Color(0xFF45E38A);
  static const Color purple = Color(0xFFA86BFF);
  static const Color orange = Color(0xFFFFB52E);

  static const Color white = Color(0xFFF5F8FC);
  static const Color muted = Color(0xFF91A0B8);

  TextStyle heading(
    double size, {
    Color color = white,
    FontWeight weight = FontWeight.w700,
  }) {
    return GoogleFonts.pressStart2p(
      fontSize: size,
      color: color,
      fontWeight: weight,
    );
  }

  TextStyle mono(
    double size, {
    Color color = white,
    FontWeight weight = FontWeight.normal,
    double? height,
  }) {
    return GoogleFonts.spaceMono(
      fontSize: size,
      color: color,
      fontWeight: weight,
      height: height,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,

        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: white,
            size: 28,
          ),
        ),

        title: Text(
          "About OneVest",
          style: heading(16),
        ),
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          final padding =
              constraints.maxWidth >= 1000
                  ? 70.0
                  : constraints.maxWidth >= 700
                      ? 40.0
                      : 18.0;

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              padding,
              18,
              padding,
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
                    _hero(),

                    const SizedBox(height: 30),

                    _sectionTitle(
                      "WHAT IS ONEVEST?",
                      Icons.account_balance_wallet_outlined,
                      teal,
                    ),

                    const SizedBox(height: 14),

                    _descriptionCard(),

                    const SizedBox(height: 30),

                    _sectionTitle(
                      "CORE FEATURES",
                      Icons.auto_awesome_rounded,
                      purple,
                    ),

                    const SizedBox(height: 14),

                    LayoutBuilder(
                      builder:
                          (context, featureConstraints) {
                        final twoColumns =
                            featureConstraints
                                    .maxWidth >=
                                700;

                        final cards = [
                          _feature(
                            Icons.dashboard_rounded,
                            "Portfolio Management",
                            "Track your investments, holdings and overall portfolio position.",
                            teal,
                          ),

                          _feature(
                            Icons.insights_rounded,
                            "Portfolio Analytics",
                            "Understand allocation, performance, goals and portfolio health.",
                            green,
                          ),

                          _feature(
                            Icons.psychology_rounded,
                            "AI Advisor",
                            "Get intelligent insights and personalized investment guidance.",
                            purple,
                          ),

                          _feature(
                            Icons.account_balance_wallet_rounded,
                            "Investment Tracking",
                            "Record purchases and monitor investment values over time.",
                            orange,
                          ),
                        ];

                        if (twoColumns) {
                          return GridView.count(
                            shrinkWrap: true,
                            physics:
                                const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 2.4,
                            children: cards,
                          );
                        }

                        return Column(
                          children: cards
                              .map(
                                (card) => Padding(
                                  padding:
                                      const EdgeInsets.only(
                                    bottom: 14,
                                  ),
                                  child: card,
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),

                    const SizedBox(height: 30),

                    _sectionTitle(
                      "DESIGNED FOR SMARTER INVESTING",
                      Icons.trending_up_rounded,
                      teal,
                    ),

                    const SizedBox(height: 14),

                    _missionCard(),

                    const SizedBox(height: 30),

                    _versionCard(),

                    const SizedBox(height: 40),

                    Center(
                      child: Column(
                        children: [
                          Text(
                            "ONEVEST",
                            style: heading(
                              13,
                              color: teal,
                            ),
                          ),

                          const SizedBox(height: 9),

                          Text(
                            "Smart investing. One portfolio.",
                            style: mono(
                              11,
                              color: muted,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            "Version 1.0.0",
                            style: mono(
                              10,
                              color: muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _hero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF102B47),
            Color(0xFF0A1428),
          ],
        ),

        borderRadius:
            BorderRadius.circular(26),

        border: Border.all(
          color:
              teal.withValues(alpha: 0.22),
        ),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(alpha: 0.20),
            blurRadius: 25,
            offset:
                const Offset(0, 10),
          ),
        ],
      ),

      child: Column(
        children: [
          Container(
            width: 82,
            height: 82,

            decoration: BoxDecoration(
              color:
                  teal.withValues(alpha: 0.10),
              borderRadius:
                  BorderRadius.circular(23),
              border: Border.all(
                color:
                    teal.withValues(alpha: 0.25),
              ),
            ),

            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: teal,
              size: 42,
            ),
          ),

          const SizedBox(height: 20),

          Text(
            "ONEVEST",
            style: heading(
              22,
              color: white,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            "INTELLIGENT INVESTMENT MANAGEMENT",
            textAlign: TextAlign.center,
            style: mono(
              11,
              color: teal,
              weight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            "A smarter way to understand, manage and improve your investment portfolio.",
            textAlign: TextAlign.center,
            style: mono(
              12,
              color: muted,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(
    String title,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 43,
          height: 43,

          decoration: BoxDecoration(
            color:
                color.withValues(alpha: 0.09),
            borderRadius:
                BorderRadius.circular(13),
          ),

          child: Icon(
            icon,
            color: color,
            size: 22,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            title,
            style: mono(
              14,
              color: white,
              weight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _descriptionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        color: surface,
        borderRadius:
            BorderRadius.circular(19),

        border: Border.all(
          color: border,
        ),
      ),

      child: Text(
        "OneVest is an intelligent investment management platform designed to help users understand their portfolio, track investments, analyze performance and make more informed financial decisions.",
        style: mono(
          13,
          color: muted,
          height: 1.7,
        ),
      ),
    );
  }

  Widget _feature(
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: surface,
        borderRadius:
            BorderRadius.circular(18),

        border: Border.all(
          color: border,
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,

            decoration: BoxDecoration(
              color:
                  color.withValues(alpha: 0.09),
              borderRadius:
                  BorderRadius.circular(14),
            ),

            child: Icon(
              icon,
              color: color,
              size: 25,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              mainAxisAlignment:
                  MainAxisAlignment.center,

              children: [
                Text(
                  title,
                  style: mono(
                    13,
                    color: white,
                    weight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  description,
                  maxLines: 3,
                  overflow:
                      TextOverflow.ellipsis,
                  style: mono(
                    10,
                    color: muted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _missionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),

      decoration: BoxDecoration(
        color:
            teal.withValues(alpha: 0.055),

        borderRadius:
            BorderRadius.circular(19),

        border: Border.all(
          color:
              teal.withValues(alpha: 0.18),
        ),
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          const Icon(
            Icons.lightbulb_outline_rounded,
            color: teal,
            size: 29,
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  "OUR MISSION",
                  style: mono(
                    11,
                    color: teal,
                    weight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 9),

                Text(
                  "Make investing easier to understand by bringing portfolio intelligence, analytics and AI-powered guidance together in one place.",
                  style: mono(
                    12,
                    color: muted,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _versionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: surface2,
        borderRadius:
            BorderRadius.circular(17),

        border: Border.all(
          color: border,
        ),
      ),

      child: Row(
        children: [
          const Icon(
            Icons.verified_outlined,
            color: green,
            size: 25,
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Text(
              "OneVest Application",
              style: mono(
                12,
                color: white,
                weight: FontWeight.bold,
              ),
            ),
          ),

          Text(
            "v1.0.0",
            style: mono(
              11,
              color: teal,
              weight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
