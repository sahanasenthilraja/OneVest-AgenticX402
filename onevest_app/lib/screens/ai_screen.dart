import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'portfolio_screen.dart';
import 'profile_screen.dart';
import 'portfolio_analytics_screen.dart';
import 'roast_screen.dart';
import 'financial_twin_screen.dart';
import 'ai_coach_screen.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  // ============================================================
  // ONEVEST COLORS
  // ============================================================

  static const Color background = Color(0xFF020B1D);
  static const Color panel = Color(0xFF0E1830);
  static const Color panel2 = Color(0xFF111E38);
  static const Color panel3 = Color(0xFF152541);
  static const Color border = Color(0xFF243B63);

  static const Color teal = Color(0xFF10D8C3);
  static const Color tealDark = Color(0xFF0B3946);

  static const Color white = Color(0xFFF4F7FF);
  static const Color muted = Color(0xFF8FA3C2);
  static const Color muted2 = Color(0xFF627696);

  static const Color green = Color(0xFF48D36B);
  static const Color orange = Color(0xFFFFB340);
  static const Color purple = Color(0xFF9871FF);
  static const Color blue = Color(0xFF5C8CFF);

  // ============================================================
  // CHAT
  // ============================================================

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> messages =
      <Map<String, dynamic>>[];

  bool isTyping = false;

  final Map<String, String> knowledgeBase = <String, String>{
    'gold':
        'Gold can help diversify your portfolio and may provide stability during periods of market uncertainty.',

    'stock':
        'Stocks can offer strong long-term growth, but they also carry market risk. Diversification is important.',

    'mutual':
        'Mutual funds provide diversification by spreading your money across multiple securities.',

    'crypto':
        'Crypto assets can be highly volatile. Keeping exposure controlled can help reduce overall portfolio risk.',

    'sip':
        'A SIP allows you to invest a fixed amount regularly. It can help build disciplined long-term investing habits.',

    'risk':
        'To reduce portfolio risk, consider spreading investments across different asset classes rather than concentrating in one area.',

    'fd':
        'Fixed deposits are generally lower-risk instruments and can provide predictable returns.',

    'portfolio':
        'A balanced portfolio usually combines different asset classes based on your goals, time horizon and risk tolerance.',

    'diversif':
        'Diversification means spreading investments across assets so that one investment does not dominate your overall portfolio.',

    'bitcoin':
        'Bitcoin is a highly volatile digital asset. Consider your risk tolerance carefully before allocating to it.',

    'ethereum':
        'Ethereum is a blockchain-based digital asset and can experience significant price volatility.',

    'emergency':
        'An emergency fund should generally be kept accessible and separate from long-term investments.',

    'return':
        'Higher potential returns generally come with higher risk. Focus on returns that match your goals and risk tolerance.',
  };

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ============================================================
  // SEND MESSAGE
  // ============================================================

  Future<void> sendMessage() async {
    final String question = _controller.text.trim();

    if (question.isEmpty) {
      return;
    }

    setState(() {
      messages.add(
        <String, dynamic>{
          'isUser': true,
          'text': question,
        },
      );

      isTyping = true;
    });

    _controller.clear();

    await Future<void>.delayed(
      const Duration(milliseconds: 550),
    );

    String answer =
        "I'm OneVest AI. Ask me about your portfolio, risk, SIPs, stocks, gold, mutual funds or crypto.";

    final String lowerQuestion = question.toLowerCase();

    for (final MapEntry<String, String> entry
        in knowledgeBase.entries) {
      if (lowerQuestion.contains(entry.key)) {
        answer = entry.value;
        break;
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      messages.add(
        <String, dynamic>{
          'isUser': false,
          'text': answer,
        },
      );

      isTyping = false;
    });

    Future<void>.delayed(
      const Duration(milliseconds: 100),
      () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      },
    );
  }

  // ============================================================
  // MAIN BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: LayoutBuilder(
        builder: (
          BuildContext context,
          BoxConstraints constraints,
        ) {
          final bool desktop = constraints.maxWidth >= 850;

          if (desktop) {
            return _buildDesktop(context);
          }

          return _buildMobile(context);
        },
      ),
    );
  }

  // ============================================================
  // DESKTOP
  // ============================================================

  Widget _buildDesktop(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _buildSidebar(context),

        Expanded(
          child: Column(
            children: <Widget>[
              _buildTopBar(context),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    28,
                    10,
                    28,
                    50,
                  ),
                  child: _buildMainContent(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // MOBILE
  // ============================================================

  Widget _buildMobile(BuildContext context) {
    return SafeArea(
      child: Column(
        children: <Widget>[
          _buildTopBar(context),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                16,
                8,
                16,
                30,
              ),
              child: _buildMainContent(context),
            ),
          ),

          _buildMobileBottomBar(context),
        ],
      ),
    );
  }

  // ============================================================
  // TOP BAR
  // ============================================================

  Widget _buildTopBar(BuildContext context) {
    return SizedBox(
      height: 70,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: Row(
          children: <Widget>[
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: white,
                size: 28,
              ),
            ),

            const SizedBox(width: 5),

            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: tealDark,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: teal.withValues(alpha: 0.5),
                ),
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: teal,
                size: 23,
              ),
            ),

            const SizedBox(width: 13),

            Text(
              'OneVest AI',
              style: GoogleFonts.pressStart2p(
                color: white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),

            const Spacer(),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF082A25),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: green.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
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
                    'AI ONLINE',
                    style: GoogleFonts.pressStart2p(
                      color: green,
                      fontSize: 6.5,
                      fontWeight: FontWeight.w700,
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
  // SIDEBAR
  // ============================================================

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 82,
      margin: const EdgeInsets.only(
        left: 10,
        top: 12,
        bottom: 12,
      ),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: border,
        ),
      ),
      child: Column(
        children: <Widget>[
          const SizedBox(height: 18),

          _sidebarButton(
            icon: Icons.home_rounded,
            tooltip: 'Home',
            selected: false,
            onTap: () {
              Navigator.pop(context);
            },
          ),

          _sidebarButton(
            icon: Icons.account_balance_wallet_rounded,
            tooltip: 'Portfolio',
            selected: false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PortfolioScreen(),
                ),
              );
            },
          ),

          _sidebarButton(
            icon: Icons.smart_toy_rounded,
            tooltip: 'AI',
            selected: true,
            onTap: () {},
          ),

          _sidebarButton(
            icon: Icons.person_rounded,
            tooltip: 'Profile',
            selected: false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfileScreen(),
                ),
              );
            },
          ),

          const Spacer(),

          _sidebarButton(
            icon: Icons.analytics_outlined,
            tooltip: 'Analytics',
            selected: false,
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
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: selected
              ? teal.withValues(alpha: 0.14)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            hoverColor: teal.withValues(alpha: 0.08),
            child: SizedBox(
              height: 58,
              width: double.infinity,
              child: Icon(
                icon,
                color: selected ? teal : muted,
                size: 23,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // MAIN CONTENT
  // ============================================================

  Widget _buildMainContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildHero(),

        const SizedBox(height: 26),

        _buildTryAsking(),

        const SizedBox(height: 32),

        _buildExperiences(context),

        const SizedBox(height: 32),

        _buildPortfolioPulse(),

        const SizedBox(height: 32),

        _buildChatPanel(),

        const SizedBox(height: 25),

        _buildDisclaimer(),
      ],
    );
  }

  // ============================================================
  // HERO
  // ============================================================

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[
            Color(0xFF12324D),
            Color(0xFF0D1B32),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: teal.withValues(alpha: 0.45),
        ),
      ),
      child: LayoutBuilder(
        builder: (
          BuildContext context,
          BoxConstraints constraints,
        ) {
          final bool compact = constraints.maxWidth < 650;

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _heroIcon(),

                const SizedBox(height: 20),

                _heroText(),
              ],
            );
          }

          return Row(
            children: <Widget>[
              _heroIcon(),

              const SizedBox(width: 25),

              Expanded(
                child: _heroText(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _heroIcon() {
    return Container(
      width: 82,
      height: 82,
      decoration: BoxDecoration(
        color: tealDark,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: teal.withValues(alpha: 0.5),
        ),
      ),
      child: const Icon(
        Icons.auto_awesome_rounded,
        color: teal,
        size: 42,
      ),
    );
  }

  Widget _heroText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'YOUR INTELLIGENT FINANCE HUB',
          style: GoogleFonts.pressStart2p(
            color: teal,
            fontSize: 7,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          'Your money. Your goals.\n'
          'One intelligent companion.',
          style: GoogleFonts.pressStart2p(
            color: white,
            fontSize: 19,
            fontWeight: FontWeight.w800,
            height: 1.08,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          'Ask questions, explore your financial personality, '
          'get portfolio insights and turn investing into '
          'a smarter daily habit.',
          style: GoogleFonts.pressStart2p(
            color: muted,
            fontSize: 9,
            height: 1.45,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TRY ASKING
  // ============================================================

  Widget _buildTryAsking() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'TRY ASKING',
          style: GoogleFonts.pressStart2p(
            color: muted,
            fontSize: 7,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),

        const SizedBox(height: 12),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: <Widget>[
            _suggestionChip(
              'How can I reduce portfolio risk?',
            ),
            _suggestionChip(
              'Should I invest in Gold?',
            ),
            _suggestionChip(
              'Explain SIP',
            ),
            _suggestionChip(
              'How should I diversify?',
            ),
            _suggestionChip(
              'Is my portfolio balanced?',
            ),
          ],
        ),
      ],
    );
  }

  Widget _suggestionChip(String text) {
    return InkWell(
      onTap: () {
        _controller.text = text;
        sendMessage();
      },
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 17,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: panel,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: border,
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.pressStart2p(
            color: muted,
            fontSize: 7,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EXPERIENCES
  // ============================================================

  Widget _buildExperiences(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'EXPLORE ONEVEST AI',
                style: GoogleFonts.pressStart2p(
                  color: white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),

            const SizedBox(width: 10),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: tealDark,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '5 EXPERIENCES',
                style: GoogleFonts.pressStart2p(
                  color: teal,
                  fontSize: 6,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        Text(
          'Choose the AI experience that fits your goal.',
          style: GoogleFonts.pressStart2p(
            color: muted,
            fontSize: 9,
          ),
        ),

        const SizedBox(height: 18),

        LayoutBuilder(
          builder: (
            BuildContext context,
            BoxConstraints constraints,
          ) {
            final bool wide = constraints.maxWidth > 900;

            if (wide) {
              return Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 5,
                    child: _experienceCard(
                      title: 'AI Advisor',
                      subtitle:
                          'Portfolio insights & personalized recommendations',
                      icon: Icons.auto_graph_rounded,
                      accent: teal,
                      tag: 'SMART',
                      large: true,
                      onTap: () {
                        _showAdvisorDialog(context);
                      },
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    flex: 4,
                    child: Column(
                      children: <Widget>[
                        _experienceCard(
                          title: 'AI Roast',
                          subtitle:
                              'A brutally honest review of your portfolio',
                          icon:
                              Icons.local_fire_department_rounded,
                          accent: orange,
                          tag: 'FUN',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RoastScreen(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 14),

                        _experienceCard(
                          title: 'Financial Twin',
                          subtitle:
                              'Discover your AI financial personality',
                          icon: Icons.person_search_rounded,
                          accent: blue,
                          tag: 'DISCOVER',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    FinancialTwinScreen(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 14),

                        _experienceCard(
                          title: 'AI Investment Coach',
                          subtitle:
                              'Daily AI guidance & personalized missions',
                          icon: Icons.smart_toy_rounded,
                          accent: purple,
                          tag: 'GUIDE',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    AICoachScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: <Widget>[
                _experienceCard(
                  title: 'AI Advisor',
                  subtitle:
                      'Portfolio insights & personalized recommendations',
                  icon: Icons.auto_graph_rounded,
                  accent: teal,
                  tag: 'SMART',
                  large: true,
                  onTap: () {
                    _showAdvisorDialog(context);
                  },
                ),

                const SizedBox(height: 14),

                _experienceCard(
                  title: 'AI Roast',
                  subtitle:
                      'A brutally honest review of your portfolio',
                  icon:
                      Icons.local_fire_department_rounded,
                  accent: orange,
                  tag: 'FUN',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RoastScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 14),

                _experienceCard(
                  title: 'Financial Twin',
                  subtitle:
                      'Discover your AI financial personality',
                  icon: Icons.person_search_rounded,
                  accent: blue,
                  tag: 'DISCOVER',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            FinancialTwinScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 14),

                _experienceCard(
                  title: 'AI Investment Coach',
                  subtitle:
                      'Daily AI guidance & personalized missions',
                  icon: Icons.smart_toy_rounded,
                  accent: purple,
                  tag: 'GUIDE',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AICoachScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 14),

                _experienceCard(
                  title: 'Challenge Center',
                  subtitle:
                      'Earn XP, unlock badges & complete missions',
                  icon: Icons.emoji_events_rounded,
                  accent: green,
                  tag: 'PLAY',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const _ChallengesCenterScreen(),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  // ============================================================
  // EXPERIENCE CARD
  // IMPORTANT:
  // NO UNBOUNDED COLUMN SPACER
  // ============================================================

  Widget _experienceCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accent,
    required String tag,
    required VoidCallback onTap,
    bool large = false,
  }) {
    final double cardHeight = large ? 250 : 110;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: double.infinity,
        height: cardHeight,
        padding: EdgeInsets.all(
          large ? 28 : 18,
        ),
        decoration: BoxDecoration(
          color: panel,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: accent.withValues(
              alpha: large ? 0.55 : 0.25,
            ),
          ),
        ),
        child: large
            ? Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      _iconBox(
                        icon,
                        accent,
                        large: true,
                      ),

                      const Spacer(),

                      _tag(
                        tag,
                        accent,
                      ),
                    ],
                  ),

                  const SizedBox(height: 27),

                  Text(
                    title,
                    style: GoogleFonts.pressStart2p(
                      color: white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 7),

                  Expanded(
                    child: Text(
                      subtitle,
                      style: GoogleFonts.pressStart2p(
                        color: muted,
                        fontSize: 9,
                      ),
                    ),
                  ),

                  Row(
                    children: <Widget>[
                      Text(
                        'OPEN EXPERIENCE',
                        style: GoogleFonts.pressStart2p(
                          color: teal,
                          fontSize: 6.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(width: 8),

                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: teal,
                        size: 18,
                      ),
                    ],
                  ),
                ],
              )
            : Row(
                children: <Widget>[
                  _iconBox(
                    icon,
                    accent,
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          title,
                          style:
                              GoogleFonts.pressStart2p(
                            color: white,
                            fontSize: 10,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow:
                              TextOverflow.ellipsis,
                          style:
                              GoogleFonts.pressStart2p(
                            color: muted,
                            fontSize: 7,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  _tag(
                    tag,
                    accent,
                  ),

                  const SizedBox(width: 8),

                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: accent,
                    size: 14,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _iconBox(
    IconData icon,
    Color color, {
    bool large = false,
  }) {
    final double size = large ? 68 : 52;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(
          large ? 19 : 15,
        ),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
        ),
      ),
      child: Icon(
        icon,
        color: color,
        size: large ? 32 : 24,
      ),
    );
  }

  Widget _tag(
    String text,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: GoogleFonts.pressStart2p(
          color: color,
          fontSize: 5.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  // ============================================================
  // PORTFOLIO PULSE
  // ============================================================

  Widget _buildPortfolioPulse() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'PORTFOLIO PULSE',
                style: GoogleFonts.pressStart2p(
                  color: white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),

            Text(
              'AI SNAPSHOT',
              style: GoogleFonts.pressStart2p(
                color: teal,
                fontSize: 6,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),

        const SizedBox(height: 15),

        LayoutBuilder(
          builder: (
            BuildContext context,
            BoxConstraints constraints,
          ) {
            if (constraints.maxWidth > 800) {
              return Row(
                children: <Widget>[
                  Expanded(
                    child: _pulseCard(
                      'RISK PROFILE',
                      'MEDIUM',
                      'Balanced exposure',
                      Icons.shield_outlined,
                      orange,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _pulseCard(
                      'DIVERSIFICATION',
                      '82 / 100',
                      'Healthy mix',
                      Icons.pie_chart_outline_rounded,
                      green,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _pulseCard(
                      'AI CONFIDENCE',
                      '91%',
                      'Strong signal',
                      Icons.auto_awesome_rounded,
                      teal,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _pulseCard(
                      'ACTION SCORE',
                      '74 / 100',
                      'Room to improve',
                      Icons.trending_up_rounded,
                      purple,
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _pulseCard(
                        'RISK PROFILE',
                        'MEDIUM',
                        'Balanced exposure',
                        Icons.shield_outlined,
                        orange,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _pulseCard(
                        'DIVERSIFICATION',
                        '82 / 100',
                        'Healthy mix',
                        Icons.pie_chart_outline_rounded,
                        green,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: <Widget>[
                    Expanded(
                      child: _pulseCard(
                        'AI CONFIDENCE',
                        '91%',
                        'Strong signal',
                        Icons.auto_awesome_rounded,
                        teal,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _pulseCard(
                        'ACTION SCORE',
                        '74 / 100',
                        'Room to improve',
                        Icons.trending_up_rounded,
                        purple,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 15),

        _buildAIInsight(),
      ],
    );
  }

  Widget _pulseCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color accent,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(18),
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
              Icon(
                icon,
                color: accent,
                size: 19,
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.pressStart2p(
                    color: muted,
                    fontSize: 5.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            value,
            style: GoogleFonts.pressStart2p(
              color: white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            subtitle,
            style: GoogleFonts.pressStart2p(
              color: muted2,
              fontSize: 7,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // AI INSIGHT
  // ============================================================

  Widget _buildAIInsight() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: tealDark.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: teal.withValues(alpha: 0.35),
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
              color: teal.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.lightbulb_outline_rounded,
              color: teal,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'AI OBSERVATION',
                  style: GoogleFonts.pressStart2p(
                    color: teal,
                    fontSize: 6,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Your portfolio appears diversified, '
                  'but the AI recommends reviewing '
                  'high-volatility assets regularly.',
                  style: GoogleFonts.pressStart2p(
                    color: white,
                    fontSize: 8,
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

  // ============================================================
  // CHAT PANEL
  // ============================================================

  Widget _buildChatPanel() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: border,
        ),
      ),
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
              color: panel2,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: tealDark,
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.smart_toy_rounded,
                    color: teal,
                    size: 22,
                  ),
                ),

                const SizedBox(width: 12),

                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'ASK ONEVEST AI',
                      style: GoogleFonts.pressStart2p(
                        color: white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      'Investment questions, explained simply.',
                      style: GoogleFonts.pressStart2p(
                        color: muted,
                        fontSize: 7,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(
            height: 230,
            child: messages.isEmpty
                ? _buildEmptyChat()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(18),
                    itemCount:
                        messages.length +
                        (isTyping ? 1 : 0),
                    itemBuilder: (
                      BuildContext context,
                      int index,
                    ) {
                      if (isTyping &&
                          index == messages.length) {
                        return _buildTyping();
                      }

                      final Map<String, dynamic> message =
                          messages[index];

                      final String text =
                          message['text'] as String;

                      final bool isUser =
                          message['isUser'] as bool;

                      return _buildMessage(
                        text,
                        isUser,
                      );
                    },
                  ),
          ),

          _buildChatInput(),
        ],
      ),
    );
  }

  Widget _buildEmptyChat() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: tealDark,
                borderRadius:
                    BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: teal,
                size: 30,
              ),
            ),

            const SizedBox(height: 15),

            Text(
              "Hi! I'm OneVest AI 👋",
              style: GoogleFonts.pressStart2p(
                color: white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              'Ask me anything about investing,\n'
              'risk or your portfolio.',
              textAlign: TextAlign.center,
              style: GoogleFonts.pressStart2p(
                color: muted,
                fontSize: 7,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(
    String text,
    bool isUser,
  ) {
    return Align(
      alignment: isUser
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 650,
        ),
        margin: const EdgeInsets.only(
          bottom: 10,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? tealDark
              : panel3,
          borderRadius:
              BorderRadius.circular(16),
          border: Border.all(
            color: isUser
                ? teal.withValues(alpha: 0.3)
                : border,
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.pressStart2p(
            color: white,
            fontSize: 8,
            height: 1.45,
          ),
        ),
      ),
    );
  }

  Widget _buildTyping() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: panel3,
          borderRadius:
              BorderRadius.circular(16),
          border: Border.all(
            color: border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _typingDot(),
            const SizedBox(width: 6),
            _typingDot(),
            const SizedBox(width: 6),
            _typingDot(),
          ],
        ),
      ),
    );
  }

  Widget _typingDot() {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: teal,
        shape: BoxShape.circle,
      ),
    );
  }

  // ============================================================
  // CHAT INPUT
  // ============================================================

  Widget _buildChatInput() {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _controller,
              onSubmitted: (_) {
                sendMessage();
              },
              style: GoogleFonts.pressStart2p(
                color: white,
                fontSize: 8,
              ),
              decoration: InputDecoration(
                hintText:
                    'Ask about investments...',
                hintStyle:
                    GoogleFonts.pressStart2p(
                  color: muted2,
                  fontSize: 8,
                ),
                filled: true,
                fillColor: background,
                contentPadding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 15,
                ),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                  borderSide:
                      const BorderSide(
                    color: border,
                  ),
                ),
                enabledBorder:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                  borderSide:
                      const BorderSide(
                    color: border,
                  ),
                ),
                focusedBorder:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                  borderSide:
                      const BorderSide(
                    color: teal,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          InkWell(
            onTap: sendMessage,
            borderRadius:
                BorderRadius.circular(16),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: teal,
                borderRadius:
                    BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.arrow_upward_rounded,
                color: background,
                size: 25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DISCLAIMER
  // ============================================================

  Widget _buildDisclaimer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF211F15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: orange.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(
            Icons.warning_amber_rounded,
            color: orange,
            size: 19,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              'AI-generated responses are for educational '
              'purposes only and should not be considered '
              'financial advice. Always verify information '
              'before making investment decisions.',
              style: GoogleFonts.pressStart2p(
                color: muted,
                fontSize: 7,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MOBILE NAVIGATION
  // ============================================================

  Widget _buildMobileBottomBar(
    BuildContext context,
  ) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: panel,
        border: Border(
          top: BorderSide(
            color: border,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceAround,
        children: <Widget>[
          _mobileNavItem(
            icon: Icons.home_rounded,
            label: 'Home',
            onTap: () {
              Navigator.pop(context);
            },
          ),

          _mobileNavItem(
            icon:
                Icons.account_balance_wallet_rounded,
            label: 'Portfolio',
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

          _mobileNavItem(
            icon: Icons.smart_toy_rounded,
            label: 'AI',
            selected: true,
            onTap: () {},
          ),

          _mobileNavItem(
            icon: Icons.person_rounded,
            label: 'Profile',
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
        ],
      ),
    );
  }

  Widget _mobileNavItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool selected = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              color: selected ? teal : muted,
              size: 22,
            ),

            const SizedBox(height: 3),

            Text(
              label,
              style: GoogleFonts.pressStart2p(
                color: selected ? teal : muted,
                fontSize: 6.5,
                fontWeight: selected
                    ? FontWeight.w700
                    : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ADVISOR DIALOG
  // ============================================================

  void _showAdvisorDialog(
    BuildContext context,
  ) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 520,
            ),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: panel,
              borderRadius:
                  BorderRadius.circular(24),
              border: Border.all(
                color: teal.withValues(alpha: 0.35),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    _iconBox(
                      Icons.auto_graph_rounded,
                      teal,
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Text(
                        'AI Advisor',
                        style:
                            GoogleFonts.pressStart2p(
                          color: white,
                          fontSize: 13,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                    ),

                    IconButton(
                      onPressed: () {
                        Navigator.pop(
                          dialogContext,
                        );
                      },
                      icon: const Icon(
                        Icons.close_rounded,
                        color: muted,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Text(
                  'PORTFOLIO SNAPSHOT',
                  style: GoogleFonts.pressStart2p(
                    color: teal,
                    fontSize: 6.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'Your current profile appears moderately '
                  'diversified. The AI recommends maintaining '
                  'diversification and reviewing concentrated '
                  'high-volatility positions.',
                  style: GoogleFonts.pressStart2p(
                    color: muted,
                    fontSize: 9,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: tealDark,
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: <Widget>[
                      const Icon(
                        Icons.lightbulb_outline,
                        color: teal,
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          'Consider reviewing your portfolio '
                          'allocation monthly.',
                          style:
                              GoogleFonts.pressStart2p(
                            color: white,
                            fontSize: 7,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(
                        dialogContext,
                      );
                    },
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor: teal,
                      foregroundColor: background,
                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'GOT IT',
                      style: GoogleFonts.pressStart2p(
                        fontSize: 6.5,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ================================================================
// CHALLENGE CENTER
// ================================================================

class _ChallengesCenterScreen
    extends StatelessWidget {
  const _ChallengesCenterScreen();

  static const Color background =
      Color(0xFF020B1D);

  static const Color panel =
      Color(0xFF0E1830);

  static const Color border =
      Color(0xFF243B63);

  static const Color teal =
      Color(0xFF10D8C3);

  static const Color white =
      Color(0xFFF4F7FF);

  static const Color muted =
      Color(0xFF8FA3C2);

  static const Color green =
      Color(0xFF48D36B);

  static const Color orange =
      Color(0xFFFFB340);

  static const Color purple =
      Color(0xFF9871FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: white,
          ),
        ),
        title: Text(
          'Challenge Center',
          style: GoogleFonts.pressStart2p(
            color: white,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          18,
          10,
          18,
          30,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: panel,
                borderRadius:
                    BorderRadius.circular(22),
                border: Border.all(
                  color:
                      teal.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color:
                          teal.withValues(alpha: 0.10),
                      borderRadius:
                          BorderRadius.circular(17),
                    ),
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      color: teal,
                      size: 30,
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'LEVEL 1',
                          style:
                              GoogleFonts.pressStart2p(
                            color: teal,
                            fontSize: 6.5,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          'Investment Explorer',
                          style:
                              GoogleFonts.pressStart2p(
                            color: white,
                            fontSize: 12,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          'Complete challenges and earn XP.',
                          style:
                              GoogleFonts.pressStart2p(
                            color: muted,
                            fontSize: 7,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Text(
              'MISSIONS',
              style: GoogleFonts.pressStart2p(
                color: muted,
                fontSize: 6.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 12),

            _challengeCard(
              title: 'Know Your Portfolio',
              subtitle:
                  'Review your current investments',
              xp: 50,
              icon:
                  Icons.account_balance_wallet_rounded,
              color: teal,
            ),

            const SizedBox(height: 12),

            _challengeCard(
              title: 'Diversification Check',
              subtitle:
                  'Learn why spreading risk matters',
              xp: 75,
              icon:
                  Icons.pie_chart_rounded,
              color: green,
            ),

            const SizedBox(height: 12),

            _challengeCard(
              title: 'Gold Explorer',
              subtitle:
                  'Understand gold as an asset class',
              xp: 100,
              icon:
                  Icons.workspace_premium_rounded,
              color: orange,
            ),

            const SizedBox(height: 12),

            _challengeCard(
              title: 'Risk Master',
              subtitle:
                  'Test your investing risk knowledge',
              xp: 125,
              icon: Icons.shield_rounded,
              color: purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _challengeCard({
    required String title,
    required String subtitle,
    required int xp,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: panel,
        borderRadius:
            BorderRadius.circular(18),
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
              color:
                  color.withValues(alpha: 0.10),
              borderRadius:
                  BorderRadius.circular(14),
              border: Border.all(
                color:
                    color.withValues(alpha: 0.30),
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 23,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style:
                      GoogleFonts.pressStart2p(
                    color: white,
                    fontSize: 9,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  style:
                      GoogleFonts.pressStart2p(
                    color: muted,
                    fontSize: 7,
                  ),
                ),
              ],
            ),
          ),

          Text(
            '+$xp XP',
            style: GoogleFonts.pressStart2p(
              color: color,
              fontSize: 6.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}