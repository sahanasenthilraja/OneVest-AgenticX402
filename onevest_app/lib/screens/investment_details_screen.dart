import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'edit_investment_screen.dart';
import '../widgets/app_sidebar.dart';

class InvestmentDetailsScreen extends StatefulWidget {
  final String investmentId;
  final Map<String, dynamic> investmentData;

  const InvestmentDetailsScreen({
    super.key,
    required this.investmentId,
    required this.investmentData,
  });

  @override
  State<InvestmentDetailsScreen> createState() =>
      _InvestmentDetailsScreenState();
}

class _InvestmentDetailsScreenState
    extends State<InvestmentDetailsScreen> {
  String get investmentId => widget.investmentId;

  Map<String, dynamic> get investmentData =>
      widget.investmentData;

  double? liveCurrentPrice;
  double? liveChangePercent;
  bool isLoadingLivePrice = false;

  Timer? livePriceTimer;

  @override
  void initState() {
    super.initState();

    fetchLiveCurrentPrice();

    livePriceTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => fetchLiveCurrentPrice(),
    );
  }

  @override
  void dispose() {
    livePriceTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchLiveCurrentPrice() async {
    final String symbol =
        (investmentData["symbol"] ??
                investmentData["stockSymbol"] ??
                investmentData["ticker"] ??
                "")
            .toString()
            .trim()
            .toUpperCase();

    if (symbol.isEmpty) {
      debugPrint(
        "Investment Details: no market symbol found.",
      );
      return;
    }

    if (isLoadingLivePrice) return;

    if (mounted) {
      setState(() {
        isLoadingLivePrice = true;
      });
    }

    try {
      final Uri uri = Uri.parse(
        "http://10.0.2.2:4021/api/market-price"
        "?symbol=${Uri.encodeQueryComponent(symbol)}",
      );

      debugPrint(
        "Investment Details: fetching live price for $symbol",
      );

      final http.Response response =
          await http.get(uri);

      debugPrint(
        "Investment Details: API status ${response.statusCode}",
      );

      if (response.statusCode != 200) {
        debugPrint(
          "Investment Details: API error ${response.body}",
        );
        return;
      }

      final dynamic decoded =
          jsonDecode(response.body);

      double? price;
      double? changePercent;

      if (decoded is Map<String, dynamic>) {
        final dynamic market = decoded["market"];
        final dynamic data = decoded["data"];

        final dynamic directPrice =
            decoded["price"];
        final dynamic directChange =
            decoded["changePercent"] ??
                decoded["change"];

        if (directPrice is num) {
          price = directPrice.toDouble();
        }

        if (directChange is num) {
          changePercent = directChange.toDouble();
        }

        if (market is Map) {
          final dynamic marketPrice =
              market["price"];
          final dynamic marketChange =
              market["changePercent"] ??
                  market["change"];

          if (marketPrice is num) {
            price = marketPrice.toDouble();
          }

          if (marketChange is num) {
            changePercent = marketChange.toDouble();
          }
        }

        if (data is Map) {
          final dynamic dataPrice =
              data["price"];
          final dynamic dataChange =
              data["changePercent"] ??
                  data["change"];

          if (dataPrice is num) {
            price = dataPrice.toDouble();
          }

          if (dataChange is num) {
            changePercent = dataChange.toDouble();
          }
        }
      }

      if (!mounted) return;

      if (price != null && price > 0) {
        setState(() {
          liveCurrentPrice = price;
          liveChangePercent = changePercent;
        });

        debugPrint(
          "Investment Details: $symbol live price = $price",
        );
      } else {
        debugPrint(
          "Investment Details: no valid price in API response.",
        );
      }
    } catch (e) {
      debugPrint(
        "Investment Details: market API error: $e",
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoadingLivePrice = false;
        });
      }
    }
  }

  // ============================================================
  // COLORS
  // ============================================================

  static const Color background = Color(0xFF020B1D);
  static const Color panel = Color(0xFF0E1830);
  static const Color panelLight = Color(0xFF111F36);
  static const Color border = Color(0xFF1E2C48);
  static const Color teal = Color(0xFF14C8B0);
  static const Color secondaryText = Color(0xFF8FA0BE);
  static const Color mutedText = Color(0xFF6D7890);
  static const Color profitColor = Color(0xFF3DDC97);
  static const Color lossColor = Color(0xFFFF6F61);

  // ============================================================
  // HELPER
  // ============================================================

  double getDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }

  // ============================================================
  // DELETE INVESTMENT
  // ============================================================

  Future<void> deleteInvestment(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: panel,

        title: Text(
          "Delete Investment",
          style: GoogleFonts.pressStart2p(
            color: Colors.white,
            fontSize: 12,
          ),
        ),

        content: Text(
          "Are you sure you want to delete this investment?",
          style: GoogleFonts.spaceMono(
            color: secondaryText,
            fontSize: 13,
          ),
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              "Cancel",
              style: GoogleFonts.spaceMono(
                color: secondaryText,
              ),
            ),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: lossColor,
              foregroundColor: Colors.white,
            ),

            onPressed: () => Navigator.pop(context, true),

            child: Text(
              "Delete",
              style: GoogleFonts.spaceMono(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await FirebaseFirestore.instance
        .collection("investments")
        .doc(investmentId)
        .delete();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Investment Deleted"),
        ),
      );

      Navigator.pop(context);
    }
  }

  // ============================================================
  // ADD TRANSACTION
  // ============================================================

  Future<void> addTransaction(BuildContext context) async {
    String transactionType = "BUY";

    final amountController = TextEditingController();
    final unitsController = TextEditingController();
    final priceController = TextEditingController();

    DateTime selectedDate = DateTime.now();

    final bool? added = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: panel,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: const BorderSide(
                  color: border,
                ),
              ),

              title: Text(
                "ADD TRANSACTION",
                style: GoogleFonts.pressStart2p(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Transaction type
                    DropdownButtonFormField<String>(
                      initialValue: transactionType,

                      dropdownColor: panel,

                      style: GoogleFonts.spaceMono(
                        color: Colors.white,
                        fontSize: 13,
                      ),

                      decoration: _dialogInputDecoration(
                        "Transaction Type",
                      ),

                      items: const [
                        DropdownMenuItem(
                          value: "BUY",
                          child: Text("BUY"),
                        ),
                        DropdownMenuItem(
                          value: "SELL",
                          child: Text("SELL"),
                        ),
                        DropdownMenuItem(
                          value: "DIVIDEND",
                          child: Text("DIVIDEND"),
                        ),
                      ],

                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            transactionType = value;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 15),

                    // Amount
                    TextField(
                      controller: amountController,

                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),

                      style: GoogleFonts.spaceMono(
                        color: Colors.white,
                      ),

                      cursorColor: teal,

                      decoration: _dialogInputDecoration(
                        "Amount",
                        prefixText: "₹ ",
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Units
                    TextField(
                      controller: unitsController,

                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),

                      style: GoogleFonts.spaceMono(
                        color: Colors.white,
                      ),

                      cursorColor: teal,

                      decoration: _dialogInputDecoration(
                        "Units",
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Price
                    TextField(
                      controller: priceController,

                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),

                      style: GoogleFonts.spaceMono(
                        color: Colors.white,
                      ),

                      cursorColor: teal,

                      decoration: _dialogInputDecoration(
                        "Price per Unit",
                        prefixText: "₹ ",
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Date
                    ListTile(
                      contentPadding: EdgeInsets.zero,

                      leading: const Icon(
                        Icons.calendar_today_rounded,
                        color: teal,
                      ),

                      title: Text(
                        "Transaction Date",
                        style: GoogleFonts.spaceMono(
                          color: secondaryText,
                          fontSize: 12,
                        ),
                      ),

                      subtitle: Text(
                        "${selectedDate.day}/"
                        "${selectedDate.month}/"
                        "${selectedDate.year}",
                        style: GoogleFonts.spaceMono(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),

                      onTap: () async {
                        final DateTime? picked =
                            await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );

                        if (picked != null) {
                          setDialogState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                      false,
                    );
                  },

                  child: Text(
                    "CANCEL",
                    style: GoogleFonts.spaceMono(
                      color: secondaryText,
                      fontSize: 12,
                    ),
                  ),
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: teal,
                    foregroundColor: const Color(0xFF04140F),
                  ),

                  onPressed: () async {
                    final double? amount =
                        double.tryParse(
                      amountController.text.trim(),
                    );

                    final double? units =
                        double.tryParse(
                      unitsController.text.trim(),
                    );

                    final double? price =
                        double.tryParse(
                      priceController.text.trim(),
                    );

                    if (amount == null ||
                        amount <= 0 ||
                        units == null ||
                        units < 0 ||
                        price == null ||
                        price < 0) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Please enter valid transaction details.",
                          ),
                        ),
                      );

                      return;
                    }

                    await FirebaseFirestore.instance
                        .collection("investments")
                        .doc(investmentId)
                        .collection("transactions")
                        .add({
                      "type": transactionType,
                      "amount": amount,
                      "units": units,
                      "price": price,
                      "date": Timestamp.fromDate(
                        selectedDate,
                      ),
                      "createdAt":
                          FieldValue.serverTimestamp(),
                    });

                    if (dialogContext.mounted) {
                      Navigator.pop(
                        dialogContext,
                        true,
                      );
                    }
                  },

                  child: Text(
                    "ADD",
                    style: GoogleFonts.spaceMono(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (added == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Transaction Added"),
        ),
      );
    }
  }

  // ============================================================
  // DIALOG INPUT DECORATION
  // ============================================================

  InputDecoration _dialogInputDecoration(
    String label, {
    String? prefixText,
  }) {
    return InputDecoration(
      labelText: label,

      labelStyle: GoogleFonts.spaceMono(
        color: secondaryText,
        fontSize: 12,
      ),

      prefixText: prefixText,

      prefixStyle: GoogleFonts.spaceMono(
        color: Colors.white,
      ),

      filled: true,

      fillColor: panelLight,

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: border,
        ),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: border,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: teal,
        ),
      ),
    );
  }

  // ============================================================
  // TRANSACTION HISTORY
  // ============================================================

  Widget transactionHistory() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("investments")
          .doc(investmentId)
          .collection("transactions")
          .orderBy(
            "date",
            descending: true,
          )
          .snapshots(),

      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(25),

            child: Center(
              child: CircularProgressIndicator(
                color: teal,
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return _emptyStateCard(
            icon: Icons.error_outline_rounded,
            title: "Unable to load transaction history.",
            subtitle: "Please try again later.",
          );
        }

        final transactions =
            snapshot.data?.docs ?? [];

        if (transactions.isEmpty) {
          return _emptyStateCard(
            icon: Icons.receipt_long_rounded,
            title: "No transactions yet",
            subtitle: "Add your first transaction.",
          );
        }

        return Column(
          children: transactions.map((doc) {
            final data =
                doc.data() as Map<String, dynamic>;

            final String type =
                data["type"] ?? "BUY";

            final double amount =
                getDouble(data["amount"]);

            final double units =
                getDouble(data["units"]);

            final double price =
                getDouble(data["price"]);

            final Timestamp? timestamp =
                data["date"] as Timestamp?;

            final DateTime? date =
                timestamp?.toDate();

            Color color;
            IconData icon;

            if (type == "BUY") {
              color = profitColor;
              icon = Icons.arrow_downward_rounded;
            } else if (type == "SELL") {
              color = lossColor;
              icon = Icons.arrow_upward_rounded;
            } else {
              color = Colors.amber;
              icon =
                  Icons.account_balance_wallet_rounded;
            }

            return MouseRegion(
              cursor: SystemMouseCursors.click,

              child: AnimatedContainer(
                duration:
                    const Duration(milliseconds: 150),

                margin:
                    const EdgeInsets.only(bottom: 10),

                padding:
                    const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: panel,

                  borderRadius:
                      BorderRadius.circular(16),

                  border: Border.all(
                    color: border,
                  ),
                ),

                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,

                      decoration: BoxDecoration(
                        color:
                            color.withValues(
                          alpha: 0.12,
                        ),

                        borderRadius:
                            BorderRadius.circular(12),
                      ),

                      alignment: Alignment.center,

                      child: Icon(
                        icon,
                        color: color,
                        size: 21,
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [
                          Text(
                            type,
                            style:
                                GoogleFonts.pressStart2p(
                              color: color,
                              fontSize: 9,
                            ),
                          ),

                          const SizedBox(height: 7),

                          Text(
                            date == null
                                ? "Date unavailable"
                                : "${date.day}/"
                                  "${date.month}/"
                                  "${date.year}",
                            style:
                                GoogleFonts.spaceMono(
                              color: secondaryText,
                              fontSize: 11,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            "Units: "
                            "${units.toStringAsFixed(2)}"
                            "  •  ₹"
                            "${price.toStringAsFixed(2)} / unit",

                            style:
                                GoogleFonts.spaceMono(
                              color: mutedText,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    Text(
                      "₹${amount.toStringAsFixed(2)}",

                      style:
                          GoogleFonts.spaceMono(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _emptyStateCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 35,
      ),

      decoration: BoxDecoration(
        color: panel,

        borderRadius:
            BorderRadius.circular(18),

        border: Border.all(
          color: border,
        ),
      ),

      child: Column(
        children: [
          Icon(
            icon,
            color: mutedText,
            size: 42,
          ),

          const SizedBox(height: 14),

          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceMono(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceMono(
              color: mutedText,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INVESTMENT SUMMARY
  // ============================================================

  Widget investmentSummaryCard() {
    final double quantity =
        getDouble(investmentData["quantity"]);

    final double buyPrice =
        getDouble(investmentData["buyPrice"]);

    final double storedCurrentPrice =
        getDouble(
      investmentData["currentPrice"],
    );

    final double currentPrice =
        liveCurrentPrice ??
        (storedCurrentPrice > 0
            ? storedCurrentPrice
            : buyPrice);

    final double currentValue =
        currentPrice * quantity;

    final double invested =
        quantity * buyPrice;

    final double profit =
        currentValue - invested;

    final double returnPercentage =
        invested == 0
            ? 0
            : (profit / invested) * 100;

    final bool isProfit =
        profit >= 0;

    final String investmentName =
        investmentData["investmentName"]
                ?.toString() ??
            "Investment";

    final String investmentType =
        investmentData["investmentType"]
                ?.toString() ??
            "";

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(30),

      decoration: BoxDecoration(
        color: panel,

        borderRadius:
            BorderRadius.circular(22),

        border: Border.all(
          color: border,
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          // --------------------------------------------------------
          // TOP IDENTITY
          // --------------------------------------------------------

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Container(
                width: 54,
                height: 54,

                decoration: BoxDecoration(
                  color:
                      teal.withValues(alpha: 0.12),

                  borderRadius:
                      BorderRadius.circular(15),
                ),

                alignment: Alignment.center,

                child: const Icon(
                  Icons.show_chart_rounded,
                  color: teal,
                  size: 27,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      investmentName,

                      style:
                          GoogleFonts.pressStart2p(
                        color: Colors.white,
                        fontSize: 19,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),

                      decoration: BoxDecoration(
                        color:
                            teal.withValues(
                          alpha: 0.10,
                        ),

                        borderRadius:
                            BorderRadius.circular(7),
                      ),

                      child: Text(
                        investmentType
                            .toUpperCase(),

                        style:
                            GoogleFonts.spaceMono(
                          color: teal,
                          fontSize: 12,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // --------------------------------------------------------
          // CURRENT VALUE
          // --------------------------------------------------------

          Text(
            "CURRENT VALUE",
            style: GoogleFonts.spaceMono(
              color: secondaryText,
              fontSize: 12,
              letterSpacing: 1.5,
            ),
          ),

          const SizedBox(height: 7),

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.end,

            children: [
              Expanded(
                child: Text(
                  "₹${currentValue.toStringAsFixed(2)}",

                  style:
                      GoogleFonts.spaceMono(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),

                decoration: BoxDecoration(
                  color: (isProfit
                          ? profitColor
                          : lossColor)
                      .withValues(
                    alpha: 0.12,
                  ),

                  borderRadius:
                      BorderRadius.circular(9),
                ),

                child: Text(
                  "${isProfit ? "+" : ""}"
                  "${returnPercentage.toStringAsFixed(2)}%",

                  style:
                      GoogleFonts.spaceMono(
                    color: isProfit
                        ? profitColor
                        : lossColor,
                    fontSize: 15,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          Container(
            height: 1,
            color: border,
          ),

          const SizedBox(height: 20),

          // --------------------------------------------------------
          // KEY METRICS
          // --------------------------------------------------------

          LayoutBuilder(
            builder:
                (context, constraints) {
              final bool compact =
                  constraints.maxWidth < 550;

              if (compact) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _metricCard(
                            "INVESTED",
                            "₹${invested.toStringAsFixed(2)}",
                            Icons.savings_outlined,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _metricCard(
                            "QUANTITY",
                            quantity
                                .toStringAsFixed(0),
                            Icons.layers_outlined,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: _metricCard(
                            isProfit
                                ? "PROFIT"
                                : "LOSS",
                            "${isProfit ? "+" : "-"}₹${profit.abs().toStringAsFixed(2)}",
                            isProfit
                                ? Icons.trending_up_rounded
                                : Icons.trending_down_rounded,
                            valueColor: isProfit
                                ? profitColor
                                : lossColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _metricCard(
                            "RETURN",
                            "${isProfit ? "+" : ""}${returnPercentage.toStringAsFixed(2)}%",
                            Icons.percent_rounded,
                            valueColor: isProfit
                                ? profitColor
                                : lossColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: _metricCard(
                      "INVESTED",
                      "₹${invested.toStringAsFixed(2)}",
                      Icons.savings_outlined,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _metricCard(
                      "QUANTITY",
                      quantity.toStringAsFixed(0),
                      Icons.layers_outlined,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _metricCard(
                      isProfit
                          ? "PROFIT"
                          : "LOSS",
                      "${isProfit ? "+" : "-"}₹${profit.abs().toStringAsFixed(2)}",
                      isProfit
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      valueColor: isProfit
                          ? profitColor
                          : lossColor,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _metricCard(
                      "RETURN",
                      "${isProfit ? "+" : ""}${returnPercentage.toStringAsFixed(2)}%",
                      Icons.percent_rounded,
                      valueColor: isProfit
                          ? profitColor
                          : lossColor,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // METRIC CARD
  // ============================================================

  Widget _metricCard(
    String label,
    String value,
    IconData icon, {
    Color valueColor = Colors.white,
  }) {
    return Container(
      padding:
          const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: panelLight,

        borderRadius:
            BorderRadius.circular(13),

        border: Border.all(
          color: border,
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Icon(
            icon,
            color: teal,
            size: 22,
          ),

          const SizedBox(height: 10),

          Text(
            label,
            style: GoogleFonts.spaceMono(
              color: secondaryText,
              fontSize: 11,
              letterSpacing: 0.9,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.spaceMono(
              color: valueColor,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFORMATION ROW
  // ============================================================

  Widget informationCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 13,
      ),

      decoration: BoxDecoration(
        color: panel,

        borderRadius:
            BorderRadius.circular(15),

        border: Border.all(
          color: border,
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,

            decoration: BoxDecoration(
              color:
                  teal.withValues(alpha: 0.10),

              borderRadius:
                  BorderRadius.circular(10),
            ),

            alignment: Alignment.center,

            child: Icon(
              icon,
              color: teal,
              size: 23,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  title.toUpperCase(),
                  style: GoogleFonts.spaceMono(
                    color: secondaryText,
                    fontSize: 11,
                    letterSpacing: 0.9,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  value,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      GoogleFonts.spaceMono(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACTION BUTTON
  // ============================================================

  Widget _actionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required bool primary,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,

      child: SizedBox(
        height: 50,

        child: primary
            ? ElevatedButton.icon(
                onPressed: onPressed,

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor: teal,
                  foregroundColor:
                      const Color(0xFF04140F),

                  elevation: 0,

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      13,
                    ),
                  ),
                ),

                icon: Icon(
                  icon,
                  size: 19,
                ),

                label: Text(
                  label,
                  style:
                      GoogleFonts.spaceMono(
                    fontSize: 13,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              )
            : OutlinedButton.icon(
                onPressed: onPressed,

                style:
                    OutlinedButton.styleFrom(
                  foregroundColor:
                      lossColor,

                  side:
                      const BorderSide(
                    color: lossColor,
                  ),

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      13,
                    ),
                  ),
                ),

                icon: Icon(
                  icon,
                  size: 19,
                ),

                label: Text(
                  label,
                  style:
                      GoogleFonts.spaceMono(
                    fontSize: 13,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        scrolledUnderElevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
          ),

          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: Text(
          "Investment Details",
          style: GoogleFonts.pressStart2p(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isDesktop =
              constraints.maxWidth >= 900;
final Widget content =
    _buildContent(
  context: context,
  isDesktop: isDesktop,
);

          if (isDesktop) {
            return Row(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,

              children: [
                const AppSidebar(
                  current: SidebarItem.portfolio,
                ),

                Expanded(
                  child: content,
                ),
              ],
            );
          }

          return content;
        },
      ),
    );
  }

  // ============================================================
  // MAIN CONTENT
  // ============================================================

  Widget _buildContent({
  required BuildContext context,
  required bool isDesktop,
}) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 28 : 16,
        vertical: 16,
      ),

      child: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(
            maxWidth: 1450,
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              // --------------------------------------------------
              // TOP LABEL
              // --------------------------------------------------

              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,

                    decoration:
                        const BoxDecoration(
                      color: teal,
                      shape: BoxShape.circle,
                    ),
                  ),

                  const SizedBox(width: 8),

                  Text(
                    "INVESTMENT // DETAILS",
                    style:
                        GoogleFonts.spaceMono(
                      color: teal,
                      fontSize: 10,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // --------------------------------------------------
              // HERO
              // --------------------------------------------------

              investmentSummaryCard(),

              const SizedBox(height: 30),

              // --------------------------------------------------
              // INVESTMENT INFORMATION
              // --------------------------------------------------

              Row(
                children: [
                  Container(
                    width: 4,
                    height: 22,

                    decoration:
                        BoxDecoration(
                      color: teal,
                      borderRadius:
                          BorderRadius.circular(
                        4,
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Text(
                    "Investment Information",
                    style:
                        GoogleFonts.pressStart2p(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              LayoutBuilder(
                builder:
                    (context, constraints) {
                  final bool twoColumns =
                      constraints.maxWidth >=
                          600;

                  final cards = [
                    informationCard(
                      "Quantity",
                      investmentData[
                                  "quantity"]
                              ?.toString() ??
                          "0",
                      Icons.layers_outlined,
                    ),

                    informationCard(
                      "Buy Price",
                      "₹${investmentData["buyPrice"] ?? 0}",
                      Icons.shopping_cart_outlined,
                    ),

                    informationCard(
                      "Current Price",
                      liveCurrentPrice != null
                          ? "₹${liveCurrentPrice!.toStringAsFixed(2)}"
                          : "Loading...",
                      Icons.show_chart_rounded,
                    ),

                    informationCard(
                      "Purchase Date",
                      investmentData[
                                  "purchaseDate"]
                              ?.toString() ??
                          "",
                      Icons.calendar_today_outlined,
                    ),
                  ];

                  if (!twoColumns) {
                    return Column(
                      children: cards
                          .map(
                            (card) => Padding(
                              padding:
                                  const EdgeInsets
                                      .only(
                                bottom: 10,
                              ),
                              child: SizedBox(
                                width:
                                    double.infinity,
                                child: card,
                              ),
                            ),
                          )
                          .toList(),
                    );
                  }

                  return GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 4.6,
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    children: cards,
                  );
                },
              ),

              const SizedBox(height: 30),

              // --------------------------------------------------
              // TRANSACTION HEADER
              // --------------------------------------------------

              Row(
                children: [
                  Container(
                    width: 4,
                    height: 22,

                    decoration:
                        BoxDecoration(
                      color: teal,
                      borderRadius:
                          BorderRadius.circular(
                        4,
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      "Transaction History",
                      style:
                          GoogleFonts.pressStart2p(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),

                  MouseRegion(
                    cursor:
                        SystemMouseCursors.click,

                    child: TextButton.icon(
                      onPressed: () {
                        addTransaction(context);
                      },

                      style:
                          TextButton.styleFrom(
                        foregroundColor: teal,
                      ),

                      icon: const Icon(
                        Icons.add_rounded,
                        size: 18,
                      ),

                      label: Text(
                        "ADD",
                        style:
                            GoogleFonts.spaceMono(
                          fontSize: 11,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              transactionHistory(),

              const SizedBox(height: 30),

              // --------------------------------------------------
              // ACTIONS
              // --------------------------------------------------

              LayoutBuilder(
                builder:
                    (context, constraints) {
                  final bool stacked =
                      constraints.maxWidth <
                          600;

                  if (stacked) {
                    return Column(
                      children: [
                        SizedBox(
                          width:
                              double.infinity,
                          child:
                              _actionButton(
                            label:
                                "EDIT INVESTMENT",
                            icon:
                                Icons.edit_rounded,
                            primary: true,
                            onPressed:
                                () async {
                              await Navigator
                                  .push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      EditInvestmentScreen(
                                    investmentId:
                                        investmentId,
                                    investmentData:
                                        investmentData,
                                  ),
                                ),
                              );

                              if (context
                                  .mounted) {
                                Navigator.pop(
                                    context);
                              }
                            },
                          ),
                        ),

                        const SizedBox(
                          height: 10,
                        ),

                        SizedBox(
                          width:
                              double.infinity,
                          child:
                              _actionButton(
                            label:
                                "DELETE INVESTMENT",
                            icon:
                                Icons
                                    .delete_outline_rounded,
                            primary: false,
                            onPressed: () {
                              deleteInvestment(
                                  context);
                            },
                          ),
                        ),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(
                        child:
                            _actionButton(
                          label:
                              "EDIT INVESTMENT",
                          icon:
                              Icons.edit_rounded,
                          primary: true,
                          onPressed:
                              () async {
                            await Navigator
                                .push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    EditInvestmentScreen(
                                  investmentId:
                                      investmentId,
                                  investmentData:
                                      investmentData,
                                ),
                              ),
                            );

                            if (context
                                .mounted) {
                              Navigator.pop(
                                  context);
                            }
                          },
                        ),
                      ),

                      const SizedBox(
                        width: 12,
                      ),

                      Expanded(
                        child:
                            _actionButton(
                          label:
                              "DELETE INVESTMENT",
                          icon: Icons
                              .delete_outline_rounded,
                          primary: false,
                          onPressed: () {
                            deleteInvestment(
                                context);
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}