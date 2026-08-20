import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

const _bg = Color(0xFF000021);
const _surface = Color(0xFF001A2A);
const _surface2 = Color(0xFF06243A);
const _teal = Color(0xFF18D0C0);
const _green = Color(0xFF42E88A);
const _purple = Color(0xFFAA6CFF);
const _blue = Color(0xFF4D8DFF);
const _muted = Color(0xFF8193A8);
const _red = Color(0xFFFF5B6E);
const _yellow = Color(0xFFFFB52E);

class AiAgentScreen extends StatefulWidget {
  const AiAgentScreen({super.key});

  @override
  State<AiAgentScreen> createState() => _AiAgentScreenState();
}

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
          result.add(Map<String, dynamic>.from(decoded));
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

  static Future<void> addPayment(Map<String, dynamic> payment) async {
    final payments = await loadPayments();
    payments.insert(0, payment);
    await savePayments(payments);
  }
}

class _AiAgentScreenState extends State<AiAgentScreen> {
  final symbolController = TextEditingController(text: 'AAPL');

  bool isLoading = false;
  String? transactionId;
  String? errorMessage;
  Map<String, dynamic>? marketData;
  List<Map<String, dynamic>> paymentHistory = [];

  String get agentBaseUrl {
    if (defaultTargetPlatform == TargetPlatform.android && !kIsWeb) {
      return 'http://10.0.2.2:4020';
    }
    return 'http://localhost:4020';
  }

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
    setState(() => paymentHistory = saved);
  }

  Future<void> getMarketIntelligence() async {
    final symbol = symbolController.text.trim().toUpperCase();

    if (symbol.isEmpty) {
      setState(() => errorMessage = 'Please enter a stock symbol.');
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
        throw Exception('Agent API returned HTTP ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map) {
        throw Exception('Invalid response from AI Agent.');
      }

      final result = Map<String, dynamic>.from(decoded);

      if (result['success'] != true) {
        throw Exception(
          result['error']?.toString() ?? 'x402 request failed.',
        );
      }

      Map<String, dynamic> payment = {};
      if (result['payment'] is Map) {
        payment = Map<String, dynamic>.from(result['payment']);
      }

      final tx = payment['transaction']?.toString() ?? '';

      Map<String, dynamic> serviceData = {};
      if (result['data'] is Map) {
        serviceData = Map<String, dynamic>.from(result['data']);
      }

      Map<String, dynamic> market = {};
      if (serviceData['market'] is Map) {
        market = Map<String, dynamic>.from(serviceData['market']);
      }

      if (tx.isEmpty) {
        throw Exception(
          'Payment settled but transaction ID was not returned.',
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

      await PaymentStorage.addPayment(paymentRecord);
      final updated = await PaymentStorage.loadPayments();

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
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _viewTransaction(String txId) async {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open explorer: $e')),
      );
    }
  }

  void _showSuccessPopup(String symbol) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _SuccessSheet(
        symbol: symbol,
        transactionId: transactionId ?? '',
        onViewTransaction: () {
          Navigator.pop(context);
          _viewTransaction(transactionId ?? '');
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
      builder: (_) => _MarketSheet(data: marketData!),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'AI Market Agent',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: .5,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Payment history',
            icon: const Icon(Icons.receipt_long_rounded, color: _teal),
            onPressed: _showHistoryPopup,
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: _teal,
          backgroundColor: _surface,
          onRefresh: _loadPaymentHistory,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 35),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _hero(),
                const SizedBox(height: 18),
                _flowCard(),
                const SizedBox(height: 18),
                _symbolCard(),
                const SizedBox(height: 18),
                if (isLoading) _processingCard(),
                if (isLoading) const SizedBox(height: 18),
                if (errorMessage != null) _errorCard(),
                if (errorMessage != null) const SizedBox(height: 18),
                if (marketData != null) _marketPreview(),
                if (marketData != null) const SizedBox(height: 18),
                _historyPreview(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _hero() {
    return _card(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconBox(Icons.auto_awesome_rounded, _purple),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ONEVEST AI',
                      style: TextStyle(
                        color: _teal,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Market Intelligence',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              _livePill(),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'AI-powered premium market insights',
            style: TextStyle(
              fontSize: 28,
              height: 1.1,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Your AI agent requests premium market data, '
            'handles x402 payment, and unlocks the result automatically.',
            style: TextStyle(
              color: _muted,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _statChip(Icons.bolt_rounded, 'AI Agent', _green),
              const SizedBox(width: 8),
              _statChip(Icons.payments_rounded, 'x402', _purple),
              const SizedBox(width: 8),
              _statChip(Icons.account_balance_rounded, 'Algorand', _teal),
            ],
          ),
        ],
      ),
    );
  }

  Widget _flowCard() {
    return GestureDetector(
      onTap: _showFlowPopup,
      child: _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(
              Icons.smart_toy_rounded,
              'AI AGENT + x402',
              _green,
              trailing: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: _muted,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Tap to view the complete autonomous payment flow',
              style: TextStyle(color: _muted, fontSize: 13),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _miniStep('1', 'Request'),
                _arrow(),
                _miniStep('2', 'Pay'),
                _arrow(),
                _miniStep('3', 'Settle'),
                _arrow(),
                _miniStep('4', 'Unlock'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _symbolCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            Icons.show_chart_rounded,
            'GET MARKET INTELLIGENCE',
            _teal,
          ),
          const SizedBox(height: 14),
          const Text(
            'Stock symbol',
            style: TextStyle(
              color: _muted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: symbolController,
            textCapitalization: TextCapitalization.characters,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              hintText: 'Enter symbol e.g. AAPL',
              hintStyle: const TextStyle(color: _muted),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: _teal,
              ),
              suffixIcon: IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  color: _muted,
                ),
                onPressed: () => symbolController.clear(),
              ),
              filled: true,
              fillColor: _surface2,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _teal),
              ),
            ),
            onSubmitted: (_) => getMarketIntelligence(),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: ['AAPL', 'MSFT', 'GOOGL', 'TSLA', 'NVDA']
                .map(
                  (symbol) => ActionChip(
                    label: Text(symbol),
                    labelStyle: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                    backgroundColor: _surface2,
                    side: BorderSide.none,
                    onPressed: () {
                      symbolController.text = symbol;
                      setState(() {});
                    },
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : getMarketIntelligence,
              style: ElevatedButton.styleFrom(
                backgroundColor: _teal,
                foregroundColor: _bg,
                disabledBackgroundColor: _teal.withValues(alpha: .35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _bg,
                      ),
                    )
                  : const Icon(Icons.auto_awesome_rounded),
              label: Text(
                isLoading
                    ? 'AI AGENT PROCESSING...'
                    : 'GET AI MARKET INTELLIGENCE',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: .4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _processingCard() {
    return _card(
      borderColor: _purple.withValues(alpha: .45),
      child: Column(
        children: [
          const SizedBox(
            width: 45,
            height: 45,
            child: CircularProgressIndicator(
              color: _teal,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'AI AGENT IS WORKING',
            style: TextStyle(
              color: _teal,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Requesting premium data → creating x402 payment → '
            'settling on Algorand → unlocking intelligence',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _muted,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          const LinearProgressIndicator(
            minHeight: 5,
            backgroundColor: _surface2,
            valueColor: AlwaysStoppedAnimation(_teal),
          ),
        ],
      ),
    );
  }

  Widget _errorCard() {
    return _card(
      borderColor: _red.withValues(alpha: .45),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, color: _red),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              errorMessage!,
              style: const TextStyle(
                color: _red,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
          IconButton(
            onPressed: () => setState(() => errorMessage = null),
            icon: const Icon(Icons.close_rounded, color: _muted),
          ),
        ],
      ),
    );
  }

  Widget _marketPreview() {
    final symbol = marketData?['symbol']?.toString() ?? 'AAPL';
    final price = marketData?['price']?.toString() ?? '-';
    final change = marketData?['changePercent']?.toString() ?? '-';

    return GestureDetector(
      onTap: _showMarketPopup,
      child: _card(
        borderColor: _green.withValues(alpha: .35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(
              Icons.lock_open_rounded,
              'PREMIUM DATA UNLOCKED',
              _green,
              trailing: const Icon(
                Icons.open_in_full_rounded,
                color: _muted,
                size: 19,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _iconBox(Icons.trending_up_rounded, _green),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    symbol,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  change == '-' ? '-' : '$change%',
                  style: const TextStyle(
                    color: _green,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '\$$price',
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap for full premium market details',
              style: TextStyle(color: _muted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _historyPreview() {
    final recent = paymentHistory.take(3).toList();

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            Icons.receipt_long_rounded,
            'PAYMENT HISTORY',
            _purple,
            trailing: TextButton(
              onPressed: _showHistoryPopup,
              child: const Text(
                'VIEW ALL',
                style: TextStyle(
                  color: _teal,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          if (recent.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Center(
                child: Text(
                  'No x402 payments yet',
                  style: TextStyle(color: _muted),
                ),
              ),
            )
          else
            ...recent.map(
              (payment) => _historyItem(
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
    final symbol = payment['symbol']?.toString() ?? '-';
    final tx = payment['transaction']?.toString() ?? '';

    return InkWell(
      borderRadius: BorderRadius.circular(13),
      onTap: () => _showTransactionDetails(payment),
      child: Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _surface2,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Row(
          children: [
            _iconBox(Icons.check_rounded, _green, size: 40),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$symbol Market Intelligence',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '0.005 USDC • Algorand TestNet',
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 10,
                    ),
                  ),
                  if (!compact && tx.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      _shortTx(tx),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: _muted,
            ),
          ],
        ),
      ),
    );
  }

  void _showTransactionDetails(Map<String, dynamic> payment) {
    final tx = payment['transaction']?.toString() ?? '';
    final symbol = payment['symbol']?.toString() ?? '-';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _DetailsSheet(
        symbol: symbol,
        transaction: tx,
        amount: payment['amount']?.toString() ?? '0.005 USDC',
        network: payment['network']?.toString() ?? 'Algorand TestNet',
        onView: () {
          Navigator.pop(context);
          _viewTransaction(tx);
        },
      ),
    );
  }

  Widget _card({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    Color? borderColor,
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor ?? _teal.withValues(alpha: .28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .18),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionHeader(
    IconData icon,
    String title,
    Color color, {
    Widget? trailing,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: .7,
            ),
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _iconBox(
    IconData icon,
    Color color, {
    double size = 44,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: color.withValues(alpha: .25),
        ),
      ),
      child: Icon(icon, color: color, size: size * .48),
    );
  }

  Widget _livePill() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: _green.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _green.withValues(alpha: .35),
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: _green, size: 7),
          SizedBox(width: 5),
          Text(
            'LIVE',
            style: TextStyle(
              color: _green,
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(IconData icon, String text, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStep(String number, String label) {
    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: _teal.withValues(alpha: .15),
            child: Text(
              number,
              style: const TextStyle(
                color: _teal,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              color: _muted,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _arrow() {
    return const Icon(
      Icons.chevron_right_rounded,
      color: Colors.white24,
      size: 16,
    );
  }

  String _shortTx(String tx) {
    if (tx.length <= 18) return tx;
    return '${tx.substring(0, 9)}...${tx.substring(tx.length - 7)}';
  }
}

// ======================================================================
// FLOW SHEET
// ======================================================================

class _FlowSheet extends StatelessWidget {
  const _FlowSheet();

  @override
  Widget build(BuildContext context) {
    return _sheet(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sheetHandle(),
          _sheetTitle(
            Icons.smart_toy_rounded,
            'AI AGENT + x402',
            _green,
          ),
          const SizedBox(height: 8),
          const Text(
            'Autonomous premium market-data flow',
            style: TextStyle(color: _muted, fontSize: 13),
          ),
          const SizedBox(height: 20),
          _flowRow('1', 'User requests premium market data'),
          _flowRow('2', 'AI Agent calls the paid API'),
          _flowRow('3', 'x402 payment is automatically created'),
          _flowRow('4', 'Payment settles on Algorand TestNet'),
          _flowRow('5', 'Premium market data is unlocked'),
          const SizedBox(height: 8),
          _infoBox(
            Icons.security_rounded,
            'Secure agentic payment',
            'The agent handles the payment flow automatically '
            'before returning premium data.',
            _teal,
          ),
        ],
      ),
    );
  }
}

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
  Widget build(BuildContext context) {
    return _sheet(
      context,
      child: Column(
        children: [
          _sheetHandle(),
          const Icon(
            Icons.check_circle_rounded,
            color: _green,
            size: 65,
          ),
          const SizedBox(height: 12),
          const Text(
            'PAYMENT SETTLED',
            style: TextStyle(
              color: _green,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$symbol premium intelligence is unlocked.',
            style: const TextStyle(color: _muted),
          ),
          const SizedBox(height: 20),
          _infoBox(
            Icons.payments_rounded,
            '0.005 USDC',
            'Algorand TestNet • AI Agent',
            _green,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onViewTransaction,
              icon: const Icon(
                Icons.open_in_new_rounded,
                color: _teal,
              ),
              label: const Text(
                'VIEW TRANSACTION',
                style: TextStyle(
                  color: _teal,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _teal),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            transactionId.isEmpty
                ? ''
                : _shortTxStatic(transactionId),
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _MarketSheet extends StatelessWidget {
  final Map<String, dynamic> data;

  const _MarketSheet({required this.data});

  @override
  Widget build(BuildContext context) {
    final symbol = data['symbol']?.toString() ?? 'AAPL';
    final price = data['price']?.toString() ?? '-';
    final change = data['changePercent']?.toString() ?? '-';
    final previous = data['previousClose']?.toString() ?? '-';
    final volume = data['volume']?.toString() ?? '-';

    return _sheet(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sheetHandle(),
          _sheetTitle(
            Icons.lock_open_rounded,
            'PREMIUM MARKET DATA',
            _green,
          ),
          const SizedBox(height: 18),
          Text(
            symbol,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '\$$price',
            style: const TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$change%',
            style: const TextStyle(
              color: _green,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          _dataRow('Previous Close', '\$$previous'),
          _dataRow('Volume', volume),
          _dataRow('Source', 'Alpha Vantage'),
          const SizedBox(height: 8),
          _infoBox(
            Icons.auto_awesome_rounded,
            'AI unlocked this data',
            'This result was returned after the x402 payment flow.',
            _purple,
          ),
        ],
      ),
    );
  }
}

class _HistorySheet extends StatelessWidget {
  final List<Map<String, dynamic>> payments;
  final Future<void> Function(String) onTransaction;

  const _HistorySheet({
    required this.payments,
    required this.onTransaction,
  });

  @override
  Widget build(BuildContext context) {
    return _sheet(
      context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sheetHandle(),
          _sheetTitle(
            Icons.receipt_long_rounded,
            'PAYMENT HISTORY',
            _purple,
          ),
          const SizedBox(height: 14),
          if (payments.isEmpty)
            const Padding(
              padding: EdgeInsets.all(25),
              child: Center(
                child: Text(
                  'No payments yet.',
                  style: TextStyle(color: _muted),
                ),
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: payments.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, index) {
                  final p = payments[index];
                  final symbol = p['symbol']?.toString() ?? '-';
                  final tx = p['transaction']?.toString() ?? '';

                  return ListTile(
                    tileColor: _surface2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                    leading: const Icon(
                      Icons.check_circle_rounded,
                      color: _green,
                    ),
                    title: Text(
                      '$symbol Market Intelligence',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    subtitle: Text(
                      '${p['amount'] ?? '0.005 USDC'} • '
                      '${p['network'] ?? 'Algorand TestNet'}',
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 11,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.open_in_new_rounded,
                      color: _teal,
                      size: 19,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      onTransaction(tx);
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

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
  Widget build(BuildContext context) {
    return _sheet(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sheetHandle(),
          _sheetTitle(
            Icons.receipt_long_rounded,
            'TRANSACTION DETAILS',
            _teal,
          ),
          const SizedBox(height: 18),
          Text(
            '$symbol Market Intelligence',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          _dataRow('Amount', amount),
          _dataRow('Network', network),
          _dataRow('Paid by', 'AI Agent'),
          const SizedBox(height: 8),
          const Text(
            'Transaction ID',
            style: TextStyle(
              color: _muted,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 5),
          SelectableText(
            transaction,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onView,
              icon: const Icon(Icons.open_in_new_rounded),
              label: const Text(
                'VIEW ON EXPLORER',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _teal,
                foregroundColor: _bg,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================================
// SHARED SHEET HELPERS
// ======================================================================

Widget _sheet(
  BuildContext context, {
  required Widget child,
}) {
  return SafeArea(
    child: Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .82,
      ),
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
      decoration: const BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
        border: Border(
          top: BorderSide(
            color: _teal,
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        child: child,
      ),
    ),
  );
}

Widget _sheetHandle() {
  return Center(
    child: Container(
      width: 42,
      height: 4,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  );
}

Widget _sheetTitle(
  IconData icon,
  String title,
  Color color,
) {
  return Row(
    children: [
      Icon(icon, color: color),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          title,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w900,
            letterSpacing: .8,
          ),
        ),
      ),
    ],
  );
}

Widget _flowRow(String number, String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      children: [
        CircleAvatar(
          radius: 15,
          backgroundColor: _teal.withValues(alpha: .14),
          child: Text(
            number,
            style: const TextStyle(
              color: _teal,
              fontWeight: FontWeight.w900,
              fontSize: 11,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _infoBox(
  IconData icon,
  String title,
  String subtitle,
  Color color,
) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .07),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: color.withValues(alpha: .18),
      ),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 11,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _dataRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 11),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(
              color: _muted,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}

String _shortTxStatic(String tx) {
  if (tx.length <= 18) return tx;
  return '${tx.substring(0, 9)}...${tx.substring(tx.length - 7)}';
}
