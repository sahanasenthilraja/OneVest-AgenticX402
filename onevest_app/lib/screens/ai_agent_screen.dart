import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

// ================================================================
// ONEVEST DESIGN SYSTEM
// ================================================================

// Exact OneVest dashboard palette
const Color _bg = Color(0xFF020B1D);
const Color _bg2 = Color(0xFF061126);

const Color _surface = Color(0xFF0E1830);
const Color _surface2 = Color(0xFF14213A);
const Color _surface3 = Color(0xFF0A2430);

const Color _teal = Color(0xFF14C8B0);
const Color _green = Color(0xFF42E88A);
const Color _purple = Color(0xFF8D70FF);
const Color _blue = Color(0xFF4D8DFF);
const Color _yellow = Color(0xFFFFB84D);
const Color _red = Color(0xFFFF6672);

const Color _white = Colors.white;
const Color _muted = Color(0xFF8C9AB5);
const Color _muted2 = Color(0xFF5F6F8A);

const double _radius = 18;

// Exact OneVest dashboard typography.
final TextStyle _mono = GoogleFonts.spaceMono(
  fontSize: 12,
);

final TextStyle _pixel = GoogleFonts.pressStart2p(
  fontSize: 12,
);
// Theme matched to DashboardScreen:
// #020B1D background, #0E1830 panels, #1E2C48 borders,
// #14C8B0 primary teal, Press Start 2P headings, Space Mono body text.

// ================================================================
// PAYMENT STORAGE
// ================================================================

class PaymentStorage {
  static const String _key = 'onevest_payment_history';

  static Future<List<Map<String, dynamic>>> loadPayments() async {
    final prefs = await SharedPreferences.getInstance();

    final saved = prefs.getStringList(_key);

    if (saved == null) return [];

    final result = <Map<String, dynamic>>[];

    for (final item in saved) {
      try {
        final decoded = jsonDecode(item);

        if (decoded is Map) {
          result.add(
            Map<String, dynamic>.from(decoded),
          );
        }
      } catch (_) {}
    }

    return result;
  }

  static Future<void> savePayments(
    List<Map<String, dynamic>> payments,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(
      _key,
      payments.map(jsonEncode).toList(),
    );
  }

  static Future<void> addPayment(
    Map<String, dynamic> payment,
  ) async {
    final payments = await loadPayments();

    payments.insert(0, payment);

    await savePayments(payments);
  }
}

// ================================================================
// SCREEN
// ================================================================

class AiAgentScreen extends StatefulWidget {
  const AiAgentScreen({super.key});

  @override
  State<AiAgentScreen> createState() => _AiAgentScreenState();
}

class _AiAgentScreenState extends State<AiAgentScreen> {
  final TextEditingController symbolController =
      TextEditingController(text: 'AAPL');

  bool isLoading = false;

  String? transactionId;
  String? errorMessage;

  Map<String, dynamic>? marketData;

  List<Map<String, dynamic>> paymentHistory = [];

  // ==============================================================
  // API
  // ==============================================================

  String get agentBaseUrl {
    if (defaultTargetPlatform == TargetPlatform.android && !kIsWeb) {
      return 'http://10.0.2.2:4020';
    }

    return 'http://localhost:4020';
  }

  // ==============================================================
  // INIT
  // ==============================================================

  @override
  void initState() {
    super.initState();

    _loadPaymentHistory();
  }

  @override
  void dispose() {
    symbolController.dispose();

    super.dispose();
  }

  Future<void> _loadPaymentHistory() async {
    final saved = await PaymentStorage.loadPayments();

    if (!mounted) return;

    setState(() {
      paymentHistory = saved;
    });
  }

  // ==============================================================
  // MARKET INTELLIGENCE
  // ==============================================================

  Future<void> getMarketIntelligence() async {
    final symbol = symbolController.text.trim().toUpperCase();

    if (symbol.isEmpty) {
      setState(() {
        errorMessage = 'PLEASE ENTER A STOCK SYMBOL';
      });

      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      isLoading = true;
      errorMessage = null;
      transactionId = null;
      marketData = null;
    });

