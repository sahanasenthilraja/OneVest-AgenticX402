import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'investment_details_screen.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() =>
      _PortfolioScreenState();
}

class _PortfolioScreenState
    extends State<PortfolioScreen> {
  final user =
      FirebaseAuth.instance.currentUser;

  final TextEditingController searchController =
      TextEditingController();

  String searchText = "";

  Timer? _refreshTimer;

  /*
   * Current live prices.
   *
   * Key   = market symbol
   * Value = latest market price
   */
  final Map<String, double> livePrices = {};

  bool isRefreshingPrices = false;

@override
void initState() {
  super.initState();

  // Fetch live prices once when Portfolio opens.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) {
      _refreshLivePrices();
    }
  });

  // Refresh live prices every 60 seconds.
  _refreshTimer = Timer.periodic(
    const Duration(seconds: 60),
    (_) {
      if (mounted) {
        _refreshLivePrices();
      }
    },
  );
}

  @override
  void dispose() {
    _refreshTimer?.cancel();
    searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // FETCH CURRENT MARKET PRICE
  // ============================================================

  Future<double?> getCurrentMarketPrice(
    String symbol,
  ) async {
    try {
      if (symbol.trim().isEmpty) {
        return null;
      }

      final uri = Uri.parse(
        "http://10.0.2.2:4021/api/market-price"
        "?symbol=${Uri.encodeComponent(symbol)}",
      );

      debugPrint(
        "Fetching live price for $symbol",
      );

      final response =
          await http.get(uri);

      debugPrint(
        "Market API status: ${response.statusCode}",
      );

      if (response.statusCode != 200) {
        debugPrint(
          "Market API failed for $symbol",
        );

        return null;
      }

      final data =
          jsonDecode(response.body);

      if (data["success"] != true) {
        debugPrint(
          "Market API returned unsuccessful response for $symbol",
        );

        return null;
      }

      final price =
          data["market"]?["price"];

      if (price == null) {
        return null;
      }

      final currentPrice =
          (price as num).toDouble();

      debugPrint(
        "$symbol current price = $currentPrice",
      );

      return currentPrice;
    } catch (e) {
      debugPrint(
        "Market price error for $symbol: $e",
      );

      return null;
    }
  }

  // ============================================================
  // REFRESH ALL LIVE PRICES
  // ============================================================

  Future<void> _refreshLivePrices() async {
    if (isRefreshingPrices) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      isRefreshingPrices = true;
    });

    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection("investments")
              .where(
                "userId",
                isEqualTo: user!.uid,
              )
              .get();

      final symbols = <String>{};

      for (final doc in snapshot.docs) {
        final data =
            doc.data();

        final symbol =
            (data["symbol"] ?? "")
                .toString()
                .trim()
                .toUpperCase();

        if (symbol.isNotEmpty) {
          symbols.add(symbol);
        }
      }

      /*
       * Fetch each unique symbol.
       */
      for (final symbol in symbols) {
        final price =
            await getCurrentMarketPrice(
          symbol,
        );

        if (price != null) {
          livePrices[symbol] =
              price;
        }
      }
    } catch (e) {
      debugPrint(
        "Live price refresh error: $e",
      );
    } finally {
      if (mounted) {
        setState(() {
          isRefreshingPrices = false;
        });
      }
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    if (user == null) {
      return const Scaffold(
        backgroundColor:
            Color(0xFF020B1D),
        body: Center(
          child: Text(
            "Please log in",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
          const Color(0xFF020B1D),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFF020B1D),
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 22,
          ),
          onPressed: () =>
              Navigator.pop(context),
        ),

        title: const Text(
          "My Portfolio",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),

        actions: [
          /*
           * Manual refresh button.
           */
          IconButton(
            icon: isRefreshingPrices
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2,
                      color:
                          Colors.tealAccent,
                    ),
                  )
                : const Icon(
                    Icons.refresh_rounded,
                    color:
                        Colors.tealAccent,
                  ),
            onPressed:
                isRefreshingPrices
                    ? null
                    : _refreshLivePrices,
          ),

          IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.white,
            ),
            onPressed: () {},
          ),

          const SizedBox(width: 8),
        ],
      ),

      body: StreamBuilder<QuerySnapshot>(
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

        builder: (
          context,
          snapshot,
        ) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error loading portfolio:\n${snapshot.error}",
                textAlign:
                    TextAlign.center,
                style:
                    const TextStyle(
                  color: Colors.white70,
                ),
              ),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No Investments Yet",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
              ),
            );
          }

          final docs =
              snapshot.data!.docs;

          // ==================================================
          // FILTER
          // ==================================================

          final filteredDocs =
              docs.where((doc) {
            final data =
                doc.data()
                    as Map<String, dynamic>;

            final investmentName =
                (data["investmentName"] ??
                        "")
                    .toString()
                    .toLowerCase();

            final investmentType =
                (data["investmentType"] ??
                        "")
                    .toString()
                    .toLowerCase();

            final symbol =
                (data["symbol"] ?? "")
                    .toString()
                    .toLowerCase();

            final query =
                searchText
                    .toLowerCase();

            return investmentName
                    .contains(query) ||
                investmentType
                    .contains(query) ||
                symbol.contains(query);
          }).toList();

          // ==================================================
          // PORTFOLIO TOTALS
          // ==================================================

          double totalInvested = 0;

          double totalPortfolio = 0;

          for (final doc in docs) {
            final data =
                doc.data()
                    as Map<String, dynamic>;

            final buyPrice =
                (data["buyPrice"] ?? 0)
                    as num;

            final quantity =
                (data["quantity"] ?? 0)
                    as num;

            final symbol =
                (data["symbol"] ?? "")
                    .toString()
                    .trim()
                    .toUpperCase();

            final investedAmount =
                buyPrice.toDouble() *
                    quantity.toInt();

            /*
             * Use live price if available.
             *
             * Otherwise fall back to buy price.
             */
            final currentPrice =
                livePrices[symbol] ??
                    buyPrice.toDouble();

            final currentValue =
                currentPrice *
                    quantity.toInt();

            totalInvested +=
                investedAmount;

            totalPortfolio +=
                currentValue;
          }

          final overallProfit =
              totalPortfolio -
                  totalInvested;

          final overallReturn =
              totalInvested == 0
                  ? 0
                  : (overallProfit /
                          totalInvested) *
                      100;

          final isOverallProfit =
              overallProfit >= 0;

          // ==================================================
          // UI
          // ==================================================

          return Column(
            children: [
              // =================================================
              // PORTFOLIO SUMMARY
              // =================================================

              Container(
                width:
                    double.infinity,

                margin:
                    const EdgeInsets.all(
                  20,
                ),

                padding:
                    const EdgeInsets.all(
                  20,
                ),

                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFF16253C,
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    22,
                  ),

                  border:
                      Border.all(
                    color:
                        Colors.white10,
                  ),

                  boxShadow:
                      const [
                    BoxShadow(
                      color:
                          Colors.black26,
                      blurRadius: 12,
                      offset:
                          Offset(0, 6),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons
                              .account_balance_wallet_rounded,
                          color:
                              Colors.tealAccent,
                          size: 28,
                        ),

                        SizedBox(
                          width: 10,
                        ),

                        Text(
                          "Portfolio Summary",
                          style:
                              TextStyle(
                            color:
                                Colors.white,
                            fontSize: 24,
                            fontWeight:
                                FontWeight
                                    .w700,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 25,
                    ),

                    // TOTAL INVESTED

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,

                      children: [
                        const Text(
                          "Total Invested",
                          style:
                              TextStyle(
                            color:
                                Colors.white70,
                            fontSize: 16,
                          ),
                        ),

                        Text(
                          "₹${totalInvested.toStringAsFixed(2)}",
                          style:
                              const TextStyle(
                            color:
                                Colors.white,
                            fontSize: 20,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    // CURRENT VALUE

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,

                      children: [
                        const Text(
                          "Current Value",
                          style:
                              TextStyle(
                            color:
                                Colors.white70,
                            fontSize: 16,
                          ),
                        ),

                        Text(
                          "₹${totalPortfolio.toStringAsFixed(2)}",
                          style:
                              const TextStyle(
                            color:
                                Colors.white,
                            fontSize: 20,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ],
                    ),

                    const Padding(
                      padding:
                          EdgeInsets.symmetric(
                        vertical: 20,
                      ),

                      child: Divider(
                        color:
                            Colors.white24,
                        thickness: 1,
                      ),
                    ),

                    // PROFIT / LOSS

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,

                      children: [
                        Text(
                          isOverallProfit
                              ? "Overall Profit"
                              : "Overall Loss",

                          style:
                              const TextStyle(
                            color:
                                Colors.white70,
                            fontSize: 16,
                          ),
                        ),

                        Text(
                          "${isOverallProfit ? "+" : "-"}₹${overallProfit.abs().toStringAsFixed(2)}",

                          style:
                              TextStyle(
                            color:
                                isOverallProfit
                                    ? Colors.greenAccent
                                    : Colors.redAccent,
                            fontSize: 20,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    // RETURN

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,

                      children: [
                        const Text(
                          "Return",
                          style:
                              TextStyle(
                            color:
                                Colors.white70,
                            fontSize: 16,
                          ),
                        ),

                        Text(
                          "${isOverallProfit ? "+" : "-"}${overallReturn.abs().toStringAsFixed(2)}%",

                          style:
                              TextStyle(
                            color:
                                isOverallProfit
                                    ? Colors.greenAccent
                                    : Colors.redAccent,
                            fontSize: 20,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    /*
                     * Shows whether live prices have
                     * been loaded.
                     */

                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 9,
                          color:
                              livePrices.isNotEmpty
                                  ? Colors.greenAccent
                                  : Colors.orangeAccent,
                        ),

                        const SizedBox(
                          width: 7,
                        ),

                        Text(
                          livePrices.isNotEmpty
                              ? "Live market prices"
                              : "Loading market prices...",
                          style:
                              const TextStyle(
                            color:
                                Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // =================================================
              // SEARCH
              // =================================================

              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 20,
                ),

                child: TextField(
                  controller:
                      searchController,

                  style:
                      const TextStyle(
                    color: Colors.white,
                  ),

                  decoration:
                      InputDecoration(
                    hintText:
                        "Search Investments...",

                    hintStyle:
                        const TextStyle(
                      color:
                          Colors.white54,
                      fontSize: 16,
                    ),

                    prefixIcon:
                        const Icon(
                      Icons.search,
                      color:
                          Colors.tealAccent,
                    ),

                    filled: true,

                    fillColor:
                        const Color(
                      0xFF132743,
                    ),

                    border:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                      borderSide:
                          BorderSide.none,
                    ),
                  ),

                  onChanged:
                      (value) {
                    setState(() {
                      searchText =
                          value;
                    });
                  },
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              // =================================================
              // INVESTMENT LIST
              // =================================================

              Expanded(
                child:
                    ListView.builder(
                  itemCount:
                      filteredDocs.length,

                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 15,
                  ),

                  itemBuilder:
                      (context, index) {
                    /*
                     * IMPORTANT:
                     *
                     * Use filteredDocs[index],
                     * not docs[index].
                     */

                    final investment =
                        filteredDocs[index];

                    final data =
                        investment.data()
                            as Map<String, dynamic>;

                    final buyPrice =
                        (data["buyPrice"] ??
                                0)
                            as num;

                    final quantity =
                        (data["quantity"] ??
                                0)
                            as num;

                    final symbol =
                        (data["symbol"] ??
                                "")
                            .toString()
                            .trim()
                            .toUpperCase();

                    /*
                     * Current live price.
                     *
                     * If the API has already returned
                     * a value, use it.
                     *
                     * Otherwise use buy price temporarily.
                     */

                    final currentPrice =
                        livePrices[symbol] ??
                            buyPrice
                                .toDouble();

                    final investedAmount =
                        buyPrice
                                .toDouble() *
                            quantity
                                .toInt();

                    final currentValue =
                        currentPrice *
                            quantity
                                .toInt();

                    final profitLoss =
                        currentValue -
                            investedAmount;

                    final profitPercent =
                        investedAmount == 0
                            ? 0
                            : (profitLoss /
                                    investedAmount) *
                                100;

                    final isProfit =
                        profitLoss >= 0;

                    return InkWell(
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),

                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) =>
                                    InvestmentDetailsScreen(
                              investmentId:
                                  investment.id,

                              investmentData:
                                  data,
                            ),
                          ),
                        );
                      },

                      child: Card(
                        elevation: 8,

                        shadowColor:
                            Colors.black26,

                        color:
                            const Color(
                          0xFF14253F,
                        ),

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            24,
                          ),
                        ),

                        margin:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 4,
                          vertical: 8,
                        ),

                        child: ListTile(
                          leading:
                              const CircleAvatar(
                            radius: 26,

                            backgroundColor:
                                Color(
                              0xFF14C8B0,
                            ),

                            child: Icon(
                              Icons
                                  .show_chart_rounded,
                              color:
                                  Colors.white,
                              size: 28,
                            ),
                          ),

                          title: Text(
                            (data[
                                      "investmentName"] ??
                                  "Investment")
                                .toString(),

                            style:
                                const TextStyle(
                              color:
                                  Colors.white,
                              fontSize: 19,
                              fontWeight:
                                  FontWeight
                                      .w700,
                            ),
                          ),

                          subtitle:
                              Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [
                              const SizedBox(
                                height: 5,
                              ),

                              Text(
                                (data[
                                          "investmentType"] ??
                                      "")
                                    .toString(),

                                style:
                                    const TextStyle(
                                  color:
                                      Colors.white70,
                                ),
                              ),

                              /*
                               * SYMBOL
                               */

                              if (symbol
                                  .isNotEmpty)
                                Text(
                                  "Symbol : $symbol",

                                  style:
                                      const TextStyle(
                                    color:
                                        Colors.white54,
                                    fontSize:
                                        12,
                                  ),
                                ),

                              Text(
                                "Quantity : ${quantity.toInt()}",

                                style:
                                    const TextStyle(
                                  color:
                                      Colors.white70,
                                ),
                              ),

                              Text(
                                "Buy Price : ₹${buyPrice.toDouble().toStringAsFixed(2)}",

                                style:
                                    const TextStyle(
                                  color:
                                      Colors.white70,
                                ),
                              ),

                              /*
                               * CURRENT MARKET PRICE
                               */

                              Text(
                                "Current Price : ₹${currentPrice.toStringAsFixed(2)}",

                                style:
                                    TextStyle(
                                  color:
                                      livePrices.containsKey(
                                            symbol,
                                          )
                                          ? Colors
                                              .greenAccent
                                          : Colors
                                              .white70,
                                  fontWeight:
                                      livePrices.containsKey(
                                            symbol,
                                          )
                                          ? FontWeight
                                              .bold
                                          : FontWeight
                                              .normal,
                                ),
                              ),

                              Text(
                                "Current Value : ₹${currentValue.toStringAsFixed(2)}",

                                style:
                                    const TextStyle(
                                  color:
                                      Colors.white,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),

                              const SizedBox(
                                height: 4,
                              ),

                              Text(
                                isProfit
                                    ? "Profit : +₹${profitLoss.toStringAsFixed(2)} (${profitPercent.toStringAsFixed(2)}%)"
                                    : "Loss : -₹${profitLoss.abs().toStringAsFixed(2)} (${profitPercent.abs().toStringAsFixed(2)}%)",

                                style:
                                    TextStyle(
                                  color:
                                      isProfit
                                          ? Colors
                                              .greenAccent
                                          : Colors
                                              .redAccent,

                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                            ],
                          ),

                          trailing:
                              Container(
                            padding:
                                const EdgeInsets
                                    .all(
                              6,
                            ),

                            decoration:
                                BoxDecoration(
                              color:
                                  Colors.white10,

                              borderRadius:
                                  BorderRadius
                                      .circular(
                                24,
                              ),
                            ),

                            child:
                                const Icon(
                              Icons
                                  .chevron_right_rounded,
                              color:
                                  Colors.white70,
                              size: 22,
                            ),
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
      ),
    );
  }
}