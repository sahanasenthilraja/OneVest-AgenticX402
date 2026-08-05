import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PortfolioAnalyticsScreen extends StatelessWidget {
  const PortfolioAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF020B1D),

      appBar: AppBar(
        backgroundColor: const Color(0xFF020B1D),
        elevation: 0,
        title: const Text(
          "Portfolio Analytics",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("investments")
            .where("userId", isEqualTo: user!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No Investments Found",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          Map<String, double> portfolio = {
            "Stock": 0,
            "Mutual Fund": 0,
            "Gold": 0,
            "Crypto": 0,
            "FD": 0,
          };

          double totalValue = 0;

          for (var doc in docs) {
            final data =
                doc.data() as Map<String, dynamic>;

            double buyPrice =
                (data["buyPrice"] as num).toDouble();

            double currentPrice =
                data.containsKey("currentPrice")
                    ? (data["currentPrice"] as num)
                        .toDouble()
                    : buyPrice;

            int quantity =
                (data["quantity"] as num).toInt();

            double value = currentPrice * quantity;

            totalValue += value;

            portfolio[data["investmentType"]] =
                (portfolio[data["investmentType"]] ??
                        0) +
                    value;
          }

          final colors = [
            Colors.blue,
            Colors.green,
            Colors.orange,
            Colors.red,
            Colors.purple,
          ];

          int colorIndex = 0;

          final sections = portfolio.entries
              .where((e) => e.value > 0)
              .map((entry) {
            final section = PieChartSectionData(
              value: entry.value,
              color:
                  colors[colorIndex % colors.length],
              title:
                  "${(entry.value / totalValue * 100).toStringAsFixed(0)}%",
              radius: 90,
              titleStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            );

            colorIndex++;

            return section;
          }).toList();

          colorIndex = 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Card(
                  color: const Color(0xFF1A2B45),
                  child: Padding(
                    padding:
                        const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text(
                          "Total Portfolio Value",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "₹${totalValue.toStringAsFixed(2)}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  height: 300,
                  child: PieChart(
                    PieChartData(
                      centerSpaceRadius: 60,
                      sectionsSpace: 3,
                      sections: sections,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                ...portfolio.entries
                    .where((e) => e.value > 0)
                    .map(
                      (entry) => Card(
                        color:
                            const Color(0xFF1A2B45),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: colors[
                                colorIndex++ %
                                    colors.length],
                          ),
                          title: Text(
                            entry.key,
                            style:
                                const TextStyle(
                              color: Colors.white,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                          trailing: Text(
                            "₹${entry.value.toStringAsFixed(2)}",
                            style:
                                const TextStyle(
                              color: Colors.white,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
              ],
            ),
          );
        },
      ),
    );
  }
}