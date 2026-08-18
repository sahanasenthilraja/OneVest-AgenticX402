import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:http/http.dart' as http;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/performance_data.dart';
import '../services/ai_recommendation_service.dart';
import '../widgets/app_sidebar.dart';
import 'add_investment_screen.dart';
import 'portfolio_screen.dart';
// ============================================================
// FONT HELPERS â€” shared across this file so every label/value
// uses the same Press Start 2P / Space Mono pairing as the
// rest of the app instead of the system default.
// ============================================================

TextStyle _heading(
  double size, {
  Color color = PortfolioAnalyticsScreen.white,
  FontWeight weight = FontWeight.w700,
  double? spacing,
  double? height,
}) {
  return GoogleFonts.pressStart2p(
    fontSize: size,
    color: color,
    fontWeight: weight,
    letterSpacing: spacing,
    height: height,
  );
}

TextStyle _mono(
  double size, {
  Color color = PortfolioAnalyticsScreen.white,
  FontWeight weight = FontWeight.normal,
  double? spacing,
  double? height,
}) {
  return GoogleFonts.spaceMono(
    fontSize: size,
    color: color,
    fontWeight: weight,
    letterSpacing: spacing,
    height: height,
  );
}

class PortfolioAnalyticsScreen extends StatelessWidget {
  const PortfolioAnalyticsScreen({super.key});

  // ============================================================
  // ONEVEST THEME
  // ============================================================

  static const Color background = Color(0xFF020B1D);
  static const Color surface = Color(0xFF0A1428);
  static const Color surface2 = Color(0xFF0F1D35);
  static const Color surface3 = Color(0xFF142542);

  static const Color border = Color(0xFF243B60);

  static const Color teal = Color(0xFF14C8B0);
  static const Color tealDark = Color(0xFF0C8F82);

  static const Color white = Color(0xFFF5F8FC);
  static const Color muted = Color(0xFF91A0B8);

  static const Color green = Color(0xFF45E38A);
  static const Color red = Color(0xFFFF5A64);
  static const Color orange = Color(0xFFFFB52E);
  static const Color blue = Color(0xFF4E8CFF);
  static const Color purple = Color(0xFFA86BFF);

  // ============================================================
  // SAFE NUMBER HELPERS
  // ============================================================

