import 'dart:async';
import 'dart:math';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class LiveMarketWidget extends StatefulWidget {
  const LiveMarketWidget({super.key});

  @override
  State<LiveMarketWidget> createState() => _LiveMarketWidgetState();
}

class _LiveMarketWidgetState extends State<LiveMarketWidget> {
  // ============================================================
  // ONEVEST THEME
  // ============================================================

  static const Color background = Color(0xFF020B1D);
  static const Color panel = Color(0xFF0E1830);
  static const Color panelLight = Color(0xFF111F36);
  static const Color border = Color(0xFF263A56);

  static const Color teal = Color(0xFF14C8B0);
  static const Color tealDark = Color(0xFF0C3942);

  static const Color white = Color(0xFFF5F8FC);
  static const Color muted = Color(0xFF91A0B8);

  static const Color green = Color(0xFF45E38A);
  static const Color orange = Color(0xFFFFB52E);
  static const Color red = Color(0xFFFF5C6C);

  // ============================================================
  // EXISTING MARKET DATA
  // ============================================================

  final Random random = Random();

  final TextEditingController symbolController = TextEditingController(
    text: "AAPL",
  );

  late Timer timer;

  double nifty = 25120.80;
  double sensex = 82450.10;
  double gold = 10250;
  double bitcoin = 9654321;
  double ethereum = 287450;

  bool isLoading = false;

  String paymentStatus = "";

  String? transactionId;

  Map<String, dynamic>? marketData;

  String? errorMessage;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;

