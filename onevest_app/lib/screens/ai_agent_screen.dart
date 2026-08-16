import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AiAgentScreen extends StatefulWidget {
  const AiAgentScreen({super.key});

  @override
  State<AiAgentScreen> createState() => _AiAgentScreenState();
}

// ================================================================
// PERSISTENT PAYMENT STORAGE
// ================================================================

class PaymentStorage {
  static const String _storageKey = "onevest_payment_history";

  static Future<List<Map<String, dynamic>>> loadPayments() async {
    final prefs = await SharedPreferences.getInstance();

    final saved = prefs.getStringList(_storageKey);

    if (saved == null || saved.isEmpty) {
      return [];
    }

    final List<Map<String, dynamic>> payments = [];

    for (final item in saved) {
      try {
        final decoded = jsonDecode(item);

        if (decoded is Map) {
          payments.add(
            Map<String, dynamic>.from(decoded),
          );
        }
      } catch (_) {
        // Ignore corrupted individual records.
      }
    }

    return payments;
  }

  static Future<void> savePayments(
    List<Map<String, dynamic>> payments,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final encoded = payments
        .map((payment) => jsonEncode(payment))
        .toList();

    await prefs.setStringList(
      _storageKey,
      encoded,
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
// AI AGENT SCREEN
// ================================================================

class _AiAgentScreenState extends State<AiAgentScreen> {
  final TextEditingController symbolController =
      TextEditingController(text: "AAPL");

  bool isLoading = false;

  String? transactionId;
  String? errorMessage;

  Map<String, dynamic>? marketData;

  List<Map<String, dynamic>> paymentHistory = [];

  // Android emulator -> 10.0.2.2
  // Web/Desktop -> localhost
  String get agentBaseUrl {
    if (defaultTargetPlatform == TargetPlatform.android &&
        !kIsWeb) {
      return "http://10.0.2.2:4020";
    }

    return "http://localhost:4020";
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

  // ================================================================
  // LOAD PERSISTENT HISTORY
  // ================================================================

  Future<void> _loadPaymentHistory() async {
    final savedPayments =
        await PaymentStorage.loadPayments();

    if (!mounted) return;

    setState(() {
      paymentHistory = savedPayments;
    });
  }

  // ================================================================
  // REQUEST MARKET INTELLIGENCE
  // ================================================================

  Future<void> getMarketIntelligence() async {
    final symbol =
        symbolController.text.trim().toUpperCase();

    if (symbol.isEmpty) {
      setState(() {
        errorMessage = "Please enter a stock symbol.";
      });

      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
      transactionId = null;
      marketData = null;
    });

    try {
      final uri = Uri.parse(
        "$agentBaseUrl/api/market-intelligence"
        "?symbol=${Uri.encodeComponent(symbol)}",
      );

      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception(
          "Agent API returned HTTP ${response.statusCode}",
        );
      }

      final decoded =
          jsonDecode(response.body);

      if (decoded is! Map) {
        throw Exception(
          "Invalid response from AI Agent.",
        );
      }

      final result =
          Map<String, dynamic>.from(decoded);

      if (result["success"] != true) {
        throw Exception(
          result["error"]?.toString() ??
              "x402 request failed.",
        );
      }

      // ============================================================
      // PAYMENT INFORMATION
      // ============================================================

      Map<String, dynamic> payment = {};

      if (result["payment"] is Map) {
        payment = Map<String, dynamic>.from(
          result["payment"],
        );
      }

      final tx =
          payment["transaction"]?.toString() ?? "";

      // ============================================================
      // MARKET INFORMATION
      // ============================================================

      Map<String, dynamic> serviceData = {};

      if (result["data"] is Map) {
        serviceData = Map<String, dynamic>.from(
          result["data"],
        );
      }

      Map<String, dynamic> market = {};

      if (serviceData["market"] is Map) {
        market = Map<String, dynamic>.from(
          serviceData["market"],
        );
      }

      if (tx.isEmpty) {
        throw Exception(
          "Payment settled but transaction ID was not returned.",
        );
      }

      // ============================================================
      // CREATE PAYMENT HISTORY RECORD
      // ============================================================

      final paymentRecord = <String, dynamic>{
        "symbol": symbol,
        "transaction": tx,
        "amount": "0.005 USDC",
        "network": "Algorand TestNet",
        "paidBy": "AI Agent",
        "timestamp": DateTime.now().toIso8601String(),
      };

      await PaymentStorage.addPayment(
        paymentRecord,
      );

      final updatedHistory =
          await PaymentStorage.loadPayments();

      if (!mounted) return;

      setState(() {
        transactionId = tx;
        marketData = market;
        paymentHistory = updatedHistory;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  // ================================================================
  // VIEW TRANSACTION
  // ================================================================

  Future<void> _viewTransaction(
    String txId,
  ) async {
    if (txId.isEmpty) return;

    final Uri explorerUrl = Uri.parse(
      "https://testnet.explorer.perawallet.app/tx/$txId",
    );

    try {
      await launchUrl(
        explorerUrl,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Could not open explorer: $e",
          ),
        ),
      );
    }
  }

  // ================================================================
  // MAIN BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000021),

      appBar: AppBar(
        backgroundColor: const Color(0xFF002333),
        elevation: 0,

        title: const Text(
          "AI Market Agent",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        iconTheme: const IconThemeData(
          color: Colors.white,
        ),

        actions: [
          IconButton(
            tooltip: "Payment History",
            icon: const Icon(
              Icons.receipt_long,
              color: Colors.greenAccent,
            ),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const PaymentHistoryScreen(),
                ),
              );

              // Reload after returning.
              await _loadPaymentHistory();
            },
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            25,
            20,
            35,
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              const Text(
                "AI-Powered Market\nIntelligence",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 31,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                "Get premium market intelligence through an "
                "autonomous AI agent powered by x402.",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  height: 1.45,
                ),
              ),

              const SizedBox(height: 28),

              // ====================================================
              // AI AGENT + X402 FLOW
              // ====================================================

              Container(
                width: double.infinity,

                padding:
                    const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: const Color(0xFF182B46),
                  borderRadius:
                      BorderRadius.circular(18),
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.smart_toy,
                          color:
                              Colors.greenAccent,
                        ),

                        SizedBox(width: 10),

                        Text(
                          "AI AGENT + x402",
                          style: TextStyle(
                            color:
                                Colors.greenAccent,
                            fontSize: 17,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    _flowStep(
                      "1",
                      "User requests premium market data",
                    ),

                    _flowStep(
                      "2",
                      "AI Agent calls the paid API",
                    ),

                    _flowStep(
                      "3",
                      "x402 payment is automatically created",
                    ),

                    _flowStep(
                      "4",
                      "Payment settles on Algorand TestNet",
                    ),

                    _flowStep(
                      "5",
                      "Premium market data is unlocked",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                "Stock Symbol",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 9),

              TextField(
                controller: symbolController,

                textCapitalization:
                    TextCapitalization.characters,

                style: const TextStyle(
                  color: Colors.white,
                ),

                decoration:
                    InputDecoration(
                  filled: true,
                  fillColor:
                      const Color(0xFF243A59),

                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(14),

                    borderSide:
                        BorderSide.none,
                  ),

                  prefixIcon:
                      const Icon(
                    Icons.show_chart,
                    color:
                        Colors.greenAccent,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // ====================================================
              // REQUEST BUTTON
              // ====================================================

              SizedBox(
                width: double.infinity,
                height: 55,

                child:
                    ElevatedButton.icon(
                  onPressed: isLoading
                      ? null
                      : getMarketIntelligence,

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.teal,

                    disabledBackgroundColor:
                        Colors.teal
                            .withOpacity(0.5),

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        15,
                      ),
                    ),
                  ),

                  icon: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,

                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                        ),

                  label: Text(
                    isLoading
                        ? "AI Agent Processing..."
                        : "Get AI Market Intelligence",

                    style:
                        const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // ====================================================
              // PAYMENT PROCESSING
              // ====================================================

              if (isLoading) ...[
                const SizedBox(height: 20),

                _buildPaymentProcessing(),
              ],

              // ====================================================
              // PAYMENT SUCCESS
              // ====================================================

              if (transactionId != null) ...[
                const SizedBox(height: 20),

                

                _buildPaymentSuccess(),
              ],

              // ====================================================
              // MARKET DATA
              // ====================================================

              if (marketData != null) ...[
                const SizedBox(height: 16),

                _buildMarketData(),
              ],

              // ====================================================
              // PAYMENT HISTORY PREVIEW
              // ====================================================

              if (paymentHistory.isNotEmpty) ...[
                const SizedBox(height: 25),

                _buildHistoryPreview(),
              ],

              // ====================================================
              // ERROR
              // ====================================================

              if (errorMessage != null) ...[
                const SizedBox(height: 16),

                Container(
                  width: double.infinity,

                  padding:
                      const EdgeInsets.all(14),

                  decoration: BoxDecoration(
                    color: Colors.red
                        .withOpacity(0.12),

                    borderRadius:
                        BorderRadius.circular(12),

                    border: Border.all(
                      color: Colors.redAccent
                          .withOpacity(0.3),
                    ),
                  ),

                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      const Icon(
                        Icons.error_outline,
                        color:
                            Colors.redAccent,
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          errorMessage!,
                          style:
                              const TextStyle(
                            color:
                                Colors.redAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // PAYMENT PROCESSING CARD
  // ================================================================

  Widget _buildPaymentProcessing() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: const Color(0xFF10233D),
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color:
              Colors.greenAccent.withOpacity(
            0.15,
          ),
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          const Row(
            children: [
              Icon(
                Icons.smart_toy,
                color: Colors.greenAccent,
              ),

              SizedBox(width: 10),

              Text(
                "AI AGENT PAYMENT",
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          _paymentStep(
            "Agent requested premium service",
            true,
          ),

          _paymentStep(
            "x402 payment required",
            true,
          ),

          _paymentStep(
            "Paying 0.005 USDC",
            true,
          ),

          _paymentStep(
            "Algorand TestNet settlement",
            false,
          ),

          _paymentStep(
            "Premium market data unlocked",
            false,
          ),

          const SizedBox(height: 10),

          const Row(
            children: [
              SizedBox(
                width: 17,
                height: 17,

                child:
                    CircularProgressIndicator(
                  strokeWidth: 2,
                  color:
                      Colors.greenAccent,
                ),
              ),

              SizedBox(width: 10),

              Text(
                "AI Agent is completing payment...",
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================================================================
  // PAYMENT SUCCESS CARD
  // ================================================================

  Widget _buildPaymentSuccess() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.10),

        borderRadius:
            BorderRadius.circular(16),

        border: Border.all(
          color:
              Colors.greenAccent.withOpacity(
            0.35,
          ),
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          const Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.greenAccent,
              ),

              SizedBox(width: 10),

              Text(
                "PAYMENT SETTLED",
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          _paymentInfo(
            "Amount",
            "0.005 USDC",
          ),

          _paymentInfo(
            "Network",
            "Algorand TestNet",
          ),

          _paymentInfo(
            "Paid by",
            "AI Agent",
          ),

          const SizedBox(height: 12),

          const Text(
            "Transaction ID",
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 6),

          SelectableText(
            transactionId ?? "",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,

            child:
                OutlinedButton.icon(
              onPressed: () {
                _viewTransaction(
                  transactionId ?? "",
                );
              },

              icon: const Icon(
                Icons.open_in_new,
                color: Colors.greenAccent,
              ),

              label: const Text(
                "View Transaction",
                style: TextStyle(
                  color:
                      Colors.greenAccent,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),

              style:
                  OutlinedButton.styleFrom(
                side:
                    const BorderSide(
                  color:
                      Colors.greenAccent,
                ),

                padding:
                    const EdgeInsets.symmetric(
                  vertical: 13,
                ),

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    25,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // PREMIUM MARKET DATA
  // ================================================================

  Widget _buildMarketData() {
    final symbol =
        marketData?["symbol"]
                ?.toString() ??
            "AAPL";

    final price =
        marketData?["price"]
                ?.toString() ??
            "-";

    final change =
        marketData?["changePercent"]
                ?.toString() ??
            "-";

    final previousClose =
        marketData?["previousClose"]
                ?.toString() ??
            "-";

    final volume =
        marketData?["volume"]
                ?.toString() ??
            "-";

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: const Color(0xFF243A59),

        borderRadius:
            BorderRadius.circular(16),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          const Row(
            children: [
              Icon(
                Icons.lock_open,
                color: Colors.greenAccent,
              ),

              SizedBox(width: 10),

              Text(
                "PREMIUM DATA UNLOCKED",
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Text(
            symbol,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            "\$$price",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            "$change%",
            style: const TextStyle(
              color: Colors.greenAccent,
              fontSize: 19,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const Divider(
            color: Colors.white24,
            height: 30,
          ),

          _paymentInfo(
            "Previous close",
            "\$$previousClose",
          ),

          _paymentInfo(
            "Volume",
            volume,
          ),

          const SizedBox(height: 8),

          const Text(
            "Source: Alpha Vantage",
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // HISTORY PREVIEW
  // ================================================================

  Widget _buildHistoryPreview() {
    final recent =
        paymentHistory.take(3).toList();

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: const Color(0xFF10233D),
        borderRadius:
            BorderRadius.circular(16),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              const Icon(
                Icons.receipt_long,
                color: Colors.greenAccent,
              ),

              const SizedBox(width: 10),

              const Expanded(
                child: Text(
                  "PAYMENT HISTORY",
                  style: TextStyle(
                    color:
                        Colors.greenAccent,
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),

              TextButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const PaymentHistoryScreen(),
                    ),
                  );

                  await _loadPaymentHistory();
                },

                child: const Text(
                  "View All",
                  style: TextStyle(
                    color:
                        Colors.greenAccent,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          ...recent.map(
            (payment) =>
                _historyItem(payment),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // HISTORY ITEM
  // ================================================================

  Widget _historyItem(
    Map<String, dynamic> payment,
  ) {
    final symbol =
        payment["symbol"]
                ?.toString() ??
            "-";

    final tx =
        payment["transaction"]
                ?.toString() ??
            "";

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),

      padding:
          const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color:
            const Color(0xFF182B46),
        borderRadius:
            BorderRadius.circular(12),
      ),

      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor:
                Colors.teal,

            child: Icon(
              Icons.check,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  "$symbol Market Intelligence",

                  style:
                      const TextStyle(
                    color: Colors.white,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                const Text(
                  "0.005 USDC • Settled",

                  style:
                      TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  _shortTransaction(tx),

                  style:
                      const TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () {
              _viewTransaction(tx);
            },

            icon: const Icon(
              Icons.open_in_new,
              color: Colors.greenAccent,
            ),
          ),
        ],
      ),
    );
  }

  String _shortTransaction(
    String tx,
  ) {
    if (tx.length <= 18) {
      return tx;
    }

    return "${tx.substring(0, 9)}..."
        "${tx.substring(tx.length - 7)}";
  }

  // ================================================================
  // FLOW STEP
  // ================================================================

  Widget _flowStep(
    String number,
    String text,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 11,
      ),

      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor:
                Colors.teal,

            child: Text(
              number,

              style:
                  const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              text,

              style:
                  const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // PAYMENT STEP
  // ================================================================

  Widget _paymentStep(
    String text,
    bool completed,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 10,
      ),

      child: Row(
        children: [
          Icon(
            completed
                ? Icons.check_circle
                : Icons.radio_button_unchecked,

            size: 18,

            color: completed
                ? Colors.greenAccent
                : Colors.white38,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              text,

              style: TextStyle(
                color: completed
                    ? Colors.white
                    : Colors.white54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // PAYMENT INFO
  // ================================================================

  Widget _paymentInfo(
    String label,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 9,
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          SizedBox(
            width: 110,

            child: Text(
              label,

              style:
                  const TextStyle(
                color: Colors.white54,
                fontSize: 13,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value,

              style:
                  const TextStyle(
                color: Colors.white,
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// PAYMENT HISTORY SCREEN
// ==================================================================

class PaymentHistoryScreen
    extends StatefulWidget {
  const PaymentHistoryScreen({
    super.key,
  });

  @override
  State<PaymentHistoryScreen>
      createState() =>
          _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState
    extends State<PaymentHistoryScreen> {
  List<Map<String, dynamic>>
      paymentHistory = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    _loadHistory();
  }

  // ================================================================
  // LOAD PERSISTENT HISTORY
  // ================================================================

  Future<void> _loadHistory() async {
    final saved =
        await PaymentStorage.loadPayments();

    if (!mounted) return;

    setState(() {
      paymentHistory = saved;
      isLoading = false;
    });
  }

  // ================================================================
  // VIEW TRANSACTION
  // ================================================================

  Future<void> _viewTransaction(
    String txId,
  ) async {
    if (txId.isEmpty) return;

    final Uri explorerUrl = Uri.parse(
      "https://testnet.explorer.perawallet.app/tx/$txId",
    );

    try {
      await launchUrl(
        explorerUrl,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            "Could not open explorer: $e",
          ),
        ),
      );
    }
  }

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF000021),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFF002333),

        elevation: 0,

        title: const Text(
          "Payment History",

          style: TextStyle(
            color: Colors.white,
            fontWeight:
                FontWeight.bold,
          ),
        ),

        iconTheme:
            const IconThemeData(
          color: Colors.white,
        ),
      ),

      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(
                color:
                    Colors.greenAccent,
              ),
            )
          : paymentHistory.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  color:
                      Colors.greenAccent,

                  onRefresh:
                      _loadHistory,

                  child:
                      ListView.builder(
                    padding:
                        const EdgeInsets.all(
                      18,
                    ),

                    itemCount:
                        paymentHistory.length,

                    itemBuilder:
                        (context, index) {
                      final payment =
                          paymentHistory[
                              index];

                      return _buildPaymentCard(
                        payment,
                      );
                    },
                  ),
                ),
    );
  }

  // ================================================================
  // EMPTY STATE
  // ================================================================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            const Icon(
              Icons.receipt_long,
              color: Colors.white38,
              size: 65,
            ),

            const SizedBox(height: 18),

            const Text(
              "No Payments Yet",

              style: TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Successful x402 payments made "
              "by the AI Agent will appear here.",

              textAlign:
                  TextAlign.center,

              style: TextStyle(
                color: Colors.white60,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // PAYMENT CARD
  // ================================================================

  Widget _buildPaymentCard(
    Map<String, dynamic> payment,
  ) {
    final symbol =
        payment["symbol"]
                ?.toString() ??
            "-";

    final transaction =
        payment["transaction"]
                ?.toString() ??
            "";

    final timestampString =
        payment["timestamp"]
                ?.toString();

    DateTime? timestamp;

    if (timestampString != null) {
      timestamp =
          DateTime.tryParse(
        timestampString,
      );
    }

    final timeText =
        timestamp == null
            ? "-"
            : _formatDate(timestamp);

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 16,
      ),

      padding:
          const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color:
            const Color(0xFF10233D),

        borderRadius:
            BorderRadius.circular(16),

        border: Border.all(
          color:
              Colors.greenAccent
                  .withOpacity(0.25),
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle,
                color:
                    Colors.greenAccent,
              ),

              const SizedBox(width: 10),

              const Expanded(
                child: Text(
                  "PAYMENT SETTLED",

                  style:
                      TextStyle(
                    color:
                        Colors.greenAccent,
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),

              Text(
                timeText,

                style:
                    const TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Text(
            "$symbol Market Intelligence",

            style:
                const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          _historyInfo(
            "Amount",
            payment["amount"]
                    ?.toString() ??
                "0.005 USDC",
          ),

          _historyInfo(
            "Network",
            payment["network"]
                    ?.toString() ??
                "Algorand TestNet",
          ),

          _historyInfo(
            "Paid by",
            payment["paidBy"]
                    ?.toString() ??
                "AI Agent",
          ),

          const SizedBox(height: 10),

          const Text(
            "Transaction ID",

            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 6),

          SelectableText(
            transaction,

            style:
                const TextStyle(
              color: Colors.white,
              fontSize: 11,
            ),
          ),

          const SizedBox(height: 15),

          SizedBox(
            width: double.infinity,

            child:
                OutlinedButton.icon(
              onPressed: () {
                _viewTransaction(
                  transaction,
                );
              },

              icon: const Icon(
                Icons.open_in_new,
                color:
                    Colors.greenAccent,
              ),

              label: const Text(
                "View Transaction",

                style:
                    TextStyle(
                  color:
                      Colors.greenAccent,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              style:
                  OutlinedButton.styleFrom(
                side:
                    const BorderSide(
                  color:
                      Colors.greenAccent,
                ),

                padding:
                    const EdgeInsets.symmetric(
                  vertical: 13,
                ),

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    25,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // HISTORY INFO
  // ================================================================

  Widget _historyInfo(
    String label,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 8,
      ),

      child: Row(
        children: [
          SizedBox(
            width: 95,

            child: Text(
              label,

              style:
                  const TextStyle(
                color: Colors.white54,
                fontSize: 13,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value,

              style:
                  const TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // FORMAT DATE
  // ================================================================

  String _formatDate(
    DateTime date,
  ) {
    final hour =
        date.hour
            .toString()
            .padLeft(2, "0");

    final minute =
        date.minute
            .toString()
            .padLeft(2, "0");

    return "${date.day}/${date.month}/${date.year} "
        "$hour:$minute";
  }
}