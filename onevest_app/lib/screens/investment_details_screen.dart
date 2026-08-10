import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'edit_investment_screen.dart';

class InvestmentDetailsScreen extends StatelessWidget {
  final String investmentId;
  final Map<String, dynamic> investmentData;

  const InvestmentDetailsScreen({
    super.key,
    required this.investmentId,
    required this.investmentData,
  });

  // ============================================================
  // HELPER METHODS
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
        title: const Text("Delete Investment"),
        content: const Text(
          "Are you sure you want to delete this investment?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
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
              backgroundColor: const Color(0xFF1A2B45),

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

                    // Transaction type
                    DropdownButtonFormField<String>(
                      value: transactionType,
                      dropdownColor: const Color(0xFF1A2B45),

                      style: const TextStyle(
                        color: Colors.white,
                      ),

                      decoration: InputDecoration(
                        labelText: "Transaction Type",
                        labelStyle: const TextStyle(
                          color: Colors.white70,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF263B57),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        labelText: "Amount",
                        prefixText: "₹ ",
                        labelStyle: const TextStyle(
                          color: Colors.white70,
                        ),
                        prefixStyle: const TextStyle(
                          color: Colors.white,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF263B57),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        labelText: "Units",
                        labelStyle: const TextStyle(
                          color: Colors.white70,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF263B57),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        labelText: "Price per Unit",
                        prefixText: "₹ ",
                        labelStyle: const TextStyle(
                          color: Colors.white70,
                        ),
                        prefixStyle: const TextStyle(
                          color: Colors.white,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF263B57),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Date
                    ListTile(
                      contentPadding: EdgeInsets.zero,

                      leading: const Icon(
                        Icons.calendar_today,
                        color: Colors.tealAccent,
                      ),

                      title: const Text(
                        "Transaction Date",
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                      ),

                      subtitle: Text(
                        "${selectedDate.day}/"
                        "${selectedDate.month}/"
                        "${selectedDate.year}",
                        style: const TextStyle(
                          color: Colors.white,
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
                    Navigator.pop(dialogContext, false);
                  },
                  child: const Text("Cancel"),
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
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
                        .doc(investmentId)
                        .collection("transactions")
                        .add({
                      "type": transactionType,
                      "amount": amount,
                      "units": units,
                      "price": price,
                      "date": Timestamp.fromDate(selectedDate),
                      "createdAt":
                          FieldValue.serverTimestamp(),
                    });

                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext, true);
                    }
                  },

                  child: const Text(
                    "ADD",
                    style: TextStyle(
                      color: Colors.white,
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
  // TRANSACTION HISTORY
  // ============================================================

  Widget transactionHistory() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("investments")
          .doc(investmentId)
          .collection("transactions")
          .orderBy("date", descending: true)
          .snapshots(),

      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(25),
            child: Center(
              child: CircularProgressIndicator(
                color: Colors.tealAccent,
              ),
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
              style: TextStyle(
                color: Colors.white70,
              ),
            ),
          );
        }

        final transactions =
            snapshot.data?.docs ?? [];

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
                Icon(
                  Icons.receipt_long,
                  color: Colors.white54,
                  size: 42,
                ),

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
                  style: TextStyle(
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
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
              margin: const EdgeInsets.only(
                bottom: 10,
              ),

              padding: const EdgeInsets.all(14),

              decoration: BoxDecoration(
                color: const Color(0xFF1A2B45),
                borderRadius:
                    BorderRadius.circular(16),
              ),

              child: Row(
                children: [

                  // Icon
                  CircleAvatar(
                    radius: 23,
                    backgroundColor:
                        color.withOpacity(0.15),

                    child: Icon(
                      icon,
                      color: color,
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        Text(
                          type,
                          style: TextStyle(
                            color: color,
                            fontWeight:
                                FontWeight.bold,
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

                  // Amount
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
  // INVESTMENT SUMMARY CARD
  // ============================================================

  Widget investmentSummaryCard() {
    final double quantity =
        getDouble(investmentData["quantity"]);

    final double buyPrice =
        getDouble(investmentData["buyPrice"]);

    final double currentValue =
        getDouble(investmentData["currentValue"]);

    final double invested =
        quantity * buyPrice;

    final double profit =
        currentValue - invested;

    final double returnPercentage =
        invested == 0
            ? 0
            : (profit / invested) * 100;

    final bool isProfit = profit >= 0;

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF163B59),
            Color(0xFF1A2B45),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

        borderRadius: BorderRadius.circular(22),

        border: Border.all(
          color: Colors.white10,
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          // Name
          Text(
            investmentData["investmentName"]
                    ?.toString() ??
                "Investment",

            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          // Type
          Text(
            investmentData["investmentType"]
                    ?.toString() ??
                "",

            style: const TextStyle(
              color: Colors.white60,
              fontSize: 15,
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

          Container(
            height: 1,
            color: Colors.white12,
          ),

          const SizedBox(height: 20),

          Row(
            children: [

              Expanded(
                child: summaryItem(
                  "Profit",
                  "${isProfit ? '+' : ''}"
                  "₹${profit.toStringAsFixed(2)}",
                  valueColor: isProfit
                      ? Colors.greenAccent
                      : Colors.redAccent,
                ),
              ),

              Expanded(
                child: summaryItem(
                  "Return",
                  "${isProfit ? '+' : ''}"
                  "${returnPercentage.toStringAsFixed(2)}%",
                  valueColor: isProfit
                      ? Colors.greenAccent
                      : Colors.redAccent,
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
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        Text(
          title,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 13,
          ),
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
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF020B1D),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFF020B1D),
        elevation: 0,

        title: const Text(
          "Investment Details",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          20,
          10,
          20,
          30,
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // ==================================================
            // INVESTMENT SUMMARY
            // ==================================================

            investmentSummaryCard(),

            const SizedBox(height: 25),

            // ==================================================
            // BASIC DETAILS
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

            informationRow(
              "Quantity",
              investmentData["quantity"]
                  ?.toString() ??
                  "0",
            ),

            informationRow(
              "Buy Price",
              "₹${investmentData["buyPrice"]}",
            ),

            informationRow(
              "Current Price",
              "₹${investmentData["currentPrice"] ?? investmentData["buyPrice"]}",
            ),

            informationRow(
              "Purchase Date",
              investmentData["purchaseDate"]
                      ?.toString() ??
                  "",
            ),

            const SizedBox(height: 25),

            // ==================================================
            // TRANSACTION HISTORY HEADER
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
                    foregroundColor:
                        Colors.tealAccent,
                  ),

                  icon: const Icon(
                    Icons.add,
                    size: 20,
                  ),

                  label: const Text(
                    "Add",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ==================================================
            // TRANSACTION HISTORY
            // ==================================================

            transactionHistory(),

            const SizedBox(height: 30),

            // ==================================================
            // EDIT
            // ==================================================

            SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.push(
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

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.teal,

                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 15,
                  ),

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                ),

                icon: const Icon(
                  Icons.edit,
                ),

                label: const Text(
                  "EDIT INVESTMENT",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
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
                  foregroundColor:
                      Colors.redAccent,

                  side: const BorderSide(
                    color: Colors.redAccent,
                  ),

                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 15,
                  ),

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                ),

                icon: const Icon(
                  Icons.delete_outline,
                ),

                label: const Text(
                  "DELETE INVESTMENT",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // INFORMATION ROW
  // ============================================================

  Widget informationRow(
    String title,
    String value,
  ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 8,
      ),

      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),

      decoration: BoxDecoration(
        color: const Color(0xFF1A2B45),
        borderRadius:
            BorderRadius.circular(14),
      ),

      child: Row(
        children: [

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 14,
              ),
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
}