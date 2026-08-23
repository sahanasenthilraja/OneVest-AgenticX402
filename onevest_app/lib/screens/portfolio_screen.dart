import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  int _unreadNotifications = 4;

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
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  tooltip: "Notifications",
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: Color(0xFFB7BED3),
                  ),
                  onPressed: _openNotifications,
                ),
                if (_unreadNotifications > 0)
                  Positioned(
                    right: 7,
                    top: 7,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF5964),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _unreadNotifications > 9
                            ? "9+"
                            : "$_unreadNotifications",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
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
                AppSidebar(
  selected: SidebarItem.portfolio,
  onSelected: (item) {
    
  },
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

  Future<void> _openNotifications() async {
    if (!mounted) return;

    // Opening the notification center marks the current notifications as read.
    setState(() {
      _unreadNotifications = 0;
    });

    final notifications = <PortfolioNotification>[];

    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection("investments")
            .where("userId", isEqualTo: currentUser.uid)
            .get();

        double totalInvested = 0;
        double totalCurrent = 0;

        for (final doc in snapshot.docs) {
          final data = doc.data();

          final buyPrice =
              (data["buyPrice"] as num?)?.toDouble() ?? 0;
          final quantity =
              (data["quantity"] as num?)?.toInt() ?? 0;

          final name =
              (data["investmentName"] ?? "Investment").toString();

          final symbol = (data["symbol"] ?? "")
              .toString()
              .trim()
              .toUpperCase();

          final currentPrice = symbol.isNotEmpty
              ? _livePrices[symbol]
              : null;

          totalInvested += buyPrice * quantity;

          if (currentPrice != null) {
            totalCurrent += currentPrice * quantity;

            final invested = buyPrice * quantity;
            final value = currentPrice * quantity;
            final profit = value - invested;

            if (invested > 0) {
              final percent = (profit / invested) * 100;

              if (percent.abs() >= 5) {
                notifications.add(
                  PortfolioNotification(
                    title: percent >= 0
                        ? "$name is performing well"
                        : "$name needs attention",
                    message: percent >= 0
                        ? "$name is currently up ${percent.toStringAsFixed(2)}%."
                        : "$name is currently down ${percent.abs().toStringAsFixed(2)}%.",
                    icon: percent >= 0
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    color: percent >= 0
                        ? const Color(0xFF3DDC97)
                        : const Color(0xFFFF6F61),
                  ),
                );
              }
            }
          }
        }

        if (totalInvested > 0 && totalCurrent > 0) {
          final profit = totalCurrent - totalInvested;
          final percent = (profit / totalInvested) * 100;

          notifications.insert(
            0,
            PortfolioNotification(
              title: "Portfolio updated",
              message:
                  "Your portfolio is ${profit >= 0 ? "up" : "down"} "
                  "${percent.abs().toStringAsFixed(2)}% "
                  "based on the latest available prices.",
              icon: profit >= 0
                  ? Icons.account_balance_wallet_rounded
                  : Icons.warning_amber_rounded,
              color: profit >= 0
                  ? const Color(0xFF14C8B0)
                  : const Color(0xFFFFB52E),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Notification loading error: $e");
    }

    // Always show useful notifications even if live market data
    // is temporarily unavailable.
    notifications.add(
      const PortfolioNotification(
        title: "Market prices",
        message:
            "OneVest is using the latest available market prices for your holdings.",
        icon: Icons.show_chart_rounded,
        color: Color(0xFF14C8B0),
      ),
    );

    notifications.add(
      const PortfolioNotification(
        title: "Portfolio tracking",
        message:
            "Your investment records are being tracked in OneVest.",
        icon: Icons.receipt_long_rounded,
        color: Color(0xFF4D8DFF),
      ),
    );

    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (_) => NotificationPanel(
        notifications: notifications,
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

class PortfolioNotification {
  final String title;
  final String message;
  final IconData icon;
  final Color color;

  const PortfolioNotification({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
  });
}

class NotificationPanel extends StatefulWidget {
  final List<PortfolioNotification> notifications;

  const NotificationPanel({
    super.key,
    required this.notifications,
  });

  @override
  State<NotificationPanel> createState() => _NotificationPanelState();
}

class _NotificationPanelState extends State<NotificationPanel> {
  late List<bool> _read;

  static const Color background = Color(0xFF02001F);
  static const Color card = Color(0xFF061B30);
  static const Color border = Color(0xFF244B70);
  static const Color teal = Color(0xFF14C8B0);
  static const Color white = Color(0xFFF5F7FF);
  static const Color muted = Color(0xFF8493AD);

  @override
  void initState() {
    super.initState();
    _read = List<bool>.filled(
      widget.notifications.length,
      false,
    );
  }

  void _markAllRead() {
    setState(() {
      for (var i = 0; i < _read.length; i++) {
        _read[i] = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _read.where((value) => !value).length;

    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.78,
        decoration: const BoxDecoration(
          color: background,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28),
          ),
          border: Border(
            top: BorderSide(
              color: border,
              width: 1,
            ),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Bottom-sheet handle.
            Container(
              width: 45,
              height: 5,
              decoration: BoxDecoration(
                color: muted,
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                20,
                12,
                16,
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: teal.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.notifications_rounded,
                      color: teal,
                      size: 23,
                    ),
                  ),

                  const SizedBox(width: 13),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Notifications",
                          style: GoogleFonts.pressStart2p(
                            color: white,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          unreadCount == 0
                              ? "You're all caught up"
                              : "$unreadCount unread update${unreadCount == 1 ? "" : "s"}",
                          style: GoogleFonts.spaceMono(
                            color: muted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),

                  TextButton(
                    onPressed: unreadCount == 0
                        ? null
                        : _markAllRead,
                    child: Text(
                      "MARK ALL READ",
                      style: GoogleFonts.spaceMono(
                        color: unreadCount == 0
                            ? muted
                            : teal,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(
              color: border,
              height: 1,
            ),

            Expanded(
              child: widget.notifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.notifications_off_outlined,
                            color: muted,
                            size: 46,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            "No notifications yet",
                            style: GoogleFonts.spaceMono(
                              color: white,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        16,
                        16,
                        28,
                      ),
                      itemCount: widget.notifications.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = widget.notifications[index];
                        final isRead = _read[index];

                        return InkWell(
                          borderRadius: BorderRadius.circular(17),
                          onTap: () {
                            setState(() {
                              _read[index] = true;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: isRead
                                  ? card.withValues(alpha: 0.65)
                                  : card,
                              borderRadius: BorderRadius.circular(17),
                              border: Border.all(
                                color: isRead
                                    ? border.withValues(alpha: 0.55)
                                    : item.color.withValues(alpha: 0.55),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: item.color.withValues(
                                      alpha: 0.12,
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(13),
                                  ),
                                  child: Icon(
                                    item.icon,
                                    color: item.color,
                                    size: 21,
                                  ),
                                ),

                                const SizedBox(width: 12),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.title,
                                              style: GoogleFonts.spaceMono(
                                                color: white,
                                                fontSize: 12,
                                                fontWeight:
                                                    FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          if (!isRead)
                                            Container(
                                              width: 7,
                                              height: 7,
                                              decoration:
                                                  BoxDecoration(
                                                color: item.color,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                        ],
                                      ),

                                      const SizedBox(height: 7),

                                      Text(
                                        item.message,
                                        style: GoogleFonts.spaceMono(
                                          color: muted,
                                          fontSize: 10,
                                          height: 1.45,
                                        ),
                                      ),

                                      const SizedBox(height: 8),

                                      Text(
                                        "Tap to mark as read",
                                        style: GoogleFonts.spaceMono(
                                          color: isRead
                                              ? muted
                                              : item.color,
                                          fontSize: 8,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