      setState(() {
        nifty += random.nextDouble() * 20 - 10;
        sensex += random.nextDouble() * 30 - 15;
        gold += random.nextDouble() * 8 - 4;
        bitcoin += random.nextDouble() * 10000 - 5000;
        ethereum += random.nextDouble() * 500 - 250;
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    symbolController.dispose();
    super.dispose();
  }

  // ============================================================
  // FONTS
  // ============================================================

  TextStyle pixel(double size, {Color color = white}) {
    return GoogleFonts.pressStart2p(
      fontSize: size,
      color: color,
      fontWeight: FontWeight.w700,
    );
  }

  TextStyle mono(
    double size, {
    Color color = white,
    FontWeight weight = FontWeight.normal,
  }) {
    return GoogleFonts.spaceMono(
      fontSize: size,
      color: color,
      fontWeight: weight,
    );
  }

  // ============================================================
  // MARKET INTELLIGENCE
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
      paymentStatus = "Agent request initiated";
      transactionId = null;
      marketData = null;
      errorMessage = null;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      setState(() {
        paymentStatus = "x402 payment required • 0.005 USDC";
      });

      final uri = Uri.parse(
        "http://10.0.2.2:4020/api/market-intelligence"
        "?symbol=${Uri.encodeComponent(symbol)}",
      );

      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception("Agent returned HTTP ${response.statusCode}");
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      if (json["success"] != true) {
        throw Exception(json["error"] ?? "Market request failed");
      }

      final payment = json["payment"] as Map<String, dynamic>?;

      final data = json["data"] as Map<String, dynamic>?;

      final market = data?["market"] as Map<String, dynamic>?;

      if (!mounted) return;

      setState(() {
        isLoading = false;

        paymentStatus = "✓ x402 payment settled on Algorand TestNet";

        transactionId = payment?["transaction"]?.toString();

        marketData = market;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        paymentStatus = "";
        errorMessage = e.toString();
      });
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: border),
      ),

      child: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ==================================================
            // HEADER
            // ==================================================
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,

                  decoration: BoxDecoration(
                    color: teal.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: teal.withValues(alpha: 0.25)),
                  ),

                  child: const Icon(
                    Icons.candlestick_chart_rounded,
                    color: teal,
                    size: 23,
                  ),
                ),

                const SizedBox(width: 13),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text("LIVE MARKET", style: pixel(11, color: white)),

                      const SizedBox(height: 7),

                      Text(
                        "Real-time market overview",
                        style: mono(9, color: muted),
                      ),
                    ],
                  ),
                ),

                // LIVE INDICATOR
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),

                  decoration: BoxDecoration(
                    color: green.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: green.withValues(alpha: 0.30)),
                  ),

                  child: Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,

                        decoration: const BoxDecoration(
                          color: green,
                          shape: BoxShape.circle,
                        ),
                      ),

                      const SizedBox(width: 6),

                      Text(
                        "LIVE",
                        style: mono(8, color: green, weight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            // ==================================================
            // MARKET SNAPSHOT
            // ==================================================
            Text("MARKET SNAPSHOT", style: pixel(9, color: teal)),

            const SizedBox(height: 14),

            Wrap(
              spacing: 10,
              runSpacing: 10,

              children: [
                _marketTile(
                  "NIFTY 50",
                  nifty.toStringAsFixed(2),
                  "+0.82%",
                  green,
                  Icons.trending_up_rounded,
                ),

                _marketTile(
                  "SENSEX",
                  sensex.toStringAsFixed(2),
                  "+0.65%",
                  green,
                  Icons.show_chart_rounded,
                ),

                _marketTile(
                  "GOLD",
                  "₹${gold.toStringAsFixed(0)} / 10g",
                  "+0.30%",
                  orange,
                  Icons.circle_outlined,
                ),

                _marketTile(
                  "BITCOIN",
                  "₹${bitcoin.toStringAsFixed(0)}",
                  "+2.10%",
                  green,
                  Icons.currency_bitcoin_rounded,
                ),

                _marketTile(
                  "ETHEREUM",
                  "₹${ethereum.toStringAsFixed(0)}",
                  "-0.75%",
                  red,
                  Icons.token_rounded,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ==================================================
            // DIVIDER
            // ==================================================
            Container(height: 1, color: border),

            const SizedBox(height: 24),

            // ==================================================
            // AI MARKET INTELLIGENCE
            // ==================================================
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,

                  decoration: BoxDecoration(
                    color: tealDark,
                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: teal,
                    size: 21,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        "AI MARKET INTELLIGENCE",
                        style: pixel(9, color: white),
                      ),

                      const SizedBox(height: 7),

                      Text(
                        "Premium insights powered by x402",
                        style: mono(9, color: muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // ==================================================
            // SYMBOL INPUT
            // ==================================================
            Text(
              "STOCK SYMBOL",
              style: mono(8, color: muted, weight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: symbolController,

              textCapitalization: TextCapitalization.characters,

              style: mono(11, color: white, weight: FontWeight.bold),

              decoration: InputDecoration(
                hintText: "AAPL",

                hintStyle: mono(10, color: muted),

                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: teal,
                  size: 20,
                ),

                filled: true,

                fillColor: background,

                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 15,
                ),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide: const BorderSide(color: border),
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide: const BorderSide(color: border),
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide: const BorderSide(color: teal, width: 1.5),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ==================================================
            // AI BUTTON
            // ==================================================
            SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(
                onPressed: isLoading ? null : getMarketIntelligence,

                style: ElevatedButton.styleFrom(
                  backgroundColor: teal,

                  foregroundColor: background,

                  disabledBackgroundColor: teal.withValues(alpha: 0.45),

                  minimumSize: const Size(double.infinity, 52),

                  elevation: 0,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),

                icon: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: background,
                        ),
                      )
                    : const Icon(Icons.auto_awesome_rounded, size: 19),

                label: Text(
                  isLoading ? "PROCESSING..." : "GET AI INTELLIGENCE",

                  style: mono(10, color: background, weight: FontWeight.bold),
                ),
              ),
            ),

            // ==================================================
            // PAYMENT STATUS
            // ==================================================
            if (isLoading || paymentStatus.isNotEmpty) ...[
              const SizedBox(height: 16),

              _buildPaymentStatus(),
            ],

            // ==================================================
            // TRANSACTION SUCCESS
            // ==================================================
            if (transactionId != null) ...[
              const SizedBox(height: 12),

              _buildTransactionCard(),
            ],

            // ==================================================
            // MARKET DATA
            // ==================================================
            if (marketData != null) ...[
              const SizedBox(height: 16),

              _buildMarketIntelligence(),
            ],

            // ==================================================
            // ERROR
            // ==================================================
            if (errorMessage != null) ...[
              const SizedBox(height: 12),

              _buildErrorCard(),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MARKET TILE
  // ============================================================

  Widget _marketTile(
    String name,
    String price,
    String change,
    Color accent,
    IconData icon,
  ) {
    return Container(
      width: 175,

      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: background,

        borderRadius: BorderRadius.circular(15),

        border: Border.all(color: border),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,

                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(9),
                ),

                child: Icon(icon, color: accent, size: 17),
              ),

              const Spacer(),

              Text(
                change,
                style: mono(8, color: accent, weight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 13),

          Text(
            name,
            style: mono(8, color: muted, weight: FontWeight.bold),
          ),

          const SizedBox(height: 7),

          Text(
            price,
            style: mono(11, color: white, weight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PAYMENT STATUS CARD
  // ============================================================

  Widget _buildPaymentStatus() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: tealDark.withValues(alpha: 0.55),

        borderRadius: BorderRadius.circular(14),

        border: Border.all(color: teal.withValues(alpha: 0.30)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet_rounded,
                color: teal,
                size: 18,
              ),

              const SizedBox(width: 8),

              Text("x402 PAYMENT", style: pixel(8, color: teal)),
            ],
          ),

          const SizedBox(height: 10),

          Text(paymentStatus, style: mono(9, color: white)),

          if (isLoading) ...[
            const SizedBox(height: 10),

            Text("Algorand TestNet • 0.005 USDC", style: mono(8, color: muted)),

            const SizedBox(height: 10),

            ClipRRect(
              borderRadius: BorderRadius.circular(10),

              child: const LinearProgressIndicator(
                minHeight: 5,
                backgroundColor: Color(0xFF263A56),
                color: teal,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // TRANSACTION CARD
  // ============================================================

  Widget _buildTransactionCard() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: green.withValues(alpha: 0.06),

        borderRadius: BorderRadius.circular(14),

        border: Border.all(color: green.withValues(alpha: 0.30)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: green, size: 20),

              const SizedBox(width: 8),

              Text("PAYMENT SUCCESSFUL", style: pixel(8, color: green)),
            ],
          ),

          const SizedBox(height: 13),

          _infoRow("AMOUNT", "0.005 USDC"),

          const SizedBox(height: 7),

          _infoRow("NETWORK", "Algorand TestNet"),

          const SizedBox(height: 10),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),

            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(9),
            ),

            child: Text(
              "TRANSACTION\n${transactionId ?? ""}",
              style: mono(8, color: muted),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MARKET INTELLIGENCE RESULT
  // ============================================================

  Widget _buildMarketIntelligence() {
    final String symbol =
        marketData!["symbol"]?.toString() ?? symbolController.text;

    final String price = marketData!["price"]?.toString() ?? "--";

    final String change = marketData!["changePercent"]?.toString() ?? "--";

    final String previousClose =
        marketData!["previousClose"]?.toString() ?? "--";

    final String volume = marketData!["volume"]?.toString() ?? "--";

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: panelLight,

        borderRadius: BorderRadius.circular(17),

        border: Border.all(color: teal.withValues(alpha: 0.30)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              const Icon(Icons.insights_rounded, color: teal, size: 20),

              const SizedBox(width: 8),

              Text("MARKET INTELLIGENCE", style: pixel(8, color: teal)),
            ],
          ),

          const SizedBox(height: 20),

          Text(symbol, style: pixel(15, color: white)),

          const SizedBox(height: 12),

          Text(
            "\$$price",
            style: mono(22, color: white, weight: FontWeight.bold),
          ),

          const SizedBox(height: 7),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),

            decoration: BoxDecoration(
              color: green.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(7),
            ),

            child: Text(
              "$change%",
              style: mono(9, color: green, weight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 18),

          Container(height: 1, color: border),

          const SizedBox(height: 15),

          _infoRow("PREVIOUS CLOSE", "\$$previousClose"),

          const SizedBox(height: 10),

          _infoRow("VOLUME", volume),

          const SizedBox(height: 15),

          Text("SOURCE: ALPHA VANTAGE", style: mono(7, color: muted)),
        ],
      ),
    );
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      children: [
        Text(
          label,
          style: mono(8, color: muted, weight: FontWeight.bold),
        ),

        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: mono(9, color: white, weight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ERROR CARD
  // ============================================================

  Widget _buildErrorCard() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(13),

      decoration: BoxDecoration(
        color: red.withValues(alpha: 0.08),

        borderRadius: BorderRadius.circular(12),

        border: Border.all(color: red.withValues(alpha: 0.30)),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Icon(Icons.error_outline_rounded, color: red, size: 19),

          const SizedBox(width: 9),

          Expanded(
            child: Text(errorMessage!, style: mono(8, color: red)),
          ),
        ],
      ),
    );
  }
}
