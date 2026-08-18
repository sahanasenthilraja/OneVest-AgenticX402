import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'investment_details_screen.dart';
import '../widgets/app_sidebar.dart';
import '../services/market_price_cache.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  final user = FirebaseAuth.instance.currentUser;

  final TextEditingController searchController =
      TextEditingController();

  String searchText = "";

  final Map<String, double> _livePrices = {};
  final Map<String, double> _liveChanges = {};
  Timer? _priceTimer;
  bool _isRefreshingPrices = false;
  String _lastSymbolKey = "";

  // Your market-data API.
  // Android emulator -> host machine uses 10.0.2.2.
  // Web/Desktop -> localhost.

  @override
  void initState() {
    super.initState();

    _priceTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => _refreshPrices(),
    );
  }

  @override
  void dispose() {
    _priceTimer?.cancel();
    searchController.dispose();
    super.dispose();
  }

Future<void> _refreshPrices() async {
  if (_isRefreshingPrices || !mounted) {
    return;
  }

  try {
    final currentUser =
        FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return;
    }

    _isRefreshingPrices = true;

    final snapshot =
        await FirebaseFirestore.instance
            .collection("investments")
            .where(
              "userId",
              isEqualTo: currentUser.uid,
            )
            .get();

    final symbols = <String>{};

    for (final doc in snapshot.docs) {
      final data = doc.data();

      final symbol =
          (data["symbol"] ?? "")
              .toString()
              .trim()
              .toUpperCase();

      if (symbol.isNotEmpty) {
        symbols.add(symbol);
      }
    }

    if (symbols.isEmpty) {
      return;
    }

    // ============================================================
    // IMPORTANT:
    // Use the SAME shared cache as DashboardScreen.
    // ============================================================

    final marketCache =
        MarketPriceCache.instance;

    await marketCache.refresh(symbols);

    if (!mounted) {
      return;
    }

    setState(() {
      for (final symbol in symbols) {
        final price =
            marketCache.getPrice(symbol);

        final change =
            marketCache.getChange(symbol);

        if (price != null) {
          _livePrices[symbol] = price;
        }

        if (change != null) {
          _liveChanges[symbol] = change;
        }
      }
    });

    debugPrint(
      "Portfolio prices updated from shared cache",
    );
  } catch (e) {
    debugPrint(
      "Portfolio price refresh error: $e",
    );
  } finally {
    _isRefreshingPrices = false;
  }
}

