import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dashboard_screen.dart';
import 'portfolio_screen.dart';
import 'ai_agent_screen.dart';

class PortfolioAnalyticsScreen extends StatefulWidget {
  const PortfolioAnalyticsScreen({super.key});

  // ============================================================
  // ONEVEST COLORS
  // ============================================================

  static const Color background = Color(0xFF020B1D);
  static const Color surface = Color(0xFF0A1428);
  static const Color surface2 = Color(0xFF0F1D35);
  static const Color border = Color(0xFF243B60);

  static const Color teal = Color(0xFF14C8B0);
  static const Color white = Color(0xFFF5F8FC);
  static const Color muted = Color(0xFF91A0B8);

  static const Color green = Color(0xFF45E38A);
  static const Color red = Color(0xFFFF5A64);
  static const Color orange = Color(0xFFFFB52E);
  static const Color blue = Color(0xFF4E8CFF);
  static const Color purple = Color(0xFFA86BFF);

  @override
  State<PortfolioAnalyticsScreen> createState() =>
      _PortfolioAnalyticsScreenState();
}

class _PortfolioAnalyticsScreenState
    extends State<PortfolioAnalyticsScreen> {
  final Color background = PortfolioAnalyticsScreen.background;
  final Color surface = PortfolioAnalyticsScreen.surface;
  final Color surface2 = PortfolioAnalyticsScreen.surface2;
  final Color border = PortfolioAnalyticsScreen.border;

  final Color teal = PortfolioAnalyticsScreen.teal;
  final Color white = PortfolioAnalyticsScreen.white;
  final Color muted = PortfolioAnalyticsScreen.muted;

  final Color green = PortfolioAnalyticsScreen.green;
  final Color red = PortfolioAnalyticsScreen.red;
  final Color orange = PortfolioAnalyticsScreen.orange;
  final Color blue = PortfolioAnalyticsScreen.blue;
  final Color purple = PortfolioAnalyticsScreen.purple;

  double goalAmount = 1000000;

  int selectedIndex = 2;

  // ============================================================
  // FONT HELPERS
  // ============================================================

  TextStyle mono(
    double size, {
    Color? color,
    FontWeight weight = FontWeight.normal,
  }) {
    return GoogleFonts.spaceMono(
      fontSize: size,
      color: color ?? white,
      fontWeight: weight,
    );
  }

  TextStyle heading(
    double size, {
    Color? color,
    FontWeight weight = FontWeight.bold,
  }) {
    return GoogleFonts.pressStart2p(
      fontSize: size,
      color: color ?? white,
      fontWeight: weight,
    );
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
            style: mono(16),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: background,

      // ========================================================
      // BODY
      // ========================================================

      body: SafeArea(
        bottom: false,
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
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
              return Center(
                child: CircularProgressIndicator(
                  color: teal,
                ),
              );
            }

            if (snapshot.hasError) {
              return _errorScreen(
                snapshot.error.toString(),
              );
            }

            final docs = snapshot.data?.docs ?? [];

            return _analyticsContent(docs);
          },
        ),
      ),

      // ========================================================
      // BOTTOM NAVIGATION
      // ========================================================

      bottomNavigationBar: _bottomNavigationBar(),
    );
  }

  // ============================================================
  // ANALYTICS CONTENT
  // ============================================================

  Widget _analyticsContent(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    double totalInvested = 0;
    double totalValue = 0;

    final Map<String, double> allocation = {
      'Stock': 0,
      'Mutual Fund': 0,
      'Gold': 0,
      'Crypto': 0,
      'FD': 0,
    };

    // ==========================================================
    // CALCULATE PORTFOLIO VALUES
    // ==========================================================

    for (final doc in docs) {
      final data = doc.data();

      final double buyPrice =
          _doubleValue(data['buyPrice']);

      final double currentPrice =
          _doubleValue(
        data['currentPrice'],
        fallback: buyPrice,
      );

      final double quantity =
          _doubleValue(data['quantity']);

      final double invested =
          buyPrice * quantity;

      final double currentValue =
          currentPrice * quantity;

      totalInvested += invested;
      totalValue += currentValue;

      final String type =
          data['investmentType']?.toString() ??
              'Other';

      if (allocation.containsKey(type)) {
        allocation[type] =
            allocation[type]! + currentValue;
      }
    }

    final double profitLoss =
        totalValue - totalInvested;

    final double returnPercent =
        totalInvested == 0
            ? 0
            : (profitLoss / totalInvested) * 100;

    double goalProgress =
        goalAmount == 0
            ? 0
            : totalValue / goalAmount;

    if (goalProgress > 1) {
      goalProgress = 1;
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        16,
        18,
        16,
        30,
      ),
      children: [
        // ======================================================
        // HEADER
        // ======================================================

        _header(),

        const SizedBox(height: 20),

        // ======================================================
        // HERO
        // ======================================================

        _interactiveSection(
          title: 'PORTFOLIO OVERVIEW',
          color: teal,
          child: _heroCard(
            totalValue: totalValue,
            totalInvested: totalInvested,
            profitLoss: profitLoss,
            returnPercent: returnPercent,
          ),
          popupChild: _heroPopupContent(
            totalValue,
            totalInvested,
            profitLoss,
            returnPercent,
          ),
        ),

        const SizedBox(height: 18),

        // ======================================================
        // KPI CARDS
        // ======================================================

        _interactiveSection(
          title: 'KEY METRICS',
          color: teal,
          child: _kpiSection(
            totalValue,
            totalInvested,
            profitLoss,
            returnPercent,
          ),
          popupChild: _kpiPopupContent(
            totalValue,
            totalInvested,
            profitLoss,
            returnPercent,
          ),
        ),

        const SizedBox(height: 18),

        // ======================================================
        // ALLOCATION
        // ======================================================

        _interactiveSection(
          title: 'ASSET ALLOCATION',
          color: teal,
          child: _allocationCard(
            allocation,
            totalValue,
          ),
          popupChild: _allocationPopupContent(
            allocation,
            totalValue,
          ),
        ),

        const SizedBox(height: 18),

        // ======================================================
        // INVESTMENT GOAL
        // ======================================================

        _interactiveSection(
          title: 'INVESTMENT GOAL',
          color: orange,
          child: _goalCard(
            totalValue,
            goalProgress,
          ),
          popupChild: _goalPopupContent(
            totalValue,
            goalProgress,
          ),
        ),

        const SizedBox(height: 18),

        // ======================================================
        // PORTFOLIO HEALTH
        // ======================================================

        _interactiveSection(
          title: 'PORTFOLIO HEALTH',
          color: green,
          child: _healthCard(
            allocation,
            totalValue,
          ),
          popupChild: _healthPopupContent(
            allocation,
            totalValue,
          ),
        ),

        const SizedBox(height: 18),

        // ======================================================
        // AI INSIGHTS
        // ======================================================

        _interactiveSection(
          title: 'AI PORTFOLIO INSIGHT',
          color: purple,
          child: _aiCard(
            allocation,
            totalValue,
          ),
          popupChild: _aiPopupContent(
            allocation,
            totalValue,
          ),
        ),

        const SizedBox(height: 18),

        // ======================================================
        // TRANSACTION INSIGHTS
        // ======================================================

        _interactiveSection(
          title: 'TRANSACTION INSIGHTS',
          color: blue,
          child: _transactionsCard(docs),
          popupChild: _transactionPopupContent(docs),
        ),

        const SizedBox(height: 18),

        // ======================================================
        // TIP
        // ======================================================

        _interactiveSection(
          title: 'TIP OF THE DAY',
          color: orange,
          child: _tipCard(),
          popupChild: _tipPopupContent(),
        ),

        const SizedBox(height: 18),

        // ======================================================
        // PERFORMANCE
        // ======================================================

        _interactiveSection(
          title: 'PORTFOLIO PERFORMANCE',
          color: teal,
          child: _performanceCard(
            totalInvested,
            totalValue,
            profitLoss,
          ),
          popupChild: _performancePopupContent(
            totalInvested,
            totalValue,
            profitLoss,
          ),
        ),

        const SizedBox(height: 18),

        // ======================================================
        // BREAKDOWN
        // ======================================================

        _interactiveSection(
          title: 'PORTFOLIO BREAKDOWN',
          color: blue,
          child: _breakdownCard(
            allocation,
            totalValue,
          ),
          popupChild: _breakdownPopupContent(
            allocation,
            totalValue,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _header() {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: teal.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: teal.withValues(alpha: 0.25),
            ),
          ),
          child: Icon(
            Icons.analytics_rounded,
            color: teal,
            size: 27,
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'PORTFOLIO',
                style: heading(
                  13,
                  color: teal,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Analytics',
                style: mono(
                  17,
                  color: white,
                  weight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: green.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: green.withValues(alpha: 0.20),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.circle,
                size: 7,
                color: green,
              ),

              const SizedBox(width: 6),

              Text(
                'LIVE',
                style: mono(
                  9,
                  color: green,
                  weight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // HERO CARD
  // ============================================================

  Widget _heroCard({
    required double totalValue,
    required double totalInvested,
    required double profitLoss,
    required double returnPercent,
  }) {
    final bool positive = profitLoss >= 0;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF102B47),
            Color(0xFF0B172C),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: teal.withValues(alpha: 0.20),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'TOTAL PORTFOLIO VALUE',
            style: mono(
              10,
              color: muted,
              weight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            '₹${totalValue.toStringAsFixed(0)}',
            style: mono(
              29,
              color: white,
              weight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _smallMetric(
                  'INVESTED',
                  '₹${totalInvested.toStringAsFixed(0)}',
                  purple,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _smallMetric(
                  'PROFIT',
                  '${positive ? '+' : '-'}₹${profitLoss.abs().toStringAsFixed(0)}',
                  positive ? green : red,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          _smallMetric(
            'RETURN',
            '${returnPercent.toStringAsFixed(2)}%',
            positive ? green : red,
          ),
        ],
      ),
    );
  }

  Widget _smallMetric(
    String title,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: mono(
              9,
              color: muted,
              weight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            value,
            style: mono(
              13,
              color: color,
              weight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // KPI
  // ============================================================

  Widget _kpiSection(
    double totalValue,
    double invested,
    double profit,
    double returnPercent,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          'KEY METRICS',
          Icons.insights_rounded,
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _metricCard(
                'VALUE',
                '₹${totalValue.toStringAsFixed(0)}',
                Icons.account_balance_wallet_rounded,
                teal,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _metricCard(
                'INVESTED',
                '₹${invested.toStringAsFixed(0)}',
                Icons.savings_rounded,
                purple,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _metricCard(
                'P/L',
                '₹${profit.abs().toStringAsFixed(0)}',
                profit >= 0
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                profit >= 0 ? green : red,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _metricCard(
                'RETURN',
                '${returnPercent.toStringAsFixed(1)}%',
                Icons.percent_rounded,
                orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _metricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 22,
          ),

          const SizedBox(height: 10),

          Text(
            title,
            style: mono(
              9,
              color: muted,
              weight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: mono(
              12,
              color: white,
              weight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ASSET ALLOCATION - PIE CHART
  // ============================================================

  Widget _allocationCard(
    Map<String, double> allocation,
    double totalValue,
  ) {
    final entries = allocation.entries
        .where((e) => e.value > 0)
        .toList();

    return _card(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _cardHeader(
            'ASSET ALLOCATION',
            Icons.pie_chart_rounded,
            teal,
          ),

          const SizedBox(height: 20),

          if (entries.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Text(
                  'No allocation data available.',
                  style: mono(
                    12,
                    color: muted,
                  ),
                ),
              ),
            )
          else ...[
            // ==================================================
            // DONUT CHART
            // ==================================================

            SizedBox(
              height: 220,
              width: double.infinity,
              child: CustomPaint(
                painter: _AllocationPiePainter(
                  entries: entries,
                  total: totalValue,
                  getColor: _assetColor,
                  surfaceColor: surface,
                  mutedColor: muted,
                  whiteColor: white,
                ),
              ),
            ),

            const SizedBox(height: 18),

            // ==================================================
            // LEGEND
            // ==================================================

            ...entries.map(
              (entry) {
                final percentage =
                    totalValue == 0
                        ? 0.0
                        : entry.value / totalValue;

                final color =
                    _assetColor(entry.key);

                return Padding(
                  padding:
                      const EdgeInsets.only(
                    bottom: 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          entry.key,
                          style: mono(
                            11,
                            color: white,
                            weight: FontWeight.bold,
                          ),
                        ),
                      ),

                      Text(
                        '₹${entry.value.toStringAsFixed(0)}',
                        style: mono(
                          10,
                          color: muted,
                        ),
                      ),

                      const SizedBox(width: 10),

                      SizedBox(
                        width: 48,
                        child: Text(
                          '${(percentage * 100).toStringAsFixed(1)}%',
                          textAlign:
                              TextAlign.right,
                          style: mono(
                            10,
                            color: color,
                            weight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // GOAL
  // ============================================================

  Widget _goalCard(
    double totalValue,
    double progress,
  ) {
    final double percentage =
        progress * 100;

    return _card(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _cardHeader(
            'INVESTMENT GOAL',
            Icons.flag_rounded,
            orange,
          ),

          const SizedBox(height: 18),

          Center(
            child: SizedBox(
              width: 150,
              height: 150,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 150,
                    height: 150,
                    child:
                        CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 13,
                      backgroundColor:
                          Colors.white
                              .withValues(
                        alpha: 0.06,
                      ),
                      valueColor:
                          AlwaysStoppedAnimation<
                              Color>(
                        teal,
                      ),
                    ),
                  ),

                  Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      Text(
                        '${percentage.toStringAsFixed(0)}%',
                        style: mono(
                          24,
                          color: white,
                          weight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        'COMPLETED',
                        style: mono(
                          8,
                          color: teal,
                          weight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          _goalValueRow(
            'CURRENT VALUE',
            '₹${totalValue.toStringAsFixed(0)}',
          ),

          const SizedBox(height: 8),

          _goalValueRow(
            'TARGET',
            '₹${goalAmount.toStringAsFixed(0)}',
          ),

          const SizedBox(height: 8),

          _goalValueRow(
            'REMAINING',
            '₹${(goalAmount - totalValue).clamp(0, goalAmount).toStringAsFixed(0)}',
          ),
        ],
      ),
    );
  }

  Widget _goalValueRow(
    String title,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: surface2,
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: mono(
                9,
                color: muted,
              ),
            ),
          ),

          Text(
            value,
            style: mono(
              11,
              color: white,
              weight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PORTFOLIO HEALTH
  // ============================================================

  Widget _healthCard(
    Map<String, double> allocation,
    double total,
  ) {
    final int activeAssets =
        allocation.values
            .where((value) => value > 0)
            .length;

    int score = 100;

    if (activeAssets <= 1) {
      score = 50;
    } else if (activeAssets == 2) {
      score = 70;
    } else if (activeAssets == 3) {
      score = 85;
    }

    final String status =
        score >= 85
            ? 'EXCELLENT'
            : score >= 70
                ? 'GOOD'
                : 'NEEDS IMPROVEMENT';

    final Color statusColor =
        score >= 85
            ? green
            : score >= 70
                ? orange
                : red;

    return _card(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _cardHeader(
            'PORTFOLIO HEALTH',
            Icons.favorite_rounded,
            statusColor,
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              SizedBox(
                width: 90,
                height: 90,
                child: Stack(
                  alignment:
                      Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: score / 100,
                      strokeWidth: 9,
                      backgroundColor:
                          Colors.white
                              .withValues(
                        alpha: 0.06,
                      ),
                      valueColor:
                          AlwaysStoppedAnimation<
                              Color>(
                        statusColor,
                      ),
                    ),

                    Text(
                      '$score',
                      style: mono(
                        20,
                        color: white,
                        weight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 18),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      status,
                      style: mono(
                        14,
                        color: statusColor,
                        weight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      activeAssets >= 3
                          ? 'Your portfolio has a healthy level of diversification.'
                          : 'Consider adding different asset classes to improve diversification.',
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
        ],
      ),
    );
  }

  // ============================================================
  // AI INSIGHT
  // ============================================================

  Widget _aiCard(
    Map<String, double> allocation,
    double total,
  ) {
    String message;

    final crypto =
        allocation['Crypto'] ?? 0;

    final cryptoPercent =
        total == 0
            ? 0
            : crypto / total * 100;

    message = _aiInsightMessage(
      allocation,
      total,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: purple.withValues(
            alpha: 0.35,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: purple.withValues(
                alpha: 0.12,
              ),
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: purple,
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
                  'AI PORTFOLIO INSIGHT',
                  style: mono(
                    11,
                    color: purple,
                    weight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 9),

                Text(
                  message,
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
    );
  }

  // ============================================================
  // TRANSACTION INSIGHTS
  // ============================================================

  Widget _transactionsCard(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _loadTransactionInsights(docs),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return _card(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _cardHeader(
                  'TRANSACTION INSIGHTS',
                  Icons.receipt_long_rounded,
                  blue,
                ),

                const SizedBox(height: 20),

                Center(
                  child:
                      CircularProgressIndicator(
                    color: teal,
                  ),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return _card(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _cardHeader(
                  'TRANSACTION INSIGHTS',
                  Icons.receipt_long_rounded,
                  blue,
                ),

                const SizedBox(height: 15),

                Text(
                  'Unable to load transaction insights.',
                  style: mono(
                    10,
                    color: muted,
                  ),
                ),
              ],
            ),
          );
        }

        final data =
            snapshot.data ?? {};

        final double bought =
            _doubleValue(data['bought']);

        final double sold =
            _doubleValue(data['sold']);

        final double dividends =
            _doubleValue(data['dividends']);

        final int buyCount =
            _intValue(data['buyCount']);

        final int sellCount =
            _intValue(data['sellCount']);

        final int dividendCount =
            _intValue(
          data['dividendCount'],
        );

        final int totalTransactions =
            buyCount +
                sellCount +
                dividendCount;

        final double netInvestment =
            bought - sold;

        return _card(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _cardHeader(
                'TRANSACTION INSIGHTS',
                Icons.receipt_long_rounded,
                blue,
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: _transactionInsight(
                      'BOUGHT',
                      '₹${bought.toStringAsFixed(0)}',
                      '$buyCount transactions',
                      green,
                      Icons.arrow_downward_rounded,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _transactionInsight(
                      'SOLD',
                      '₹${sold.toStringAsFixed(0)}',
                      '$sellCount transactions',
                      red,
                      Icons.arrow_upward_rounded,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _transactionInsight(
                      'DIVIDENDS',
                      '₹${dividends.toStringAsFixed(0)}',
                      '$dividendCount transactions',
                      orange,
                      Icons.account_balance_wallet_rounded,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _transactionInsight(
                      'TOTAL',
                      '$totalTransactions',
                      'all transactions',
                      blue,
                      Icons.receipt_long_rounded,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: surface2,
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_rounded,
                      color: teal,
                      size: 20,
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        'Net investment',
                        style: mono(
                          10,
                          color: muted,
                        ),
                      ),
                    ),

                    Text(
                      '₹${netInvestment.toStringAsFixed(0)}',
                      style: mono(
                        13,
                        color: white,
                        weight: FontWeight.bold,
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

  // ============================================================
  // TRANSACTION INSIGHT SMALL CARD
  // ============================================================

  Widget _transactionInsight(
    String title,
    String amount,
    String subtitle,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.05,
        ),
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(
            alpha: 0.15,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(
                alpha: 0.10,
              ),
              borderRadius:
                  BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 19,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: mono(
                    8,
                    color: muted,
                    weight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  amount,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: mono(
                    13,
                    color: color,
                    weight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  subtitle,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: mono(
                    7,
                    color: muted,
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
  // LOAD TRANSACTION DATA
  // ============================================================

  Future<Map<String, dynamic>>
      _loadTransactionInsights(
    List<QueryDocumentSnapshot<Map<String, dynamic>>>
        docs,
  ) async {
    double bought = 0;
    double sold = 0;
    double dividends = 0;

    int buyCount = 0;
    int sellCount = 0;
    int dividendCount = 0;

    for (final investment in docs) {
      try {
        final transactions =
            await FirebaseFirestore.instance
                .collection('investments')
                .doc(investment.id)
                .collection('transactions')
                .get();

        for (final transaction
            in transactions.docs) {
          final data = transaction.data();

          final String type =
              (
                data['type'] ??
                data['transactionType'] ??
                data['action'] ??
                ''
              )
                  .toString()
                  .trim()
                  .toUpperCase();

          double amount =
              _doubleValue(
            data['amount'],
          );

          // Support alternate amount field names.
          if (amount == 0) {
            amount = _doubleValue(
              data['totalAmount'],
            );
          }

          if (amount == 0) {
            amount = _doubleValue(
              data['value'],
            );
          }

          // If the transaction stores price + quantity,
          // calculate the amount.
          if (amount == 0) {
            final price =
                _doubleValue(
              data['price'],
            );

            final quantity =
                _doubleValue(
              data['quantity'],
            );

            if (price > 0 &&
                quantity > 0) {
              amount =
                  price * quantity;
            }
          }

          if (type == 'BUY' ||
              type == 'BOUGHT') {
            bought += amount;
            buyCount++;
          } else if (type == 'SELL' ||
              type == 'SOLD') {
            sold += amount;
            sellCount++;
          } else if (type == 'DIVIDEND' ||
              type == 'DIVIDENDS') {
            dividends += amount;
            dividendCount++;
          }
        }
      } catch (_) {
        // Some investments may not have
        // a transactions subcollection.
        // Ignore them and continue.
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
  // TIP
  // ============================================================

  Widget _tipCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: orange.withValues(
          alpha: 0.06,
        ),
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: orange.withValues(
            alpha: 0.18,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_rounded,
            color: orange,
            size: 26,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'TIP OF THE DAY',
                  style: mono(
                    10,
                    color: orange,
                    weight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Diversify your investments and review your portfolio regularly instead of making emotional decisions.',
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
    );
  }

  // ============================================================
  // PERFORMANCE GRAPH
  // ============================================================

  Widget _performanceCard(
    double invested,
    double value,
    double profit,
  ) {
    final double percentage =
        invested == 0
            ? 0
            : ((value - invested) /
                    invested) *
                100;

    final Color graphColor =
        percentage >= 0 ? green : red;

    return _card(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _cardHeader(
            'PORTFOLIO PERFORMANCE',
            Icons.show_chart_rounded,
            teal,
          ),

          const SizedBox(height: 18),

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              Text(
                '${percentage.toStringAsFixed(2)}%',
                style: mono(
                  28,
                  color: graphColor,
                  weight: FontWeight.bold,
                ),
              ),

              const Spacer(),

              Text(
                '₹${value.toStringAsFixed(0)}',
                style: mono(
                  12,
                  color: white,
                  weight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            percentage >= 0
                ? 'Portfolio is currently in profit.'
                : 'Portfolio is currently below invested value.',
            style: mono(
              10,
              color: muted,
            ),
          ),

          const SizedBox(height: 20),

          // ==================================================
          // GRAPH
          // ==================================================

          SizedBox(
            height: 190,
            width: double.infinity,
            child: CustomPaint(
              painter:
                  _PerformanceGraphPainter(
                invested: invested,
                value: value,
                profit: profit,
                lineColor: graphColor,
                gridColor: border,
                surfaceColor: surface,
              ),
            ),
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              _graphLegend(
                'INVESTED',
                '₹${invested.toStringAsFixed(0)}',
                purple,
              ),

              const Spacer(),

              _graphLegend(
                'CURRENT',
                '₹${value.toStringAsFixed(0)}',
                teal,
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            'Profit / Loss: ₹${profit.abs().toStringAsFixed(0)}',
            style: mono(
              10,
              color: white,
              weight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // GRAPH LEGEND
  // ============================================================

  Widget _graphLegend(
    String title,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(width: 7),

        Text(
          '$title  ',
          style: mono(
            8,
            color: muted,
            weight: FontWeight.bold,
          ),
        ),

        Text(
          value,
          style: mono(
            9,
            color: color,
            weight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PORTFOLIO BREAKDOWN
  // ============================================================

  Widget _breakdownCard(
    Map<String, double> allocation,
    double total,
  ) {
    return _card(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _cardHeader(
            'PORTFOLIO BREAKDOWN',
            Icons.bar_chart_rounded,
            blue,
          ),

          const SizedBox(height: 18),

          ...allocation.entries.map(
            (entry) {
              final double percentage =
                  total == 0
                      ? 0
                      : entry.value / total;

              return Padding(
                padding:
                    const EdgeInsets.only(
                  bottom: 13,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 85,
                      child: Text(
                        entry.key,
                        style: mono(
                          9,
                          color: white,
                        ),
                      ),
                    ),

                    Expanded(
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(
                          8,
                        ),
                        child:
                            LinearProgressIndicator(
                          value:
                              percentage
                                  .toDouble(),
                          minHeight: 6,
                          backgroundColor:
                              Colors.white
                                  .withValues(
                            alpha: 0.05,
                          ),
                          valueColor:
                              AlwaysStoppedAnimation<
                                  Color>(
                            _assetColor(
                              entry.key,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    SizedBox(
                      width: 45,
                      child: Text(
                        '${(percentage * 100).toStringAsFixed(0)}%',
                        textAlign:
                            TextAlign.right,
                        style: mono(
                          9,
                          color: muted,
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
  // DYNAMIC ANALYTICS POPUPS
  // ============================================================

  Widget _interactiveSection({
    required String title,
    required Color color,
    required Widget child,
    required Widget popupChild,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        splashColor: color.withValues(alpha: 0.08),
        highlightColor: color.withValues(alpha: 0.04),
        onTap: () {
          _showAnalyticsPopup(
            title: title,
            color: color,
            child: popupChild,
          );
        },
        child: child,
      ),
    );
  }

  void _showAnalyticsPopup({
    required String title,
    required Color color,
    required Widget child,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return Container(
          constraints: BoxConstraints(
            maxHeight:
                MediaQuery.of(sheetContext).size.height * 0.88,
          ),
          decoration: BoxDecoration(
            color: background,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
            border: Border.all(
              color: color.withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),

              Container(
                width: 46,
                height: 5,
                decoration: BoxDecoration(
                  color: muted.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  14,
                  12,
                  12,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: color.withValues(alpha: 0.22),
                        ),
                      ),
                      child: Icon(
                        Icons.touch_app_rounded,
                        color: color,
                        size: 20,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        title,
                        style: mono(
                          12,
                          color: white,
                          weight: FontWeight.bold,
                        ),
                      ),
                    ),

                    IconButton(
                      tooltip: 'Close',
                      onPressed: () =>
                          Navigator.of(sheetContext).pop(),
                      icon: Icon(
                        Icons.close_rounded,
                        color: muted,
                      ),
                    ),
                  ],
                ),
              ),

              Divider(
                height: 1,
                color: border.withValues(alpha: 0.7),
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    18,
                    18,
                    18,
                    30,
                  ),
                  child: child,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _popupSectionTitle(
    String title,
    String subtitle,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: mono(
            15,
            color: color,
            weight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: mono(
            9,
            color: muted,
          ),
        ),
      ],
    );
  }

  Widget _popupMetricRow(
    String title,
    String value,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: border.withValues(alpha: 0.8),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: mono(
                9,
                color: muted,
                weight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            value,
            style: mono(
              12,
              color: color,
              weight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroPopupContent(
    double totalValue,
    double invested,
    double profit,
    double returnPercent,
  ) {
    final positive = profit >= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _popupSectionTitle(
          'PORTFOLIO OVERVIEW',
          'Live values calculated from your investment records.',
          teal,
        ),
        const SizedBox(height: 20),
        _popupMetricRow(
          'CURRENT VALUE',
          '₹${totalValue.toStringAsFixed(0)}',
          teal,
        ),
        _popupMetricRow(
          'TOTAL INVESTED',
          '₹${invested.toStringAsFixed(0)}',
          purple,
        ),
        _popupMetricRow(
          'PROFIT / LOSS',
          '${positive ? '+' : '-'}₹${profit.abs().toStringAsFixed(0)}',
          positive ? green : red,
        ),
        _popupMetricRow(
          'RETURN',
          '${returnPercent.toStringAsFixed(2)}%',
          positive ? green : red,
        ),
        const SizedBox(height: 10),
        _popupInfoBox(
          positive
              ? 'Your current portfolio value is above the total amount invested.'
              : 'Your current portfolio value is below the total amount invested.',
          positive ? green : red,
        ),
      ],
    );
  }

  Widget _kpiPopupContent(
    double totalValue,
    double invested,
    double profit,
    double returnPercent,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _popupSectionTitle(
          'KEY METRICS',
          'Tap any metric area on the analytics screen to explore your numbers.',
          teal,
        ),
        const SizedBox(height: 20),
        _popupMetricRow(
          'PORTFOLIO VALUE',
          '₹${totalValue.toStringAsFixed(0)}',
          teal,
        ),
        _popupMetricRow(
          'INVESTED',
          '₹${invested.toStringAsFixed(0)}',
          purple,
        ),
        _popupMetricRow(
          'PROFIT / LOSS',
          '₹${profit.abs().toStringAsFixed(0)}',
          profit >= 0 ? green : red,
        ),
        _popupMetricRow(
          'RETURN',
          '${returnPercent.toStringAsFixed(2)}%',
          returnPercent >= 0 ? green : red,
        ),
      ],
    );
  }

  Widget _allocationPopupContent(
    Map<String, double> allocation,
    double totalValue,
  ) {
    final entries = allocation.entries
        .where((entry) => entry.value > 0)
        .toList();

    if (entries.isEmpty || totalValue <= 0) {
      return _popupInfoBox(
        'No asset allocation data is available yet.',
        muted,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _popupSectionTitle(
          'ASSET ALLOCATION',
          'A larger view of how your portfolio is distributed.',
          teal,
        ),
        const SizedBox(height: 18),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: 18,
          ),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: border),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 270,
                width: double.infinity,
                child: CustomPaint(
                  painter: _AllocationPiePainter(
                    entries: entries,
                    total: totalValue,
                    getColor: _assetColor,
                    surfaceColor: surface,
                    mutedColor: muted,
                    whiteColor: white,
                  ),
                ),
              ),
              Text(
                'TOTAL  ₹${totalValue.toStringAsFixed(0)}',
                style: mono(
                  10,
                  color: muted,
                  weight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        ...entries.map((entry) {
          final percentage =
              entry.value / totalValue;
          final color = _assetColor(entry.key);

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: color.withValues(alpha: 0.18),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    entry.key,
                    style: mono(
                      10,
                      color: white,
                      weight: FontWeight.bold,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${entry.value.toStringAsFixed(0)}',
                      style: mono(
                        10,
                        color: white,
                        weight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${(percentage * 100).toStringAsFixed(1)}%',
                      style: mono(
                        9,
                        color: color,
                        weight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _goalPopupContent(
    double totalValue,
    double progress,
  ) {
    final percentage = progress * 100;
    final remaining =
        (goalAmount - totalValue).clamp(0, goalAmount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _popupSectionTitle(
          'INVESTMENT GOAL',
          'Track how close your portfolio is to your wealth target.',
          orange,
        ),
        const SizedBox(height: 18),
        Center(
          child: SizedBox(
            width: 190,
            height: 190,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 190,
                  height: 190,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 14,
                    backgroundColor:
                        Colors.white.withValues(alpha: 0.06),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(teal),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${percentage.toStringAsFixed(0)}%',
                      style: mono(
                        28,
                        color: white,
                        weight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'COMPLETED',
                      style: mono(
                        8,
                        color: teal,
                        weight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),
        _popupMetricRow(
          'CURRENT VALUE',
          '₹${totalValue.toStringAsFixed(0)}',
          teal,
        ),
        _popupMetricRow(
          'TARGET',
          '₹${goalAmount.toStringAsFixed(0)}',
          orange,
        ),
        _popupMetricRow(
          'REMAINING',
          '₹${remaining.toStringAsFixed(0)}',
          purple,
        ),
      ],
    );
  }

  Widget _healthPopupContent(
    Map<String, double> allocation,
    double total,
  ) {
    final activeAssets =
        allocation.values.where((value) => value > 0).length;

    int score = 100;
    if (activeAssets <= 1) {
      score = 50;
    } else if (activeAssets == 2) {
      score = 70;
    } else if (activeAssets == 3) {
      score = 85;
    }

    final status = score >= 85
        ? 'EXCELLENT'
        : score >= 70
            ? 'GOOD'
            : 'NEEDS IMPROVEMENT';

    final color = score >= 85
        ? green
        : score >= 70
            ? orange
            : red;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _popupSectionTitle(
          'PORTFOLIO HEALTH',
          'A quick diversification score based on active asset classes.',
          color,
        ),
        const SizedBox(height: 22),
        Center(
          child: SizedBox(
            width: 170,
            height: 170,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 170,
                  height: 170,
                  child: CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 14,
                    backgroundColor:
                        Colors.white.withValues(alpha: 0.06),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                Text(
                  '$score',
                  style: mono(
                    30,
                    color: white,
                    weight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: Text(
            status,
            style: mono(
              15,
              color: color,
              weight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _popupInfoBox(
          activeAssets >= 3
              ? 'Your portfolio has a healthy level of diversification across multiple asset classes.'
              : 'Consider adding different asset classes to improve diversification.',
          color,
        ),
      ],
    );
  }

  String _aiInsightMessage(
    Map<String, double> allocation,
    double total,
  ) {
    final crypto = allocation['Crypto'] ?? 0;
    final cryptoPercent =
        total == 0 ? 0 : crypto / total * 100;

    if (cryptoPercent > 30) {
      return 'Your crypto exposure is relatively high. Consider balancing it with stable assets.';
    }

    if (allocation.values.where((value) => value > 0).length <= 1) {
      return 'Your portfolio is concentrated. Diversifying across asset classes can reduce risk.';
    }

    return 'Your portfolio is reasonably diversified. Continue reviewing allocations regularly.';
  }

  Widget _aiPopupContent(
    Map<String, double> allocation,
    double total,
  ) {
    final crypto = allocation['Crypto'] ?? 0;
    final cryptoPercent =
        total == 0 ? 0 : crypto / total * 100;
    final message = _aiInsightMessage(
      allocation,
      total,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _popupSectionTitle(
          'AI PORTFOLIO INSIGHT',
          'Rule-based portfolio guidance using your current allocation.',
          purple,
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: purple.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: purple.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                color: purple,
                size: 26,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  message,
                  style: mono(
                    10,
                    color: white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _popupMetricRow(
          'CRYPTO EXPOSURE',
          '${cryptoPercent.toStringAsFixed(1)}%',
          cryptoPercent > 30 ? red : green,
        ),
        _popupMetricRow(
          'ACTIVE ASSET CLASSES',
          '${allocation.values.where((value) => value > 0).length}',
          teal,
        ),
        const SizedBox(height: 8),
        _popupInfoBox(
          'This insight is informational and should not be treated as financial advice.',
          orange,
        ),
      ],
    );
  }

  Widget _transactionPopupContent(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _loadTransactionInsights(docs),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return _popupInfoBox(
            'Unable to load transaction details.',
            red,
          );
        }

        final data = snapshot.data ?? {};

        final bought = _doubleValue(data['bought']);
        final sold = _doubleValue(data['sold']);
        final dividends =
            _doubleValue(data['dividends']);

        final buyCount =
            _intValue(data['buyCount']);
        final sellCount =
            _intValue(data['sellCount']);
        final dividendCount =
            _intValue(data['dividendCount']);

        final totalTransactions =
            buyCount + sellCount + dividendCount;

        return Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            _popupSectionTitle(
              'TRANSACTION INSIGHTS',
              'Detailed activity calculated from your investment transaction records.',
              blue,
            ),
            const SizedBox(height: 18),
            _popupMetricRow(
              'TOTAL TRANSACTIONS',
              '$totalTransactions',
              blue,
            ),
            _popupMetricRow(
              'TOTAL BOUGHT',
              '₹${bought.toStringAsFixed(0)}',
              green,
            ),
            _popupMetricRow(
              'TOTAL SOLD',
              '₹${sold.toStringAsFixed(0)}',
              red,
            ),
            _popupMetricRow(
              'DIVIDENDS',
              '₹${dividends.toStringAsFixed(0)}',
              orange,
            ),
            _popupMetricRow(
              'NET INVESTMENT',
              '₹${(bought - sold).toStringAsFixed(0)}',
              teal,
            ),
            const SizedBox(height: 12),
            _transactionActivityRow(
              'BUY',
              buyCount,
              green,
              Icons.arrow_downward_rounded,
            ),
            _transactionActivityRow(
              'SELL',
              sellCount,
              red,
              Icons.arrow_upward_rounded,
            ),
            _transactionActivityRow(
              'DIVIDEND',
              dividendCount,
              orange,
              Icons.account_balance_wallet_rounded,
            ),
          ],
        );
      },
    );
  }

  Widget _transactionActivityRow(
    String title,
    int count,
    Color color,
    IconData icon,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 19,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: mono(
                10,
                color: white,
                weight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            '$count',
            style: mono(
              12,
              color: color,
              weight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tipPopupContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _popupSectionTitle(
          'TIP OF THE DAY',
          'A simple portfolio habit to keep in mind.',
          orange,
        ),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: orange.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: orange.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.lightbulb_rounded,
                color: orange,
                size: 30,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  'Diversify your investments and review your portfolio regularly instead of making emotional decisions.',
                  style: mono(
                    11,
                    color: white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _performancePopupContent(
    double invested,
    double value,
    double profit,
  ) {
    final percentage = invested == 0
        ? 0
        : ((value - invested) / invested) * 100;
    final color = percentage >= 0 ? green : red;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _popupSectionTitle(
          'PORTFOLIO PERFORMANCE',
          'Expanded view of your current return and performance trend.',
          color,
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${percentage.toStringAsFixed(2)}%',
              style: mono(
                30,
                color: color,
                weight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              '₹${value.toStringAsFixed(0)}',
              style: mono(
                12,
                color: white,
                weight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: border),
          ),
          child: SizedBox(
            height: 300,
            width: double.infinity,
            child: CustomPaint(
              painter: _PerformanceGraphPainter(
                invested: invested,
                value: value,
                profit: profit,
                lineColor: color,
                gridColor: border,
                surfaceColor: surface,
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        _popupMetricRow(
          'INVESTED',
          '₹${invested.toStringAsFixed(0)}',
          purple,
        ),
        _popupMetricRow(
          'CURRENT VALUE',
          '₹${value.toStringAsFixed(0)}',
          teal,
        ),
        _popupMetricRow(
          'PROFIT / LOSS',
          '₹${profit.abs().toStringAsFixed(0)}',
          profit >= 0 ? green : red,
        ),
      ],
    );
  }

  Widget _breakdownPopupContent(
    Map<String, double> allocation,
    double total,
  ) {
    final entries = allocation.entries
        .where((entry) => entry.value > 0)
        .toList();

    if (entries.isEmpty || total <= 0) {
      return _popupInfoBox(
        'No portfolio breakdown data is available yet.',
        muted,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _popupSectionTitle(
          'PORTFOLIO BREAKDOWN',
          'Detailed percentage and value for every active asset class.',
          blue,
        ),
        const SizedBox(height: 18),
        ...entries.map((entry) {
          final percentage = entry.value / total;
          final color = _assetColor(entry.key);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: color.withValues(alpha: 0.18),
              ),
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.key,
                        style: mono(
                          10,
                          color: white,
                          weight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '${(percentage * 100).toStringAsFixed(1)}%',
                      style: mono(
                        10,
                        color: color,
                        weight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: percentage,
                    minHeight: 9,
                    backgroundColor:
                        Colors.white.withValues(alpha: 0.05),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${entry.value.toStringAsFixed(0)}',
                  style: mono(
                    9,
                    color: muted,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _popupInfoBox(
    String message,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: color.withValues(alpha: 0.20),
        ),
      ),
      child: Text(
        message,
        style: mono(
          10,
          color: muted,
        ),
      ),
    );
  }

  // ============================================================
  // GENERIC CARD
  // ============================================================

  Widget _card({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: border,
        ),
      ),
      child: child,
    );
  }

  // ============================================================
  // CARD HEADER
  // ============================================================

  Widget _cardHeader(
    String title,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: 22,
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Text(
            title,
            style: mono(
              11,
              color: white,
              weight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(
    String title,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: teal,
          size: 19,
        ),

        const SizedBox(width: 8),

        Text(
          title,
          style: mono(
            10,
            color: muted,
            weight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  Widget _bottomNavigationBar() {
    return Container(
      height: 74,
      decoration: BoxDecoration(
        color: background,
        border: Border(
          top: BorderSide(
            color: border,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _navItem(
              0,
              Icons.home_rounded,
              'Home',
            ),

            _navItem(
              1,
              Icons.account_balance_wallet_rounded,
              'Portfolio',
            ),

            _navItem(
              2,
              Icons.analytics_rounded,
              'Analytics',
            ),

            _navItem(
              3,
              Icons.auto_awesome_rounded,
              'AI',
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(
    int index,
    IconData icon,
    String label,
  ) {
    final bool selected =
        selectedIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          if (selected) return;

          setState(() {
            selectedIndex = index;
          });

          _navigate(index);
        },
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 21,
              color:
                  selected ? teal : muted,
            ),

            const SizedBox(height: 4),

            Text(
              label,
              style: mono(
                8,
                color:
                    selected
                        ? teal
                        : muted,
                weight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  void _navigate(int index) {
    Widget screen;

    switch (index) {
      case 0:
        screen = const DashboardScreen();
        break;

      case 1:
        screen = const PortfolioScreen();
        break;

      case 3:
        screen = const AiAgentScreen();
        break;

      default:
        return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => screen,
      ),
    );
  }

  // ============================================================
  // ERROR SCREEN
  // ============================================================

  Widget _errorScreen(
    String error,
  ) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(24),
        child: _card(
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: red,
                size: 55,
              ),

              const SizedBox(height: 18),

              Text(
                'Unable to Load Analytics',
                textAlign:
                    TextAlign.center,
                style: mono(
                  16,
                  color: white,
                  weight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                error,
                maxLines: 4,
                overflow:
                    TextOverflow.ellipsis,
                textAlign:
                    TextAlign.center,
                style: mono(
                  9,
                  color: muted,
                ),
              ),

              const SizedBox(height: 18),

              ElevatedButton(
                onPressed: () {
                  setState(() {});
                },
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor: teal,
                  foregroundColor:
                      background,
                ),
                child: Text(
                  'RETRY',
                  style: mono(
                    10,
                    color: background,
                    weight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  double _doubleValue(
    dynamic value, {
    double fallback = 0,
  }) {
    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value) ??
          fallback;
    }

    return fallback;
  }

  int _intValue(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value) ?? 0;
    }

    return 0;
  }

  Color _assetColor(
    String name,
  ) {
    switch (name) {
      case 'Stock':
        return blue;

      case 'Mutual Fund':
        return teal;

      case 'Gold':
        return orange;

      case 'Crypto':
        return red;

      case 'FD':
        return purple;

      default:
        return muted;
    }
  }
}

// ==================================================================
// ASSET ALLOCATION DONUT CHART
// ==================================================================

class _AllocationPiePainter
    extends CustomPainter {
  final List<MapEntry<String, double>>
      entries;

  final double total;

  final Color Function(String)
      getColor;

  final Color surfaceColor;
  final Color mutedColor;
  final Color whiteColor;

  _AllocationPiePainter({
    required this.entries,
    required this.total,
    required this.getColor,
    required this.surfaceColor,
    required this.mutedColor,
    required this.whiteColor,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    if (total <= 0 ||
        entries.isEmpty) {
      return;
    }

    final Offset center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final double radius =
        math.min(
              size.width,
              size.height,
            ) *
            0.32;

    double startAngle =
        -math.pi / 2;

    // ==========================================================
    // DONUT
    // ==========================================================

    for (final entry in entries) {
      final double sweepAngle =
          (entry.value / total) *
              math.pi *
              2;

      final Paint paint = Paint()
        ..style =
            PaintingStyle.stroke
        ..strokeWidth = 32
        ..strokeCap =
            StrokeCap.butt
        ..color =
            getColor(entry.key);

      canvas.drawArc(
        Rect.fromCircle(
          center: center,
          radius: radius,
        ),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }

    // ==========================================================
    // CENTER CIRCLE
    // ==========================================================

    final Paint centerPaint =
        Paint()
          ..color = surfaceColor;

    canvas.drawCircle(
      center,
      radius - 18,
      centerPaint,
    );

    // ==========================================================
    // CENTER TEXT
    // ==========================================================

    final TextPainter textPainter =
        TextPainter(
      text: TextSpan(
        text: 'ALLOCATION',
        style:
            GoogleFonts.spaceMono(
          fontSize: 9,
          color: mutedColor,
          fontWeight:
              FontWeight.bold,
        ),
      ),
      textDirection:
          TextDirection.ltr,
    );

    textPainter.layout();

    textPainter.paint(
      canvas,
      Offset(
        center.dx -
            textPainter.width / 2,
        center.dy -
            textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(
    covariant _AllocationPiePainter
        oldDelegate,
  ) {
    return oldDelegate.entries !=
            entries ||
        oldDelegate.total != total;
  }
}

// ==================================================================
// PERFORMANCE GRAPH
// ==================================================================

class _PerformanceGraphPainter
    extends CustomPainter {
  final double invested;
  final double value;
  final double profit;

  final Color lineColor;
  final Color gridColor;
  final Color surfaceColor;

  _PerformanceGraphPainter({
    required this.invested,
    required this.value,
    required this.profit,
    required this.lineColor,
    required this.gridColor,
    required this.surfaceColor,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    if (size.width <= 0 ||
        size.height <= 0) {
      return;
    }

    final Rect chartRect =
        Rect.fromLTWH(
      8,
      10,
      size.width - 16,
      size.height - 25,
    );

    // ==========================================================
    // GRID
    // ==========================================================

    final Paint gridPaint =
        Paint()
          ..color =
              gridColor.withValues(
            alpha: 0.45,
          )
          ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final double y =
          chartRect.top +
              chartRect.height *
                  (i / 4);

      canvas.drawLine(
        Offset(
          chartRect.left,
          y,
        ),
        Offset(
          chartRect.right,
          y,
        ),
        gridPaint,
      );
    }

    // ==========================================================
    // VALUE RANGE
    // ==========================================================

    final double minValue =
        math.min(
      invested,
      value,
    );

    final double maxValue =
        math.max(
      invested,
      value,
    );

    final double range =
        math.max(
      maxValue - minValue,
      1,
    );

    // ==========================================================
    // GRAPH POINTS
    // ==========================================================

    final List<Offset> points =
        <Offset>[];

    const int pointCount = 12;

    for (int i = 0;
        i < pointCount;
        i++) {
      final double t =
          i / (pointCount - 1);

      // Creates a subtle natural curve
      // between invested and current value.
      final double wave =
          math.sin(
                t * math.pi * 2,
              ) *
              range *
              0.08;

      final double current =
          invested +
              (value - invested) *
                  t +
              wave;

      final double normalized =
          range == 0
              ? 0.5
              : (current -
                      minValue) /
                  range;

      final double x =
          chartRect.left +
              chartRect.width * t;

      final double y =
          chartRect.bottom -
              chartRect.height *
                  (0.12 +
                      normalized *
                          0.76);

      points.add(
        Offset(x, y),
      );
    }

    if (points.length < 2) {
      return;
    }

    // ==========================================================
    // MAIN PATH
    // ==========================================================

    final Path path = Path();

    path.moveTo(
      points.first.dx,
      points.first.dy,
    );

    for (int i = 1;
        i < points.length;
        i++) {
      final Offset previous =
          points[i - 1];

      final Offset current =
          points[i];

      final double controlX =
          (previous.dx +
                  current.dx) /
              2;

      path.cubicTo(
        controlX,
        previous.dy,
        controlX,
        current.dy,
        current.dx,
        current.dy,
      );
    }

    // ==========================================================
    // FILL
    // ==========================================================

    final Path fillPath =
        Path.from(path);

    fillPath.lineTo(
      points.last.dx,
      chartRect.bottom,
    );

    fillPath.lineTo(
      points.first.dx,
      chartRect.bottom,
    );

    fillPath.close();

    final Paint fillPaint =
        Paint()
          ..shader =
              LinearGradient(
            begin:
                Alignment.topCenter,
            end:
                Alignment.bottomCenter,
            colors: [
              lineColor.withValues(
                alpha: 0.20,
              ),
              lineColor.withValues(
                alpha: 0.01,
              ),
            ],
          ).createShader(
            chartRect,
          );

    canvas.drawPath(
      fillPath,
      fillPaint,
    );

    // ==========================================================
    // GRAPH LINE
    // ==========================================================

    final Paint linePaint =
        Paint()
          ..color = lineColor
          ..strokeWidth = 3
          ..style =
              PaintingStyle.stroke
          ..strokeCap =
              StrokeCap.round
          ..strokeJoin =
              StrokeJoin.round;

    canvas.drawPath(
      path,
      linePaint,
    );

    // ==========================================================
    // LAST POINT
    // ==========================================================

    final Paint pointPaint =
        Paint()
          ..color = lineColor;

    canvas.drawCircle(
      points.last,
      5,
      pointPaint,
    );

    final Paint innerPaint =
        Paint()
          ..color = surfaceColor;

    canvas.drawCircle(
      points.last,
      2,
      innerPaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant _PerformanceGraphPainter
        oldDelegate,
  ) {
    return oldDelegate.invested !=
            invested ||
        oldDelegate.value != value ||
        oldDelegate.profit != profit ||
        oldDelegate.lineColor !=
            lineColor;
  }
}