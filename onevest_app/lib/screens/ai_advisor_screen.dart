import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AIAdvisorScreen extends StatelessWidget {
  const AIAdvisorScreen({super.key});

  // ============================================================
  // COLORS
  // ============================================================

  static const Color background = Color(0xFF020B1D);
  static const Color panel = Color(0xFF0A1428);
  static const Color panelLight = Color(0xFF10203A);
  static const Color fieldColor = Color(0xFF142542);
  static const Color border = Color(0xFF263B5C);

  static const Color teal = Color(0xFF14C8B0);
  static const Color green = Color(0xFF45E38A);
  static const Color orange = Color(0xFFFFB52E);
  static const Color purple = Color(0xFFA86BFF);
  static const Color red = Color(0xFFFF5A64);
  static const Color blue = Color(0xFF5C8CFF);

  static const Color white = Color(0xFFF5F8FC);
  static const Color muted = Color(0xFF91A0B8);
  static const Color muted2 = Color(0xFF647793);

  TextStyle mono(
    double size, {
    Color color = white,
    FontWeight weight = FontWeight.normal,
    double? height,
    double? spacing,
  }) {
    return GoogleFonts.spaceMono(
      fontSize: size,
      color: color,
      fontWeight: weight,
      height: height,
      letterSpacing: spacing,
    );
  }

  TextStyle pixel(
    double size, {
    Color color = white,
  }) {
    return GoogleFonts.pressStart2p(
      fontSize: size,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
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
            size: 19,
          ),
        ),
        title: RichText(
          text: TextSpan(
            children: <InlineSpan>[
              TextSpan(
                text: 'ONEVEST ',
                style: pixel(
                  11,
                  color: white,
                ),
              ),
              TextSpan(
                text: 'AI ADVISOR',
                style: pixel(
                  11,
                  color: teal,
                ),
              ),
            ],
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (
          BuildContext context,
          BoxConstraints constraints,
        ) {
          final bool desktop = constraints.maxWidth >= 900;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: desktop ? 50 : 18,
              vertical: 20,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 1150,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildHero(),
                    const SizedBox(height: 26),
                    _buildPortfolioHealth(),
                    const SizedBox(height: 28),
                    _buildOverview(desktop),
                    const SizedBox(height: 30),
                    _buildAllocation(desktop),
                    const SizedBox(height: 30),
                    _buildInsightHeader(),
                    const SizedBox(height: 16),
                    _buildSuggestions(desktop),
                    const SizedBox(height: 28),
                    _buildNextMove(),
                    const SizedBox(height: 28),
                    _buildAdvisorNote(),
                    const SizedBox(height: 32),
                    _buildFooter(),
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
  // HERO
  // ============================================================

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(27),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFF123451),
            Color(0xFF071326),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: teal.withValues(alpha: 0.30),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (
          BuildContext context,
          BoxConstraints constraints,
        ) {
          final bool compact = constraints.maxWidth < 650;

          if (compact) {
            return Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                _heroIcon(),
                const SizedBox(height: 20),
                _heroContent(),
              ],
            );
          }

          return Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: <Widget>[
              _heroIcon(),
              const SizedBox(width: 20),
              Expanded(
                child: _heroContent(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _heroIcon() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: teal.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: teal.withValues(alpha: 0.30),
        ),
      ),
      child: const Icon(
        Icons.auto_awesome_rounded,
        color: teal,
        size: 36,
      ),
    );
  }

  Widget _heroContent() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              'AI PORTFOLIO ANALYSIS',
              style: mono(
                9,
                color: teal,
                weight: FontWeight.bold,
                spacing: 1.5,
              ),
            ),
            const SizedBox(width: 10),
            _statusBadge(),
          ],
        ),
        const SizedBox(height: 13),
        Text(
          'Your AI Investment Advisor',
          style: mono(
            22,
            color: white,
            weight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          'I analyzed your current portfolio structure, '
          'risk exposure and diversification to surface '
          'the areas that deserve your attention.',
          style: mono(
            10.5,
            color: muted,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _statusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: green.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: green.withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            'ACTIVE',
            style: mono(
              7,
              color: green,
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

  Widget _buildPortfolioHealth() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'PORTFOLIO HEALTH',
                  style: mono(
                    9,
                    color: muted,
                    weight: FontWeight.bold,
                    spacing: 1.2,
                  ),
                ),
              ),
              Text(
                '84 / 100',
                style: mono(
                  16,
                  color: teal,
                  weight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: 0.84,
              minHeight: 9,
              backgroundColor: fieldColor,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(
                teal,
              ),
            ),
          ),
          const SizedBox(height: 13),
          Row(
            children: <Widget>[
              const Icon(
                Icons.check_circle_outline_rounded,
                color: green,
                size: 17,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  'Overall portfolio structure looks healthy.',
                  style: mono(
                    9,
                    color: muted,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // OVERVIEW
  // ============================================================

  Widget _buildOverview(bool desktop) {
    final List<_Metric> metrics = <_Metric>[
      _Metric(
        title: 'RISK LEVEL',
        value: 'MODERATE',
        subtitle: 'Balanced exposure',
        icon: Icons.shield_outlined,
        color: orange,
      ),
      _Metric(
        title: 'DIVERSIFICATION',
        value: '82 / 100',
        subtitle: 'Well diversified',
        icon: Icons.pie_chart_outline_rounded,
        color: green,
      ),
      _Metric(
        title: 'AI CONFIDENCE',
        value: '91%',
        subtitle: 'Strong signal',
        icon: Icons.auto_awesome_rounded,
        color: teal,
      ),
      _Metric(
        title: 'ACTION SCORE',
        value: '74 / 100',
        subtitle: 'Room to improve',
        icon: Icons.trending_up_rounded,
        color: purple,
      ),
    ];

    if (desktop) {
      return Row(
        children: metrics.map(
          (_Metric metric) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  right: 12,
                ),
                child: _metricCard(metric),
              ),
            );
          },
        ).toList(),
      );
    }

    return Column(
      children: metrics.map(
        (_Metric metric) {
          return Padding(
            padding: const EdgeInsets.only(
              bottom: 12,
            ),
            child: _metricCard(metric),
          );
        },
      ).toList(),
    );
  }

  Widget _metricCard(_Metric metric) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: border,
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: metric.color.withValues(
                alpha: 0.09,
              ),
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: Icon(
              metric.icon,
              color: metric.color,
              size: 24,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  metric.title,
                  style: mono(
                    8,
                    color: muted,
                    weight: FontWeight.bold,
                    spacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  metric.value,
                  style: mono(
                    15,
                    color: white,
                    weight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  metric.subtitle,
                  style: mono(
                    8,
                    color: muted2,
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
  // ALLOCATION
  // ============================================================

  Widget _buildAllocation(bool desktop) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: border,
        ),
      ),
      child: LayoutBuilder(
        builder: (
          BuildContext context,
          BoxConstraints constraints,
        ) {
          final bool wide =
              constraints.maxWidth >= 700;

          final Widget chart =
              _buildAllocationChart();

          final Widget details =
              _buildAllocationDetails();

          if (wide) {
            return Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 4,
                  child: chart,
                ),
                const SizedBox(width: 30),
                Expanded(
                  flex: 5,
                  child: details,
                ),
              ],
            );
          }

          return Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: <Widget>[
              chart,
              const SizedBox(height: 25),
              details,
            ],
          );
        },
      ),
    );
  }

  Widget _buildAllocationChart() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'ASSET ALLOCATION',
          style: mono(
            9,
            color: muted,
            weight: FontWeight.bold,
            spacing: 1,
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: 180,
          height: 180,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              SizedBox(
                width: 180,
                height: 180,
                child: CircularProgressIndicator(
                  value: 0.42,
                  strokeWidth: 22,
                  backgroundColor: fieldColor,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(
                    teal,
                  ),
                ),
              ),
              SizedBox(
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                  value: 0.28,
                  strokeWidth: 22,
                  backgroundColor:
                      Colors.transparent,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(
                    blue,
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(
                  value: 0.18,
                  strokeWidth: 22,
                  backgroundColor:
                      Colors.transparent,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(
                    orange,
                  ),
                ),
              ),
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  value: 0.12,
                  strokeWidth: 22,
                  backgroundColor:
                      Colors.transparent,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(
                    purple,
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    '100%',
                    style: mono(
                      16,
                      color: white,
                      weight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'ALLOCATED',
                    style: mono(
                      6,
                      color: muted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAllocationDetails() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'AI READ OF YOUR MIX',
          style: mono(
            9,
            color: teal,
            weight: FontWeight.bold,
            spacing: 1,
          ),
        ),
        const SizedBox(height: 14),
        _allocationRow(
          'EQUITY',
          '42%',
          teal,
        ),
        _allocationRow(
          'MUTUAL FUNDS',
          '28%',
          blue,
        ),
        _allocationRow(
          'GOLD',
          '18%',
          orange,
        ),
        _allocationRow(
          'OTHER',
          '12%',
          purple,
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: teal.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: teal.withValues(alpha: 0.16),
            ),
          ),
          child: Text(
            'AI VIEW: Your allocation is reasonably '
            'spread across multiple asset classes. '
            'The biggest opportunity is maintaining '
            'balance as your portfolio grows.',
            style: mono(
              9,
              color: muted,
              height: 1.55,
            ),
          ),
        ),
      ],
    );
  }

  Widget _allocationRow(
    String name,
    String percentage,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 13,
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              name,
              style: mono(
                9,
                color: muted,
              ),
            ),
          ),
          Text(
            percentage,
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
  // INSIGHTS
  // ============================================================

  Widget _buildInsightHeader() {
    return Row(
      children: <Widget>[
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: purple.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(
            Icons.auto_awesome,
            color: purple,
            size: 23,
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'AI SUGGESTIONS',
                style: pixel(
                  11,
                  color: white,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                'Personalized actions based on your portfolio',
                style: mono(
                  9,
                  color: muted,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: purple.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: purple.withValues(alpha: 0.18),
            ),
          ),
          child: Text(
            '5 INSIGHTS',
            style: mono(
              8,
              color: purple,
              weight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestions(bool desktop) {
    final List<_SuggestionData> suggestions =
        <_SuggestionData>[
      _SuggestionData(
        title: 'Increase Gold Allocation',
        description:
            'Gold could strengthen diversification '
            'and provide another defensive asset in '
            'your overall mix.',
        priority: 'RECOMMENDED',
        icon: Icons.savings_outlined,
        color: orange,
        action: 'VIEW GOLD',
      ),
      _SuggestionData(
        title: 'Continue Monthly SIP',
        description:
            'Your recurring investment habit supports '
            'disciplined long-term wealth creation.',
        priority: 'POSITIVE',
        icon: Icons.autorenew_rounded,
        color: green,
        action: 'VIEW SIP',
      ),
      _SuggestionData(
        title: 'Review Crypto Exposure',
        description:
            'High-volatility assets can have a large '
            'impact on portfolio swings. Review their '
            'share against your risk tolerance.',
        priority: 'ATTENTION',
        icon: Icons.currency_bitcoin_rounded,
        color: red,
        action: 'REVIEW',
      ),
      _SuggestionData(
        title: 'Schedule Monthly Review',
        description:
            'A monthly portfolio review can help keep '
            'your asset allocation aligned with your goals.',
        priority: 'RECOMMENDED',
        icon: Icons.calendar_month_outlined,
        color: teal,
        action: 'SET REMINDER',
      ),
      _SuggestionData(
        title: 'Maintain Emergency Fund',
        description:
            'Keep accessible savings available before '
            'increasing exposure to higher-risk assets.',
        priority: 'IMPORTANT',
        icon: Icons.account_balance_outlined,
        color: purple,
        action: 'LEARN MORE',
      ),
    ];

    if (desktop) {
      return GridView.builder(
        shrinkWrap: true,
        physics:
            const NeverScrollableScrollPhysics(),
        itemCount: suggestions.length,
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.65,
        ),
        itemBuilder: (
          BuildContext context,
          int index,
        ) {
          return _SuggestionCard(
            data: suggestions[index],
          );
        },
      );
    }

    return Column(
      children: suggestions.map(
        (_SuggestionData suggestion) {
          return Padding(
            padding: const EdgeInsets.only(
              bottom: 14,
            ),
            child: _SuggestionCard(
              data: suggestion,
            ),
          );
        },
      ).toList(),
    );
  }

  // ============================================================
  // NEXT MOVE
  // ============================================================

  Widget _buildNextMove() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            teal.withValues(alpha: 0.13),
            panel,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: teal.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: teal.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.flag_outlined,
              color: teal,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'YOUR NEXT BEST MOVE',
                  style: mono(
                    9,
                    color: teal,
                    weight: FontWeight.bold,
                    spacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Review your highest-volatility '
                  'holding before adding new risk.',
                  style: mono(
                    11,
                    color: white,
                    weight: FontWeight.bold,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'AI prioritizes this because it can '
                  'have the biggest effect on your overall '
                  'portfolio stability.',
                  style: mono(
                    9,
                    color: muted,
                    height: 1.5,
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
  // NOTE
  // ============================================================

  Widget _buildAdvisorNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: teal.withValues(alpha: 0.16),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: teal.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.lightbulb_outline_rounded,
              color: teal,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'ADVISOR NOTE',
                  style: mono(
                    9,
                    color: teal,
                    weight: FontWeight.bold,
                    spacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'These insights are generated from the '
                  'portfolio information currently available '
                  'to OneVest. They are intended for education '
                  'and decision support, not guaranteed returns.',
                  style: mono(
                    9,
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

  // ============================================================
  // FOOTER
  // ============================================================

  Widget _buildFooter() {
    return Center(
      child: Column(
        children: <Widget>[
          const Icon(
            Icons.auto_awesome_rounded,
            color: teal,
            size: 24,
          ),
          const SizedBox(height: 9),
          Text(
            'ONEVEST AI',
            style: pixel(
              9,
              color: teal,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Smarter insights. Better decisions.',
            style: mono(
              9,
              color: muted,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// SUGGESTION DATA
// ================================================================

class _SuggestionData {
  final String title;
  final String description;
  final String priority;
  final IconData icon;
  final Color color;
  final String action;

  const _SuggestionData({
    required this.title,
    required this.description,
    required this.priority,
    required this.icon,
    required this.color,
    required this.action,
  });
}

// ================================================================
// SUGGESTION CARD
// ================================================================

class _SuggestionCard extends StatefulWidget {
  final _SuggestionData data;

  const _SuggestionCard({
    required this.data,
  });

  @override
  State<_SuggestionCard> createState() =>
      _SuggestionCardState();
}

class _SuggestionCardState
    extends State<_SuggestionCard> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    final _SuggestionData data = widget.data;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          hovering = true;
        });
      },
      onExit: (_) {
        setState(() {
          hovering = false;
        });
      },
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 180),
        transform: Matrix4.translationValues(
          0,
          hovering ? -3 : 0,
          0,
        ),
        padding: const EdgeInsets.all(19),
        decoration: BoxDecoration(
          color:
              AIAdvisorScreen.panel,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: hovering
                ? data.color.withValues(
                    alpha: 0.45,
                  )
                : AIAdvisorScreen.border,
          ),
          boxShadow: hovering
              ? <BoxShadow>[
                  BoxShadow(
                    color: data.color.withValues(
                      alpha: 0.08,
                    ),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : <BoxShadow>[],
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: data.color.withValues(
                      alpha: 0.09,
                    ),
                    borderRadius:
                        BorderRadius.circular(13),
                  ),
                  child: Icon(
                    data.icon,
                    color: data.color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    data.title,
                    style:
                        GoogleFonts.spaceMono(
                      fontSize: 11,
                      color:
                          AIAdvisorScreen.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: data.color.withValues(
                      alpha: 0.08,
                    ),
                    borderRadius:
                        BorderRadius.circular(6),
                  ),
                  child: Text(
                    data.priority,
                    style:
                        GoogleFonts.spaceMono(
                      fontSize: 6.5,
                      color: data.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              data.description,
              style: GoogleFonts.spaceMono(
                fontSize: 9,
                color: AIAdvisorScreen.muted,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 36,
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    SnackBar(
                      behavior:
                          SnackBarBehavior.floating,
                      backgroundColor:
                          AIAdvisorScreen.panelLight,
                      content: Text(
                        '${data.action} selected',
                        style:
                            GoogleFonts.spaceMono(
                          color:
                              AIAdvisorScreen.white,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  );
                },
                style:
                    OutlinedButton.styleFrom(
                  foregroundColor: data.color,
                  side: BorderSide(
                    color: data.color.withValues(
                      alpha: 0.35,
                    ),
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(9),
                  ),
                ),
                child: Text(
                  data.action,
                  style: GoogleFonts.spaceMono(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// METRIC MODEL
// ================================================================

class _Metric {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _Metric({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}
