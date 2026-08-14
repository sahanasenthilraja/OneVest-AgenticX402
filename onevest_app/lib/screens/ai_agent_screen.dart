import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class AiAgentScreen extends StatefulWidget {
  const AiAgentScreen({super.key});

  @override
  State<AiAgentScreen> createState() => _AiAgentScreenState();
}

class _AiAgentScreenState extends State<AiAgentScreen> {
  final TextEditingController symbolController =
      TextEditingController(text: "AAPL");

  bool isLoading = false;

  String? transactionId;

  Map<String, dynamic>? marketData;

  String? errorMessage;

  @override
  void dispose() {
    symbolController.dispose();
    super.dispose();
  }

  // ============================================================
  // REQUEST MARKET INTELLIGENCE
  // ============================================================

  Future<void> getMarketIntelligence() async {
    final symbol = symbolController.text.trim().toUpperCase();

    if (symbol.isEmpty) {
      setState(() {
        errorMessage = "Please enter a stock symbol.";
      });
      return;
    }

    setState(() {
      isLoading = true;
      transactionId = null;
      marketData = null;
      errorMessage = null;
    });

    try {
      /*
       * Android Emulator -> Windows host
       *
       * 10.0.2.2 = Windows host machine
       *
       * Our Agent API:
       * http://localhost:4020
       */

      final uri = Uri.parse(
        "http://10.0.2.2:4020/api/market-intelligence"
        "?symbol=${Uri.encodeComponent(symbol)}",
      );

      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception(
          "Agent returned HTTP ${response.statusCode}",
        );
      }

      final json = jsonDecode(response.body)
          as Map<String, dynamic>;

      if (json["success"] != true) {
        throw Exception(
          json["error"] ?? "Market request failed",
        );
      }

      final payment =
          json["payment"] as Map<String, dynamic>?;

      final data =
          json["data"] as Map<String, dynamic>?;

      final market =
          data?["market"] as Map<String, dynamic>?;

      if (market == null) {
        throw Exception(
          "Market data was not returned.",
        );
      }

      if (!mounted) return;

      setState(() {
        isLoading = false;

        transactionId =
            payment?["transaction"]?.toString();

        marketData = market;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        transactionId = null;
        marketData = null;
        errorMessage = e.toString();
      });
    }
  }

  // ============================================================
  // PAGE
  // ============================================================

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

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================================================
              // HEADER
              // ==================================================

              const Text(
                "AI-Powered Market Intelligence",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Get premium market intelligence through "
                "an autonomous AI agent powered by x402.",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 25),

              // ==================================================
              // HOW IT WORKS
              // ==================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: const Color(0xFF10233D),
                  borderRadius: BorderRadius.circular(16),
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
                          "AI AGENT + x402",
                          style: TextStyle(
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

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

              const SizedBox(height: 22),

              // ==================================================
              // STOCK SYMBOL
              // ==================================================

              const Text(
                "Stock Symbol",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: symbolController,

                textCapitalization:
                    TextCapitalization.characters,

                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                ),

                decoration: InputDecoration(
                  hintText: "AAPL",

                  hintStyle: const TextStyle(
                    color: Colors.white38,
                  ),

                  filled: true,

                  fillColor:
                      const Color(0xFF243A59),

                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(14),

                    borderSide: BorderSide.none,
                  ),

                  prefixIcon: const Icon(
                    Icons.show_chart,
                    color: Colors.greenAccent,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // ==================================================
              // REQUEST BUTTON
              // ==================================================

              SizedBox(
                width: double.infinity,

                height: 55,

                child: ElevatedButton.icon(
                  onPressed:
                      isLoading
                          ? null
                          : getMarketIntelligence,

                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.teal,

                    disabledBackgroundColor:
                        Colors.teal.withOpacity(0.5),

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(15),
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

                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // ==================================================
              // PAYMENT PROCESSING
              // ==================================================

              if (isLoading) ...[
                const SizedBox(height: 20),

                _buildPaymentProcessing(),
              ],

              // ==================================================
              // PAYMENT SUCCESS
              // ==================================================

              if (transactionId != null) ...[
                const SizedBox(height: 20),

                _buildPaymentSuccess(),
              ],

              // ==================================================
              // MARKET DATA
              // ==================================================

              if (marketData != null) ...[
                const SizedBox(height: 16),

                _buildMarketData(),
              ],

              // ==================================================
              // ERROR
              // ==================================================

              if (errorMessage != null) ...[
                const SizedBox(height: 16),

                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(14),

                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.12),

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
                        color: Colors.redAccent,
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(
                            color: Colors.redAccent,
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

  // ============================================================
  // PAYMENT PROCESSING CARD
  // ============================================================

  Widget _buildPaymentProcessing() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: const Color(0xFF10233D),

        borderRadius:
            BorderRadius.circular(16),

        border: Border.all(
          color: Colors.greenAccent
              .withOpacity(0.15),
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
                  fontWeight: FontWeight.bold,
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
                  color: Colors.greenAccent,
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

  // ============================================================
  // PAYMENT SUCCESS CARD
  // ============================================================

  Widget _buildPaymentSuccess() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.10),

        borderRadius:
            BorderRadius.circular(16),

        border: Border.all(
          color: Colors.greenAccent
              .withOpacity(0.35),
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
                  fontWeight: FontWeight.bold,
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

            child: OutlinedButton.icon(
              onPressed: () {
                Clipboard.setData(
                  ClipboardData(
                    text: transactionId ?? "",
                  ),
                );

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Transaction ID copied",
                    ),
                  ),
                );
              },

              icon: const Icon(
                Icons.copy,
                color: Colors.greenAccent,
              ),

              label: const Text(
                "Copy Transaction ID",
                style: TextStyle(
                  color: Colors.greenAccent,
                ),
              ),

              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  color: Colors.greenAccent,
                ),

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(25),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PREMIUM MARKET DATA
  // ============================================================

  Widget _buildMarketData() {
    final symbol =
        marketData?["symbol"]?.toString() ?? "AAPL";

    final price =
        marketData?["price"]?.toString() ?? "-";

    final change =
        marketData?["changePercent"]?.toString() ?? "-";

    final previousClose =
        marketData?["previousClose"]?.toString() ?? "-";

    final volume =
        marketData?["volume"]?.toString() ?? "-";

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
                  fontWeight: FontWeight.bold,
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
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            "\$$price",

            style: const TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            "$change%",

            style: const TextStyle(
              color: Colors.greenAccent,
              fontSize: 19,
              fontWeight: FontWeight.bold,
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

  // ============================================================
  // FLOW STEP
  // ============================================================

  Widget _flowStep(
    String number,
    String text,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 11),

      child: Row(
        children: [
          CircleAvatar(
            radius: 12,

            backgroundColor:
                Colors.teal,

            child: Text(
              number,

              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              text,

              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PAYMENT STEP
  // ============================================================

  Widget _paymentStep(
    String text,
    bool completed,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 10),

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

  // ============================================================
  // PAYMENT INFO
  // ============================================================

  Widget _paymentInfo(
    String label,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 9),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          SizedBox(
            width: 110,

            child: Text(
              label,

              style: const TextStyle(
                color: Colors.white54,
                fontSize: 13,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value,

              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}