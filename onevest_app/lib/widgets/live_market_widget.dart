import 'dart:async';
import 'dart:math';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LiveMarketWidget extends StatefulWidget {
  const LiveMarketWidget({super.key});

  @override
  State<LiveMarketWidget> createState() => _LiveMarketWidgetState();
}

class _LiveMarketWidgetState extends State<LiveMarketWidget> {
  final Random random = Random();
  final TextEditingController symbolController =
      TextEditingController(text: "AAPL");

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

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(
      const Duration(seconds: 3),
      (_) {
        if (!mounted) return;

        setState(() {
          nifty += random.nextDouble() * 20 - 10;
          sensex += random.nextDouble() * 30 - 15;
          gold += random.nextDouble() * 8 - 4;
          bitcoin += random.nextDouble() * 10000 - 5000;
          ethereum += random.nextDouble() * 500 - 250;
        });
      },
    );
  }

  @override
  void dispose() {
    timer.cancel();
    symbolController.dispose();
    super.dispose();
  }

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
      paymentStatus = "Agent request initiated";
      transactionId = null;
      marketData = null;
      errorMessage = null;
    });

    try {
      await Future.delayed(
        const Duration(milliseconds: 500),
      );

      if (!mounted) return;

      setState(() {
        paymentStatus =
            "x402 payment required • 0.005 USDC";
      });

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

      final json =
          jsonDecode(response.body)
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

      if (!mounted) return;

      setState(() {
        isLoading = false;
        paymentStatus =
            "✓ x402 payment settled on Algorand TestNet";
        transactionId =
            payment?["transaction"]?.toString();
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

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1A2B45),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.show_chart,
                  color: Colors.greenAccent,
                ),
                const SizedBox(width: 10),
                const Text(
                  "Live Market",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.circle,
                        color: Colors.white,
                        size: 10,
                      ),
                      SizedBox(width: 5),
                      Text(
                        "LIVE",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            marketTile(
              "NIFTY 50",
              nifty.toStringAsFixed(2),
              "+0.82%",
              Colors.green,
            ),

            marketTile(
              "SENSEX",
              sensex.toStringAsFixed(2),
              "+0.65%",
              Colors.green,
            ),

            marketTile(
              "Gold",
              "₹${gold.toStringAsFixed(0)} / 10g",
              "+0.30%",
              Colors.orange,
            ),

            marketTile(
              "Bitcoin",
              "₹${bitcoin.toStringAsFixed(0)}",
              "+2.10%",
              Colors.green,
            ),

            marketTile(
              "Ethereum",
              "₹${ethereum.toStringAsFixed(0)}",
              "-0.75%",
              Colors.red,
            ),

            const SizedBox(height: 20),

            const Divider(
              color: Colors.white24,
            ),

            const SizedBox(height: 15),

            const Text(
              "AI Market Intelligence",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Get premium market intelligence through an "
              "AI agent powered by x402.",
              style: TextStyle(
                color: Colors.white70,
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: symbolController,
              textCapitalization:
                  TextCapitalization.characters,
              style: const TextStyle(
                color: Colors.white,
              ),
              decoration: InputDecoration(
                labelText: "Stock Symbol",
                labelStyle: const TextStyle(
                  color: Colors.white70,
                ),
                hintText: "AAPL",
                hintStyle: const TextStyle(
                  color: Colors.white38,
                ),
                filled: true,
                fillColor:
                    Colors.white.withOpacity(0.08),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    isLoading
                        ? null
                        : getMarketIntelligence,
                icon: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.auto_awesome,
                      ),
                label: Text(
                  isLoading
                      ? "Processing..."
                      : "Get AI Market Intelligence",
                ),
              ),
            ),

            if (isLoading ||
                paymentStatus.isNotEmpty) ...[
              const SizedBox(height: 15),

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color:
                      Colors.black.withOpacity(0.18),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "x402 PAYMENT",
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      paymentStatus,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),

                    if (isLoading) ...[
                      const SizedBox(height: 10),
                      const Text(
                        "Algorand TestNet • 0.005 USDC",
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const LinearProgressIndicator(),
                    ],
                  ],
                ),
              ),
            ],

            if (transactionId != null) ...[
              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.green
                      .withOpacity(0.12),
                  borderRadius:
                      BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green
                        .withOpacity(0.4),
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
                        SizedBox(width: 8),
                        Text(
                          "x402 PAYMENT SUCCESSFUL",
                          style: TextStyle(
                            color:
                                Colors.greenAccent,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Amount: 0.005 USDC",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),

                    const Text(
                      "Network: Algorand TestNet",
                      style: TextStyle(
                        color: Colors.white70,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Transaction:\n$transactionId",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (marketData != null) ...[
              const SizedBox(height: 15),

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      const Color(0xFF243A59),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "MARKET INTELLIGENCE",
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      marketData!["symbol"]
                              ?.toString() ??
                          symbolController.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      "\$${marketData!["price"]}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      "${marketData!["changePercent"]}%",
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const Divider(
                      color: Colors.white24,
                    ),

                    Text(
                      "Previous close: \$${marketData!["previousClose"]}",
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),

                    Text(
                      "Volume: ${marketData!["volume"]}",
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
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
              ),
            ],

            if (errorMessage != null) ...[
              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red
                      .withOpacity(0.12),
                  borderRadius:
                      BorderRadius.circular(10),
                ),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static Widget marketTile(
    String name,
    String price,
    String change,
    Color color,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,

      leading: CircleAvatar(
        backgroundColor: color,
        child: const Icon(
          Icons.trending_up,
          color: Colors.white,
        ),
      ),

      title: Text(
        name,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),

      subtitle: Text(
        price,
        style: const TextStyle(
          color: Colors.white70,
        ),
      ),

      trailing: Text(
        change,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}