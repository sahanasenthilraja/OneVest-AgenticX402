import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LiveMarketWidget extends StatefulWidget {
  const LiveMarketWidget({super.key});

  @override
  State<LiveMarketWidget> createState() =>
      _LiveMarketWidgetState();
}

class _LiveMarketWidgetState
    extends State<LiveMarketWidget> {
  final Random random = Random();

  late Timer timer;

  double nifty = 25120.80;
  double sensex = 82450.10;
  double gold = 10250;
  double bitcoin = 9654321;
  double ethereum = 287450;

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      decoration: BoxDecoration(
        color: const Color(0xFF0E1830),

        borderRadius:
            BorderRadius.circular(14),

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
                // Pixel-style graph icon
                const Icon(
                  Icons.show_chart_rounded,
                  color: Color(0xFF14C8B0),
                  size: 21,
                ),

                const SizedBox(width: 10),

                Text(
                  "Live Market",
                  style:
                      GoogleFonts.pressStart2p(
                    color: Colors.white,
                    fontSize: 11,
                  ),
                ),

                const Spacer(),

                // LIVE indicator
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),

                  decoration:
                      BoxDecoration(
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
                            GoogleFonts.pressStart2p(
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
            // MARKET ITEMS
            // ==================================================

            _marketTile(
              "NIFTY 50",
              nifty.toStringAsFixed(2),
              "+0.82%",
              const Color(0xFF4CAF50),
            ),

            _marketTile(
              "SENSEX",
              sensex.toStringAsFixed(2),
              "+0.65%",
              const Color(0xFF4CAF50),
            ),

            _marketTile(
              "Gold",
              "₹${gold.toStringAsFixed(0)} / 10g",
              "+0.30%",
              const Color(0xFFFFA000),
            ),

            _marketTile(
              "Bitcoin",
              "₹${bitcoin.toStringAsFixed(0)}",
              "+2.10%",
              const Color(0xFF4CAF50),
            ),

            _marketTile(
              "Ethereum",
              "₹${ethereum.toStringAsFixed(0)}",
              "-0.75%",
              const Color(0xFFFF4D4D),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // MARKET TILE
  // ==========================================================

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
          // PIXEL MARKET ICON
          // ==================================================

          Container(
            width: 40,
            height: 40,

            decoration:
                BoxDecoration(
              color: changeColor.withValues(
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
                  ? Icons.trending_down_rounded
                  : Icons.trending_up_rounded,

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