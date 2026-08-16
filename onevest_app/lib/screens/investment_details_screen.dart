import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

class _InvestmentDetailsScreenState extends State<InvestmentDetailsScreen> {
  double? livePrice;
  bool isLoadingPrice = true;
  bool isRefreshing = false;

  Timer? refreshTimer;

  @override
  void initState() {
    super.initState();

    fetchLivePrice();

    refreshTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => fetchLivePrice(),
    );
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }

  // ============================================================
  // HELPERS
  // ============================================================

  double getDouble(dynamic value) {
    if (value == null) return 0;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }

  // ============================================================
  // LIVE MARKET PRICE
  // ============================================================

  Future<void> fetchLivePrice() async {
    final symbol = (widget.investmentData["symbol"] ?? "")
        .toString()
        .trim()
        .toUpperCase();

    if (symbol.isEmpty) {
      if (mounted) {
        setState(() {
          isLoadingPrice = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        isRefreshing = true;
      });
    }

    try {
      final uri = Uri.parse(
        "http://10.0.2.2:4021/api/market-price"
        "?symbol=${Uri.encodeComponent(symbol)}",
      );

      debugPrint("Fetching live price for $symbol");

      final response = await http.get(uri);

      debugPrint("Market API status: ${response.statusCode}");

      if (response.statusCode != 200) {
        throw Exception("Market API returned ${response.statusCode}");
      }

      final data = jsonDecode(response.body);

      if (data["success"] != true) {
        throw Exception("Market API request failed");
      }

      final price = data["market"]?["price"];

      if (price == null) {
        throw Exception("Price unavailable");
      }

      final currentPrice = (price as num).toDouble();

      if (!mounted) return;

      setState(() {
        livePrice = currentPrice;
        isLoadingPrice = false;
        isRefreshing = false;
      });

      debugPrint("$symbol live price = $currentPrice");
    } catch (e) {
      debugPrint("Live price error: $e");

      if (!mounted) return;

      setState(() {
        isLoadingPrice = false;
        isRefreshing = false;
      });
    }
  }

  // ============================================================
  // CURRENT PRICE
  // ============================================================

  double get currentPrice {
    return livePrice ?? getDouble(widget.investmentData["buyPrice"]);
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

    final added = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF14253F),

              title: const Text(
                "Add Transaction",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: transactionType,

                      dropdownColor: const Color(0xFF1A2B45),

                      style: const TextStyle(color: Colors.white),

                      decoration: InputDecoration(
                        labelText: "Transaction Type",
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: const Color(0xFF263B57),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),

                      items: const [
                        DropdownMenuItem(value: "BUY", child: Text("BUY")),
                        DropdownMenuItem(value: "SELL", child: Text("SELL")),
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

                    TextField(
                      controller: amountController,

                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),

                      style: const TextStyle(color: Colors.white),

                      decoration: InputDecoration(
                        labelText: "Amount",
                        prefixText: "₹ ",
                        labelStyle: const TextStyle(color: Colors.white70),
                        prefixStyle: const TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: const Color(0xFF263B57),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    TextField(
                      controller: unitsController,

                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),

                      style: const TextStyle(color: Colors.white),

                      decoration: InputDecoration(
                        labelText: "Units",
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: const Color(0xFF263B57),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    TextField(
                      controller: priceController,

                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),

                      style: const TextStyle(color: Colors.white),

                      decoration: InputDecoration(
                        labelText: "Price per Unit",
                        prefixText: "₹ ",
                        labelStyle: const TextStyle(color: Colors.white70),
                        prefixStyle: const TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: const Color(0xFF263B57),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    ListTile(
                      contentPadding: EdgeInsets.zero,

                      leading: const Icon(
                        Icons.calendar_today,
                        color: Colors.tealAccent,
                      ),

                      title: const Text(
                        "Transaction Date",
                        style: TextStyle(color: Colors.white70),
                      ),

                      subtitle: Text(
                        "${selectedDate.day}/"
                        "${selectedDate.month}/"
                        "${selectedDate.year}",
                        style: const TextStyle(color: Colors.white),
                      ),

                      onTap: () async {
                        final picked = await showDatePicker(
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
                    Navigator.pop(dialogContext, false);
                  },
                  child: const Text("Cancel"),
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),

                  onPressed: () async {
                    final amount = double.tryParse(
                      amountController.text.trim(),
                    );

                    final units = double.tryParse(unitsController.text.trim());

                    final price = double.tryParse(priceController.text.trim());

                    if (amount == null ||
                        amount <= 0 ||
                        units == null ||
                        units < 0 ||
                        price == null ||
                        price < 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
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
                        .doc(widget.investmentId)
                        .collection("transactions")
                        .add({
                          "type": transactionType,
                          "amount": amount,
                          "units": units,
                          "price": price,
                          "date": Timestamp.fromDate(selectedDate),
                          "createdAt": FieldValue.serverTimestamp(),
                        });

                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext, true);
                    }
                  },

                  child: const Text(
                    "ADD",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    amountController.dispose();
    unitsController.dispose();
    priceController.dispose();

    if (added == true && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Transaction Added")));
    }
  }

  // ============================================================
  // TRANSACTION HISTORY
  // ============================================================

  Widget transactionHistory() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("investments")
          .doc(widget.investmentId)
          .collection("transactions")
          .orderBy("date", descending: true)
          .snapshots(),

      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(25),
            child: Center(
              child: CircularProgressIndicator(color: Colors.tealAccent),
            ),
          );
        }

        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2B45),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              "Unable to load transaction history.",
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        final transactions = snapshot.data?.docs ?? [];

        if (transactions.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2B45),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              children: [
                Icon(Icons.receipt_long, color: Colors.white54, size: 42),
                SizedBox(height: 10),
                Text(
                  "No transactions yet",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Add your first transaction.",
                  style: TextStyle(color: Colors.white54),
                ),
              ],
            ),
          );
        }

        return Column(
          children: transactions.map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            final type = data["type"] ?? "BUY";

            final amount = getDouble(data["amount"]);

            final units = getDouble(data["units"]);

            final price = getDouble(data["price"]);

            final timestamp = data["date"] as Timestamp?;

            final date = timestamp?.toDate();

            Color color;
            IconData icon;

            if (type == "BUY") {
              color = Colors.greenAccent;
              icon = Icons.arrow_downward;
            } else if (type == "SELL") {
              color = Colors.redAccent;
              icon = Icons.arrow_upward;
            } else {
              color = Colors.amber;
              icon = Icons.account_balance_wallet;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 10),

              padding: const EdgeInsets.all(14),

              decoration: BoxDecoration(
                color: const Color(0xFF1A2B45),
                borderRadius: BorderRadius.circular(16),
              ),

              child: Row(
                children: [
                  CircleAvatar(
                    radius: 23,
                    backgroundColor: color.withValues(alpha: 0.15),
                    child: Icon(icon, color: color),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          type,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          date == null
                              ? "Date unavailable"
                              : "${date.day}/"
                                    "${date.month}/"
                                    "${date.year}",
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 13,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          "Units: "
                          "${units.toStringAsFixed(2)}"
                          "  •  ₹"
                          "${price.toStringAsFixed(2)} / unit",
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Text(
                    "₹${amount.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // ============================================================
  // INVESTMENT SUMMARY
  // ============================================================

  Widget investmentSummaryCard() {
    final quantity = getDouble(widget.investmentData["quantity"]);

    final buyPrice = getDouble(widget.investmentData["buyPrice"]);

    final current = currentPrice;

    final invested = quantity * buyPrice;

    final currentValue = quantity * current;

    final profit = currentValue - invested;

    final returnPercentage = invested == 0 ? 0 : (profit / invested) * 100;

    final isProfit = profit >= 0;

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF163B59), Color(0xFF1A2B45)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

        borderRadius: BorderRadius.circular(22),

        border: Border.all(color: Colors.white10),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            widget.investmentData["investmentName"]?.toString() ?? "Investment",

            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            widget.investmentData["investmentType"]?.toString() ?? "",

            style: const TextStyle(color: Colors.white60, fontSize: 15),
          ),

          if ((widget.investmentData["symbol"] ?? "").toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                "Symbol: ${widget.investmentData["symbol"]}",
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ),

          const SizedBox(height: 25),

          Row(
            children: [
              Expanded(
                child: summaryItem(
                  "Invested",
                  "₹${invested.toStringAsFixed(2)}",
                ),
              ),

              Expanded(
                child: summaryItem(
                  "Current Value",
                  "₹${currentValue.toStringAsFixed(2)}",
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          Container(height: 1, color: Colors.white12),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: summaryItem(
                  "Profit",
                  "${isProfit ? '+' : '-'}"
                      "₹${profit.abs().toStringAsFixed(2)}",
                  valueColor: isProfit ? Colors.greenAccent : Colors.redAccent,
                ),
              ),

              Expanded(
                child: summaryItem(
                  "Return",
                  "${isProfit ? '+' : '-'}"
                      "${returnPercentage.abs().toStringAsFixed(2)}%",
                  valueColor: isProfit ? Colors.greenAccent : Colors.redAccent,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Icon(
                Icons.circle,
                size: 9,
                color: livePrice != null
                    ? Colors.greenAccent
                    : Colors.orangeAccent,
              ),

              const SizedBox(width: 7),

              Text(
                livePrice != null ? "Live market price" : "Using buy price",
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),

              const Spacer(),

              if (isRefreshing)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.tealAccent,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY ITEM
  // ============================================================

  Widget summaryItem(
    String title,
    String value, {
    Color valueColor = Colors.white,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white60, fontSize: 13),
        ),

        const SizedBox(height: 6),

        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // INFORMATION ROW
  // ============================================================

  Widget informationRow(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),

      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

      decoration: BoxDecoration(
        color: const Color(0xFF1A2B45),
        borderRadius: BorderRadius.circular(14),
      ),

      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.white60, fontSize: 14),
            ),
          ),

          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DELETE INVESTMENT
  // ============================================================

  Future<void> deleteInvestment(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF14253F),

          title: const Text(
            "Delete Investment?",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),

          content: const Text(
            "This will permanently delete this investment and its transaction history.",
            style: TextStyle(color: Colors.white70),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),

              onPressed: () {
                Navigator.pop(dialogContext, true);
              },

              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      final investmentRef = FirebaseFirestore.instance
          .collection("investments")
          .doc(widget.investmentId);

      final transactions = await investmentRef.collection("transactions").get();

      for (final doc in transactions.docs) {
        await doc.reference.delete();
      }

      await investmentRef.delete();

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Investment deleted")));

      Navigator.pop(context);
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Delete failed: $e")));
    }
  }

  // ============================================================
  // EDIT INVESTMENT
  // ============================================================

  Future<void> editInvestment(BuildContext context) async {
    final nameController = TextEditingController(
      text: widget.investmentData["investmentName"]?.toString() ?? "",
    );

    final symbolController = TextEditingController(
      text: widget.investmentData["symbol"]?.toString() ?? "",
    );

    final quantityController = TextEditingController(
      text: getDouble(widget.investmentData["quantity"]).toStringAsFixed(0),
    );

    final buyPriceController = TextEditingController(
      text: getDouble(widget.investmentData["buyPrice"]).toString(),
    );

    String type =
        widget.investmentData["investmentType"]?.toString() ?? "Stock";

    final edited = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF14253F),

              title: const Text(
                "Edit Investment",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _editField(nameController, "Investment Name"),

                    const SizedBox(height: 12),

                    _editField(symbolController, "Market Symbol"),

                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      initialValue: type,

                      dropdownColor: const Color(0xFF1A2B45),

                      style: const TextStyle(color: Colors.white),

                      decoration: _editDecoration("Investment Type"),

                      items: const [
                        DropdownMenuItem(value: "Stock", child: Text("Stock")),
                        DropdownMenuItem(
                          value: "Mutual Fund",
                          child: Text("Mutual Fund"),
                        ),
                        DropdownMenuItem(value: "Gold", child: Text("Gold")),
                        DropdownMenuItem(
                          value: "Crypto",
                          child: Text("Crypto"),
                        ),
                        DropdownMenuItem(
                          value: "FD",
                          child: Text("Fixed Deposit"),
                        ),
                      ],

                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            type = value;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 12),

                    _editField(quantityController, "Quantity", numeric: true),

                    const SizedBox(height: 12),

                    _editField(buyPriceController, "Buy Price", numeric: true),
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, false);
                  },
                  child: const Text("Cancel"),
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),

                  onPressed: () async {
                    final quantity = int.tryParse(
                      quantityController.text.trim(),
                    );

                    final buyPrice = double.tryParse(
                      buyPriceController.text.trim(),
                    );

                    if (nameController.text.trim().isEmpty ||
                        symbolController.text.trim().isEmpty ||
                        quantity == null ||
                        quantity <= 0 ||
                        buyPrice == null ||
                        buyPrice <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Enter valid investment details."),
                        ),
                      );

                      return;
                    }

                    await FirebaseFirestore.instance
                        .collection("investments")
                        .doc(widget.investmentId)
                        .update({
                          "investmentName": nameController.text.trim(),

                          "symbol": symbolController.text.trim().toUpperCase(),

                          "investmentType": type,

                          "quantity": quantity,

                          "buyPrice": buyPrice,
                        });

                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext, true);
                    }
                  },

                  child: const Text(
                    "SAVE",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    symbolController.dispose();
    quantityController.dispose();
    buyPriceController.dispose();

    if (edited == true && mounted) {
      Navigator.pop(context);
    }
  }

  InputDecoration _editDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: const Color(0xFF263B57),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _editField(
    TextEditingController controller,
    String label, {
    bool numeric = false,
  }) {
    return TextField(
      controller: controller,

      keyboardType: numeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,

      textCapitalization: label == "Market Symbol"
          ? TextCapitalization.characters
          : TextCapitalization.sentences,

      style: const TextStyle(color: Colors.white),

      decoration: _editDecoration(label),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final symbol = (widget.investmentData["symbol"] ?? "")
        .toString()
        .trim()
        .toUpperCase();

    final buyPrice = getDouble(widget.investmentData["buyPrice"]);

    return Scaffold(
      backgroundColor: const Color(0xFF020B1D),

      appBar: AppBar(
        backgroundColor: const Color(0xFF020B1D),
        elevation: 0,

        title: const Text(
          "Investment Details",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        actions: [
          IconButton(
            onPressed: isRefreshing ? null : fetchLivePrice,
            icon: isRefreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.tealAccent,
                    ),
                  )
                : const Icon(Icons.refresh_rounded, color: Colors.tealAccent),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ==================================================
            // SUMMARY
            // ==================================================
            investmentSummaryCard(),

            const SizedBox(height: 25),

            // ==================================================
            // INFORMATION
            // ==================================================
            const Text(
              "Investment Information",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            informationRow("Symbol", symbol.isEmpty ? "Not available" : symbol),

            informationRow(
              "Quantity",
              widget.investmentData["quantity"]?.toString() ?? "0",
            ),

            informationRow("Buy Price", "₹${buyPrice.toStringAsFixed(2)}"),

            informationRow(
              "Current Price",
              livePrice == null
                  ? "Loading..."
                  : "₹${currentPrice.toStringAsFixed(2)}",
            ),

            informationRow(
              "Purchase Date",
              widget.investmentData["purchaseDate"]?.toString() ?? "",
            ),

            const SizedBox(height: 25),

            // ==================================================
            // TRANSACTION HISTORY
            // ==================================================
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "📜 Transaction History",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                TextButton.icon(
                  onPressed: () {
                    addTransaction(context);
                  },

                  style: TextButton.styleFrom(
                    foregroundColor: Colors.tealAccent,
                  ),

                  icon: const Icon(Icons.add, size: 20),

                  label: const Text(
                    "Add",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            transactionHistory(),

            const SizedBox(height: 30),

            // ==================================================
            // EDIT
            // ==================================================
            SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(
                onPressed: () {
                  editInvestment(context);
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,

                  padding: const EdgeInsets.symmetric(vertical: 15),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),

                icon: const Icon(Icons.edit),

                label: const Text(
                  "EDIT INVESTMENT",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ==================================================
            // DELETE
            // ==================================================
            SizedBox(
              width: double.infinity,

              child: OutlinedButton.icon(
                onPressed: () {
                  deleteInvestment(context);
                },

                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,

                  side: const BorderSide(color: Colors.redAccent),

                  padding: const EdgeInsets.symmetric(vertical: 15),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),

                icon: const Icon(Icons.delete_outline),

                label: const Text(
                  "DELETE INVESTMENT",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
