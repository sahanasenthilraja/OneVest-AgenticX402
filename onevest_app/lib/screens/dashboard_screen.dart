import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'add_investment_screen.dart';
import 'ai_screen.dart';
import 'ai_agent_screen.dart';
import 'portfolio_analytics_screen.dart';
import 'portfolio_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

import '../widgets/live_market_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ScrollController quickActionController =
      ScrollController();

  bool showForwardArrow = true;

  Map<String, dynamic>? userData;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    quickActionController.addListener(
      _handleQuickActionScroll,
    );

    loadUser();
  }

  // ============================================================
  // QUICK ACTION SCROLL
  // ============================================================

  void _handleQuickActionScroll() {
    if (!mounted ||
        !quickActionController.hasClients) {
      return;
    }

    setState(() {
      showForwardArrow =
          quickActionController.offset < 100;
    });
  }

  // ============================================================
  // LOAD USER
  // ============================================================

  Future<void> loadUser() async {
    try {
      final user =
          FirebaseAuth.instance.currentUser;

      if (user == null) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
        });

        return;
      }

      final doc = await FirebaseFirestore
          .instance
          .collection("users")
          .doc(user.uid)
          .get();

      if (!mounted) return;

      setState(() {
        userData = doc.data();
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    quickActionController.removeListener(
      _handleQuickActionScroll,
    );

    quickActionController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF020B1D),
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.tealAccent,
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

    return Scaffold(
      backgroundColor:
          const Color(0xFF020B1D),

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor:
            const Color(0xFF020B1D),

        elevation: 0,

        title: const Text(
          "OneVest",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),

        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none,
              color: Colors.white,
            ),

            onPressed: () {
              // Notification feature
            },
          ),

          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: Colors.white,
            ),

            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const SettingsScreen(),
                ),
              );
            },
          ),

          const SizedBox(width: 8),
        ],
      ),

      // ========================================================
      // HOME CONTENT
      // ========================================================

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // ==================================================
            // GREETING
            // ==================================================

            Text(
              "Hello, $name 👋",

              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              email,

              style: const TextStyle(
                color: Colors.white70,
              ),
            ),

            const SizedBox(height: 12),

            // ==================================================
            // RISK PROFILE
            // ==================================================

            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),

              decoration: BoxDecoration(
                color: Colors.teal
                    .withValues(alpha: 0.2),

                borderRadius:
                    BorderRadius.circular(10),
              ),

              child: Text(
                "Risk Profile : $riskProfile",

                style: const TextStyle(
                  color: Colors.tealAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 25),

            // ==================================================
            // PORTFOLIO SUMMARY
            // ==================================================

            Container(
              width: double.infinity,

              padding:
                  const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.blueGrey.shade800,

                borderRadius:
                    BorderRadius.circular(20),
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  const Text(
                    "Portfolio Value",

                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "₹${portfolio.toStringAsFixed(2)}",

                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Total Investment",

                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "₹${investment.toStringAsFixed(2)}",

                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ==================================================
            // QUICK ACTIONS HEADER
            // ==================================================

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

              children: [
                const Text(
                  "Quick Actions",

                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                IconButton(
                  icon: Icon(
                    showForwardArrow
                        ? Icons.arrow_forward_ios
                        : Icons.arrow_back_ios_new,

                    color: Colors.white54,

                    size: 18,
                  ),

                  onPressed: () {
                    if (!quickActionController
                        .hasClients) {
                      return;
                    }

                    if (showForwardArrow) {
                      quickActionController.animateTo(
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

            const SizedBox(height: 20),

            // ==================================================
            // QUICK ACTION BUTTONS
            // ==================================================

            SizedBox(
              height: 110,

              child: ListView(
                scrollDirection:
                    Axis.horizontal,

                controller:
                    quickActionController,

                children: [
                  // INVEST
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

                  const SizedBox(width: 24),

                  // PORTFOLIO
                  actionButton(
                    context,
                    Icons.account_balance_wallet,
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

                  const SizedBox(width: 24),

                  // ANALYTICS
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

                  const SizedBox(width: 24),

                  // AI
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

                  const SizedBox(width: 24),

                  // PROFILE
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

                  const SizedBox(width: 20),
                ],
              ),
            ),

            const SizedBox(height: 35),

            // ==================================================
            // LIVE MARKET ONLY
            //
            // IMPORTANT:
            // x402/payment UI is NOT here.
            // It is now inside AiAgentScreen.
            // ==================================================

            const LiveMarketWidget(),

            const SizedBox(height: 25),
          ],
        ),
      ),

      // ========================================================
      // BOTTOM NAVIGATION
      // ========================================================

      bottomNavigationBar:
          BottomNavigationBar(
        backgroundColor:
            const Color(0xFF1A2B45),

        selectedItemColor:
            Colors.tealAccent,

        unselectedItemColor:
            Colors.white60,

        currentIndex: 0,

        type:
            BottomNavigationBarType.fixed,

        onTap: (index) {
          // ----------------------------------------------
          // HOME
          // ----------------------------------------------

          if (index == 0) {
            return;
          }

          // ----------------------------------------------
          // PORTFOLIO
          // ----------------------------------------------

          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const PortfolioScreen(),
              ),
            );

            return;
          }

          // ----------------------------------------------
          // AI AGENT
          // ----------------------------------------------

          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const AiAgentScreen(),
              ),
            );

            return;
          }

          // ----------------------------------------------
          // EXISTING AI
          // ----------------------------------------------

          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const AiScreen(),
              ),
            );

            return;
          }

          // ----------------------------------------------
          // PROFILE
          // ----------------------------------------------

          if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const ProfileScreen(),
              ),
            );

            return;
          }
        },

        items: const [
          // HOME
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
            ),
            label: "Home",
          ),

          // PORTFOLIO
          BottomNavigationBarItem(
            icon: Icon(
              Icons.account_balance_wallet,
            ),
            label: "Portfolio",
          ),

          // AI AGENT
          BottomNavigationBarItem(
            icon: Icon(
              Icons.smart_toy,
            ),
            label: "AI Agent",
          ),

          // AI
          BottomNavigationBarItem(
            icon: Icon(
              Icons.psychology,
            ),
            label: "AI",
          ),

          // PROFILE
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

  // ============================================================
  // QUICK ACTION BUTTON
  // ============================================================

  Widget actionButton(
    BuildContext context,
    IconData icon,
    String text,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,

      child: SizedBox(
        width: 90,

        child: Column(
          children: [
            CircleAvatar(
              radius: 30,

              backgroundColor:
                  Colors.teal,

              child: Icon(
                icon,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              text,

              textAlign:
                  TextAlign.center,

              style: const TextStyle(
                color: Colors.white,
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}