double? _currentPrice(
  Map<String, dynamic> data,
) {
  final symbol =
      (data["symbol"] ?? "")
          .toString()
          .trim()
          .toUpperCase();

  // Always prefer the latest price from the
  // Yahoo Finance-backed market API.
  if (symbol.isNotEmpty &&
      _livePrices.containsKey(symbol)) {
    return _livePrices[symbol];
  }

  // Do NOT use buyPrice as the current market price.
  // If the live API hasn't returned a price yet,
  // return null so the UI can indicate that
  // the current market price is unavailable.
  return null;
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020B1D),

      appBar: AppBar(
        backgroundColor: const Color(0xFF020B1D),
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,

        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "My ",
                style: GoogleFonts.pressStart2p(
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
              TextSpan(
                text: "Portfolio",
                style: GoogleFonts.pressStart2p(
                  color: const Color(0xFF14C8B0),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFFB7BED3),
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 900;

          if (isDesktop) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AppSidebar(
                  current: SidebarItem.portfolio,
                ),

                Expanded(
                  child: _buildPortfolioContent(),
                ),
              ],
            );
          }

          return _buildPortfolioContent();
        },
      ),
    );
  }

  Widget _buildPortfolioContent() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("investments")
          .where(
            "userId",
            isEqualTo: user!.uid,
          )
          .orderBy(
            "createdAt",
            descending: true,
          )
          .snapshots(),

      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF14C8B0),
            ),
          );
        }

        if (!snapshot.hasData ||
            snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.inbox_outlined,
                  color: Color(0xFF6D7890),
                  size: 40,
                ),
                const SizedBox(height: 14),
                Text(
                  "No investments yet",
                  style: GoogleFonts.spaceMono(
                    color: const Color(0xFFB7BED3),
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          );
        }

        final docs = snapshot.data!.docs;

        // Fetch real current prices as soon as Firestore
        // provides the user's holdings. The symbol key prevents
        // rebuilds caused by price updates from starting another
        // request loop.
        final symbolKey = docs
            .map((doc) {
              final data =
                  doc.data()
                      as Map<String, dynamic>;

              return (data["symbol"] ?? "")
                  .toString()
                  .trim()
                  .toUpperCase();
            })
            .where((symbol) => symbol.isNotEmpty)
            .toList()
          ..sort();

        final joinedSymbolKey =
            symbolKey.join("|");

        if (joinedSymbolKey != _lastSymbolKey) {
          _lastSymbolKey = joinedSymbolKey;

          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _refreshPrices(),
          );
        }

        final filteredDocs = docs.where((doc) {
          final data =
              doc.data() as Map<String, dynamic>;

          final investmentName =
              (data["investmentName"] ?? "")
                  .toString()
                  .toLowerCase();

          final investmentType =
              (data["investmentType"] ?? "")
                  .toString()
                  .toLowerCase();

          return investmentName.contains(
                searchText.toLowerCase(),
              ) ||
              investmentType.contains(
                searchText.toLowerCase(),
              );
        }).toList();

        double totalInvested = 0;
        double totalPortfolio = 0;

        for (var doc in docs) {
          final data =
              doc.data() as Map<String, dynamic>;

          final double buyPrice =
              (data["buyPrice"] as num).toDouble();

          final double? currentPrice =
              _currentPrice(data);

          final int quantity =
              (data["quantity"] as num).toInt();

          totalInvested += buyPrice * quantity;

          if (currentPrice != null) {
            totalPortfolio += currentPrice * quantity;
          }
        }

        final double overallProfit =
            totalPortfolio - totalInvested;

        final double overallReturn =
            totalInvested == 0
                ? 0
                : (overallProfit / totalInvested) * 100;

        final bool isOverallProfit =
            overallProfit >= 0;

        return Column(
          children: [
            // ==========================================================
            // PORTFOLIO SUMMARY
            // ==========================================================

            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(22),

              decoration: BoxDecoration(
                color: const Color(0xFF0E1830),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF1E2C48),
                ),
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,

                        decoration: BoxDecoration(
                          color: const Color(0xFF14C8B0)
                              .withValues(alpha: 0.14),
                          borderRadius:
                              BorderRadius.circular(11),
                        ),

                        alignment: Alignment.center,

                        child: const Icon(
                          Icons
                              .account_balance_wallet_rounded,
                          color: Color(0xFF14C8B0),
                          size: 21,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Text(
                        "Portfolio Summary",
                        style: GoogleFonts.pressStart2p(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 26),

                  _summaryRow(
                    "TOTAL INVESTED",
                    "₹${totalInvested.toStringAsFixed(2)}",
                  ),

                  const SizedBox(height: 18),

                  _summaryRow(
                    "CURRENT VALUE",
                    "₹${totalPortfolio.toStringAsFixed(2)}",
                  ),

                  const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 20),
                    child: Divider(
                      color: Color(0xFF1E2C48),
                      thickness: 1,
                    ),
                  ),

                  _summaryRow(
                    isOverallProfit
                        ? "OVERALL PROFIT"
                        : "OVERALL LOSS",
                    "${isOverallProfit ? "+" : "-"}₹${overallProfit.abs().toStringAsFixed(2)}",
                    valueColor: isOverallProfit
                        ? const Color(0xFF3DDC97)
                        : const Color(0xFFFF6F61),
                  ),

                  const SizedBox(height: 18),

                  _summaryRow(
                    "RETURN",
                    "${isOverallProfit ? "+" : "-"}${overallReturn.abs().toStringAsFixed(2)}%",
                    valueColor: isOverallProfit
                        ? const Color(0xFF3DDC97)
                        : const Color(0xFFFF6F61),
                  ),
                ],
              ),
            ),

            // ==========================================================
            // SEARCH
            // ==========================================================

            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20),

              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF111F36),
                  borderRadius:
                      BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF263A56),
                  ),
                ),

                child: TextField(
                  controller: searchController,

                  style: GoogleFonts.spaceMono(
                    color: Colors.white,
                    fontSize: 14,
                  ),

                  cursorColor:
                      const Color(0xFF14C8B0),

                  decoration: InputDecoration(
                    hintText:
                        "Search investments...",

                    hintStyle:
                        GoogleFonts.spaceMono(
                      color:
                          const Color(0xFF8A96AA),
                      fontSize: 14,
                    ),

                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF14C8B0),
                    ),

                    border: InputBorder.none,
                    enabledBorder:
                        InputBorder.none,
                    focusedBorder:
                        InputBorder.none,

                    contentPadding:
                        const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                  ),

                  onChanged: (value) {
                    setState(() {
                      searchText = value;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ==========================================================
            // INVESTMENT LIST
            // ==========================================================

            Expanded(
              child: filteredDocs.isEmpty
                  ? Center(
                      child: Text(
                        "No matches for \"$searchText\"",
                        style:
                            GoogleFonts.spaceMono(
                          color:
                              const Color(0xFF6D7890),
                          fontSize: 14,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount:
                          filteredDocs.length,

                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),

                      itemBuilder:
                          (context, index) {
                        final investment =
                            filteredDocs[index];

                        final data =
                            investment.data()
                                as Map<String, dynamic>;

                        final double buyPrice =
                            (data["buyPrice"] as num)
                                .toDouble();

                        final double? currentPrice =
                            _currentPrice(data);

                        final int quantity =
                            (data["quantity"] as num).toInt();

                        final double investedAmount =
                            buyPrice * quantity;

                        final double currentValue =
                            currentPrice != null
                                ? currentPrice * quantity
                                : 0;

                        final double profitLoss =
                            currentValue -
                                investedAmount;
                        final double profitPercent =
                            investedAmount == 0
                                ? 0
                                : (profitLoss /
                                        investedAmount) *
                                    100;

                        final bool isProfit =
                            profitLoss >= 0;

                        return MouseRegion(
                          cursor:
                              SystemMouseCursors.click,

                          child: InkWell(
                            borderRadius:
                                BorderRadius.circular(16),

                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      InvestmentDetailsScreen(
                                    investmentId:
                                        investment.id,
                                    investmentData:
                                        data,
                                  ),
                                ),
                              );
                            },

                            child: Container(
                              margin:
                                  const EdgeInsets.only(
                                bottom: 12,
                              ),

                              padding:
                                  const EdgeInsets.all(
                                16,
                              ),

                              decoration:
                                  BoxDecoration(
                                color:
                                    const Color(
                                  0xFF0E1830,
                                ),

                                borderRadius:
                                    BorderRadius.circular(
                                  16,
                                ),

                                border: Border.all(
                                  color:
                                      const Color(
                                    0xFF1E2C48,
                                  ),
                                ),
                              ),

                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,

                                children: [
                                  Container(
                                    width: 46,
                                    height: 46,

                                    decoration:
                                        BoxDecoration(
                                      color:
                                          const Color(
                                        0xFF14C8B0,
                                      ).withValues(
                                        alpha: 0.14,
                                      ),

                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                        13,
                                      ),
                                    ),

                                    alignment:
                                        Alignment.center,

                                    child:
                                        const Icon(
                                      Icons
                                          .show_chart_rounded,
                                      color:
                                          Color(
                                        0xFF14C8B0,
                                      ),
                                      size: 24,
                                    ),
                                  ),

                                  const SizedBox(
                                    width: 14,
                                  ),

                                  Expanded(
                                    child:
                                        Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,

                                      children: [
                                        Text(
                                          data[
                                              "investmentName"],
                                          style: GoogleFonts
                                              .spaceMono(
                                            color:
                                                Colors.white,
                                            fontSize:
                                                15.5,
                                            fontWeight:
                                                FontWeight
                                                    .w700,
                                          ),
                                        ),

                                        const SizedBox(
                                          height: 6,
                                        ),

                                        Text(
                                          "${data["investmentType"]} · Qty $quantity",
                                          style: GoogleFonts
                                              .spaceMono(
                                            color:
                                                const Color(
                                              0xFF8FA0BE,
                                            ),
                                            fontSize:
                                                11.5,
                                          ),
                                        ),

                                        const SizedBox(
                                          height: 3,
                                        ),

                                        Text(
                                              "Buy ₹${buyPrice.toStringAsFixed(2)}  ·  "
                                              "Now ${currentPrice != null ? "₹${currentPrice.toStringAsFixed(2)}" : "Loading..."}",                                          style: GoogleFonts
                                              .spaceMono(
                                            color:
                                                const Color(
                                              0xFF8FA0BE,
                                            ),
                                            fontSize:
                                                11.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(
                                    width: 10,
                                  ),

                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .end,

                                    children: [
                                      Text(
                                        "₹${currentValue.toStringAsFixed(2)}",
                                        style: GoogleFonts
                                            .spaceMono(
                                          color:
                                              Colors.white,
                                          fontSize:
                                              14,
                                          fontWeight:
                                              FontWeight
                                                  .w700,
                                        ),
                                      ),

                                      const SizedBox(
                                        height: 6,
                                      ),

                                      Container(
                                        padding:
                                            const EdgeInsets
                                                .symmetric(
                                          horizontal:
                                              8,
                                          vertical:
                                              4,
                                        ),

                                        decoration:
                                            BoxDecoration(
                                          color: (isProfit
                                                  ? const Color(
                                                      0xFF3DDC97,
                                                    )
                                                  : const Color(
                                                      0xFFFF6F61,
                                                    ))
                                              .withValues(
                                            alpha: 0.14,
                                          ),

                                          borderRadius:
                                              BorderRadius
                                                  .circular(
                                            8,
                                          ),
                                        ),

                                        child: Text(
                                          isProfit
                                              ? "+${profitPercent.toStringAsFixed(2)}%"
                                              : "-${profitPercent.abs().toStringAsFixed(2)}%",

                                          style:
                                              GoogleFonts
                                                  .spaceMono(
                                            color: isProfit
                                                ? const Color(
                                                    0xFF3DDC97,
                                                  )
                                                : const Color(
                                                    0xFFFF6F61,
                                                  ),
                                            fontSize:
                                                11,
                                            fontWeight:
                                                FontWeight
                                                    .w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(
                                    width: 6,
                                  ),

                                  const Icon(
                                    Icons
                                        .chevron_right_rounded,
                                    color:
                                        Color(0xFF6D7890),
                                    size: 22,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,

      children: [
        Text(
          label,
          style: GoogleFonts.spaceMono(
            color:
                const Color(0xFF8FA0BE),
            fontSize: 11,
            letterSpacing: 1,
          ),
        ),

        Text(
          value,
          style: GoogleFonts.spaceMono(
            color:
                valueColor ?? Colors.white,
            fontSize: 18,
            fontWeight:
                FontWeight.w700,
          ),
        ),
      ],
    );
  }
}