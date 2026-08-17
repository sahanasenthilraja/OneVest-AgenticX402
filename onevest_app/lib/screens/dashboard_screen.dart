import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'add_investment_screen.dart';
import 'ai_screen.dart';
import 'portfolio_analytics_screen.dart';
import 'portfolio_screen.dart';
import 'profile_screen.dart';
import '../widgets/live_market_widget.dart';
import 'ai_agent_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState
    extends State<DashboardScreen> {
  final ScrollController quickActionController =
      ScrollController();

  bool showForwardArrow = true;

  Map<String, dynamic>? userData;

  bool isLoading = true;

  static const Color backgroundColor =
      Color(0xFF020B1D);

  static const Color panelColor =
      Color(0xFF0E1830);

  static const Color borderColor =
      Color(0xFF1E2C48);

  static const Color teal =
      Color(0xFF14C8B0);

  static const Color muted =
      Color(0xFF8C9AB5);

  @override
  void initState() {
    super.initState();

    quickActionController.addListener(() {
      if (!mounted) return;

      if (!quickActionController.hasClients) {
        return;
      }

      setState(() {
        showForwardArrow =
            quickActionController.offset < 50;
      });
    });

    loadUser();
  }

  Future<void> loadUser() async {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }

      return;
    }

    final doc =
        await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .get();

    if (!mounted) return;

    setState(() {
      userData = doc.data();
      isLoading = false;
    });
  }

  @override
  void dispose() {
    quickActionController.dispose();
    super.dispose();
  }

  TextStyle pixelText({
    double size = 14,
    Color color = Colors.white,
  }) {
    return GoogleFonts.pressStart2p(
      fontSize: size,
      color: color,
      height: 1.4,
    );
  }

  TextStyle monoText({
    double size = 13,
    Color color = Colors.white,
    FontWeight weight = FontWeight.w400,
  }) {
    return GoogleFonts.spaceMono(
      fontSize: size,
      color: color,
      fontWeight: weight,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            color: teal,
          ),
        ),
      );
    }

    final name =
        userData?["name"] ?? "User";

    final email =
        userData?["email"] ?? "";

    final riskProfile =
        userData?["riskProfile"] ?? "Not Set";

    final portfolio =
        (userData?["portfolio"] ?? 0).toDouble();

    final investment =
        (userData?["totalInvestment"] ?? 0).toDouble();

    final width =
        MediaQuery.of(context).size.width;

    final isDesktop = width >= 900;

    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: _buildAppBar(),

      body: isDesktop
          ? _buildDesktopLayout(
              context,
              name,
              email,
              riskProfile,
              portfolio,
              investment,
            )
          : _buildMobileLayout(
              context,
              name,
              email,
              riskProfile,
              portfolio,
              investment,
            ),

      bottomNavigationBar:
          isDesktop
              ? null
              : _buildBottomNavigation(context),
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,

      title: Text(
        "OneVest",
        style: pixelText(
          size: 14,
        ),
      ),

      actions: [
        IconButton(
          icon: const Icon(
            Icons.notifications_none,
            color: Colors.white,
          ),
          onPressed: () {},
        ),

        const SizedBox(width: 8),
      ],
    );
  }

  // ============================================================
  // MOBILE LAYOUT
  // ============================================================

  Widget _buildMobileLayout(
    BuildContext context,
    String name,
    String email,
    String riskProfile,
    double portfolio,
    double investment,
  ) {
    return Center(
      child: ConstrainedBox(
        constraints:
            const BoxConstraints(
          maxWidth: 480,
        ),
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.fromLTRB(
            18,
            12,
            18,
            30,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _buildWelcome(
                name,
                email,
                riskProfile,
              ),

              const SizedBox(height: 25),

              _buildPortfolioCard(
                portfolio,
                investment,
              ),

              const SizedBox(height: 28),

              _buildQuickActions(context),

              const SizedBox(height: 28),

              _buildRecommendation(
                riskProfile,
              ),

              const SizedBox(height: 28),

              _buildLiveMarket(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DESKTOP LAYOUT
  // ============================================================

  Widget _buildDesktopLayout(
    BuildContext context,
    String name,
    String email,
    String riskProfile,
    double portfolio,
    double investment,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _buildSidebar(context),

        Expanded(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.fromLTRB(
              30,
              20,
              30,
              40,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _buildWelcome(
                  name,
                  email,
                  riskProfile,
                ),

                const SizedBox(height: 28),

                LayoutBuilder(
                  builder:
                      (context, constraints) {
                    final leftWidth =
                        constraints.maxWidth *
                            0.47;

                    final rightWidth =
                        constraints.maxWidth *
                            0.49;

                    return Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: leftWidth,
                          child: Column(
                            children: [
                              _buildPortfolioCard(
                                portfolio,
                                investment,
                              ),

                              const SizedBox(
                                height: 25,
                              ),

                              _buildQuickActions(
                                context,
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        SizedBox(
                          width: rightWidth,
                          child: Column(
                            children: [
                              _buildLiveMarket(),

                              const SizedBox(
                                height: 25,
                              ),

                              _buildRecommendation(
                                riskProfile,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SIDEBAR
  // ============================================================

  Widget _buildSidebar(
    BuildContext context,
  ) {
    return Container(
      width: 82,
      margin: const EdgeInsets.only(
        left: 12,
        top: 12,
        bottom: 12,
      ),
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 18),

          _sidebarButton(
            icon: Icons.home_rounded,
            selected: true,
            tooltip: "Home",
            onTap: () {},
          ),

          _sidebarButton(
            icon: Icons
                .account_balance_wallet_rounded,
            tooltip: "Portfolio",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const PortfolioScreen(),
                ),
              );
            },
          ),

          _sidebarButton(
            icon: Icons.smart_toy_rounded,
            tooltip: "AI",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const AiScreen(),
                ),
              );
            },
          ),

          _sidebarButton(
            icon: Icons.person_rounded,
            tooltip: "Profile",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const ProfileScreen(),
                ),
              );
            },
          ),

          const Spacer(),

          _sidebarButton(
            icon: Icons
                .analytics_outlined,
            tooltip: "Analytics",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const PortfolioAnalyticsScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 18),
        ],
      ),
    );
  }

  Widget _sidebarButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    bool selected = false,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: selected
              ? teal.withValues(
                  alpha: 0.14,
                )
              : Colors.transparent,
          borderRadius:
              BorderRadius.circular(14),
          child: InkWell(
            onTap: onTap,
            borderRadius:
                BorderRadius.circular(14),
            hoverColor:
                teal.withValues(
              alpha: 0.08,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 58,
              child: Icon(
                icon,
                color: selected
                    ? teal
                    : muted,
                size: 23,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // WELCOME
  // ============================================================

  Widget _buildWelcome(
    String name,
    String email,
    String riskProfile,
  ) {
    return _EntranceAnimation(
      delay:
          const Duration(milliseconds: 50),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            "Hello, $name 👋",
            style: pixelText(
              size: 17,
            ),
          ),

          const SizedBox(height: 9),

          Text(
            email,
            style: monoText(
              size: 11,
              color: muted,
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: teal.withValues(
                alpha: 0.10,
              ),
              borderRadius:
                  BorderRadius.circular(8),
              border: Border.all(
                color: teal.withValues(
                  alpha: 0.28,
                ),
              ),
            ),
            child: Text(
              "Risk Profile : $riskProfile",
              style: monoText(
                size: 9,
                color: teal,
                weight:
                    FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PORTFOLIO
  // ============================================================

  Widget _buildPortfolioCard(
    double portfolio,
    double investment,
  ) {
    final gain =
        portfolio - investment;

    final percentage =
        investment == 0
            ? 0.0
            : (gain / investment) *
                100;

    return _EntranceAnimation(
      delay:
          const Duration(milliseconds: 150),
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: panelColor,
          borderRadius:
              BorderRadius.circular(18),
          border: Border.all(
            color: borderColor,
          ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "Portfolio Value",
                  style: monoText(
                    size: 10,
                    color: muted,
                  ),
                ),

                const Spacer(),

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        teal.withValues(
                      alpha: 0.08,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      6,
                    ),
                  ),
                  child: Text(
                    "ALL TIME",
                    style: monoText(
                      size: 7,
                      color: teal,
                      weight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.end,
              children: [
                Expanded(
                  child:
                      TweenAnimationBuilder<
                          double>(
                    tween: Tween<double>(
                      begin: 0,
                      end: portfolio,
                    ),
                    duration:
                        const Duration(
                      milliseconds: 1200,
                    ),
                    curve:
                        Curves.easeOutCubic,
                    builder:
                        (
                      context,
                      value,
                      child,
                    ) {
                      return Text(
                        "₹${value.toStringAsFixed(2)}",
                        style:
                            GoogleFonts.spaceMono(
                          color:
                              Colors.white,
                          fontSize: 26,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(
                  width: 95,
                  height: 42,
                  child: CustomPaint(
                    painter:
                        SparklinePainter(
                      points: const [
                        0.32,
                        0.41,
                        0.38,
                        0.52,
                        0.48,
                        0.67,
                        0.82,
                      ],
                      color: teal,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              "${gain >= 0 ? '+' : ''}"
              "₹${gain.toStringAsFixed(2)} "
              "(${percentage.toStringAsFixed(2)}%) all time",
              style: monoText(
                size: 9,
                color: gain >= 0
                    ? teal
                    : const Color(
                        0xFFFF5D6C,
                      ),
              ),
            ),

            const SizedBox(height: 22),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Total Investment",
                        style: monoText(
                          size: 9,
                          color: muted,
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Text(
                        "₹${investment.toStringAsFixed(2)}",
                        style: monoText(
                          size: 13,
                          color:
                              Colors.white,
                          weight:
                              FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  width: 15,
                ),

                const SizedBox(
                  width: 110,
                  height: 110,
                  child: AllocationRing(),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: const [
                AllocationLegend(
                  color:
                      Color(0xFF14C8B0),
                  text: "Equity",
                ),
                AllocationLegend(
                  color:
                      Color(0xFF8D70FF),
                  text: "Bonds",
                ),
                AllocationLegend(
                  color:
                      Color(0xFFFFB84D),
                  text: "REITs",
                ),
                AllocationLegend(
                  color:
                      Color(0xFFFF6672),
                  text: "Gold",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // QUICK ACTIONS
  // ============================================================

  Widget _buildQuickActions(
    BuildContext context,
  ) {
    return _EntranceAnimation(
      delay:
          const Duration(milliseconds: 300),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Quick Actions",
                style: pixelText(
                  size: 12,
                ),
              ),

              const Spacer(),

              IconButton(
                icon: Icon(
                  showForwardArrow
                      ? Icons.arrow_forward_ios
                      : Icons.arrow_back_ios_new,
                  color: muted,
                  size: 14,
                ),
                onPressed: () {
                  if (!quickActionController
                      .hasClients) {
                    return;
                  }

                  if (showForwardArrow) {
                    quickActionController
                        .animateTo(
                      quickActionController
                          .position
                          .maxScrollExtent,
                      duration:
                          const Duration(
                        milliseconds: 350,
                      ),
                      curve:
                          Curves.easeInOut,
                    );
                  } else {
                    quickActionController
                        .animateTo(
                      0,
                      duration:
                          const Duration(
                        milliseconds: 350,
                      ),
                      curve:
                          Curves.easeInOut,
                    );
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 15),

          SizedBox(
            height: 105,
            child: ListView(
              controller:
                  quickActionController,
              scrollDirection:
                  Axis.horizontal,
              children: [
                actionButton(
                  context,
                  Icons.trending_up,
                  "Invest",
                  () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const AddInvestmentScreen(),
                      ),
                    );

                    await loadUser();
                  },
                ),

                const SizedBox(width: 18),

                actionButton(
                  context,
                  Icons
                      .account_balance_wallet,
                  "Portfolio",
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const PortfolioScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(width: 18),

                actionButton(
                  context,
                  Icons.pie_chart,
                  "Analytics",
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const PortfolioAnalyticsScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(width: 18),

                actionButton(
                  context,
                  Icons.smart_toy,
                  "AI",
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const AiScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(width: 18),

                actionButton(
                  context,
                  Icons.person,
                  "Profile",
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const ProfileScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(width: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget actionButton(
    BuildContext context,
    IconData icon,
    String text,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(14),
        hoverColor:
            teal.withValues(
          alpha: 0.08,
        ),
        child: SizedBox(
          width: 78,
          child: Column(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration:
                    BoxDecoration(
                  color:
                      teal.withValues(
                    alpha: 0.12,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                  border: Border.all(
                    color:
                        teal.withValues(
                      alpha: 0.30,
                    ),
                  ),
                ),
                child: Icon(
                  icon,
                  color: teal,
                  size: 21,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                text,
                textAlign:
                    TextAlign.center,
                style: monoText(
                  size: 8,
                  color:
                      Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // RECOMMENDATION
  // ============================================================

  Widget _buildRecommendation(
    String riskProfile,
  ) {
    String message;

    if (riskProfile
        .toString()
        .toLowerCase()
        .contains("low")) {
      message =
          "Conservative assets match your Low risk profile.";
    } else if (riskProfile
        .toString()
        .toLowerCase()
        .contains("high")) {
      message =
          "Growth-focused assets may suit your High risk profile.";
    } else {
      message =
          "Diversified assets match your Medium risk profile.";
    }

    return _EntranceAnimation(
      delay:
          const Duration(milliseconds: 450),
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: const Color(0xFF0A2430),
          borderRadius:
              BorderRadius.circular(15),
          border: Border.all(
            color: teal.withValues(
              alpha: 0.25,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration:
                  BoxDecoration(
                color:
                    teal.withValues(
                  alpha: 0.10,
                ),
                borderRadius:
                    BorderRadius.circular(
                  10,
                ),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: teal,
                size: 19,
              ),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    "RECOMMENDED FOR YOU",
                    style: monoText(
                      size: 7,
                      color: teal,
                      weight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  Text(
                    message,
                    style: monoText(
                      size: 9,
                      color:
                          Colors.white,
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
  // LIVE MARKET
  // ============================================================

  Widget _buildLiveMarket() {
    return _EntranceAnimation(
      delay:
          const Duration(milliseconds: 600),
      child:
          const LiveMarketWidget(),
    );
  }

  // ============================================================
  // MOBILE BOTTOM NAV
  // ============================================================

    Widget _buildBottomNavigation(
      BuildContext context,
    ) {
      return Container(
        decoration: const BoxDecoration(
          color: panelColor,
          border: Border(
            top: BorderSide(
              color: borderColor,
            ),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: panelColor,
          elevation: 0,

          selectedItemColor: teal,
          unselectedItemColor: muted,

          currentIndex: 0,

          type: BottomNavigationBarType.fixed,

          onTap: (index) {
            if (index == 0) {
              return;
            }

            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PortfolioScreen(),
                ),
              );
            }

            // CENTER: AI MARKET AGENT
            if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AiAgentScreen(),
                ),
              );
            }

            // FRIEND'S EXISTING AI SCREEN
            if (index == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AiScreen(),
                ),
              );
            }

            if (index == 4) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfileScreen(),
                ),
              );
            }
          },

          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ),

            BottomNavigationBarItem(
              icon: Icon(
                Icons.account_balance_wallet,
              ),
              label: "Portfolio",
            ),

            // YOUR HACKATHON FEATURE
            BottomNavigationBarItem(
              icon: Icon(
                Icons.smart_toy,
              ),
              label: "AI Agent",
            ),

            // FRIEND'S AI
            BottomNavigationBarItem(
              icon: Icon(
                Icons.auto_awesome,
              ),
              label: "AI",
            ),

            BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
              ),
              label: "Profile",
            ),
          ],
        ),
      );
    }
  }
// ============================================================
// ENTRANCE ANIMATION
// ============================================================

class _EntranceAnimation
    extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const _EntranceAnimation({
    required this.child,
    required this.delay,
  });

  @override
  State<_EntranceAnimation> createState() =>
      _EntranceAnimationState();
}

class _EntranceAnimationState
    extends State<_EntranceAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  late Animation<double> opacity;

  late Animation<Offset> slide;

  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(
      vsync: this,
      duration:
          const Duration(milliseconds: 500),
    );

    opacity =
        CurvedAnimation(
      parent: controller,
      curve: Curves.easeOut,
    );

    slide =
        Tween<Offset>(
      begin:
          const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve:
            Curves.easeOutCubic,
      ),
    );

    Future.delayed(
      widget.delay,
      () {
        if (mounted) {
          controller.forward();
        }
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return FadeTransition(
      opacity: opacity,
      child:
          SlideTransition(
        position: slide,
        child:
            widget.child,
      ),
    );
  }
}

// ============================================================
// ALLOCATION RING
// ============================================================

class AllocationRing
    extends StatelessWidget {
  const AllocationRing({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return CustomPaint(
      painter:
          AllocationRingPainter(),
      child: Center(
        child: Text(
          "MIX",
          style:
              GoogleFonts.pressStart2p(
            color:
                Colors.white70,
            fontSize: 7,
          ),
        ),
      ),
    );
  }
}

class AllocationRingPainter
    extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final center =
        Offset(
      size.width / 2,
      size.height / 2,
    );

    final radius =
        min(
              size.width,
              size.height,
            ) /
            2 -
        8;

    const strokeWidth = 10.0;

    const allocations = [
      0.42,
      0.27,
      0.19,
      0.12,
    ];

    const colors = [
      Color(0xFF14C8B0),
      Color(0xFF8D70FF),
      Color(0xFFFFB84D),
      Color(0xFFFF6672),
    ];

    double startAngle =
        -pi / 2;

    for (int i = 0;
        i < allocations.length;
        i++) {
      final sweep =
          allocations[i] *
              2 *
              pi;

      final paint =
          Paint()
            ..color =
                colors[i]
            ..style =
                PaintingStyle.stroke
            ..strokeWidth =
                strokeWidth
            ..strokeCap =
                StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(
          center: center,
          radius: radius,
        ),
        startAngle,
        sweep - 0.04,
        false,
        paint,
      );

      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter
        oldDelegate,
  ) {
    return false;
  }
}

// ============================================================
// ALLOCATION LEGEND
// ============================================================

class AllocationLegend
    extends StatelessWidget {
  final Color color;
  final String text;

  const AllocationLegend({
    super.key,
    required this.color,
    required this.text,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Row(
      mainAxisSize:
          MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration:
              BoxDecoration(
            color: color,
            borderRadius:
                BorderRadius.circular(
              2,
            ),
          ),
        ),

        const SizedBox(width: 6),

        Text(
          text,
          style:
              GoogleFonts.spaceMono(
            color:
                Colors.white60,
            fontSize: 8,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// SPARKLINE
// ============================================================

class SparklinePainter
    extends CustomPainter {
  final List<double> points;
  final Color color;

  SparklinePainter({
    required this.points,
    required this.color,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    if (points.length < 2) {
      return;
    }

    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 2
          ..style =
              PaintingStyle.stroke
          ..strokeCap =
              StrokeCap.round
          ..strokeJoin =
              StrokeJoin.round;

    final path = Path();

    for (int i = 0;
        i < points.length;
        i++) {
      final x =
          i *
              size.width /
              (points.length - 1);

      final y =
          size.height -
              points[i] *
                  size.height;

      if (i == 0) {
        path.moveTo(
          x,
          y,
        );
      } else {
        path.lineTo(
          x,
          y,
        );
      }
    }

    canvas.drawPath(
      path,
      paint,
    );
  }

  @override
  bool shouldRepaint(
    covariant SparklinePainter
        oldDelegate,
  ) {
    return false;
  }
}