    try {
      final uri = Uri.parse(
        '$agentBaseUrl/api/market-intelligence'
        '?symbol=${Uri.encodeComponent(symbol)}',
      );

      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception(
          'AGENT API RETURNED HTTP ${response.statusCode}',
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map) {
        throw Exception(
          'INVALID RESPONSE FROM AI AGENT',
        );
      }

      final result = Map<String, dynamic>.from(decoded);

      if (result['success'] != true) {
        throw Exception(
          result['error']?.toString() ??
              'X402 REQUEST FAILED',
        );
      }

      Map<String, dynamic> payment = {};

      if (result['payment'] is Map) {
        payment = Map<String, dynamic>.from(
          result['payment'],
        );
      }

      final tx = payment['transaction']?.toString() ?? '';

      Map<String, dynamic> serviceData = {};

      if (result['data'] is Map) {
        serviceData = Map<String, dynamic>.from(
          result['data'],
        );
      }

      Map<String, dynamic> market = {};

      if (serviceData['market'] is Map) {
        market = Map<String, dynamic>.from(
          serviceData['market'],
        );
      }

      if (tx.isEmpty) {
        throw Exception(
          'PAYMENT SETTLED BUT TRANSACTION ID WAS NOT RETURNED',
        );
      }

      final paymentRecord = <String, dynamic>{
        'symbol': symbol,
        'transaction': tx,
        'amount': '0.005 USDC',
        'network': 'Algorand TestNet',
        'paidBy': 'AI Agent',
        'timestamp': DateTime.now().toIso8601String(),
      };

      await PaymentStorage.addPayment(
        paymentRecord,
      );

      final updated =
          await PaymentStorage.loadPayments();

      if (!mounted) return;

      setState(() {
        transactionId = tx;
        marketData = market;
        paymentHistory = updated;
        isLoading = false;
      });

      _showSuccessPopup(symbol);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;

        errorMessage = e
            .toString()
            .replaceFirst(
              'Exception: ',
              '',
            );
      });
    }
  }

  // ==============================================================
  // EXPLORER
  // ==============================================================

  Future<void> _viewTransaction(
    String txId,
  ) async {
    if (txId.isEmpty) return;

    final url = Uri.parse(
      'https://testnet.explorer.perawallet.app/tx/$txId',
    );

    try {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      if (!mounted) return;

      _snack(
        'COULD NOT OPEN EXPLORER',
      );
    }
  }

  // ==============================================================
  // POPUPS
  // ==============================================================

  void _showSuccessPopup(
    String symbol,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _SuccessSheet(
        symbol: symbol,
        transactionId: transactionId ?? '',
        onViewTransaction: () {
          Navigator.pop(context);

          _viewTransaction(
            transactionId ?? '',
          );
        },
      ),
    );
  }

  void _showFlowPopup() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _FlowSheet(),
    );
  }

  void _showMarketPopup() {
    if (marketData == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _MarketSheet(
        data: marketData!,
      ),
    );
  }

  void _showHistoryPopup() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _HistorySheet(
        payments: paymentHistory,
        onTransaction: _viewTransaction,
      ),
    );
  }

  void _showTransactionDetails(
    Map<String, dynamic> payment,
  ) {
    final tx =
        payment['transaction']?.toString() ?? '';

    final symbol =
        payment['symbol']?.toString() ?? '-';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _DetailsSheet(
        symbol: symbol,
        transaction: tx,
        amount:
            payment['amount']?.toString() ??
                '0.005 USDC',
        network:
            payment['network']?.toString() ??
                'Algorand TestNet',
        onView: () {
          Navigator.pop(context);

          _viewTransaction(tx);
        },
      ),
    );
  }

  void _snack(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _surface3,
        behavior: SnackBarBehavior.floating,
        content: Text(
          message,
          style: _mono.copyWith(
            color: _white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ==============================================================
  // BUILD
  // ==============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final width = MediaQuery.sizeOf(context).width;

    final bool desktop = width >= 900;

    return Scaffold(
      backgroundColor: _bg,

      appBar: _topBar(),

      body: SafeArea(
        child: RefreshIndicator(
          color: _teal,
          backgroundColor: _surface,
          onRefresh: _loadPaymentHistory,

          child: SingleChildScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(),

            padding: EdgeInsets.fromLTRB(
              desktop ? 32 : 16,
              24,
              desktop ? 32 : 16,
              45,
            ),

            child: Center(
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(
                  maxWidth: 1320,
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    _hero(),

                    const SizedBox(height: 20),

                    _flowCard(),

                    const SizedBox(height: 20),

                    if (desktop)
                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 6,
                            child: _symbolCard(),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            flex: 4,
                            child: _sideInfo(),
                          ),
                        ],
                      )
                    else ...[
                      _symbolCard(),
                      const SizedBox(height: 20),
                      _sideInfo(),
                    ],

                    if (isLoading) ...[
                      const SizedBox(height: 20),
                      _processingCard(),
                    ],

                    if (errorMessage != null) ...[
                      const SizedBox(height: 20),
                      _errorCard(),
                    ],

                    if (marketData != null) ...[
                      const SizedBox(height: 20),
                      _marketPreview(),
                    ],

                    const SizedBox(height: 20),

                    _historyPreview(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==============================================================
  // TOP BAR
  // ==============================================================

  PreferredSizeWidget _topBar() {
    return PreferredSize(
      preferredSize:
          const Size.fromHeight(66),

      child: Container(
        decoration: const BoxDecoration(
          color: _surface,
          border: Border(
            bottom: BorderSide(
              color: Color(0xFF1E2C48),
              width: 1,
            ),
          ),
        ),

        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,

          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: _white,
            ),

            onPressed: () {
              Navigator.maybePop(context);
            },
          ),

          titleSpacing: 4,

          title: Text(
            'AI MARKET AGENT',
            style: _pixel.copyWith(
              color: _white,
              fontSize: 11,
              height: 1.4,
            ),
          ),

          actions: [
            _topStatus(),

            const SizedBox(width: 8),

            IconButton(
              tooltip: 'Payment history',

              icon: const Icon(
                Icons.receipt_long_rounded,
                color: _teal,
              ),

              onPressed:
                  _showHistoryPopup,
            ),

            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _topStatus() {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),

      decoration: BoxDecoration(
        color: _green.withOpacity(.08),
        borderRadius:
            BorderRadius.circular(20),

        border: Border.all(
          color: _green.withOpacity(.28),
        ),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,

        children: [
          Container(
            width: 6,
            height: 6,

            decoration:
                const BoxDecoration(
              color: _green,
              shape: BoxShape.circle,
            ),
          ),

          const SizedBox(width: 6),

          Text(
            'LIVE',
            style: _mono.copyWith(
              color: _green,
              fontSize: 8,
              fontWeight:
                  FontWeight.w900,
              letterSpacing: .8,
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // HERO
  // ==============================================================

  Widget _hero() {
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(24),

      decoration: BoxDecoration(
        color: _surface,

        borderRadius:
            BorderRadius.circular(20),

        border: Border.all(
          color: _teal.withOpacity(.32),
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(.25),
            blurRadius: 24,
            offset:
                const Offset(0, 10),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              _glowIcon(
                Icons.auto_awesome_rounded,
                _purple,
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      'ONEVEST AI',
                      style: _pixel.copyWith(
                        color: _teal,
                        fontSize: 8,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      'MARKET INTELLIGENCE',
                      style: _pixel.copyWith(
                        color: _white,
                        fontSize: 11,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              _livePill(),
            ],
          ),

          const SizedBox(height: 25),

          Text(
            'AI-POWERED PREMIUM\nMARKET INSIGHTS',
            style: _pixel.copyWith(
              color: _white,
              fontSize: 13,
              height: 1.7,
            ),
          ),

          const SizedBox(height: 13),

          Text(
            'Your AI agent requests premium market data, '
            'handles x402 payment, and unlocks the result automatically.',
            style: _mono.copyWith(
              color: _muted,
              fontSize: 11,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 23),

          LayoutBuilder(
            builder: (
              context,
              constraints,
            ) {
              return Row(
                children: [
                  Expanded(
                    child: _heroChip(
                      Icons.bolt_rounded,
                      'AI AGENT',
                      _green,
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: _heroChip(
                      Icons.payments_rounded,
                      'X402',
                      _purple,
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: _heroChip(
                      Icons.account_balance_rounded,
                      'ALGORAND',
                      _teal,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _heroChip(
    IconData icon,
    String text,
    Color color,
  ) {
    return Container(
      height: 38,

      decoration: BoxDecoration(
        color: color.withOpacity(.07),

        borderRadius:
            BorderRadius.circular(9),

        border: Border.all(
          color: color.withOpacity(.14),
        ),
      ),

      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [
          Icon(
            icon,
            color: color,
            size: 14,
          ),

          const SizedBox(width: 6),

          Text(
            text,
            style: _mono.copyWith(
              color: color,
              fontSize: 8,
              fontWeight:
                  FontWeight.w900,
              letterSpacing: .6,
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // FLOW
  // ==============================================================

  Widget _flowCard() {
    return InkWell(
      borderRadius:
          BorderRadius.circular(_radius),

      onTap: _showFlowPopup,

      child: _card(
        borderColor:
            _green.withOpacity(.30),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            _sectionHeader(
              Icons.smart_toy_rounded,
              'AI AGENT + X402',
              _green,

              trailing: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: _muted,
                size: 21,
              ),
            ),

            const SizedBox(height: 9),

            Text(
              'TAP TO VIEW THE COMPLETE AUTONOMOUS PAYMENT FLOW',
              style: _mono.copyWith(
                color: _muted,
                fontSize: 9,
                letterSpacing: .3,
              ),
            ),

            const SizedBox(height: 19),

            LayoutBuilder(
              builder: (
                context,
                constraints,
              ) {
                return Row(
                  children: [
                    Expanded(
                      child: _flowStep(
                        '01',
                        'REQUEST',
                        Icons.chat_bubble_outline_rounded,
                      ),
                    ),

                    _flowArrow(),

                    Expanded(
                      child: _flowStep(
                        '02',
                        'PAY',
                        Icons.payments_outlined,
                      ),
                    ),

                    _flowArrow(),

                    Expanded(
                      child: _flowStep(
                        '03',
                        'SETTLE',
                        Icons.account_balance_outlined,
                      ),
                    ),

                    _flowArrow(),

                    Expanded(
                      child: _flowStep(
                        '04',
                        'UNLOCK',
                        Icons.lock_open_rounded,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _flowStep(
    String number,
    String label,
    IconData icon,
  ) {
    return Column(
      children: [
        Container(
          width: 38,
          height: 38,

          decoration: BoxDecoration(
            color: _teal.withOpacity(.10),
            shape: BoxShape.circle,

            border: Border.all(
              color: Color(0xFF1E2C48),
            ),
          ),

          child: Icon(
            icon,
            color: _teal,
            size: 16,
          ),
        ),

        const SizedBox(height: 7),

        Text(
          number,
          style: _mono.copyWith(
            color: _teal,
            fontSize: 8,
            fontWeight:
                FontWeight.w900,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          label,
          style: _mono.copyWith(
            color: _muted,
            fontSize: 8,
            fontWeight:
                FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _flowArrow() {
    return const Padding(
      padding:
          EdgeInsets.symmetric(
        horizontal: 4,
      ),

      child: Icon(
        Icons.chevron_right_rounded,
        color: Colors.white24,
        size: 18,
      ),
    );
  }

  // ==============================================================
  // MARKET INPUT
  // ==============================================================

  Widget _symbolCard() {
    return _card(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          _sectionHeader(
            Icons.show_chart_rounded,
            'GET MARKET INTELLIGENCE',
            _teal,
          ),

          const SizedBox(height: 17),

          Text(
            'STOCK SYMBOL',
            style: _mono.copyWith(
              color: _muted,
              fontSize: 9,
              fontWeight:
                  FontWeight.w900,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 8),

          Container(
            height: 55,

            decoration: BoxDecoration(
              color: _surface2,

              borderRadius:
                  BorderRadius.circular(13),

              border: Border.all(
                color: _blue.withOpacity(.20),
              ),
            ),

            child: TextField(
              controller: symbolController,

              textCapitalization:
                  TextCapitalization.characters,

              style: _mono.copyWith(
                color: _white,
                fontSize: 12,
                fontWeight:
                    FontWeight.w900,
              ),

              decoration:
                  InputDecoration(
                hintText:
                    'ENTER SYMBOL  •  E.G. AAPL',

                hintStyle:
                    _mono.copyWith(
                  color: _muted2,
                  fontSize: 10,
                  fontWeight:
                      FontWeight.w700,
                ),

                prefixIcon:
                    const Icon(
                  Icons.search_rounded,
                  color: _teal,
                  size: 21,
                ),

                suffixIcon:
                    IconButton(
                  icon:
                      const Icon(
                    Icons.close_rounded,
                    color: _muted,
                    size: 18,
                  ),

                  onPressed: () {
                    symbolController.clear();

                    setState(() {});
                  },
                ),

                border:
                    InputBorder.none,

                contentPadding:
                    const EdgeInsets.symmetric(
                  vertical: 17,
                ),
              ),

              onSubmitted: (_) =>
                  getMarketIntelligence(),
            ),
          ),

          const SizedBox(height: 10),

          Wrap(
            spacing: 7,
            runSpacing: 7,

            children: [
              'AAPL',
              'MSFT',
              'GOOGL',
              'TSLA',
              'NVDA',
            ]
                .map(
                  (symbol) =>
                      _symbolChip(symbol),
                )
                .toList(),
          ),

          const SizedBox(height: 15),

          SizedBox(
            width: double.infinity,
            height: 55,

            child: ElevatedButton.icon(
              onPressed:
                  isLoading
                      ? null
                      : getMarketIntelligence,

              style:
                  ElevatedButton.styleFrom(
                backgroundColor: _teal,
                foregroundColor: _bg,

                disabledBackgroundColor:
                    _teal.withOpacity(.35),

                elevation: 0,

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(13),
                ),
              ),

              icon: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,

                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _bg,
                      ),
                    )
                  : const Icon(
                      Icons.auto_awesome_rounded,
                      size: 18,
                    ),

              label: Text(
                isLoading
                    ? 'AI AGENT PROCESSING...'
                    : 'GET AI MARKET INTELLIGENCE',

                style: _mono.copyWith(
                  fontSize: 9,
                  fontWeight:
                      FontWeight.w900,
                  letterSpacing: .6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _symbolChip(
    String symbol,
  ) {
    final selected =
        symbolController.text
            .toUpperCase() ==
        symbol;

    return InkWell(
      borderRadius:
          BorderRadius.circular(8),

      onTap: () {
        setState(() {
          symbolController.text =
              symbol;
        });
      },

      child: AnimatedContainer(
        duration:
            const Duration(
          milliseconds: 160,
        ),

        padding:
            const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 9,
        ),

        decoration: BoxDecoration(
          color: selected
              ? _teal.withOpacity(.12)
              : _surface2,

          borderRadius:
              BorderRadius.circular(8),

          border: Border.all(
            color: selected
                ? _teal.withOpacity(.35)
                : Colors.transparent,
          ),
        ),

        child: Text(
          symbol,
          style: _mono.copyWith(
            color: selected
                ? _teal
                : _muted,
            fontSize: 9,
            fontWeight:
                FontWeight.w900,
          ),
        ),
      ),
    );
  }

  // ==============================================================
  // SIDE INFO
  // ==============================================================

  Widget _sideInfo() {
    return _card(
      borderColor:
          _purple.withOpacity(.25),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          _sectionHeader(
            Icons.bolt_rounded,
            'AUTONOMOUS PAYMENT',
            _purple,
          ),

          const SizedBox(height: 15),

          _infoRow(
            'REQUEST',
            'PREMIUM DATA',
            Icons.api_rounded,
          ),

          _divider(),

          _infoRow(
            'PAYMENT',
            '0.005 USDC',
            Icons.payments_rounded,
          ),

          _divider(),

          _infoRow(
            'NETWORK',
            'ALGORAND TESTNET',
            Icons.account_balance_rounded,
          ),

          _divider(),

          _infoRow(
            'SETTLEMENT',
            'AUTOMATIC',
            Icons.check_circle_outline,
          ),

          const SizedBox(height: 14),

          Container(
            width: double.infinity,

            padding:
                const EdgeInsets.all(13),

            decoration: BoxDecoration(
              color:
                  _purple.withOpacity(.06),

              borderRadius:
                  BorderRadius.circular(11),

              border: Border.all(
                color:
                    _purple.withOpacity(.14),
              ),
            ),

            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                const Icon(
                  Icons.auto_awesome,
                  color: _purple,
                  size: 16,
                ),

                const SizedBox(width: 9),

                Expanded(
                  child: Text(
                    'THE AI AGENT HANDLES THE PAYMENT FLOW — YOU JUST REQUEST THE DATA.',
                    style: _mono.copyWith(
                      color: _muted,
                      fontSize: 8,
                      height: 1.5,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
    String title,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: _muted,
          size: 16,
        ),

        const SizedBox(width: 9),

        Expanded(
          child: Text(
            title,
            style: _mono.copyWith(
              color: _muted,
              fontSize: 8,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
        ),

        Text(
          value,
          style: _mono.copyWith(
            color: _white,
            fontSize: 8,
            fontWeight:
                FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(
      height: 1,
      margin:
          const EdgeInsets.symmetric(
        vertical: 12,
      ),
      color: Colors.white.withOpacity(.05),
    );
  }

  // ==============================================================
  // PROCESSING
  // ==============================================================

  Widget _processingCard() {
    return _card(
      borderColor:
          _purple.withOpacity(.40),

      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,

            decoration: BoxDecoration(
              color:
                  _purple.withOpacity(.08),
              shape: BoxShape.circle,

              border: Border.all(
                color:
                    _purple.withOpacity(.25),
              ),
            ),

            child:
                const Padding(
              padding:
                  EdgeInsets.all(14),

              child:
                  CircularProgressIndicator(
                color: _teal,
                strokeWidth: 2.5,
              ),
            ),
          ),

          const SizedBox(height: 14),

          Text(
            'AI AGENT IS WORKING',
            style: _mono.copyWith(
              color: _teal,
              fontSize: 10,
              fontWeight:
                  FontWeight.w900,
              letterSpacing: 1.3,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            'REQUESTING PREMIUM DATA  →  '
            'CREATING X402 PAYMENT  →  '
            'SETTLING ON ALGORAND  →  '
            'UNLOCKING INTELLIGENCE',

            textAlign:
                TextAlign.center,

            style: _mono.copyWith(
              color: _muted,
              fontSize: 8,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 16),

          ClipRRect(
            borderRadius:
                BorderRadius.circular(20),

            child:
                const LinearProgressIndicator(
              minHeight: 4,
              backgroundColor:
                  _surface2,
              valueColor:
                  AlwaysStoppedAnimation(
                _teal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // ERROR
  // ==============================================================

  Widget _errorCard() {
    return _card(
      borderColor:
          _red.withOpacity(.35),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Container(
            width: 38,
            height: 38,

            decoration: BoxDecoration(
              color:
                  _red.withOpacity(.08),
              borderRadius:
                  BorderRadius.circular(10),
            ),

            child: const Icon(
              Icons.error_outline_rounded,
              color: _red,
              size: 19,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  'AGENT ERROR',
                  style: _mono.copyWith(
                    color: _red,
                    fontSize: 9,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  errorMessage ?? '',
                  style: _mono.copyWith(
                    color: _muted,
                    fontSize: 9,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () {
              setState(() {
                errorMessage = null;
              });
            },

            icon: const Icon(
              Icons.close_rounded,
              color: _muted,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // MARKET RESULT
  // ==============================================================

  Widget _marketPreview() {
    final symbol =
        marketData?['symbol']
                ?.toString() ??
            'AAPL';

    final price =
        marketData?['price']
                ?.toString() ??
            '-';

    final change =
        marketData?['changePercent']
                ?.toString() ??
            '-';

    return InkWell(
      borderRadius:
          BorderRadius.circular(_radius),

      onTap: _showMarketPopup,

      child: _card(
        borderColor:
            _green.withOpacity(.38),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            _sectionHeader(
              Icons.lock_open_rounded,
              'PREMIUM DATA UNLOCKED',
              _green,

              trailing:
                  const Icon(
                Icons.open_in_full_rounded,
                color: _muted,
                size: 18,
              ),
            ),

            const SizedBox(height: 18),

            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                _glowIcon(
                  Icons.trending_up_rounded,
                  _green,
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Text(
                        symbol,
                        style: _mono.copyWith(
                          color: _white,
                          fontSize: 24,
                          fontWeight:
                              FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        'PREMIUM MARKET INTELLIGENCE',
                        style: _mono.copyWith(
                          color: _muted,
                          fontSize: 8,
                          letterSpacing: .8,
                        ),
                      ),
                    ],
                  ),
                ),

                Text(
                  change == '-'
                      ? '-'
                      : '$change%',
                  style: _mono.copyWith(
                    color: _green,
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Text(
              '\$$price',
              style: _mono.copyWith(
                color: _white,
                fontSize: 32,
                fontWeight:
                    FontWeight.w900,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'TAP FOR FULL PREMIUM MARKET DETAILS',
              style: _mono.copyWith(
                color: _muted,
                fontSize: 8,
                letterSpacing: .4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // HISTORY
  // ==============================================================

  Widget _historyPreview() {
    final recent =
        paymentHistory
            .take(3)
            .toList();

    return _card(
      borderColor:
          _purple.withOpacity(.25),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          _sectionHeader(
            Icons.receipt_long_rounded,
            'PAYMENT HISTORY',
            _purple,

            trailing:
                TextButton(
              onPressed:
                  _showHistoryPopup,

              child: Text(
                'VIEW ALL',
                style: _mono.copyWith(
                  color: _teal,
                  fontSize: 9,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),
            ),
          ),

          const SizedBox(height: 6),

          if (recent.isEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(
                vertical: 25,
              ),

              child: Center(
                child: Text(
                  'NO X402 PAYMENTS YET',
                  style: _mono.copyWith(
                    color: _muted,
                    fontSize: 9,
                    letterSpacing: .5,
                  ),
                ),
              ),
            )
          else
            ...recent.map(
              (payment) =>
                  _historyItem(
                payment,
                compact: true,
              ),
            ),
        ],
      ),
    );
  }

  Widget _historyItem(
    Map<String, dynamic> payment, {
    bool compact = false,
  }) {
    final symbol =
        payment['symbol']
                ?.toString() ??
            '-';

    final tx =
        payment['transaction']
                ?.toString() ??
            '';

    return InkWell(
      borderRadius:
          BorderRadius.circular(12),

      onTap: () =>
          _showTransactionDetails(
        payment,
      ),

      child: Container(
        margin:
            const EdgeInsets.only(
          bottom: 8,
        ),

        padding:
            const EdgeInsets.all(12),

        decoration: BoxDecoration(
          color: _surface2,

          borderRadius:
              BorderRadius.circular(12),

          border: Border.all(
            color:
                Colors.white.withOpacity(.025),
          ),
        ),

        child: Row(
          children: [
            _glowIcon(
              Icons.check_rounded,
              _green,
              size: 40,
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    '$symbol MARKET INTELLIGENCE',
                    style: _mono.copyWith(
                      color: _white,
                      fontSize: 9,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    '0.005 USDC  •  ALGORAND TESTNET',
                    style: _mono.copyWith(
                      color: _muted,
                      fontSize: 8,
                    ),
                  ),

                  if (!compact &&
                      tx.isNotEmpty) ...[
                    const SizedBox(height: 4),

                    Text(
                      _shortTx(tx),
                      style: _mono.copyWith(
                        color: _muted2,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
              color: _muted,
              size: 19,
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // CARD
  // ==============================================================

  Widget _card({
    required Widget child,
    EdgeInsetsGeometry padding =
        const EdgeInsets.all(18),
    Color? borderColor,
  }) {
    return Container(
      width: double.infinity,

      padding: padding,

      decoration: BoxDecoration(
        color: _surface,

        borderRadius:
            BorderRadius.circular(_radius),

        border: Border.all(
          color:
              borderColor ??
              Color(0xFF1E2C48),
        ),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(.18),
            blurRadius: 18,
            offset:
                const Offset(0, 7),
          ),
        ],
      ),

      child: child,
    );
  }

  // ==============================================================
  // SECTION HEADER
  // ==============================================================

  Widget _sectionHeader(
    IconData icon,
    String title,
    Color color, {
    Widget? trailing,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: 18,
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Text(
            title,
            style: _pixel.copyWith(
              color: color,
              fontSize: 8,
              height: 1.4,
              letterSpacing: .2,
            ),
          ),
        ),

        if (trailing != null)
          trailing,
      ],
    );
  }

  // ==============================================================
  // ICON
  // ==============================================================

  Widget _glowIcon(
    IconData icon,
    Color color, {
    double size = 46,
  }) {
    return Container(
      width: size,
      height: size,

      decoration: BoxDecoration(
        color: color.withOpacity(.09),

        borderRadius:
            BorderRadius.circular(13),

        border: Border.all(
          color:
              color.withOpacity(.22),
        ),

        boxShadow: [
          BoxShadow(
            color:
                color.withOpacity(.05),
            blurRadius: 14,
          ),
        ],
      ),

      child: Icon(
        icon,
        color: color,
        size: size * .43,
      ),
    );
  }

  // ==============================================================
  // LIVE
  // ==============================================================

  Widget _livePill() {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),

      decoration: BoxDecoration(
        color: _green.withOpacity(.08),

        borderRadius:
            BorderRadius.circular(20),

        border: Border.all(
          color:
              _green.withOpacity(.30),
        ),
      ),

      child: Row(
        mainAxisSize:
            MainAxisSize.min,

        children: [
          const Icon(
            Icons.circle,
            color: _green,
            size: 6,
          ),

          const SizedBox(width: 5),

          Text(
            'LIVE',
            style: _mono.copyWith(
              color: _green,
              fontSize: 8,
              fontWeight:
                  FontWeight.w900,
              letterSpacing: .8,
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // BOTTOM SHEET BASE
  // ==============================================================

  Widget _sheetBase(
    BuildContext context, {
    required Widget child,
  }) {
    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight:
              MediaQuery.sizeOf(context)
                      .height *
                  .85,
        ),

        padding:
            const EdgeInsets.fromLTRB(
          18,
          10,
          18,
          20,
        ),

        decoration:
            const BoxDecoration(
          color: _bg,

          borderRadius:
              BorderRadius.vertical(
            top: Radius.circular(25),
          ),

          border: Border(
            top: BorderSide(
              color: _teal,
              width: 1,
            ),
          ),
        ),

        child:
            SingleChildScrollView(
          child: child,
        ),
      ),
    );
  }

  Widget _handle() {
    return Center(
      child: Container(
        width: 42,
        height: 4,

        margin:
            const EdgeInsets.only(
          bottom: 20,
        ),

        decoration:
            BoxDecoration(
          color: Colors.white24,
          borderRadius:
              BorderRadius.circular(20),
        ),
      ),
    );
  }

  // ==============================================================
  // HELPERS
  // ==============================================================

  String _shortTx(String tx) {
    if (tx.length <= 18) return tx;

    return '${tx.substring(0, 9)}...'
        '${tx.substring(tx.length - 7)}';
  }
}

// ==================================================================
// FLOW SHEET
// ==================================================================

class _FlowSheet extends StatelessWidget {
  const _FlowSheet();

  @override
  Widget build(
    BuildContext context,
  ) {
    return _SheetContainer(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          _SheetHandle(),

          _SheetTitle(
            icon:
                Icons.smart_toy_rounded,
            title:
                'AI AGENT + X402',
            color:
                _green,
          ),

          const SizedBox(height: 8),

          Text(
            'AUTONOMOUS PREMIUM MARKET-DATA FLOW',
            style: _mono.copyWith(
              color: _muted,
              fontSize: 9,
            ),
          ),

          const SizedBox(height: 20),

          _FlowRow(
            number: '01',
            text:
                'USER REQUESTS PREMIUM MARKET DATA',
          ),

          _FlowRow(
            number: '02',
            text:
                'AI AGENT CALLS THE PAID API',
          ),

          _FlowRow(
            number: '03',
            text:
                'X402 PAYMENT IS AUTOMATICALLY CREATED',
          ),

          _FlowRow(
            number: '04',
            text:
                'PAYMENT SETTLES ON ALGORAND TESTNET',
          ),

          _FlowRow(
            number: '05',
            text:
                'PREMIUM MARKET DATA IS UNLOCKED',
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// SUCCESS SHEET
// ==================================================================

class _SuccessSheet extends StatelessWidget {
  final String symbol;
  final String transactionId;
  final VoidCallback onViewTransaction;

  const _SuccessSheet({
    required this.symbol,
    required this.transactionId,
    required this.onViewTransaction,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return _SheetContainer(
      child: Column(
        children: [
          _SheetHandle(),

          const SizedBox(height: 5),

          const Icon(
            Icons.check_circle_rounded,
            color: _green,
            size: 68,
          ),

          const SizedBox(height: 14),

          Text(
            'PAYMENT SETTLED',
            style: _mono.copyWith(
              color: _green,
              fontSize: 16,
              fontWeight:
                  FontWeight.w900,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            '$symbol PREMIUM INTELLIGENCE IS UNLOCKED',
            style: _mono.copyWith(
              color: _muted,
              fontSize: 9,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          _SheetInfo(
            icon:
                Icons.payments_rounded,
            title:
                '0.005 USDC',
            subtitle:
                'ALGORAND TESTNET  •  AI AGENT',
            color:
                _green,
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,

            child:
                OutlinedButton.icon(
              onPressed:
                  onViewTransaction,

              icon:
                  const Icon(
                Icons.open_in_new_rounded,
                color: _teal,
              ),

              label:
                  Text(
                'VIEW TRANSACTION',
                style: _mono.copyWith(
                  color: _teal,
                  fontSize: 9,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),

              style:
                  OutlinedButton.styleFrom(
                side:
                    const BorderSide(
                  color: _teal,
                ),

                padding:
                    const EdgeInsets.symmetric(
                  vertical: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// MARKET SHEET
// ==================================================================

class _MarketSheet extends StatelessWidget {
  final Map<String, dynamic> data;

  const _MarketSheet({
    required this.data,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final symbol =
        data['symbol']?.toString() ??
            'AAPL';

    final price =
        data['price']?.toString() ??
            '-';

    final change =
        data['changePercent']
                ?.toString() ??
            '-';

    final previous =
        data['previousClose']
                ?.toString() ??
            '-';

    final volume =
        data['volume']?.toString() ??
            '-';

    return _SheetContainer(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          _SheetHandle(),

          _SheetTitle(
            icon:
                Icons.lock_open_rounded,
            title:
                'PREMIUM MARKET DATA',
            color:
                _green,
          ),

          const SizedBox(height: 20),

          Text(
            symbol,
            style: _mono.copyWith(
              color: _white,
              fontSize: 29,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            '\$$price',
            style: _mono.copyWith(
              color: _white,
              fontSize: 27,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            '$change%',
            style: _mono.copyWith(
              color: _green,
              fontSize: 15,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(height: 20),

          _DataRow(
            label: 'PREVIOUS CLOSE',
            value: '\$$previous',
          ),

          _DataRow(
            label: 'VOLUME',
            value: volume,
          ),

          _DataRow(
            label: 'SOURCE',
            value: 'ALPHA VANTAGE',
          ),

          const SizedBox(height: 8),

          _SheetInfo(
            icon:
                Icons.auto_awesome_rounded,
            title:
                'AI UNLOCKED THIS DATA',
            subtitle:
                'RESULT RETURNED AFTER THE X402 PAYMENT FLOW.',
            color:
                _purple,
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// HISTORY SHEET
// ==================================================================

class _HistorySheet extends StatelessWidget {
  final List<Map<String, dynamic>> payments;
  final Future<void> Function(String)
      onTransaction;

  const _HistorySheet({
    required this.payments,
    required this.onTransaction,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return _SheetContainer(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          _SheetHandle(),

          _SheetTitle(
            icon:
                Icons.receipt_long_rounded,
            title:
                'PAYMENT HISTORY',
            color:
                _purple,
          ),

          const SizedBox(height: 15),

          if (payments.isEmpty)
            Center(
              child: Padding(
                padding:
                    const EdgeInsets.all(25),

                child: Text(
                  'NO PAYMENTS YET',
                  style: _mono.copyWith(
                    color: _muted,
                    fontSize: 9,
                  ),
                ),
              ),
            )
          else
            ...payments.map(
              (payment) {
                final symbol =
                    payment['symbol']
                            ?.toString() ??
                        '-';

                final tx =
                    payment['transaction']
                            ?.toString() ??
                        '';

                return ListTile(
                  tileColor:
                      _surface2,

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),

                  leading:
                      const Icon(
                    Icons.check_circle_rounded,
                    color: _green,
                  ),

                  title: Text(
                    '$symbol MARKET INTELLIGENCE',
                    style: _mono.copyWith(
                      color: _white,
                      fontSize: 9,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),

                  subtitle: Text(
                    '${payment['amount'] ?? '0.005 USDC'}'
                    '  •  '
                    '${payment['network'] ?? 'Algorand TestNet'}',
                    style: _mono.copyWith(
                      color: _muted,
                      fontSize: 8,
                    ),
                  ),

                  trailing:
                      const Icon(
                    Icons.open_in_new_rounded,
                    color: _teal,
                    size: 18,
                  ),

                  onTap: () {
                    Navigator.pop(context);

                    onTransaction(tx);
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}

// ==================================================================
// DETAILS SHEET
// ==================================================================

class _DetailsSheet extends StatelessWidget {
  final String symbol;
  final String transaction;
  final String amount;
  final String network;
  final VoidCallback onView;

  const _DetailsSheet({
    required this.symbol,
    required this.transaction,
    required this.amount,
    required this.network,
    required this.onView,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return _SheetContainer(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          _SheetHandle(),

          _SheetTitle(
            icon:
                Icons.receipt_long_rounded,
            title:
                'TRANSACTION DETAILS',
            color:
                _teal,
          ),

          const SizedBox(height: 18),

          Text(
            '$symbol MARKET INTELLIGENCE',
            style: _mono.copyWith(
              color: _white,
              fontSize: 16,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(height: 20),

          _DataRow(
            label: 'AMOUNT',
            value: amount,
          ),

          _DataRow(
            label: 'NETWORK',
            value: network,
          ),

          _DataRow(
            label: 'PAID BY',
            value: 'AI AGENT',
          ),

          const SizedBox(height: 8),

          Text(
            'TRANSACTION ID',
            style: _mono.copyWith(
              color: _muted,
              fontSize: 8,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(height: 6),

          SelectableText(
            transaction,
            style: _mono.copyWith(
              color: _white,
              fontSize: 8,
            ),
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,

            child:
                ElevatedButton.icon(
              onPressed: onView,

              icon:
                  const Icon(
                Icons.open_in_new_rounded,
                size: 17,
              ),

              label:
                  Text(
                'VIEW ON EXPLORER',
                style: _mono.copyWith(
                  fontSize: 9,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),

              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    _teal,

                foregroundColor:
                    _bg,

                padding:
                    const EdgeInsets.symmetric(
                  vertical: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// SHARED SHEET WIDGETS
// ==================================================================

class _SheetContainer
    extends StatelessWidget {
  final Widget child;

  const _SheetContainer({
    required this.child,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return SafeArea(
      child: Container(
        constraints:
            BoxConstraints(
          maxHeight:
              MediaQuery.sizeOf(context)
                      .height *
                  .85,
        ),

        padding:
            const EdgeInsets.fromLTRB(
          18,
          10,
          18,
          20,
        ),

        decoration:
            const BoxDecoration(
          color: _bg,

          borderRadius:
              BorderRadius.vertical(
            top: Radius.circular(25),
          ),

          border: Border(
            top: BorderSide(
              color: _teal,
            ),
          ),
        ),

        child:
            SingleChildScrollView(
          child: child,
        ),
      ),
    );
  }
}

class _SheetHandle
    extends StatelessWidget {
  @override
  Widget build(
    BuildContext context,
  ) {
    return Center(
      child: Container(
        width: 42,
        height: 4,

        margin:
            const EdgeInsets.only(
          bottom: 20,
        ),

        decoration:
            BoxDecoration(
          color: Colors.white24,

          borderRadius:
              BorderRadius.circular(20),
        ),
      ),
    );
  }
}

class _SheetTitle
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _SheetTitle({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),

        const SizedBox(width: 9),

        Expanded(
          child: Text(
            title,
            style: _pixel.copyWith(
              color: color,
              fontSize: 8,
              height: 1.4,
              letterSpacing: .2,
            ),
          ),
        ),
      ],
    );
  }
}

class _FlowRow
    extends StatelessWidget {
  final String number;
  final String text;

  const _FlowRow({
    required this.number,
    required this.text,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 13,
      ),

      child: Row(
        children: [
          Container(
            width: 31,
            height: 31,

            decoration: BoxDecoration(
              color:
                  _teal.withOpacity(.10),

              shape: BoxShape.circle,

              border: Border.all(
                color:
                    _teal.withOpacity(.22),
              ),
            ),

            child: Center(
              child: Text(
                number,
                style: _mono.copyWith(
                  color: _teal,
                  fontSize: 8,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Text(
              text,
              style: _mono.copyWith(
                color: _white,
                fontSize: 9,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetInfo
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _SheetInfo({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(13),

      decoration: BoxDecoration(
        color:
            color.withOpacity(.06),

        borderRadius:
            BorderRadius.circular(13),

        border: Border.all(
          color:
              color.withOpacity(.17),
        ),
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Icon(
            icon,
            color: color,
            size: 18,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  style: _mono.copyWith(
                    color: color,
                    fontSize: 9,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  style: _mono.copyWith(
                    color: _muted,
                    fontSize: 8,
                    height: 1.45,
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

class _DataRow
    extends StatelessWidget {
  final String label;
  final String value;

  const _DataRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 12,
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          SizedBox(
            width: 120,

            child: Text(
              label,
              style: _mono.copyWith(
                color: _muted,
                fontSize: 8,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value,
              style: _mono.copyWith(
                color: _white,
                fontSize: 8,
                fontWeight:
                    FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}