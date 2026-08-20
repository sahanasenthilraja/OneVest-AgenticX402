import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../models/performance_data.dart';
import '../services/ai_recommendation_service.dart';
import '../widgets/app_sidebar.dart';
import 'add_investment_screen.dart';
import 'portfolio_screen.dart';

// ============================================================================
// PORTFOLIO ANALYTICS SCREEN
// ============================================================================

class PortfolioAnalyticsScreen extends StatelessWidget {
  const PortfolioAnalyticsScreen({super.key});

  // ==========================================================================
  // ONEVEST THEME
  // ==========================================================================

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

  // Unicode-safe characters.
  static const String rupee = '\u20B9';
  static const String bullet = '\u00B7';

  // ==========================================================================
  // NUMBER HELPERS
  // ==========================================================================

  static double safeDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value.trim()) ?? 0;
    }

    return 0;
  }

  static int safeInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value.trim()) ?? 0;
    }

    return 0;
  }

  // ==========================================================================
  // FONT HELPERS
  // ==========================================================================

  static TextStyle heading(
    double size, {
    Color color = white,
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

  static TextStyle mono(
    double size, {
    Color color = white,
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

  // ==========================================================================
  // MAIN
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: background,
        body: Center(
          child: Text(
            'Please sign in again.',
            style: mono(18, color: white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: background,
      body: Row(
        children: [
          const AppSidebar(
            current: SidebarItem.analytics,
          ),
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
                    return _stateMessage(
                      title: 'Unable to Load Analytics',
                      subtitle:
                          'Check your connection and try again.',
                      icon: Icons.error_outline_rounded,
                      color: red,
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return _stateMessage(
                      title: 'No Investments Yet',
                      subtitle:
                          'Add an investment to unlock your complete portfolio analytics.',
                      icon: Icons.analytics_rounded,
                      color: teal,
                    );
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

  Widget _stateMessage({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Center(
      child: Container(
        width: 540,
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(24),
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
            Icon(
              icon,
              color: color,
              size: 60,
            ),
            const SizedBox(height: 22),
            Text(
              title,
              textAlign: TextAlign.center,
              style: mono(
                18,
                color: white,
                weight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: mono(
                13,
                color: muted,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// ANALYTICS BODY
// ============================================================================

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
  // ==========================================================================
  // THEME
  // ==========================================================================

  static const Color surface =
      PortfolioAnalyticsScreen.surface;

  static const Color surface2 =
      PortfolioAnalyticsScreen.surface2;

  static const Color border =
      PortfolioAnalyticsScreen.border;

  static const Color teal =
      PortfolioAnalyticsScreen.teal;

  static const Color white =
      PortfolioAnalyticsScreen.white;

  static const Color muted =
      PortfolioAnalyticsScreen.muted;

  static const Color green =
      PortfolioAnalyticsScreen.green;

  static const Color red =
      PortfolioAnalyticsScreen.red;

  static const Color orange =
      PortfolioAnalyticsScreen.orange;

  static const Color blue =
      PortfolioAnalyticsScreen.blue;

  static const Color purple =
      PortfolioAnalyticsScreen.purple;

  static const String rupee =
      PortfolioAnalyticsScreen.rupee;

  static const String bullet =
      PortfolioAnalyticsScreen.bullet;

  // ==========================================================================
  // STATE
  // ==========================================================================

  double goalAmount = 1000000;

  String selectedTimeframe = '1M';

  String? selectedAssetType;

  final GlobalKey healthKey = GlobalKey();

  final Map<String, double> _livePrices = {};

  Timer? _marketTimer;

  bool _marketLoading = false;

  List<QueryDocumentSnapshot> get docs => widget.docs;

  // ==========================================================================
  // MARKET API
  // ==========================================================================

  String get _marketBaseUrl {
    // Android Emulator -> Windows host machine.
    if (!kIsWeb &&
        defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:4021';
    }

    // Chrome / Windows desktop -> localhost.
    return 'http://localhost:4021';
  }

  String? _marketSymbol(
    Map<String, dynamic> data,
  ) {
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

    final name =
        (data['name'] ?? data['assetName'] ?? '')
            .toString()
            .trim()
            .toUpperCase();

    final type =
        (data['investmentType'] ?? '')
            .toString()
            .trim()
            .toUpperCase();

    if (name.contains('RELIANCE')) {
      return 'RELIANCE.NS';
    }

    if (name.contains('INFY') ||
        name.contains('INFOSYS')) {
      return 'INFY.NS';
    }

    if (name.contains('NIFTY')) {
      return '^NSEI';
    }

    if (name.contains('SENSEX')) {
      return '^BSESN';
    }

    if (name.contains('BITCOIN') ||
        name == 'BTC') {
      return 'BTC-INR';
    }

    if (name.contains('ETHEREUM') ||
        name == 'ETH') {
      return 'ETH-INR';
    }

    if (name.contains('GOLD') ||
        type == 'GOLD') {
      return 'GC=F';
    }

    return null;
  }

  Future<void> _fetchLivePrices() async {
    if (!mounted || _marketLoading) {
      return;
    }

    final symbols = <String>{};

    for (final doc in docs) {
      final data =
          doc.data() as Map<String, dynamic>;

      final symbol = _marketSymbol(data);

      if (symbol != null) {
        symbols.add(symbol);
      }
    }

    if (symbols.isEmpty) {
      return;
    }

    setState(() {
      _marketLoading = true;
    });

    try {
      final updates = <String, double>{};

      await Future.wait(
        symbols.map(
          (symbol) async {
            try {
              final uri = Uri.parse(
                '$_marketBaseUrl/api/market-price'
                '?symbol=${Uri.encodeComponent(symbol)}',
              );

              debugPrint(
                'Analytics: fetching $symbol',
              );

              final response = await http
                  .get(uri)
                  .timeout(
                    const Duration(seconds: 10),
                  );

              debugPrint(
                'Analytics: $symbol -> '
                '${response.statusCode}',
              );

              if (response.statusCode != 200) {
                return;
              }

              final decoded =
                  jsonDecode(response.body);

              if (decoded
                  is! Map<String, dynamic>) {
                return;
              }

              final market = decoded['market'];

              if (market
                  is! Map<String, dynamic>) {
                return;
              }

              final price =
                  PortfolioAnalyticsScreen
                      .safeDouble(
                market['price'],
              );

              if (price > 0) {
                updates[symbol] = price;
              }
            } catch (e) {
              debugPrint(
                'Analytics: failed $symbol -> $e',
              );
            }
          },
        ),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _livePrices
          ..clear()
          ..addAll(updates);
      });
    } finally {
      if (mounted) {
        setState(() {
          _marketLoading = false;
        });
      }
    }
  }

  double _currentPrice(
    Map<String, dynamic> data,
    double buyPrice,
  ) {
    final symbol = _marketSymbol(data);

    if (symbol != null) {
      final livePrice = _livePrices[symbol];

      if (livePrice != null && livePrice > 0) {
        return livePrice;
      }
    }

    final stored =
        PortfolioAnalyticsScreen.safeDouble(
      data['currentPrice'],
    );

    if (stored > 0) {
      return stored;
    }

    return buyPrice;
  }

  // ==========================================================================
  // INITIALIZATION
  // ==========================================================================

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

  // ==========================================================================
  // GOAL
  // ==========================================================================

  Future<void> _loadGoal() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (!mounted) {
        return;
      }

      final data = doc.data();

      final value =
          PortfolioAnalyticsScreen.safeDouble(
        data?['analyticsGoal'],
      );

      if (value > 0) {
        setState(() {
          goalAmount = value;
        });
      }
    } catch (_) {}
  }

  Future<void> _editGoal() async {
    final controller = TextEditingController(
      text: goalAmount.toStringAsFixed(0),
    );

    final result = await showDialog<double>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(
              color: border,
            ),
          ),
          title: Text(
            'SET YOUR WEALTH GOAL',
            style: PortfolioAnalyticsScreen
                .heading(
              12,
              color: white,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType:
                const TextInputType.numberWithOptions(
              decimal: true,
            ),
            style:
                PortfolioAnalyticsScreen.mono(
              17,
              color: white,
              weight: FontWeight.bold,
            ),
            cursorColor: teal,
            decoration: InputDecoration(
              prefixText: '$rupee ',
              prefixStyle:
                  PortfolioAnalyticsScreen.mono(
                17,
                color: teal,
                weight: FontWeight.bold,
              ),
              hintText: 'Example: 1000000',
              hintStyle:
                  PortfolioAnalyticsScreen.mono(
                13,
                color: muted,
              ),
              filled: true,
              fillColor: surface2,
              enabledBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(12),
                borderSide:
                    const BorderSide(
                  color: border,
                ),
              ),
              focusedBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(12),
                borderSide:
                    const BorderSide(
                  color: teal,
                  width: 1.5,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(ctx),
              child: Text(
                'CANCEL',
                style: PortfolioAnalyticsScreen
                    .mono(
                  11,
                  color: muted,
                  weight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(
                backgroundColor: teal,
                foregroundColor: Colors.black,
                elevation: 0,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                final value =
                    double.tryParse(
                  controller.text.trim(),
                );

                if (value != null &&
                    value > 0) {
                  Navigator.pop(
                    ctx,
                    value,
                  );
                }
              },
              child: Text(
                'SAVE GOAL',
                style: PortfolioAnalyticsScreen
                    .mono(
                  11,
                  color: Colors.black,
                  weight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (result == null ||
        result <= 0 ||
        !mounted) {
      return;
    }

    setState(() {
      goalAmount = result;
    });

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .set(
        {
          'analyticsGoal': result,
          'analyticsGoalUpdatedAt':
              FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          backgroundColor: red,
          content: Text(
            'Could not save goal.',
            style:
                PortfolioAnalyticsScreen.mono(
              12,
              color: white,
            ),
          ),
        ),
      );
    }
  }

  // ==========================================================================
  // DATE HELPERS
  // ==========================================================================

  DateTime _investmentDate(
    Map<String, dynamic> data,
    int fallbackIndex,
  ) {
    final candidates = [
      data['purchaseDate'],
      data['date'],
      data['createdAt'],
      data['timestamp'],
    ];

    for (final value in candidates) {
      if (value is Timestamp) {
        return value.toDate();
      }

      if (value is DateTime) {
        return value;
      }

      if (value is String) {
        final parsed =
            DateTime.tryParse(value);

        if (parsed != null) {
          return parsed;
        }
      }
    }

    return DateTime.now().subtract(
      Duration(
        days: docs.length - fallbackIndex,
      ),
    );
  }

  // ==========================================================================
  // PERFORMANCE FILTER
  // ==========================================================================

  final List<String> timeframes = const [
    '1W',
    '1M',
    '3M',
    '1Y',
    'All',
  ];

  List<PerformanceData> _filterPerformanceData(
    List<PerformanceData> data,
  ) {
    if (data.isEmpty ||
        selectedTimeframe == 'All') {
      return data;
    }

    Duration duration;

    switch (selectedTimeframe) {
      case '1W':
        duration =
            const Duration(days: 7);
        break;

      case '1M':
        duration =
            const Duration(days: 30);
        break;

      case '3M':
        duration =
            const Duration(days: 90);
        break;

      case '1Y':
        duration =
            const Duration(days: 365);
        break;

      default:
        duration =
            const Duration(days: 30);
    }

    final start =
        DateTime.now().subtract(duration);

    return data
        .where(
          (item) =>
              !item.date.isBefore(start),
        )
        .toList();
  }

  double _chartInterval(int length) {
    if (length <= 5) {
      return 1;
    }

    if (length <= 10) {
      return 2;
    }

    if (length <= 20) {
      return 4;
    }

    return math
        .max(
          1,
          (length / 6).ceil(),
        )
        .toDouble();
  }

  // ==========================================================================
  // SCROLL TO HEALTH
  // ==========================================================================

  void _scrollToHealth() {
    final ctx =
        healthKey.currentContext;

    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration:
            const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    }
  }

  // ==========================================================================
  // ASSET SELECTION
  // ==========================================================================

  void _toggleAsset(String asset) {
    setState(() {
      selectedAssetType =
          selectedAssetType == asset
              ? null
              : asset;
    });
  }

  // ==========================================================================
  // MAIN BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    // ------------------------------------------------------------------------
    // PORTFOLIO CALCULATIONS
    // ------------------------------------------------------------------------

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
      final data =
          doc.data() as Map<String, dynamic>;

      final buyPrice =
          PortfolioAnalyticsScreen
              .safeDouble(
        data['buyPrice'],
      );

      final currentPrice =
          _currentPrice(
        data,
        buyPrice,
      );

      final quantity =
          PortfolioAnalyticsScreen.safeInt(
        data['quantity'],
      );

      final invested =
          buyPrice * quantity;

      final currentValue =
          currentPrice * quantity;

      totalInvested += invested;
      totalValue += currentValue;

      final type =
          data['investmentType']
                  ?.toString() ??
              'Other';

      portfolio[type] =
          (portfolio[type] ?? 0) +
              currentValue;
    }

    final profitLoss =
        totalValue - totalInvested;

    final returnPercent =
        totalInvested == 0
            ? 0
            : (profitLoss /
                    totalInvested) *
                100;

    double goalProgress =
        goalAmount == 0
            ? 0
            : totalValue / goalAmount;

    goalProgress =
        goalProgress.clamp(0.0, 1.0);

    // ------------------------------------------------------------------------
    // PORTFOLIO HEALTH
    // ------------------------------------------------------------------------

    int healthScore = 100;

    final List<String> suggestions = [];

    final assetTypes = portfolio.entries
        .where(
          (entry) => entry.value > 0,
        )
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

    final cryptoPercent =
        totalValue == 0
            ? 0
            : ((portfolio['Crypto'] ??
                        0) /
                    totalValue) *
                100;

    if (cryptoPercent > 20) {
      healthScore -= 15;

      suggestions.add(
        'Reduce Crypto exposure',
      );
    }

    final goldPercent =
        totalValue == 0
            ? 0
            : ((portfolio['Gold'] ??
                        0) /
                    totalValue) *
                100;

    if (goldPercent < 5) {
      healthScore -= 10;

      suggestions.add(
        'Consider adding Gold',
      );
    }

    final mutualFundPercent =
        totalValue == 0
            ? 0
            : ((portfolio['Mutual Fund'] ??
                        0) /
                    totalValue) *
                100;

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

    healthScore =
        healthScore.clamp(0, 100);

    final String healthStatus =
        healthScore >= 85
            ? 'Excellent'
            : healthScore >= 70
                ? 'Good'
                : healthScore >= 50
                    ? 'Average'
                    : 'Needs Improvement';

    final String riskLevel =
        healthScore >= 85
            ? 'Low'
            : healthScore >= 70
                ? 'Medium'
                : 'High';

    final Color riskColor =
        healthScore >= 85
            ? green
            : healthScore >= 70
                ? orange
                : red;

    // ------------------------------------------------------------------------
    // AI RECOMMENDATIONS
    // ------------------------------------------------------------------------

    final recommendations =
        AIRecommendationService
            .getRecommendations(
      portfolio,
    );

    // ------------------------------------------------------------------------
    // PERFORMANCE DATA
    // ------------------------------------------------------------------------

    final sortedDocs = [...docs];

    sortedDocs.sort(
      (a, b) {
        final ad =
            a.data()
                as Map<String, dynamic>;

        final bd =
            b.data()
                as Map<String, dynamic>;

        return _investmentDate(
          ad,
          0,
        ).compareTo(
          _investmentDate(
            bd,
            0,
          ),
        );
      },
    );

    final List<PerformanceData>
        performanceData = [];

    double runningValue = 0;

    for (int i = 0;
        i < sortedDocs.length;
        i++) {
      final data =
          sortedDocs[i].data()
              as Map<String, dynamic>;

      final buyPrice =
          PortfolioAnalyticsScreen
              .safeDouble(
        data['buyPrice'],
      );

      final currentPrice =
          _currentPrice(
        data,
        buyPrice,
      );

      final quantity =
          PortfolioAnalyticsScreen.safeInt(
        data['quantity'],
      );

      final value =
          currentPrice * quantity;

      runningValue += value;

      performanceData.add(
        PerformanceData(
          date: _investmentDate(
            data,
            i,
          ),
          value: runningValue,
        ),
      );
    }

    // =========================================================================
    // RESPONSIVE UI
    // =========================================================================

    return LayoutBuilder(
      builder:
          (context, constraints) {
        final width =
            constraints.maxWidth;

        final desktop =
            width >= 1100;

        final tablet =
            width >= 700;

        final horizontalPadding =
            desktop
                ? 42.0
                : tablet
                    ? 28.0
                    : 16.0;

        return CustomScrollView(
          physics:
              const BouncingScrollPhysics(),
          slivers: [
            // HEADER
            SliverToBoxAdapter(
              child: _topHeader(
                desktop,
              ),
            ),

            SliverPadding(
              padding:
                  EdgeInsets.fromLTRB(
                horizontalPadding,
                8,
                horizontalPadding,
                45,
              ),
              sliver: SliverList(
                delegate:
                    SliverChildListDelegate(
                  [
                    // HERO
                    _heroSection(
                      totalValue:
                          totalValue,
                      totalInvested:
                          totalInvested,
                      profitLoss:
                          profitLoss,
                      returnPercent:
                          returnPercent.toDouble(),
                      goalProgress:
                          goalProgress,
                    ),

                    const SizedBox(
                      height: 22,
                    ),

                    // KPI
                    _kpiSection(
                      desktop:
                          desktop,
                      tablet:
                          tablet,
                      totalValue:
                          totalValue,
                      totalInvested:
                          totalInvested,
                      profitLoss:
                          profitLoss,
                      healthScore:
                          healthScore,
                    ),

                    const SizedBox(
                      height: 22,
                    ),

                    // ALLOCATION + GOAL
                    if (desktop)
                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Expanded(
                            flex: 6,
                            child:
                                _allocationCard(
                              portfolio:
                                  portfolio,
                              totalValue:
                                  totalValue,
                            ),
                          ),
                          const SizedBox(
                            width: 22,
                          ),
                          Expanded(
                            flex: 4,
                            child:
                                _goalCard(
                              totalValue:
                                  totalValue,
                              progress:
                                  goalProgress,
                            ),
                          ),
                        ],
                      )
                    else ...[
                      _allocationCard(
                        portfolio:
                            portfolio,
                        totalValue:
                            totalValue,
                      ),
                      const SizedBox(
                        height: 22,
                      ),
                      _goalCard(
                        totalValue:
                            totalValue,
                        progress:
                            goalProgress,
                      ),
                    ],

                    const SizedBox(
                      height: 22,
                    ),

                    // HEALTH
                    KeyedSubtree(
                      key: healthKey,
                      child: _healthCard(
                        desktop:
                            desktop,
                        healthScore:
                            healthScore,
                        healthStatus:
                            healthStatus,
                        riskLevel:
                            riskLevel,
                        riskColor:
                            riskColor,
                        suggestions:
                            suggestions,
                      ),
                    ),

                    const SizedBox(
                      height: 22,
                    ),

                    // AI
                    _aiCard(
                      recommendations:
                          recommendations,
                    ),

                    const SizedBox(
                      height: 22,
                    ),

                    // TRANSACTIONS
                    TransactionInsights(
                      userId:
                          widget.userId,
                    ),

                    const SizedBox(
                      height: 22,
                    ),

                    // PERFORMANCE
                    _performanceCard(
                      performanceData:
                          performanceData,
                      totalValue:
                          totalValue,
                    ),

                    const SizedBox(
                      height: 22,
                    ),

                    // BREAKDOWN
                    _breakdownCard(
                      portfolio:
                          portfolio,
                      totalValue:
                          totalValue,
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

  // ==========================================================================
  // HEADER
  // ==========================================================================

  Widget _topHeader(
    bool desktop,
  ) {
    return Padding(
      padding:
          EdgeInsets.fromLTRB(
        desktop ? 42 : 18,
        28,
        desktop ? 42 : 18,
        22,
      ),
      child: Row(
        children: [
          _iconContainer(
            icon:
                Icons.analytics_rounded,
            color: teal,
            size: 56,
          ),
          const SizedBox(width: 17),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'PORTFOLIO ANALYTICS',
                  style:
                      PortfolioAnalyticsScreen
                          .heading(
                    14,
                    color: white,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  'Understand your wealth, performance and risk',
                  style:
                      PortfolioAnalyticsScreen
                          .mono(
                    13,
                    color: muted,
                  ),
                ),
              ],
            ),
          ),
          if (desktop)
            _marketStatus(),
        ],
      ),
    );
  }

  Widget _marketStatus() {
    final color =
        _marketLoading
            ? orange
            : green;

    final text =
        _marketLoading
            ? 'UPDATING MARKET'
            : 'LIVE MARKET';

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 11,
      ),
      decoration:
          BoxDecoration(
        color:
            color.withValues(
          alpha: 0.07,
        ),
        borderRadius:
            BorderRadius.circular(30),
        border: Border.all(
          color:
              color.withValues(
            alpha: 0.22,
          ),
        ),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            color: color,
            size: 8,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style:
                PortfolioAnalyticsScreen
                    .mono(
              9,
              color: color,
              weight:
                  FontWeight.bold,
              spacing: 0.7,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // HERO
  // ==========================================================================

  Widget _heroSection({
    required double totalValue,
    required double totalInvested,
    required double profitLoss,
    required double returnPercent,
    required double goalProgress,
  }) {
    final positive =
        profitLoss >= 0;

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(30),
      decoration:
          BoxDecoration(
        gradient:
            const LinearGradient(
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
          colors: [
            Color(0xFF102B47),
            Color(0xFF0B172C),
          ],
        ),
        borderRadius:
            BorderRadius.circular(25),
        border: Border.all(
          color:
              teal.withValues(
            alpha: 0.20,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(
              alpha: 0.28,
            ),
            blurRadius: 28,
            offset:
                const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconContainer(
                icon: Icons
                    .account_balance_wallet_rounded,
                color: teal,
                size: 48,
              ),
              const SizedBox(
                width: 14,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'YOUR WEALTH DASHBOARD',
                      style:
                          PortfolioAnalyticsScreen
                              .mono(
                        11,
                        color: teal,
                        weight:
                            FontWeight.bold,
                        spacing: 1.4,
                      ),
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    Text(
                      'Real-time portfolio overview',
                      style:
                          PortfolioAnalyticsScreen
                              .mono(
                        13,
                        color: muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 28,
          ),

          Text(
            'TOTAL PORTFOLIO VALUE',
            style:
                PortfolioAnalyticsScreen
                    .mono(
              11,
              color: muted,
              weight:
                  FontWeight.bold,
              spacing: 1.3,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            '$rupee${totalValue.toStringAsFixed(2)}',
            style:
                PortfolioAnalyticsScreen
                    .mono(
              40,
              color: white,
              weight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(
            height: 25,
          ),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _heroMetric(
                title: 'INVESTED',
                value:
                    '$rupee${totalInvested.toStringAsFixed(0)}',
                icon:
                    Icons.savings_rounded,
                color: purple,
              ),
              _heroMetric(
                title:
                    'PROFIT / LOSS',
                value:
                    '${positive ? '+' : '-'}$rupee${profitLoss.abs().toStringAsFixed(0)}',
                icon: positive
                    ? Icons
                        .trending_up_rounded
                    : Icons
                        .trending_down_rounded,
                color:
                    positive ? green : red,
              ),
              _heroMetric(
                title: 'RETURN',
                value:
                    '${returnPercent.toStringAsFixed(2)}%',
                icon:
                    Icons.percent_rounded,
                color:
                    positive ? green : red,
              ),
              _heroMetric(
                title: 'GOAL',
                value:
                    '${(goalProgress * 100).toStringAsFixed(0)}%',
                icon:
                    Icons.flag_rounded,
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
      padding:
          const EdgeInsets.all(16),
      decoration:
          BoxDecoration(
        color:
            Colors.white.withValues(
          alpha: 0.035,
        ),
        borderRadius:
            BorderRadius.circular(15),
        border: Border.all(
          color:
              Colors.white.withValues(
            alpha: 0.07,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 23,
          ),
          const SizedBox(
            width: 12,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                      PortfolioAnalyticsScreen
                          .mono(
                    9,
                    color: muted,
                    weight:
                        FontWeight.bold,
                    spacing: 0.7,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  value,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      PortfolioAnalyticsScreen
                          .mono(
                    17,
                    color: color,
                    weight:
                        FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // KPI
  // ==========================================================================

  Widget _kpiSection({
    required bool desktop,
    required bool tablet,
    required double totalValue,
    required double totalInvested,
    required double profitLoss,
    required int healthScore,
  }) {
    final positive =
        profitLoss >= 0;

    final cards = [
      _KpiData(
        title: 'PORTFOLIO VALUE',
        value:
            '$rupee${totalValue.toStringAsFixed(0)}',
        subtitle:
            'Current market value $bullet tap to open',
        icon:
            Icons.account_balance_wallet_rounded,
        color: teal,
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
      _KpiData(
        title: 'TOTAL INVESTED',
        value:
            '$rupee${totalInvested.toStringAsFixed(0)}',
        subtitle:
            'Capital deployed',
        icon:
            Icons.savings_rounded,
        color: purple,
      ),
      _KpiData(
        title: 'PROFIT / LOSS',
        value:
            '${positive ? '+' : '-'}$rupee${profitLoss.abs().toStringAsFixed(0)}',
        subtitle: positive
            ? 'Portfolio is positive'
            : 'Portfolio is negative',
        icon: positive
            ? Icons.trending_up_rounded
            : Icons.trending_down_rounded,
        color:
            positive ? green : red,
      ),
      _KpiData(
        title: 'HEALTH SCORE',
        value:
            '$healthScore / 100',
        subtitle:
            'Portfolio quality $bullet tap to view',
        icon:
            Icons.favorite_rounded,
        color: green,
        onTap:
            _scrollToHealth,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: desktop
            ? 4
            : tablet
                ? 2
                : 1,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio:
            desktop
                ? 2.05
                : tablet
                    ? 2.4
                    : 3.4,
      ),
      itemBuilder:
          (context, index) {
        final card =
            cards[index];

        return MouseRegion(
          cursor:
              card.onTap != null
                  ? SystemMouseCursors
                      .click
                  : SystemMouseCursors
                      .basic,
          child: GestureDetector(
            onTap:
                card.onTap,
            child: Container(
              padding:
                  const EdgeInsets.all(19),
              decoration:
                  BoxDecoration(
                color: surface,
                borderRadius:
                    BorderRadius.circular(
                  18,
                ),
                border: Border.all(
                  color: border,
                ),
              ),
              child: Row(
                children: [
                  _iconContainer(
                    icon: card.icon,
                    color: card.color,
                    size: 48,
                  ),
                  const SizedBox(
                    width: 13,
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Text(
                          card.title,
                          style:
                              PortfolioAnalyticsScreen
                                  .mono(
                            9,
                            color: muted,
                            weight:
                                FontWeight.bold,
                            spacing:
                                0.7,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          card.value,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style:
                              PortfolioAnalyticsScreen
                                  .mono(
                            18,
                            color: white,
                            weight:
                                FontWeight.w900,
                          ),
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        Text(
                          card.subtitle,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style:
                              PortfolioAnalyticsScreen
                                  .mono(
                            9,
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
    );
  }

  // ==========================================================================
  // ALLOCATION
  // ==========================================================================

  Widget _allocationCard({
    required Map<String, double> portfolio,
    required double totalValue,
  }) {
    final colors = [
      blue,
      teal,
      orange,
      red,
      purple,
    ];

    final entries = portfolio.entries
        .where(
          (entry) => entry.value > 0,
        )
        .toList();

    final sections =
        <PieChartSectionData>[];

    for (int i = 0;
        i < entries.length;
        i++) {
      final percentage =
          totalValue == 0
              ? 0
              : (entries[i].value /
                      totalValue) *
                  100;

      sections.add(
        PieChartSectionData(
          value:
              entries[i].value,
          color:
              colors[i % colors.length],
          radius:
              selectedAssetType ==
                      entries[i].key
                  ? 105
                  : 92,
          title:
              '${percentage.toStringAsFixed(0)}%',
          titleStyle:
              PortfolioAnalyticsScreen
                  .mono(
            13,
            color:
                Colors.white,
            weight:
                FontWeight.w900,
          ),
        ),
      );
    }

    return _panel(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            icon:
                Icons.donut_large_rounded,
            title:
                'Asset Allocation',
            subtitle:
                'Where your money is invested',
            color: teal,
          ),

          const SizedBox(
            height: 22,
          ),

          SizedBox(
            height: 290,
            child: totalValue <= 0
                ? Center(
                    child: Text(
                      'No allocation data',
                      style:
                          PortfolioAnalyticsScreen
                              .mono(
                        14,
                        color: muted,
                      ),
                    ),
                  )
                : PieChart(
                    PieChartData(
                      sections:
                          sections,
                      centerSpaceRadius:
                          68,
                      sectionsSpace:
                          4,
                    ),
                  ),
          ),

          const SizedBox(
            height: 16,
          ),

          ...List.generate(
            entries.length,
            (index) {
              final entry =
                  entries[index];

              final percentage =
                  totalValue == 0
                      ? 0
                      : (entry.value /
                              totalValue) *
                          100;

              final color =
                  colors[index %
                      colors.length];

              final selected =
                  selectedAssetType ==
                      entry.key;

              final dimmed =
                  selectedAssetType !=
                          null &&
                      !selected;

              return GestureDetector(
                onTap: () =>
                    _toggleAsset(
                  entry.key,
                ),
                child:
                    AnimatedOpacity(
                  duration:
                      const Duration(
                    milliseconds: 180,
                  ),
                  opacity:
                      dimmed
                          ? 0.35
                          : 1.0,
                  child:
                      Container(
                    margin:
                        const EdgeInsets
                            .only(
                      bottom: 9,
                    ),
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 11,
                      vertical: 10,
                    ),
                    decoration:
                        BoxDecoration(
                      color: selected
                          ? teal.withValues(
                              alpha: 0.08,
                            )
                          : Colors
                              .transparent,
                      borderRadius:
                          BorderRadius
                              .circular(
                        12,
                      ),
                      border:
                          Border.all(
                        color: selected
                            ? teal.withValues(
                                alpha:
                                    0.25,
                              )
                            : Colors
                                .transparent,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 11,
                          height: 11,
                          decoration:
                              BoxDecoration(
                            color:
                                color,
                            shape:
                                BoxShape
                                    .circle,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            entry.key,
                            style:
                                PortfolioAnalyticsScreen
                                    .mono(
                              12,
                              color:
                                  white,
                              weight:
                                  FontWeight
                                      .w600,
                            ),
                          ),
                        ),
                        Text(
                          '$rupee${entry.value.toStringAsFixed(0)}',
                          style:
                              PortfolioAnalyticsScreen
                                  .mono(
                            12,
                            color:
                                white,
                            weight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                        const SizedBox(
                          width: 14,
                        ),
                        SizedBox(
                          width: 55,
                          child: Text(
                            '${percentage.toStringAsFixed(1)}%',
                            textAlign:
                                TextAlign
                                    .right,
                            style:
                                PortfolioAnalyticsScreen
                                    .mono(
                              11,
                              color:
                                  color,
                              weight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // GOAL
  // ==========================================================================

  Widget _goalCard({
    required double totalValue,
    required double progress,
  }) {
    final remaining =
        math.max(
      0,
      goalAmount - totalValue,
    );

    return _panel(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child:
                    _sectionTitle(
                  icon:
                      Icons.flag_rounded,
                  title:
                      'Investment Goal',
                  subtitle:
                      'Track your wealth target',
                  color: orange,
                ),
              ),
              IconButton(
                onPressed:
                    _editGoal,
                tooltip:
                    'Edit goal',
                icon:
                    const Icon(
                  Icons.edit_rounded,
                  color: orange,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 20,
          ),

          Center(
            child: SizedBox(
              width: 215,
              height: 215,
              child: Stack(
                alignment:
                    Alignment.center,
                children: [
                  SizedBox(
                    width: 195,
                    height: 195,
                    child:
                        CircularProgressIndicator(
                      value:
                          progress,
                      strokeWidth:
                          18,
                      backgroundColor:
                          Colors.white
                              .withValues(
                        alpha:
                            0.055,
                      ),
                      valueColor:
                          const AlwaysStoppedAnimation(
                        teal,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      Text(
                        '${(progress * 100).toStringAsFixed(1)}%',
                        style:
                            PortfolioAnalyticsScreen
                                .mono(
                          32,
                          color:
                              white,
                          weight:
                              FontWeight
                                  .w900,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        'COMPLETED',
                        style:
                            PortfolioAnalyticsScreen
                                .mono(
                          9,
                          color:
                              teal,
                          weight:
                              FontWeight
                                  .bold,
                          spacing:
                              1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(
            height: 22,
          ),

          _valueRow(
            'Current value',
            '$rupee${totalValue.toStringAsFixed(0)}',
          ),

          const SizedBox(
            height: 10,
          ),

          _valueRow(
            'Target',
            '$rupee${goalAmount.toStringAsFixed(0)}',
          ),

          const SizedBox(
            height: 10,
          ),

          _valueRow(
            'Remaining',
            '$rupee${remaining.toStringAsFixed(0)}',
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // HEALTH
  // ==========================================================================

  Widget _healthCard({
    required bool desktop,
    required int healthScore,
    required String healthStatus,
    required String riskLevel,
    required Color riskColor,
    required List<String> suggestions,
  }) {
    final statusColor =
        healthScore >= 85
            ? green
            : healthScore >= 70
                ? orange
                : red;

    return _panel(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            icon:
                Icons.favorite_rounded,
            title:
                'Portfolio Health',
            subtitle:
                'Diversification and risk assessment',
            color: green,
          ),

          const SizedBox(
            height: 23,
          ),

          if (desktop)
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Expanded(
                  child:
                      _healthScoreBox(
                    healthScore,
                    healthStatus,
                    statusColor,
                  ),
                ),
                const SizedBox(
                  width: 18,
                ),
                Expanded(
                  child:
                      _riskBox(
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
                const SizedBox(
                  height: 15,
                ),
                _riskBox(
                  riskLevel,
                  riskColor,
                ),
              ],
            ),

          const SizedBox(
            height: 24,
          ),

          Divider(
            color: border,
          ),

          const SizedBox(
            height: 20,
          ),

          Text(
            'SMART SUGGESTIONS',
            style:
                PortfolioAnalyticsScreen
                    .mono(
              10,
              color: muted,
              weight:
                  FontWeight.bold,
              spacing: 1.1,
            ),
          ),

          const SizedBox(
            height: 13,
          ),

          ...suggestions.map(
            (suggestion) {
              final positive =
                  suggestion
                          .toLowerCase()
                          .contains(
                            'good',
                          ) ||
                      suggestion
                          .toLowerCase()
                          .contains(
                            'well',
                          );

              final color =
                  positive
                      ? green
                      : orange;

              final actionable =
                  !positive &&
                  (suggestion
                          .toLowerCase()
                          .contains(
                            'gold',
                          ) ||
                      suggestion
                          .toLowerCase()
                          .contains(
                            'mutual fund',
                          ));

              return Container(
                width:
                    double.infinity,
                margin:
                    const EdgeInsets
                        .only(
                  bottom: 9,
                ),
                padding:
                    const EdgeInsets.all(
                  15,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      color.withValues(
                    alpha: 0.06,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    13,
                  ),
                  border:
                      Border.all(
                    color:
                        color.withValues(
                      alpha: 0.15,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      positive
                          ? Icons
                              .check_circle_rounded
                          : Icons
                              .lightbulb_outline_rounded,
                      color: color,
                      size: 21,
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child: Text(
                        suggestion,
                        style:
                            PortfolioAnalyticsScreen
                                .mono(
                          12,
                          color:
                              white,
                          height:
                              1.4,
                        ),
                      ),
                    ),
                    if (actionable)
                      OutlinedButton(
                        onPressed:
                            () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) =>
                                      const AddInvestmentScreen(),
                            ),
                          );
                        },
                        style:
                            OutlinedButton.styleFrom(
                          foregroundColor:
                              color,
                          side:
                              BorderSide(
                            color:
                                color.withValues(
                              alpha:
                                  0.4,
                            ),
                          ),
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal:
                                10,
                            vertical:
                                8,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              10,
                            ),
                          ),
                        ),
                        child:
                            Text(
                          'ACT',
                          style:
                              PortfolioAnalyticsScreen
                                  .mono(
                            9,
                            color:
                                color,
                            weight:
                                FontWeight
                                    .bold,
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

  Widget _healthScoreBox(
    int score,
    String status,
    Color color,
  ) {
    return _healthMetricBox(
      icon:
          Icons.health_and_safety_rounded,
      title:
          'HEALTH SCORE',
      value:
          '$score / 100',
      subtitle:
          status,
      color:
          color,
    );
  }

  Widget _riskBox(
    String risk,
    Color color,
  ) {
    return _healthMetricBox(
      icon:
          Icons.shield_rounded,
      title:
          'RISK LEVEL',
      value:
          risk,
      subtitle:
          'Based on current allocation',
      color:
          color,
    );
  }

  Widget _healthMetricBox({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(21),
      decoration:
          BoxDecoration(
        color:
            color.withValues(
          alpha: 0.055,
        ),
        borderRadius:
            BorderRadius.circular(17),
        border:
            Border.all(
          color:
              color.withValues(
            alpha: 0.15,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration:
                BoxDecoration(
              color:
                  color.withValues(
                alpha: 0.10,
              ),
              shape:
                  BoxShape.circle,
            ),
            child: Icon(
              icon,
              color:
                  color,
              size: 31,
            ),
          ),
          const SizedBox(
            width: 17,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  title,
                  style:
                      PortfolioAnalyticsScreen
                          .mono(
                    9,
                    color:
                        muted,
                    weight:
                        FontWeight
                            .bold,
                    spacing:
                        1,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  value,
                  style:
                      PortfolioAnalyticsScreen
                          .mono(
                    25,
                    color:
                        color,
                    weight:
                        FontWeight
                            .w900,
                  ),
                ),
                Text(
                  subtitle,
                  style:
                      PortfolioAnalyticsScreen
                          .mono(
                    10,
                    color:
                        color,
                    weight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // AI RECOMMENDATIONS
  // ==========================================================================

  Widget _aiCard({
    required List<String> recommendations,
  }) {
    return _panel(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            icon:
                Icons.psychology_rounded,
            title:
                'AI Recommendations',
            subtitle:
                'Personalized insights for your portfolio',
            color:
                purple,
          ),

          const SizedBox(
            height: 22,
          ),

          if (recommendations.isEmpty)
            Text(
              'No recommendations available.',
              style:
                  PortfolioAnalyticsScreen
                      .mono(
                13,
                color:
                    muted,
              ),
            )
          else
            ...recommendations.map(
              (recommendation) {
                return Container(
                  width:
                      double.infinity,
                  margin:
                      const EdgeInsets
                          .only(
                    bottom: 11,
                  ),
                  padding:
                      const EdgeInsets.all(
                    17,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        purple.withValues(
                      alpha: 0.055,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                    border:
                        Border.all(
                      color:
                          purple.withValues(
                        alpha: 0.15,
                      ),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      _iconContainer(
                        icon:
                            Icons
                                .auto_awesome_rounded,
                        color:
                            purple,
                        size: 36,
                      ),
                      const SizedBox(
                        width: 13,
                      ),
                      Expanded(
                        child: Text(
                          recommendation,
                          style:
                              PortfolioAnalyticsScreen
                                  .mono(
                            12,
                            color:
                                white,
                            height:
                                1.45,
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

  // ==========================================================================
  // PERFORMANCE
  // ==========================================================================

  Widget _performanceCard({
    required List<PerformanceData>
        performanceData,
    required double totalValue,
  }) {
    final filtered =
        _filterPerformanceData(
      performanceData,
    );

    if (filtered.isEmpty) {
      return _panel(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            _sectionTitle(
              icon:
                  Icons.show_chart_rounded,
              title:
                  'Portfolio Performance',
              subtitle:
                  'Investment value trend',
              color:
                  teal,
            ),
            const SizedBox(
              height: 30,
            ),
            Center(
              child: Text(
                'No performance data for this period.',
                style:
                    PortfolioAnalyticsScreen
                        .mono(
                  13,
                  color:
                      muted,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final spots =
        List.generate(
      filtered.length,
      (index) => FlSpot(
        index.toDouble(),
        filtered[index].value,
      ),
    );

    double maxY = 0;

    for (final item in filtered) {
      if (item.value > maxY) {
        maxY = item.value;
      }
    }

    if (maxY <= 0) {
      maxY = 100;
    }

    maxY *= 1.18;

    return _panel(
      padding:
          const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Expanded(
                child:
                    _sectionTitle(
                  icon:
                      Icons.show_chart_rounded,
                  title:
                      'Portfolio Performance',
                  subtitle:
                      'Track how your portfolio changes over time',
                  color:
                      teal,
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              Flexible(
                child:
                    SingleChildScrollView(
                  scrollDirection:
                      Axis.horizontal,
                  child:
                      Container(
                    padding:
                        const EdgeInsets.all(
                      4,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          surface2,
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                      border:
                          Border.all(
                        color:
                            border,
                      ),
                    ),
                    child:
                        Row(
                      mainAxisSize:
                          MainAxisSize
                              .min,
                      children:
                          timeframes.map(
                        (range) {
                          final selected =
                              selectedTimeframe ==
                                  range;

                          return GestureDetector(
                            onTap:
                                () {
                              setState(
                                () {
                                  selectedTimeframe =
                                      range;
                                },
                              );
                            },
                            child:
                                AnimatedContainer(
                              duration:
                                  const Duration(
                                milliseconds:
                                    180,
                              ),
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal:
                                    11,
                                vertical:
                                    8,
                              ),
                              decoration:
                                  BoxDecoration(
                                color:
                                    selected
                                        ? teal
                                        : Colors
                                            .transparent,
                                borderRadius:
                                    BorderRadius.circular(
                                  9,
                                ),
                              ),
                              child:
                                  Text(
                                range,
                                style:
                                    PortfolioAnalyticsScreen
                                        .mono(
                                  9,
                                  color:
                                      selected
                                          ? Colors
                                              .black
                                          : muted,
                                  weight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 24,
          ),

          Row(
            children: [
              Text(
                'CURRENT VALUE',
                style:
                    PortfolioAnalyticsScreen
                        .mono(
                  9,
                  color:
                      muted,
                  weight:
                      FontWeight.bold,
                  spacing:
                      1,
                ),
              ),
              const Spacer(),
              Text(
                '$rupee${totalValue.toStringAsFixed(2)}',
                style:
                    PortfolioAnalyticsScreen
                        .mono(
                  23,
                  color:
                      white,
                  weight:
                      FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 22,
          ),

          SizedBox(
            height: 390,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: spots.length > 1
                    ? (spots.length - 1)
                        .toDouble()
                    : 1,
                minY: 0,
                maxY: maxY,
                backgroundColor:
                    surface2,

                gridData:
                    FlGridData(
                  show: true,
                  drawVerticalLine:
                      false,
                  horizontalInterval:
                      maxY / 4,
                  getDrawingHorizontalLine:
                      (_) {
                    return FlLine(
                      color:
                          border,
                      strokeWidth:
                          1,
                    );
                  },
                ),

                borderData:
                    FlBorderData(
                  show: false,
                ),

                titlesData:
                    FlTitlesData(
                  topTitles:
                      const AxisTitles(
                    sideTitles:
                        SideTitles(
                      showTitles:
                          false,
                    ),
                  ),
                  rightTitles:
                      const AxisTitles(
                    sideTitles:
                        SideTitles(
                      showTitles:
                          false,
                    ),
                  ),

                  leftTitles:
                      AxisTitles(
                    sideTitles:
                        SideTitles(
                      showTitles:
                          true,
                      reservedSize:
                          65,
                      getTitlesWidget:
                          (value, meta) {
                        return Text(
                          _formatValue(
                            value,
                          ),
                          style:
                              PortfolioAnalyticsScreen
                                  .mono(
                            9,
                            color:
                                muted,
                          ),
                        );
                      },
                    ),
                  ),

                  bottomTitles:
                      AxisTitles(
                    sideTitles:
                        SideTitles(
                      showTitles:
                          true,
                      reservedSize:
                          38,
                      interval:
                          _chartInterval(
                        filtered.length,
                      ),
                      getTitlesWidget:
                          (value, meta) {
                        final index =
                            value.round();

                        if (index <
                                0 ||
                            index >=
                                filtered
                                    .length) {
                          return const SizedBox();
                        }

                        final date =
                            filtered[
                                    index]
                                .date;

                        return Padding(
                          padding:
                              const EdgeInsets
                                  .only(
                            top:
                                8,
                          ),
                          child:
                              Text(
                            '${date.day}/${date.month}',
                            style:
                                PortfolioAnalyticsScreen
                                    .mono(
                              9,
                              color:
                                  muted,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                lineTouchData:
                    LineTouchData(
                  touchTooltipData:
                      LineTouchTooltipData(
                    getTooltipItems:
                        (spots) {
                      return spots
                          .map(
                        (spot) {
                          final index =
                              spot.x
                                  .round();

                          if (index <
                                  0 ||
                              index >=
                                  filtered
                                      .length) {
                            return null;
                          }

                          final date =
                              filtered[
                                      index]
                                  .date;

                          return LineTooltipItem(
                            '${date.day}/${date.month}/${date.year}\n'
                            '$rupee${spot.y.toStringAsFixed(0)}',
                            PortfolioAnalyticsScreen
                                .mono(
                              10,
                              color:
                                  white,
                              weight:
                                  FontWeight
                                      .bold,
                            ),
                          );
                        },
                      ).toList();
                    },
                  ),
                ),

                lineBarsData: [
                  LineChartBarData(
                    spots:
                        spots,
                    isCurved:
                        true,
                    color:
                        teal,
                    barWidth:
                        4,
                    isStrokeCapRound:
                        true,
                    dotData:
                        FlDotData(
                      show:
                          filtered.length <=
                              15,
                    ),
                    belowBarData:
                        BarAreaData(
                      show:
                          true,
                      gradient:
                          LinearGradient(
                        begin:
                            Alignment
                                .topCenter,
                        end:
                            Alignment
                                .bottomCenter,
                        colors: [
                          teal.withValues(
                            alpha:
                                0.24,
                          ),
                          teal.withValues(
                            alpha:
                                0.01,
                          ),
                        ],
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

  String _formatValue(
    double value,
  ) {
    if (value >= 10000000) {
      return '$rupee${(value / 10000000).toStringAsFixed(1)}Cr';
    }

    if (value >= 100000) {
      return '$rupee${(value / 100000).toStringAsFixed(1)}L';
    }

    if (value >= 1000) {
      return '$rupee${(value / 1000).toStringAsFixed(1)}K';
    }

    return '$rupee${value.toStringAsFixed(0)}';
  }

  // ==========================================================================
  // BREAKDOWN
  // ==========================================================================

  Widget _breakdownCard({
    required Map<String, double> portfolio,
    required double totalValue,
  }) {
    final colors = [
      blue,
      teal,
      orange,
      red,
      purple,
    ];

    final entries = portfolio.entries
        .where(
          (entry) => entry.value > 0,
        )
        .toList();

    return _panel(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            icon:
                Icons.bar_chart_rounded,
            title:
                'Allocation Breakdown',
            subtitle:
                'Detailed view of your holdings',
            color: blue,
          ),

          const SizedBox(
            height: 24,
          ),

          if (entries.isEmpty)
            Text(
              'No holdings available.',
              style:
                  PortfolioAnalyticsScreen
                      .mono(
                14,
                color:
                    muted,
              ),
            ),

          ...List.generate(
            entries.length,
            (index) {
              final entry =
                  entries[index];

              final percent =
                  totalValue == 0
                      ? 0
                      : (entry.value /
                              totalValue) *
                          100;

              final color =
                  colors[index %
                      colors.length];

              final selected =
                  selectedAssetType ==
                      entry.key;

              final dimmed =
                  selectedAssetType !=
                          null &&
                      !selected;

              return GestureDetector(
                onTap: () =>
                    _toggleAsset(
                  entry.key,
                ),
                child:
                    AnimatedOpacity(
                  duration:
                      const Duration(
                    milliseconds: 180,
                  ),
                  opacity:
                      dimmed
                          ? 0.35
                          : 1.0,
                  child:
                      AnimatedContainer(
                    duration:
                        const Duration(
                      milliseconds:
                          180,
                    ),
                    padding:
                        const EdgeInsets.all(
                      12,
                    ),
                    margin:
                        const EdgeInsets
                            .only(
                      bottom: 10,
                    ),
                    decoration:
                        BoxDecoration(
                      color: selected
                          ? teal.withValues(
                              alpha:
                                  0.08,
                            )
                          : surface2,
                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                      border:
                          Border.all(
                        color: selected
                            ? teal.withValues(
                                alpha:
                                    0.35,
                              )
                            : border,
                      ),
                    ),
                    child:
                        Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              entry.key,
                              style:
                                  PortfolioAnalyticsScreen
                                      .mono(
                                13,
                                color:
                                    white,
                                weight:
                                    FontWeight
                                        .w600,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '$rupee${entry.value.toStringAsFixed(0)}',
                              style:
                                  PortfolioAnalyticsScreen
                                      .mono(
                                13,
                                color:
                                    white,
                                weight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            SizedBox(
                              width: 60,
                              child:
                                  Text(
                                '${percent.toStringAsFixed(1)}%',
                                textAlign:
                                    TextAlign
                                        .right,
                                style:
                                    PortfolioAnalyticsScreen
                                        .mono(
                                  11,
                                  color:
                                      color,
                                  weight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 9,
                        ),
                        ClipRRect(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            20,
                          ),
                          child:
                              LinearProgressIndicator(
                            value:
                                percent /
                                    100,
                            minHeight:
                                8,
                            backgroundColor:
                                Colors.white
                                    .withValues(
                              alpha:
                                  0.05,
                            ),
                            valueColor:
                                AlwaysStoppedAnimation(
                              color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // GENERIC PANEL
  // ==========================================================================

  Widget _panel({
    required Widget child,
    EdgeInsetsGeometry padding =
        const EdgeInsets.all(27),
  }) {
    return Container(
      width:
          double.infinity,
      padding:
          padding,
      decoration:
          BoxDecoration(
        color:
            surface,
        borderRadius:
            BorderRadius.circular(
          22,
        ),
        border:
            Border.all(
          color:
              border,
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(
              alpha:
                  0.18,
            ),
            blurRadius:
                20,
            offset:
                const Offset(
              0,
              8,
            ),
          ),
        ],
      ),
      child:
          child,
    );
  }

  // ==========================================================================
  // SECTION TITLE
  // ==========================================================================

  Widget _sectionTitle({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Row(
      children: [
        _iconContainer(
          icon:
              icon,
          color:
              color,
          size:
              52,
        ),
        const SizedBox(
          width: 15,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              Text(
                title,
                style:
                    PortfolioAnalyticsScreen
                        .heading(
                  12,
                  color:
                      white,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                subtitle,
                style:
                    PortfolioAnalyticsScreen
                        .mono(
                  11,
                  color:
                      muted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // ICON CONTAINER
  // ==========================================================================

  Widget _iconContainer({
    required IconData icon,
    required Color color,
    required double size,
  }) {
    return Container(
      width:
          size,
      height:
          size,
      decoration:
          BoxDecoration(
        color:
            color.withValues(
          alpha:
              0.10,
        ),
        borderRadius:
            BorderRadius.circular(
          size >= 50
              ? 15
              : 13,
        ),
        border:
            Border.all(
          color:
              color.withValues(
            alpha:
                0.17,
          ),
        ),
      ),
      child:
          Icon(
        icon,
        color:
            color,
        size:
            size * 0.48,
      ),
    );
  }

  // ==========================================================================
  // VALUE ROW
  // ==========================================================================

  Widget _valueRow(
    String label,
    String value,
  ) {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.symmetric(
        horizontal:
            16,
        vertical:
            15,
      ),
      decoration:
          BoxDecoration(
        color:
            surface2,
        borderRadius:
            BorderRadius.circular(
          13,
        ),
      ),
      child:
          Row(
        children: [
          Text(
            label,
            style:
                PortfolioAnalyticsScreen
                    .mono(
              12,
              color:
                  muted,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style:
                PortfolioAnalyticsScreen
                    .mono(
              14,
              color:
                  white,
              weight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// KPI MODEL
// ============================================================================

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

// ============================================================================
// TRANSACTION INSIGHTS
// ============================================================================

class TransactionInsights
    extends StatelessWidget {
  final String userId;

  const TransactionInsights({
    super.key,
    required this.userId,
  });

  static const Color surface =
      PortfolioAnalyticsScreen.surface;

  static const Color surface2 =
      PortfolioAnalyticsScreen.surface2;

  static const Color border =
      PortfolioAnalyticsScreen.border;

  static const Color teal =
      PortfolioAnalyticsScreen.teal;

  static const Color white =
      PortfolioAnalyticsScreen.white;

  static const Color muted =
      PortfolioAnalyticsScreen.muted;

  static const Color green =
      PortfolioAnalyticsScreen.green;

  static const Color red =
      PortfolioAnalyticsScreen.red;

  static const Color orange =
      PortfolioAnalyticsScreen.orange;

  static const String rupee =
      PortfolioAnalyticsScreen.rupee;

  // ==========================================================================
  // LOAD TRANSACTIONS
  // ==========================================================================

  Future<Map<String, dynamic>>
      loadTransactions() async {
    double bought = 0;
    double sold = 0;
    double dividends = 0;

    int buyCount = 0;
    int sellCount = 0;
    int dividendCount = 0;

    final investments =
        await FirebaseFirestore
            .instance
            .collection(
              'investments',
            )
            .where(
              'userId',
              isEqualTo:
                  userId,
            )
            .get();

    for (final investment
        in investments.docs) {
      final transactions =
          await FirebaseFirestore
              .instance
              .collection(
                'investments',
              )
              .doc(
                investment.id,
              )
              .collection(
                'transactions',
              )
              .get();

      for (final transaction
          in transactions.docs) {
        final data =
            transaction.data();

        final type =
            data['type']
                    ?.toString() ??
                '';

        final amount =
            PortfolioAnalyticsScreen
                .safeDouble(
          data['amount'],
        );

        if (type == 'BUY') {
          bought += amount;
          buyCount++;
        } else if (type == 'SELL') {
          sold += amount;
          sellCount++;
        } else if (type ==
            'DIVIDEND') {
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
      'dividendCount':
          dividendCount,
    };
  }

  // ==========================================================================
  // UI
  // ==========================================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return FutureBuilder<
        Map<String, dynamic>>(
      future:
          loadTransactions(),
      builder:
          (context, snapshot) {
        if (snapshot
                .connectionState ==
            ConnectionState.waiting) {
          return _panel(
            child:
                const SizedBox(
              height: 130,
              child:
                  Center(
                child:
                    CircularProgressIndicator(
                  color:
                      teal,
                ),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return _panel(
            child: Text(
              'Unable to load transaction insights.',
              style:
                  PortfolioAnalyticsScreen
                      .mono(
                13,
                color:
                    muted,
              ),
            ),
          );
        }

        final data =
            snapshot.data ??
                {};

        final bought =
            PortfolioAnalyticsScreen
                .safeDouble(
          data['bought'],
        );

        final sold =
            PortfolioAnalyticsScreen
                .safeDouble(
          data['sold'],
        );

        final dividends =
            PortfolioAnalyticsScreen
                .safeDouble(
          data['dividends'],
        );

        final buyCount =
            PortfolioAnalyticsScreen
                .safeInt(
          data['buyCount'],
        );

        final sellCount =
            PortfolioAnalyticsScreen
                .safeInt(
          data['sellCount'],
        );

        final dividendCount =
            PortfolioAnalyticsScreen
                .safeInt(
          data['dividendCount'],
        );

        return _panel(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              _header(),

              const SizedBox(
                height: 23,
              ),

              LayoutBuilder(
                builder:
                    (
                  context,
                  constraints,
                ) {
                  final wide =
                      constraints
                              .maxWidth >=
                          800;

                  final cards = [
                    _transactionCard(
                      title:
                          'BOUGHT',
                      amount:
                          bought,
                      count:
                          buyCount,
                      color:
                          green,
                      icon:
                          Icons
                              .arrow_downward_rounded,
                    ),
                    _transactionCard(
                      title:
                          'SOLD',
                      amount:
                          sold,
                      count:
                          sellCount,
                      color:
                          red,
                      icon:
                          Icons
                              .arrow_upward_rounded,
                    ),
                    _transactionCard(
                      title:
                          'DIVIDENDS',
                      amount:
                          dividends,
                      count:
                          dividendCount,
                      color:
                          orange,
                      icon:
                          Icons
                              .account_balance_wallet_rounded,
                    ),
                  ];

                  if (wide) {
                    return Row(
                      children: [
                        Expanded(
                          child:
                              cards[0],
                        ),
                        const SizedBox(
                          width:
                              14,
                        ),
                        Expanded(
                          child:
                              cards[1],
                        ),
                        const SizedBox(
                          width:
                              14,
                        ),
                        Expanded(
                          child:
                              cards[2],
                        ),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      cards[0],
                      const SizedBox(
                        height:
                            12,
                      ),
                      cards[1],
                      const SizedBox(
                        height:
                            12,
                      ),
                      cards[2],
                    ],
                  );
                },
              ),

              const SizedBox(
                height: 16,
              ),

              Container(
                width:
                    double.infinity,
                padding:
                    const EdgeInsets.all(
                  18,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      surface2,
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                  border:
                      Border.all(
                    color:
                        border,
                  ),
                ),
                child: Row(
                  children: [
                    _iconContainer(
                      icon:
                          Icons
                              .account_balance_wallet_rounded,
                      color:
                          teal,
                      size:
                          43,
                    ),
                    const SizedBox(
                      width:
                          13,
                    ),
                    Expanded(
                      child:
                          Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            'NET INVESTMENT',
                            style:
                                PortfolioAnalyticsScreen
                                    .mono(
                              9,
                              color:
                                  muted,
                              weight:
                                  FontWeight
                                      .bold,
                              spacing:
                                  1,
                            ),
                          ),
                          const SizedBox(
                            height:
                                4,
                          ),
                          Text(
                            'Bought minus sold value',
                            style:
                                PortfolioAnalyticsScreen
                                    .mono(
                              10,
                              color:
                                  muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '$rupee${(bought - sold).toStringAsFixed(2)}',
                      style:
                          PortfolioAnalyticsScreen
                              .mono(
                        19,
                        color:
                            white,
                        weight:
                            FontWeight
                                .w900,
                      ),
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

  // ==========================================================================
  // TRANSACTION HEADER
  // ==========================================================================

  Widget _header() {
    return Row(
      children: [
        _iconContainer(
          icon:
              Icons.receipt_long_rounded,
          color:
              teal,
          size:
              52,
        ),
        const SizedBox(
          width:
              15,
        ),
        Column(
          crossAxisAlignment:
              CrossAxisAlignment
                  .start,
          children: [
            Text(
              'Transaction Insights',
              style:
                  PortfolioAnalyticsScreen
                      .heading(
                12,
                color:
                    white,
              ),
            ),
            const SizedBox(
              height:
                  8,
            ),
            Text(
              'Your investment activity',
              style:
                  PortfolioAnalyticsScreen
                      .mono(
                11,
                color:
                    muted,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================================================
  // TRANSACTION CARD
  // ==========================================================================

  Widget _transactionCard({
    required String title,
    required double amount,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding:
          const EdgeInsets.all(
        18,
      ),
      decoration:
          BoxDecoration(
        color:
            color.withValues(
          alpha:
              0.05,
        ),
        borderRadius:
            BorderRadius.circular(
          15,
        ),
        border:
            Border.all(
          color:
              color.withValues(
            alpha:
                0.16,
          ),
        ),
      ),
      child: Row(
        children: [
          _iconContainer(
            icon:
                icon,
            color:
                color,
            size:
                45,
          ),
          const SizedBox(
            width:
                12,
          ),
          Expanded(
            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  title,
                  style:
                      PortfolioAnalyticsScreen
                          .mono(
                    9,
                    color:
                        muted,
                    weight:
                        FontWeight
                            .bold,
                    spacing:
                        1,
                  ),
                ),
                const SizedBox(
                  height:
                      5,
                ),
                Text(
                  '$rupee${amount.toStringAsFixed(0)}',
                  overflow:
                      TextOverflow
                          .ellipsis,
                  style:
                      PortfolioAnalyticsScreen
                          .mono(
                    18,
                    color:
                        color,
                    weight:
                        FontWeight
                            .w900,
                  ),
                ),
                const SizedBox(
                  height:
                      3,
                ),
                Text(
                  '$count transaction${count == 1 ? '' : 's'}',
                  style:
                      PortfolioAnalyticsScreen
                          .mono(
                    10,
                    color:
                        muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // TRANSACTION PANEL
  // ==========================================================================

  Widget _panel({
    required Widget child,
  }) {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(
        27,
      ),
      decoration:
          BoxDecoration(
        color:
            surface,
        borderRadius:
            BorderRadius.circular(
          22,
        ),
        border:
            Border.all(
          color:
              border,
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(
              alpha:
                  0.18,
            ),
            blurRadius:
                20,
            offset:
                const Offset(
              0,
              8,
            ),
          ),
        ],
      ),
      child:
          child,
    );
  }

  Widget _iconContainer({
    required IconData icon,
    required Color color,
    required double size,
  }) {
    return Container(
      width:
          size,
      height:
          size,
      decoration:
          BoxDecoration(
        color:
            color.withValues(
          alpha:
              0.10,
        ),
        borderRadius:
            BorderRadius.circular(
          13,
        ),
      ),
      child:
          Icon(
        icon,
        color:
            color,
        size:
            size * 0.48,
      ),
    );
  }
}
