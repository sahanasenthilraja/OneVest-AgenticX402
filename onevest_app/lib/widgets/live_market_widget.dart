import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class LiveMarketWidget extends StatefulWidget {
  const LiveMarketWidget({super.key});

  @override
  State<LiveMarketWidget> createState() =>
      _LiveMarketWidgetState();
}

class _LiveMarketWidgetState
    extends State<LiveMarketWidget> {
  Timer? timer;

  double nifty = 0;
  double sensex = 0;
  double gold = 0;
  double bitcoin = 0;
  double ethereum = 0;

  double niftyChange = 0;
  double sensexChange = 0;
  double goldChange = 0;
  double bitcoinChange = 0;
  double ethereumChange = 0;

  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();

    _fetchAllMarketData();

    timer = Timer.periodic(
      const Duration(seconds: 60),
      (_) {
        _fetchAllMarketData();
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // ============================================================
  // MARKET API BASE URL
  // ============================================================

  String get marketApiBaseUrl {
    if (kIsWeb) {
      return "http://localhost:4021";
    }

    // Android Emulator
    return "http://10.0.2.2:4021";
  }

  // ============================================================
  // FETCH ONE MARKET PRICE
  // ============================================================

  Future<Map<String, dynamic>?> _fetchMarketPrice(
    String symbol,
  ) async {
    try {
      debugPrint(
        "Fetching live market data for $symbol",
      );

      final response = await http
          .get(
            Uri.parse(
              "$marketApiBaseUrl/api/market-price"
              "?symbol=${Uri.encodeComponent(symbol)}",
            ),
          )
          .timeout(
            const Duration(seconds: 10),
          );

      debugPrint(
        "$symbol market API status: "
        "${response.statusCode}",
      );

      if (response.statusCode != 200) {
        debugPrint(
          "Market API failed for $symbol: "
          "${response.body}",
        );
        return null;
      }

      final data =
          jsonDecode(response.body)
              as Map<String, dynamic>;

      if (data["success"] != true) {
        debugPrint(
          "Market API returned success=false "
          "for $symbol",
        );
        return null;
      }

      final market = data["market"];

      if (market is! Map) {
        debugPrint(
          "Invalid market data returned for $symbol",
        );
        return null;
      }

      return Map<String, dynamic>.from(market);
    } catch (e) {
      debugPrint(
        "Market API error for $symbol: $e",
      );

      return null;
    }
  }

  // ============================================================
  // FETCH ALL MARKET DATA
  // ============================================================

  Future<void> _fetchAllMarketData() async {
    try {
      final results = await Future.wait([
        _fetchMarketPrice("^NSEI"),
        _fetchMarketPrice("^BSESN"),
        _fetchMarketPrice("GC=F"),
        _fetchMarketPrice("BTC-INR"),
        _fetchMarketPrice("ETH-INR"),
      ]);

      if (!mounted) return;

      final niftyData = results[0];
      final sensexData = results[1];
      final goldData = results[2];
      final bitcoinData = results[3];
      final ethereumData = results[4];

      setState(() {
        if (niftyData != null) {
          final price = niftyData["price"];
          final change = niftyData["changePercent"];

          if (price is num) {
            nifty = price.toDouble();
          }

          if (change is num) {
            niftyChange = change.toDouble();
          }
        }

        if (sensexData != null) {
          final price = sensexData["price"];
          final change = sensexData["changePercent"];

          if (price is num) {
            sensex = price.toDouble();
          }

          if (change is num) {
            sensexChange = change.toDouble();
          }
        }

        if (goldData != null) {
          final price = goldData["price"];
          final change = goldData["changePercent"];

          if (price is num) {
            gold = price.toDouble();
          }

          if (change is num) {
            goldChange = change.toDouble();
          }
        }

        if (bitcoinData != null) {
          final price = bitcoinData["price"];
          final change = bitcoinData["changePercent"];

          if (price is num) {
            bitcoin = price.toDouble();
          }

          if (change is num) {
            bitcoinChange = change.toDouble();
          }
        }

        if (ethereumData != null) {
          final price = ethereumData["price"];
          final change = ethereumData["changePercent"];

          if (price is num) {
            ethereum = price.toDouble();
          }

          if (change is num) {
            ethereumChange = change.toDouble();
          }
        }

        loading = false;

        if (niftyData != null ||
            sensexData != null ||
            goldData != null ||
            bitcoinData != null ||
            ethereumData != null) {
          error = null;
        } else {
          error = "Unable to load live market data";
        }
      });
    } catch (e) {
      debugPrint(
        "Error fetching all market data: $e",
      );

      if (!mounted) return;

      setState(() {
        loading = false;
        error = "Unable to load live market data";
      });
    }
  }

  // ============================================================
  // FORMAT CHANGE
  // ============================================================

  String _formatChange(double value) {
    final sign = value >= 0 ? "+" : "";

    return "$sign${value.toStringAsFixed(2)}%";
  }

  // ============================================================
  // CHANGE COLOR
  // ============================================================

  Color _changeColor(double value) {
    if (value < 0) {
      return const Color(0xFFFF4D4D);
    }

    return const Color(0xFF4CAF50);
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0E1830),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF243758),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          18,
          18,
          18,
          10,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // ==================================================
            // HEADER
            // ==================================================

            Row(
              children: [
                const Icon(
                  Icons.show_chart_rounded,
                  color: Color(0xFF14C8B0),
                  size: 21,
                ),

                const SizedBox(width: 10),

                Text(
                  "Live Market",
                  style: GoogleFonts.pressStart2p(
                    color: Colors.white,
                    fontSize: 11,
                  ),
                ),

                const Spacer(),

                // LIVE INDICATOR
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color:
                        const Color(0xFF14C8B0)
                            .withValues(
                      alpha: 0.12,
                    ),
                    borderRadius:
                        BorderRadius.circular(6),
                    border: Border.all(
                      color:
                          const Color(0xFF14C8B0)
                              .withValues(
                        alpha: 0.35,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration:
                            const BoxDecoration(
                          color:
                              Color(0xFF14C8B0),
                          shape:
                              BoxShape.circle,
                        ),
                      ),

                      const SizedBox(width: 6),

                      Text(
                        "LIVE",
                        style:
                            GoogleFonts
                                .pressStart2p(
                          color:
                              const Color(
                            0xFF14C8B0,
                          ),
                          fontSize: 7,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ==================================================
            // LOADING
            // ==================================================

            if (loading &&
                nifty == 0 &&
                sensex == 0 &&
                gold == 0 &&
                bitcoin == 0 &&
                ethereum == 0)
              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 25,
                ),
                child: Center(
                  child: Column(
                    children: [
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Loading live market data...",
                        style:
                            GoogleFonts.spaceMono(
                          color:
                              const Color(
                            0xFF8A96AA,
                          ),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              // ==================================================
              // MARKET ITEMS
              // ==================================================

              _marketTile(
                "NIFTY 50",
                nifty == 0
                    ? "--"
                    : nifty.toStringAsFixed(2),
                _formatChange(niftyChange),
                _changeColor(niftyChange),
              ),

              _marketTile(
                "SENSEX",
                sensex == 0
                    ? "--"
                    : sensex.toStringAsFixed(2),
                _formatChange(sensexChange),
                _changeColor(sensexChange),
              ),

              _marketTile(
                "Gold",
                gold == 0
                    ? "--"
                    : "₹${gold.toStringAsFixed(2)}",
                _formatChange(goldChange),
                _changeColor(goldChange),
              ),

              _marketTile(
                "Bitcoin",
                bitcoin == 0
                    ? "--"
                    : "₹${bitcoin.toStringAsFixed(2)}",
                _formatChange(bitcoinChange),
                _changeColor(bitcoinChange),
              ),

              _marketTile(
                "Ethereum",
                ethereum == 0
                    ? "--"
                    : "₹${ethereum.toStringAsFixed(2)}",
                _formatChange(ethereumChange),
                _changeColor(ethereumChange),
              ),
            ],

            // ==================================================
            // ERROR MESSAGE
            // ==================================================

            if (error != null)
              Padding(
                padding:
                    const EdgeInsets.only(
                  top: 8,
                  bottom: 4,
                ),
                child: Text(
                  error!,
                  style:
                      GoogleFonts.spaceMono(
                    color:
                        const Color(0xFFFF4D4D),
                    fontSize: 9,
                  ),
                ),
              ),

            // ==================================================
            // REFRESH
            // ==================================================

            const SizedBox(height: 4),

            Align(
              alignment:
                  Alignment.centerRight,
              child: TextButton.icon(
                onPressed:
                    _fetchAllMarketData,
                icon: const Icon(
                  Icons.refresh_rounded,
                  size: 16,
                  color: Color(0xFF14C8B0),
                ),
                label: Text(
                  "Refresh",
                  style:
                      GoogleFonts.spaceMono(
                    color:
                        const Color(0xFF14C8B0),
                    fontSize: 10,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize:
                      MaterialTapTargetSize
                          .shrinkWrap,
                ),
              ),
            ),
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
    Color changeColor,
  ) {
    final bool negative =
        change.startsWith("-");

    return Container(
      margin:
          const EdgeInsets.only(bottom: 4),
      padding:
          const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 2,
      ),
      child: Row(
        children: [
          // ==================================================
          // MARKET ICON
          // ==================================================

          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color:
                  changeColor.withValues(
                alpha: 0.14,
              ),
              borderRadius:
                  BorderRadius.circular(8),
              border: Border.all(
                color:
                    changeColor.withValues(
                  alpha: 0.30,
                ),
              ),
            ),
            child: Icon(
              negative
                  ? Icons
                      .trending_down_rounded
                  : Icons
                      .trending_up_rounded,
              color: changeColor,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          // ==================================================
          // NAME + PRICE
          // ==================================================

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style:
                      GoogleFonts.spaceMono(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  price,
                  style:
                      GoogleFonts.spaceMono(
                    color:
                        const Color(
                      0xFF8A96AA,
                    ),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          // ==================================================
          // CHANGE
          // ==================================================

          Text(
            change,
            style:
                GoogleFonts.spaceMono(
              color: changeColor,
              fontSize: 11,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