  static double safeDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value) ?? 0;
    }

    return 0;
  }

  static int safeInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value) ?? 0;
    }

    return 0;
  }

  // ============================================================
  // MAIN
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: background,
        body: Center(
          child: Text(
            'Please sign in again.',
            style: _mono(20, color: white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: background,
      body: Row(
        children: [
          const AppSidebar(current: SidebarItem.analytics),
          Expanded(
            child: SafeArea(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('investments')
                    .where(
                      'userId',
                      isEqualTo: user.uid,
                    )
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: teal,
                        strokeWidth: 3,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return _errorState();
                  }

                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return _emptyState();
                  }

                  return _AnalyticsBody(
                    docs: docs,
                    userId: user.uid,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _errorState() {
    return Center(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(35),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: red,
              size: 58,
            ),
            const SizedBox(height: 20),
            Text(
              'Unable to Load Analytics',
              style: _mono(20, color: white, weight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Text(
              'Please try again.',
              style: _mono(14, color: muted),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _emptyState() {
    return Center(
      child: Container(
        width: 540,
        padding: const EdgeInsets.all(45),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.analytics_rounded,
              color: teal,
              size: 72,
            ),
            const SizedBox(height: 25),
            Text(
              'No Investments Yet',
              style: _mono(24, color: white, weight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Text(
              'Add an investment to unlock your complete portfolio analytics.',
              textAlign: TextAlign.center,
              style: _mono(15, color: muted, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// ANALYTICS BODY
// ==================================================================

class _AnalyticsBody extends StatefulWidget {
  final List<QueryDocumentSnapshot> docs;
  final String userId;

  const _AnalyticsBody({
    required this.docs,
    required this.userId,
  });

  @override
  State<_AnalyticsBody> createState() => _AnalyticsBodyState();
}

class _AnalyticsBodyState extends State<_AnalyticsBody> {
  List<QueryDocumentSnapshot> get docs => widget.docs;
  String get userId => widget.userId;

  static const Color surface = PortfolioAnalyticsScreen.surface;
  static const Color surface2 = PortfolioAnalyticsScreen.surface2;
  static const Color border = PortfolioAnalyticsScreen.border;

  static const Color teal = PortfolioAnalyticsScreen.teal;
  static const Color white = PortfolioAnalyticsScreen.white;
  static const Color muted = PortfolioAnalyticsScreen.muted;

  static const Color green = PortfolioAnalyticsScreen.green;
  static const Color red = PortfolioAnalyticsScreen.red;
  static const Color orange = PortfolioAnalyticsScreen.orange;
  static const Color blue = PortfolioAnalyticsScreen.blue;
  static const Color purple = PortfolioAnalyticsScreen.purple;

  double goalAmount = 1000000;
  String selectedTimeframe = '1M';
  String? selectedAssetType;
  final GlobalKey healthKey = GlobalKey();

  // ============================================================
  // LIVE MARKET PRICES
  // ============================================================

  final Map<String, double> _livePrices = {};
  Timer? _marketTimer;
  bool _marketLoading = false;

  String get _marketBaseUrl {
    // Android emulator -> host machine.
    // Windows / web / desktop -> localhost.
    if (const bool.fromEnvironment('dart.library.io')) {
      return 'http://10.0.2.2:4021';
    }
    return 'http://localhost:4021';
  }

  String? _marketSymbol(Map<String, dynamic> data) {
    final candidates = [
      data['symbol'],
      data['ticker'],
      data['stockSymbol'],
      data['marketSymbol'],
      data['yahooSymbol'],
    ];

    for (final candidate in candidates) {
      final value = candidate?.toString().trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }

    final name = (data['name'] ?? data['assetName'] ?? '')
        .toString()
        .trim()
        .toUpperCase();

    final type = (data['investmentType'] ?? '').toString().trim().toUpperCase();

    if (name.contains('RELIANCE')) return 'RELIANCE.NS';
    if (name.contains('INFY') || name.contains('INFOSYS')) return 'INFY.NS';
    if (name.contains('NIFTY')) return '^NSEI';
    if (name.contains('SENSEX')) return '^BSESN';
    if (name.contains('BITCOIN') || name == 'BTC') return 'BTC-INR';
    if (name.contains('ETHEREUM') || name == 'ETH') return 'ETH-INR';
    if (name.contains('GOLD') || type == 'GOLD') return 'GC=F';

    return null;
  }

  Future<void> _fetchLivePrices() async {
    if (!mounted || _marketLoading) return;

    final symbols = <String>{};

    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final symbol = _marketSymbol(data);
      if (symbol != null) symbols.add(symbol);
    }

    if (symbols.isEmpty) return;

    setState(() => _marketLoading = true);

    try {
      final updates = <String, double>{};

      await Future.wait(
        symbols.map((symbol) async {
          try {
            final uri = Uri.parse(
              '$_marketBaseUrl/api/market-price'
              '?symbol=${Uri.encodeComponent(symbol)}',
            );

            debugPrint('Analytics: fetching $symbol');

            final response = await http.get(uri).timeout(
              const Duration(seconds: 10),
            );

            debugPrint(
              'Analytics: $symbol -> ${response.statusCode}',
            );

            if (response.statusCode != 200) return;

            final decoded = jsonDecode(response.body);
            if (decoded is! Map<String, dynamic>) return;

            final market = decoded['market'];
            if (market is! Map<String, dynamic>) return;

            final price = PortfolioAnalyticsScreen.safeDouble(
              market['price'],
            );

            if (price > 0) {
              updates[symbol] = price;
            }
          } catch (e) {
            debugPrint('Analytics: failed $symbol -> $e');
          }
        }),
      );

      if (!mounted) return;

      setState(() {
        _livePrices
          ..clear()
          ..addAll(updates);
      });
    } finally {
      if (mounted) {
        setState(() => _marketLoading = false);
      }
    }
  }

  double _currentPrice(
    Map<String, dynamic> data,
    double buyPrice,
  ) {
    final symbol = _marketSymbol(data);

    if (symbol != null) {
      final live = _livePrices[symbol];
      if (live != null && live > 0) {
        return live;
      }
    }

    // Only use Firestore's stored currentPrice when live API data
    // is unavailable. Never invent a market price here.
    final stored = PortfolioAnalyticsScreen.safeDouble(
      data['currentPrice'],
    );

    return stored > 0 ? stored : buyPrice;
  }

  @override
  void initState() {
    super.initState();

    _loadGoal();
    _fetchLivePrices();

    _marketTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => _fetchLivePrices(),
    );
  }

  @override
  void dispose() {
    _marketTimer?.cancel();
    super.dispose();
  }


  final List<String> timeframes = const [
    '1W',
    '1M',
    '3M',
    '1Y',
    'All',
  ];

  Future<void> _loadGoal() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();
      if (!mounted) return;
      final data = doc.data();
      final value = PortfolioAnalyticsScreen.safeDouble(data?['analyticsGoal']);
      if (value > 0) {
        setState(() => goalAmount = value);
      }
    } catch (_) {}
  }

  void _scrollToHealth() {
    final ctx = healthKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _toggleAsset(String asset) {
    setState(() {
      selectedAssetType = selectedAssetType == asset ? null : asset;
    });
  }

  DateTime _investmentDate(Map<String, dynamic> data, int fallbackIndex) {
    final candidates = [
      data['purchaseDate'],
      data['date'],
      data['createdAt'],
      data['timestamp'],
    ];
    for (final value in candidates) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) {
        final parsed = DateTime.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return DateTime.now().subtract(Duration(days: docs.length - fallbackIndex));
  }

  List<PerformanceData> _filterPerformanceData(List<PerformanceData> data) {
    if (data.isEmpty || selectedTimeframe == 'All') return data;
    final Duration duration;
    switch (selectedTimeframe) {
      case '1W': duration = const Duration(days: 7); break;
      case '1M': duration = const Duration(days: 30); break;
      case '3M': duration = const Duration(days: 90); break;
      case '1Y': duration = const Duration(days: 365); break;
      default: duration = const Duration(days: 30);
    }
    final start = DateTime.now().subtract(duration);
    return data.where((e) => !e.date.isBefore(start)).toList();
  }

  double _chartInterval(int length) {
    if (length <= 5) return 1;
    if (length <= 10) return 2;
    if (length <= 20) return 4;
    return math.max(1, (length / 6).ceil()).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    // ============================================================
    // PORTFOLIO DATA
    // ============================================================

    final Map<String, double> portfolio = {
      'Stock': 0,
      'Mutual Fund': 0,
      'Gold': 0,
      'Crypto': 0,
      'FD': 0,
    };

    double totalValue = 0;
    double totalInvested = 0;

    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;

      final double buyPrice = PortfolioAnalyticsScreen.safeDouble(
        data['buyPrice'],
      );

      final double currentPrice = _currentPrice(
        data,
        buyPrice,
      );

      final int quantity = PortfolioAnalyticsScreen.safeInt(
        data['quantity'],
      );

      final double invested = buyPrice * quantity;

      final double currentValue = currentPrice * quantity;

      totalInvested += invested;
      totalValue += currentValue;

      final String type = data['investmentType']?.toString() ?? 'Other';

      portfolio[type] = (portfolio[type] ?? 0) + currentValue;
    }

    final double profitLoss = totalValue - totalInvested;

    final double returnPercent = totalInvested == 0
        ? 0
        : (profitLoss / totalInvested) * 100;

    double goalProgress = goalAmount == 0 ? 0 : totalValue / goalAmount;

    if (goalProgress > 1) {
      goalProgress = 1;
    }

    // ============================================================
    // PERFORMANCE DATA
    // ============================================================

    final sortedDocs = [...docs];
    sortedDocs.sort((a, b) {
      final ad = a.data() as Map<String, dynamic>;
      final bd = b.data() as Map<String, dynamic>;
      return _investmentDate(ad, 0).compareTo(_investmentDate(bd, 0));
    });

    final List<PerformanceData> performanceData = [];
    double runningValue = 0;

    for (int i = 0; i < sortedDocs.length; i++) {
      final data = sortedDocs[i].data() as Map<String, dynamic>;
      final buyPrice = PortfolioAnalyticsScreen.safeDouble(data['buyPrice']);
      final currentPrice = _currentPrice(
        data,
        buyPrice,
      );
      final quantity = PortfolioAnalyticsScreen.safeInt(data['quantity']);

      // Performance uses the live market value as well. Do not use a
      // stale stored currentValue when a live price is available.
      final value = currentPrice * quantity;
      runningValue += value;
      performanceData.add(
        PerformanceData(
          date: _investmentDate(data, i),
          value: runningValue,
        ),
      );
    }

    // ============================================================
    // HEALTH
    // ============================================================

    int healthScore = 100;

    final List<String> suggestions = [];

    final int assetTypes = portfolio.entries
        .where((entry) => entry.value > 0)
        .length;

    if (assetTypes >= 4) {
      suggestions.add(
        'Well diversified portfolio',
      );
    } else if (assetTypes == 3) {
      healthScore -= 10;
      suggestions.add(
        'Add one more investment type',
      );
    } else if (assetTypes == 2) {
      healthScore -= 20;
      suggestions.add(
        'Diversify across more asset classes',
      );
    } else {
      healthScore -= 35;
      suggestions.add(
        'Portfolio is highly concentrated',
      );
    }

    final double cryptoPercent = totalValue == 0
        ? 0
        : ((portfolio['Crypto'] ?? 0) / totalValue) * 100;

    if (cryptoPercent > 20) {
      healthScore -= 15;
      suggestions.add(
        'Reduce Crypto exposure',
      );
    }

    final double goldPercent = totalValue == 0
        ? 0
        : ((portfolio['Gold'] ?? 0) / totalValue) * 100;

    if (goldPercent < 5) {
      healthScore -= 10;
      suggestions.add(
        'Consider adding Gold',
      );
    }

    final double mutualFundPercent = totalValue == 0
        ? 0
        : ((portfolio['Mutual Fund'] ?? 0) / totalValue) * 100;

    if (mutualFundPercent >= 30) {
      suggestions.add(
        'Good Mutual Fund allocation',
      );
    } else {
      healthScore -= 10;
      suggestions.add(
        'Increase Mutual Fund allocation',
      );
    }

    if (healthScore < 0) {
      healthScore = 0;
    }

    String healthStatus;

    if (healthScore >= 85) {
      healthStatus = 'Excellent';
    } else if (healthScore >= 70) {
      healthStatus = 'Good';
    } else if (healthScore >= 50) {
      healthStatus = 'Average';
    } else {
      healthStatus = 'Needs Improvement';
    }

    String riskLevel;
    Color riskColor;

    if (healthScore >= 85) {
      riskLevel = 'Low';
      riskColor = green;
    } else if (healthScore >= 70) {
      riskLevel = 'Medium';
      riskColor = orange;
    } else {
      riskLevel = 'High';
      riskColor = red;
    }

    // ============================================================
    // AI
    // ============================================================

    final recommendations = AIRecommendationService.getRecommendations(
      portfolio,
    );

    // ============================================================
    // RESPONSIVE UI
    // ============================================================

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;

        final bool desktop = width >= 1100;
        final bool tablet = width >= 700;

        final double horizontalPadding = desktop
            ? 42
            : tablet
                ? 28
                : 16;

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _topHeader(
                context,
                desktop,
              ),
            ),

            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                8,
                horizontalPadding,
                45,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    // ==================================================
                    // HERO
                    // ==================================================

                    _heroSection(
                      totalValue: totalValue,
                      totalInvested: totalInvested,
                      profitLoss: profitLoss,
                      returnPercent: returnPercent,
                      goalProgress: goalProgress,
                    ),

                    const SizedBox(height: 22),

                    // ==================================================
                    // KPI ROW
                    // ==================================================

                    _kpiSection(
                      desktop: desktop,
                      tablet: tablet,
                      totalValue: totalValue,
                      totalInvested: totalInvested,
                      profitLoss: profitLoss,
                      healthScore: healthScore,
                    ),

                    const SizedBox(height: 22),

                    // ==================================================
                    // ALLOCATION + GOAL
                    // ==================================================

                    if (desktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 6,
                            child: _allocationCard(
                              portfolio: portfolio,
                              totalValue: totalValue,
                            ),
                          ),
                          const SizedBox(width: 22),
                          Expanded(
                            flex: 4,
                            child: _goalCard(
                              totalValue: totalValue,
                              progress: goalProgress,
                            ),
                          ),
                        ],
                      )
                    else ...[
                      _allocationCard(
                        portfolio: portfolio,
                        totalValue: totalValue,
                      ),
                      const SizedBox(height: 22),
                      _goalCard(
                        totalValue: totalValue,
                        progress: goalProgress,
                      ),
                    ],

                    const SizedBox(height: 22),

                    // ==================================================
                    // HEALTH
                    // ==================================================

                    KeyedSubtree(
                      key: healthKey,
                      child: _healthCard(
                        desktop: desktop,
                      healthScore: healthScore,
                      healthStatus: healthStatus,
                      riskLevel: riskLevel,
                      riskColor: riskColor,
                        suggestions: suggestions,
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ==================================================
                    // AI
                    // ==================================================

                    _aiCard(
                      recommendations: recommendations,
                    ),

                    const SizedBox(height: 22),

                    // ==================================================
                    // TRANSACTIONS
                    // ==================================================

                    TransactionInsights(
                      userId: userId,
                    ),

                    const SizedBox(height: 22),

                    // ==================================================
                    // PERFORMANCE
                    // ==================================================

                    _performanceCard(
                      performanceData: performanceData,
                      totalValue: totalValue,
                    ),

                    const SizedBox(height: 22),

                    // ==================================================
                    // BREAKDOWN
                    // ==================================================

                    _breakdownCard(
                      portfolio: portfolio,
                      totalValue: totalValue,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _topHeader(
    BuildContext context,
    bool desktop,
  ) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        desktop ? 42 : 18,
        28,
        desktop ? 42 : 18,
        22,
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: teal.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                color: teal.withValues(alpha: 0.22),
              ),
            ),
            child: const Icon(
              Icons.analytics_rounded,
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
                  'Portfolio Analytics',
                  style: _heading(16, color: white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Understand your wealth, performance and risk',
                  style: _mono(15, color: muted),
                ),
              ],
            ),
          ),
          if (desktop)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 11,
              ),
              decoration: BoxDecoration(
                color: green.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: green.withValues(alpha: 0.20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.circle,
                    color: green,
                    size: 8,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _marketLoading
                        ? 'UPDATING MARKET'
                        : 'LIVE MARKET',
                    style: _mono(
                      11,
                      color: green,
                      weight: FontWeight.bold,
                      spacing: 0.7,
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
  // HERO
  // ============================================================

  Widget _heroSection({
    required double totalValue,
    required double totalInvested,
    required double profitLoss,
    required double returnPercent,
    required double goalProgress,
  }) {
    final bool positive = profitLoss >= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF102B47),
            Color(0xFF0B172C),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: teal.withValues(alpha: 0.20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: teal.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: teal,
                  size: 25,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'YOUR WEALTH DASHBOARD',
                      style: _mono(
                        12,
                        color: teal,
                        weight: FontWeight.bold,
                        spacing: 1.6,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Real-time portfolio overview',
                      style: _mono(14, color: muted),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          Text(
            'TOTAL PORTFOLIO VALUE',
            style: _mono(
              12,
              color: muted,
              weight: FontWeight.bold,
              spacing: 1.4,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            'â‚¹${totalValue.toStringAsFixed(2)}',
            style: _mono(
              40,
              color: white,
              weight: FontWeight.w900,
              spacing: -1,
            ),
          ),

          const SizedBox(height: 25),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _heroMetric(
                title: 'INVESTED',
                value: 'â‚¹${totalInvested.toStringAsFixed(0)}',
                icon: Icons.savings_rounded,
                color: purple,
              ),
              _heroMetric(
                title: 'PROFIT / LOSS',
                value:
                    '${positive ? '+' : '-'}â‚¹${profitLoss.abs().toStringAsFixed(0)}',
                icon: positive
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                color: positive ? green : red,
              ),
              _heroMetric(
                title: 'RETURN',
                value: '${returnPercent.toStringAsFixed(2)}%',
                icon: Icons.percent_rounded,
                color: positive ? green : red,
              ),
              _heroMetric(
                title: 'GOAL',
                value: '${(goalProgress * 100).toStringAsFixed(0)}%',
                icon: Icons.flag_rounded,
                color: orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroMetric({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 215,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.07),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 23,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: _mono(
                    10,
                    color: muted,
                    weight: FontWeight.bold,
                    spacing: 0.7,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: _mono(18, color: color, weight: FontWeight.w900),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // KPI
  // ============================================================

  Widget _kpiSection({
    required bool desktop,
    required bool tablet,
    required double totalValue,
    required double totalInvested,
    required double profitLoss,
    required int healthScore,
  }) {
    final positive = profitLoss >= 0;
    final cards = [
      _KpiData(
        title: 'PORTFOLIO VALUE',
        value: 'â‚¹${totalValue.toStringAsFixed(0)}',
        subtitle: 'Current market value Â· tap to open',
        icon: Icons.account_balance_wallet_rounded,
        color: teal,
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => PortfolioScreen()));
        },
      ),
      _KpiData(
        title: 'TOTAL INVESTED',
        value: 'â‚¹${totalInvested.toStringAsFixed(0)}',
        subtitle: 'Capital deployed',
        icon: Icons.savings_rounded,
        color: purple,
      ),
      _KpiData(
        title: 'PROFIT / LOSS',
        value: '${positive ? '+' : '-'}â‚¹${profitLoss.abs().toStringAsFixed(0)}',
        subtitle: positive ? 'Portfolio is positive' : 'Portfolio is negative',
        icon: positive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
        color: positive ? green : red,
      ),
      _KpiData(
        title: 'HEALTH SCORE',
        value: '$healthScore / 100',
        subtitle: 'Portfolio quality Â· tap to view',
        icon: Icons.favorite_rounded,
        color: green,
        onTap: _scrollToHealth,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: desktop ? 4 : tablet ? 2 : 1,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: desktop ? 2.05 : tablet ? 2.4 : 3.4,
      ),
      itemBuilder: (context, index) {
        final card = cards[index];
        return MouseRegion(
          cursor: card.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
          child: GestureDetector(
            onTap: card.onTap,
            child: Container(
              padding: const EdgeInsets.all(19),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: card.color.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(card.icon, color: card.color, size: 23),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(card.title, style: _mono(10, color: muted, weight: FontWeight.bold, spacing: 0.7)),
                        const SizedBox(height: 5),
                        Text(card.value, overflow: TextOverflow.ellipsis, style: _mono(19, color: white, weight: FontWeight.w900)),
                        const SizedBox(height: 3),
                        Text(card.subtitle, overflow: TextOverflow.ellipsis, style: _mono(10, color: muted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // ALLOCATION
  // ============================================================

  Widget _allocationCard({
    required Map<String, double> portfolio,
    required double totalValue,
  }) {
    final colors = [blue, teal, orange, red, purple];
    final entries = portfolio.entries.where((e) => e.value > 0).toList();
    final sections = <PieChartSectionData>[];

    for (int i = 0; i < entries.length; i++) {
      final percentage = totalValue == 0 ? 0 : (entries[i].value / totalValue) * 100;
      sections.add(
        PieChartSectionData(
          value: entries[i].value,
          color: colors[i % colors.length],
          radius: selectedAssetType == entries[i].key ? 105 : 92,
          title: '${percentage.toStringAsFixed(0)}%',
          titleStyle: _mono(15, color: Colors.white, weight: FontWeight.w900),
        ),
      );
    }

    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(icon: Icons.donut_large_rounded, title: 'Asset Allocation', subtitle: 'Where your money is invested', color: teal),
          const SizedBox(height: 25),
          SizedBox(
            height: 300,
            child: totalValue <= 0
                ? Center(child: Text('No allocation data', style: _mono(16, color: muted)))
                : PieChart(PieChartData(sections: sections, centerSpaceRadius: 68, sectionsSpace: 4)),
          ),
          const SizedBox(height: 18),
          ...List.generate(entries.length, (index) {
            final entry = entries[index];
            final percentage = totalValue == 0 ? 0 : (entry.value / totalValue) * 100;
            final color = colors[index % colors.length];
            final selected = selectedAssetType == entry.key;
            final dimmed = selectedAssetType != null && !selected;
            return GestureDetector(
              onTap: () => _toggleAsset(entry.key),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: dimmed ? 0.35 : 1.0,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                  decoration: BoxDecoration(
                    color: selected ? teal.withValues(alpha: 0.08) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: selected ? teal.withValues(alpha: 0.25) : Colors.transparent),
                  ),
                  child: Row(
                    children: [
                      Container(width: 11, height: 11, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                      const SizedBox(width: 10),
                      Expanded(child: Text(entry.key, style: _mono(14, color: white, weight: FontWeight.w600))),
                      Text('â‚¹${entry.value.toStringAsFixed(0)}', style: _mono(14, color: white, weight: FontWeight.bold)),
                      const SizedBox(width: 14),
                      SizedBox(width: 55, child: Text('${percentage.toStringAsFixed(1)}%', textAlign: TextAlign.right, style: _mono(13, color: color, weight: FontWeight.bold))),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ============================================================
  // GOAL
  // ============================================================

  Future<void> _editGoal() async {
    final controller = TextEditingController(
      text: goalAmount.toStringAsFixed(0),
    );

    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: border),
        ),
        title: Text('SET YOUR WEALTH GOAL', style: _heading(12, color: white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: _mono(17, color: white, weight: FontWeight.bold),
          cursorColor: teal,
          decoration: InputDecoration(
            prefixText: 'â‚¹ ',
            prefixStyle: _mono(17, color: teal, weight: FontWeight.bold),
            hintText: 'Example: 1000000',
            hintStyle: _mono(13, color: muted),
            filled: true,
            fillColor: surface2,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: teal, width: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CANCEL', style: _mono(12, color: muted, weight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: teal,
              foregroundColor: Colors.black,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              final value = double.tryParse(controller.text.trim());
              if (value != null && value > 0) Navigator.pop(ctx, value);
            },
            child: Text('SAVE GOAL', style: _mono(12, color: Colors.black, weight: FontWeight.bold)),
          ),
        ],
      ),
    );

    controller.dispose();
    if (result == null || result <= 0 || !mounted) return;

    setState(() => goalAmount = result);

    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).set(
        {
          'analyticsGoal': result,
          'analyticsGoalUpdatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: red,
          content: Text('Could not save goal.', style: _mono(13, color: white)),
        ),
      );
    }
  }

  Widget _goalCard({
    required double totalValue,
    required double progress,
  }) {
    final double remaining = (goalAmount - totalValue).clamp(0, goalAmount);

    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _sectionTitle(
                  icon: Icons.flag_rounded,
                  title: 'Investment Goal',
                  subtitle: 'Track your wealth target',
                  color: orange,
                ),
              ),
              IconButton(
                onPressed: _editGoal,
                tooltip: 'Edit goal',
                icon: const Icon(Icons.edit_rounded, color: orange),
              ),
            ],
          ),

          const SizedBox(height: 25),

          Center(
            child: SizedBox(
              width: 215,
              height: 215,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 195,
                    height: 195,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 18,
                      backgroundColor: Colors.white.withValues(
                        alpha: 0.055,
                      ),
                      valueColor: const AlwaysStoppedAnimation(
                        teal,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(progress * 100).toStringAsFixed(1)}%',
                        style: _mono(34, color: white, weight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'COMPLETED',
                        style: _mono(
                          10,
                          color: teal,
                          weight: FontWeight.bold,
                          spacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 25),

          _valueRow(
            'Current value',
            'â‚¹${totalValue.toStringAsFixed(0)}',
          ),

          const SizedBox(height: 11),

          _valueRow(
            'Target',
            'â‚¹${goalAmount.toStringAsFixed(0)}',
          ),

          const SizedBox(height: 11),

          _valueRow(
            'Remaining',
            'â‚¹${remaining.toStringAsFixed(0)}',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HEALTH
  // ============================================================

  Widget _healthCard({
    required bool desktop,
    required int healthScore,
    required String healthStatus,
    required String riskLevel,
    required Color riskColor,
    required List<String> suggestions,
  }) {
    final statusColor = healthScore >= 85
        ? green
        : healthScore >= 70
            ? orange
            : red;

    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            icon: Icons.favorite_rounded,
            title: 'Portfolio Health',
            subtitle: 'Diversification and risk assessment',
            color: green,
          ),

          const SizedBox(height: 25),

          if (desktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _healthScoreBox(
                    healthScore,
                    healthStatus,
                    statusColor,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: _riskBox(
                    riskLevel,
                    riskColor,
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                _healthScoreBox(
                  healthScore,
                  healthStatus,
                  statusColor,
                ),
                const SizedBox(height: 15),
                _riskBox(
                  riskLevel,
                  riskColor,
                ),
              ],
            ),

          const SizedBox(height: 25),

          Divider(color: border),

          const SizedBox(height: 22),

          Text(
            'SMART SUGGESTIONS',
            style: _mono(
              11,
              color: muted,
              weight: FontWeight.bold,
              spacing: 1.1,
            ),
          ),

          const SizedBox(height: 13),

          ...suggestions.map(
            (suggestion) {
              final bool positive =
                  suggestion.toLowerCase().contains('good') ||
                      suggestion.toLowerCase().contains('well');

              final Color color = positive ? green : orange;

              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(
                  bottom: 9,
                ),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: color.withValues(
                    alpha: 0.06,
                  ),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: color.withValues(
                      alpha: 0.15,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      positive
                          ? Icons.check_circle_rounded
                          : Icons.lightbulb_outline_rounded,
                      color: color,
                      size: 21,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        suggestion,
                        style: _mono(14, color: white, height: 1.4),
                      ),
                    ),
                    if (!positive && (suggestion.toLowerCase().contains('gold') || suggestion.toLowerCase().contains('mutual fund')))
                      OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AddInvestmentScreen()),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: color,
                          side: BorderSide(color: color.withValues(alpha: 0.4)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text('ACT', style: _mono(10, color: color, weight: FontWeight.bold)),
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

  Widget _healthScoreBox(
    int score,
    String status,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.health_and_safety_rounded,
              color: color,
              size: 31,
            ),
          ),
          const SizedBox(width: 17),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HEALTH SCORE',
                  style: _mono(
                    10,
                    color: muted,
                    weight: FontWeight.bold,
                    spacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$score / 100',
                  style: _mono(28, color: color, weight: FontWeight.w900),
                ),
                Text(
                  status,
                  style: _mono(14, color: color, weight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _riskBox(
    String risk,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shield_rounded,
              color: color,
              size: 31,
            ),
          ),
          const SizedBox(width: 17),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'RISK LEVEL',
                style: _mono(
                  10,
                  color: muted,
                  weight: FontWeight.bold,
                  spacing: 1,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                risk,
                style: _mono(27, color: color, weight: FontWeight.w900),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // AI
  // ============================================================

  Widget _aiCard({
    required List<String> recommendations,
  }) {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            icon: Icons.psychology_rounded,
            title: 'AI Recommendations',
            subtitle: 'Personalized insights for your portfolio',
            color: purple,
          ),

          const SizedBox(height: 22),

          if (recommendations.isEmpty)
            Text(
              'No recommendations available.',
              style: _mono(16, color: muted),
            )
          else
            ...recommendations.map(
              (recommendation) {
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(
                    bottom: 11,
                  ),
                  padding: const EdgeInsets.all(17),
                  decoration: BoxDecoration(
                    color: purple.withValues(
                      alpha: 0.055,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: purple.withValues(
                        alpha: 0.15,
                      ),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: purple.withValues(
                            alpha: 0.10,
                          ),
                          borderRadius: BorderRadius.circular(
                            10,
                          ),
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: purple,
                          size: 19,
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Text(
                          recommendation,
                          style: _mono(15, color: white, height: 1.45),
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
  // PERFORMANCE
  // ============================================================

  Widget _performanceCard({
    required List<PerformanceData> performanceData,
    required double totalValue,
  }) {
    final filtered = _filterPerformanceData(performanceData);
    if (filtered.isEmpty) {
      return _panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(
              icon: Icons.show_chart_rounded,
              title: 'Portfolio Performance',
              subtitle: 'Investment value trend',
              color: teal,
            ),
            const SizedBox(height: 30),
            Center(child: Text('No performance data for this period.', style: _mono(14, color: muted))),
          ],
        ),
      );
    }

    final spots = List.generate(
      filtered.length,
      (i) => FlSpot(i.toDouble(), filtered[i].value),
    );
    
double maxY = filtered.map((e) => e.value).fold<double>(
  0,
  (max, e) => e > max ? e : max,
);


    if (maxY <= 0) maxY = 100;
    maxY *= 1.18;

    return _panel(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _sectionTitle(
                  icon: Icons.show_chart_rounded,
                  title: 'Portfolio Performance',
                  subtitle: 'Track how your portfolio changes over time',
                  color: teal,
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: surface2,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: timeframes.map((range) {
                        final selected = selectedTimeframe == range;
                        return GestureDetector(
                          onTap: () => setState(() => selectedTimeframe = range),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected ? teal : Colors.transparent,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Text(
                              range,
                              style: _mono(10, color: selected ? Colors.black : muted, weight: FontWeight.bold),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text('CURRENT VALUE', style: _mono(10, color: muted, weight: FontWeight.bold, spacing: 1)),
              const Spacer(),
              Text('â‚¹${totalValue.toStringAsFixed(2)}', style: _mono(25, color: white, weight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 390,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: spots.length > 1 ? (spots.length - 1).toDouble() : 1,
                minY: 0,
                maxY: maxY,
                backgroundColor: surface2,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 4,
                  getDrawingHorizontalLine: (_) => FlLine(color: border, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 65,
                      getTitlesWidget: (value, meta) => Text(_formatValue(value), style: _mono(10, color: muted)),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 38,
                      interval: _chartInterval(filtered.length),
                      getTitlesWidget: (value, meta) {
                        final index = value.round();
                        if (index < 0 || index >= filtered.length) return const SizedBox();
                        final date = filtered[index].date;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text('${date.day}/${date.month}', style: _mono(10, color: muted)),
                        );
                      },
                    ),
                  ),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (spots) => spots.map((spot) {
                      final index = spot.x.round();
                      if (index < 0 || index >= filtered.length) return null;
                      final date = filtered[index].date;
                      return LineTooltipItem(
                        '${date.day}/${date.month}/${date.year}\nâ‚¹${spot.y.toStringAsFixed(0)}',
                        _mono(12, color: white, weight: FontWeight.bold),
                      );
                    }).toList(),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: teal,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: filtered.length <= 15),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [teal.withValues(alpha: 0.24), teal.withValues(alpha: 0.01)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatValue(double value) {
    if (value >= 10000000) {
      return 'â‚¹${(value / 10000000).toStringAsFixed(1)}Cr';
    }

    if (value >= 100000) {
      return 'â‚¹${(value / 100000).toStringAsFixed(1)}L';
    }

    if (value >= 1000) {
      return 'â‚¹${(value / 1000).toStringAsFixed(1)}K';
    }

    return 'â‚¹${value.toStringAsFixed(0)}';
  }

  // ============================================================
  // BREAKDOWN
  // ============================================================

  Widget _breakdownCard({
    required Map<String, double> portfolio,
    required double totalValue,
  }) {
    final colors = [blue, teal, orange, red, purple];
    final entries = portfolio.entries.where((e) => e.value > 0).toList();

    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(icon: Icons.bar_chart_rounded, title: 'Allocation Breakdown', subtitle: 'Detailed view of your holdings', color: blue),
          const SizedBox(height: 24),
          if (entries.isEmpty) Text('No holdings available.', style: _mono(16, color: muted)),
          ...List.generate(entries.length, (index) {
            final entry = entries[index];
            final percent = totalValue == 0 ? 0 : (entry.value / totalValue) * 100;
            final color = colors[index % colors.length];
            final selected = selectedAssetType == entry.key;
            final dimmed = selectedAssetType != null && !selected;
            return GestureDetector(
              onTap: () => _toggleAsset(entry.key),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: dimmed ? 0.35 : 1.0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: selected ? teal.withValues(alpha: 0.08) : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: selected ? teal.withValues(alpha: 0.35) : Colors.transparent),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(entry.key, style: _mono(15, color: white, weight: FontWeight.w600)),
                          const Spacer(),
                          Text('â‚¹${entry.value.toStringAsFixed(0)}', style: _mono(15, color: white, weight: FontWeight.bold)),
                          const SizedBox(width: 15),
                          SizedBox(width: 60, child: Text('${percent.toStringAsFixed(1)}%', textAlign: TextAlign.right, style: _mono(13, color: color, weight: FontWeight.bold))),
                        ],
                      ),
                      const SizedBox(height: 9),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: percent / 100,
                          minHeight: 9,
                          backgroundColor: Colors.white.withValues(alpha: 0.05),
                          valueColor: AlwaysStoppedAnimation(color),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ============================================================
  // GENERIC PANEL
  // ============================================================

  Widget _panel({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(27),
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: border,
        ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: child,
      ),
    );
  }

  // ============================================================
  // SECTION TITLE â€” used by every card, so this one edit point
  // keeps all section headers themed consistently.
  // ============================================================

  Widget _sectionTitle({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: color.withValues(alpha: 0.18),
            ),
          ),
          child: Icon(
            icon,
            color: color,
            size: 25,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: _heading(13, color: white),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: _mono(13, color: muted),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // VALUE ROW
  // ============================================================

  Widget _valueRow(
    String label,
    String value,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: surface2,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: _mono(14, color: muted),
          ),
          const Spacer(),
          Text(
            value,
            style: _mono(16, color: white, weight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// KPI MODEL
// ==================================================================

class _KpiData {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _KpiData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  });
}

// ==================================================================
// TRANSACTION INSIGHTS
// ==================================================================

class TransactionInsights extends StatelessWidget {
  final String userId;

  const TransactionInsights({
    super.key,
    required this.userId,
  });

  static const Color surface = PortfolioAnalyticsScreen.surface;
  static const Color surface2 = PortfolioAnalyticsScreen.surface2;
  static const Color border = PortfolioAnalyticsScreen.border;
  static const Color teal = PortfolioAnalyticsScreen.teal;
  static const Color white = PortfolioAnalyticsScreen.white;
  static const Color muted = PortfolioAnalyticsScreen.muted;
  static const Color green = PortfolioAnalyticsScreen.green;
  static const Color red = PortfolioAnalyticsScreen.red;
  static const Color orange = PortfolioAnalyticsScreen.orange;

  // ============================================================
  // LOAD TRANSACTIONS
  // ============================================================

  Future<Map<String, dynamic>> loadTransactions() async {
    double bought = 0;
    double sold = 0;
    double dividends = 0;

    int buyCount = 0;
    int sellCount = 0;
    int dividendCount = 0;

    final investments = await FirebaseFirestore.instance
        .collection('investments')
        .where(
          'userId',
          isEqualTo: userId,
        )
        .get();

    for (final investment in investments.docs) {
      final transactions = await FirebaseFirestore.instance
          .collection('investments')
          .doc(investment.id)
          .collection('transactions')
          .get();

      for (final transaction in transactions.docs) {
        final data = transaction.data();

        final String type = data['type']?.toString() ?? '';

        final double amount = PortfolioAnalyticsScreen.safeDouble(
          data['amount'],
        );

        if (type == 'BUY') {
          bought += amount;
          buyCount++;
        } else if (type == 'SELL') {
          sold += amount;
          sellCount++;
        } else if (type == 'DIVIDEND') {
          dividends += amount;
          dividendCount++;
        }
      }
    }

    return {
      'bought': bought,
      'sold': sold,
      'dividends': dividends,
      'buyCount': buyCount,
      'sellCount': sellCount,
      'dividendCount': dividendCount,
    };
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: loadTransactions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _panel(
            child: Column(
              children: [
                _transactionSkeleton(),
                const SizedBox(height: 12),
                _transactionSkeleton(),
                const SizedBox(height: 12),
                _transactionSkeleton(),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return _panel(
            child: Text(
              'Unable to load transaction insights.',
              style: _mono(16, color: muted),
            ),
          );
        }

        final data = snapshot.data ?? {};

        final double bought = PortfolioAnalyticsScreen.safeDouble(
          data['bought'],
        );

        final double sold = PortfolioAnalyticsScreen.safeDouble(
          data['sold'],
        );

        final double dividends = PortfolioAnalyticsScreen.safeDouble(
          data['dividends'],
        );

        final int buyCount = PortfolioAnalyticsScreen.safeInt(
          data['buyCount'],
        );

        final int sellCount = PortfolioAnalyticsScreen.safeInt(
          data['sellCount'],
        );

        final int dividendCount = PortfolioAnalyticsScreen.safeInt(
          data['dividendCount'],
        );

        return _panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),

              const SizedBox(height: 23),

              LayoutBuilder(
                builder: (context, constraints) {
                  final bool wide = constraints.maxWidth >= 800;

                  final cards = [
                    _transactionCard(
                      title: 'BOUGHT',
                      amount: bought,
                      count: buyCount,
                      color: green,
                      icon: Icons.arrow_downward_rounded,
                    ),
                    _transactionCard(
                      title: 'SOLD',
                      amount: sold,
                      count: sellCount,
                      color: red,
                      icon: Icons.arrow_upward_rounded,
                    ),
                    _transactionCard(
                      title: 'DIVIDENDS',
                      amount: dividends,
                      count: dividendCount,
                      color: orange,
                      icon: Icons.account_balance_wallet_rounded,
                    ),
                  ];

                  if (wide) {
                    return Row(
                      children: [
                        Expanded(
                          child: cards[0],
                        ),
                        const SizedBox(
                          width: 14,
                        ),
                        Expanded(
                          child: cards[1],
                        ),
                        const SizedBox(
                          width: 14,
                        ),
                        Expanded(
                          child: cards[2],
                        ),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      cards[0],
                      const SizedBox(
                        height: 12,
                      ),
                      cards[1],
                      const SizedBox(
                        height: 12,
                      ),
                      cards[2],
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: surface2,
                  borderRadius: BorderRadius.circular(
                    14,
                  ),
                  border: Border.all(
                    color: border,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 43,
                      height: 43,
                      decoration: BoxDecoration(
                        color: teal.withValues(
                          alpha: 0.10,
                        ),
                        borderRadius: BorderRadius.circular(
                          12,
                        ),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: teal,
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NET INVESTMENT',
                            style: _mono(
                              10,
                              color: muted,
                              weight: FontWeight.bold,
                              spacing: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Bought minus sold value',
                            style: _mono(12, color: muted),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'â‚¹${(bought - sold).toStringAsFixed(2)}',
                      style: _mono(20, color: white, weight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _transactionSkeleton() {
    return Container(
      height: 78,
      width: double.infinity,
      decoration: BoxDecoration(
        color: surface2,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 90, height: 10, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(5))),
                const SizedBox(height: 10),
                Container(width: 150, height: 14, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(5))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: teal.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(
            Icons.receipt_long_rounded,
            color: teal,
            size: 26,
          ),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transaction Insights',
              style: _heading(13, color: white),
            ),
            const SizedBox(height: 8),
            Text(
              'Your investment activity',
              style: _mono(13, color: muted),
            ),
          ],
        ),
      ],
    );
  }

  Widget _transactionCard({
    required String title,
    required double amount,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: color.withValues(alpha: 0.16),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: _mono(
                    10,
                    color: muted,
                    weight: FontWeight.bold,
                    spacing: 1,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'â‚¹${amount.toStringAsFixed(0)}',
                  overflow: TextOverflow.ellipsis,
                  style: _mono(19, color: color, weight: FontWeight.w900),
                ),
                const SizedBox(height: 3),
                Text(
                  '$count transaction${count == 1 ? '' : 's'}',
                  style: _mono(11, color: muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _panel({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(27),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
