import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'investment_details_screen.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  final user = FirebaseAuth.instance.currentUser;

final TextEditingController searchController = TextEditingController();

String searchText = "";

@override
void dispose() {
  searchController.dispose();
  super.dispose();
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020B1D),

      appBar: AppBar(
        backgroundColor: const Color(0xFF020B1D),
        elevation: 0,
        title: const Text(
          "My Portfolio",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("investments")
            .where("userId", isEqualTo: user!.uid)
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No Investments Yet",
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            );
          }

          final docs = snapshot.data!.docs;
          final filteredDocs = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;

            final investmentName =
                (data["investmentName"] ?? "")
                    .toString()
                    .toLowerCase();

            final investmentType =
                (data["investmentType"] ?? "")
                    .toString()
                    .toLowerCase();

            return investmentName.contains(searchText.toLowerCase()) ||
                investmentType.contains(searchText.toLowerCase());
          }).toList();

          double totalInvested = 0;
          double totalPortfolio = 0;

          for (var doc in docs) {
            double buyPrice = (doc["buyPrice"] as num).toDouble();

            double currentPrice =
                (doc.data() as Map<String, dynamic>).containsKey("currentPrice")
                ? (doc["currentPrice"] as num).toDouble()
                : buyPrice;

            int quantity = (doc["quantity"] as num).toInt();

            totalInvested += buyPrice * quantity;
            totalPortfolio += currentPrice * quantity;
          }

          double overallProfit = totalPortfolio - totalInvested;

          double overallReturn = totalInvested == 0
              ? 0
              : (overallProfit / totalInvested) * 100;

          bool isOverallProfit = overallProfit >= 0;

          return Column(
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade800,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Portfolio Summary",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total Invested",
                          style: TextStyle(color: Colors.white70),
                        ),
                        Text(
                          "₹${totalInvested.toStringAsFixed(2)}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Current Value",
                          style: TextStyle(color: Colors.white70),
                        ),
                        Text(
                          "₹${totalPortfolio.toStringAsFixed(2)}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const Divider(color: Colors.white30, height: 30),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isOverallProfit ? "Overall Profit" : "Overall Loss",
                          style: const TextStyle(color: Colors.white70),
                        ),
                        Text(
                          "${isOverallProfit ? "+" : "-"}₹${overallProfit.abs().toStringAsFixed(2)}",
                          style: TextStyle(
                            color: isOverallProfit
                                ? Colors.greenAccent
                                : Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Return",
                          style: TextStyle(color: Colors.white70),
                        ),
                        Text(
                          "${isOverallProfit ? "+" : "-"}${overallReturn.abs().toStringAsFixed(2)}%",
                          style: TextStyle(
                            color: isOverallProfit
                                ? Colors.greenAccent
                                : Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Search Investments...",
                    hintStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Colors.tealAccent,
                    ),
                    filled: true,
                    fillColor: const Color(0xFF1A2B45),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchText = value;
                    });
                  },
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: ListView.builder(
                  itemCount: filteredDocs.length,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemBuilder: (context, index) {
                    final investment = filteredDocs[index];

                    double buyPrice = (investment["buyPrice"] as num)
                        .toDouble();

                    double currentPrice =
                        (investment.data() as Map<String, dynamic>).containsKey(
                          "currentPrice",
                        )
                        ? (investment["currentPrice"] as num).toDouble()
                        : buyPrice;

                    int quantity = (investment["quantity"] as num).toInt();

                    double investedAmount = buyPrice * quantity;

                    double currentValue = currentPrice * quantity;

                    double profitLoss = currentValue - investedAmount;

                    double profitPercent = investedAmount == 0
                        ? 0
                        : (profitLoss / investedAmount) * 100;

                    bool isProfit = profitLoss >= 0;

                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => InvestmentDetailsScreen(
                              investmentId: investment.id,
                              investmentData:
                                  investment.data() as Map<String, dynamic>,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        color: const Color(0xFF1A2B45),
                        margin: const EdgeInsets.only(bottom: 15),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.teal,
                            child: Icon(Icons.trending_up, color: Colors.white),
                          ),

                          title: Text(
                            investment["investmentName"],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 5),

                              Text(
                                investment["investmentType"],
                                style: const TextStyle(color: Colors.white70),
                              ),

                              Text(
                                "Quantity : $quantity",
                                style: const TextStyle(color: Colors.white70),
                              ),

                              Text(
                                "Buy Price : ₹${buyPrice.toStringAsFixed(2)}",
                                style: const TextStyle(color: Colors.white70),
                              ),

                              Text(
                                "Current Price : ₹${currentPrice.toStringAsFixed(2)}",
                                style: const TextStyle(color: Colors.white70),
                              ),

                              Text(
                                "Current Value : ₹${currentValue.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                isProfit
                                    ? "Profit : +₹${profitLoss.toStringAsFixed(2)} (${profitPercent.toStringAsFixed(2)}%)"
                                    : "Loss : -₹${profitLoss.abs().toStringAsFixed(2)} (${profitPercent.abs().toStringAsFixed(2)}%)",
                                style: TextStyle(
                                  color: isProfit
                                      ? Colors.greenAccent
                                      : Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white54,
                            size: 18,
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
